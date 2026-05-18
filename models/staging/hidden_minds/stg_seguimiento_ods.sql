

with mortalidad as (
    select
          id_comunidad
        , id_periodo
        , avg(tasa_por_100k)   as valor_indicador
    from {{ ref('stg_mortalidad_suicidio') }}
    group by id_comunidad, id_periodo
),

indicadores as (
    select
          id_comunidad
        , id_periodo
        , id_tipo_indicador
        , avg(valor)           as valor_indicador
    from {{ ref('stg_indicador_socioeconomico') }}
    group by id_comunidad, id_periodo, id_tipo_indicador
),

ods as (
    select * from {{ ref('stg_ods_meta') }}
),

tipo_indicador as (
    select * from {{ ref('stg_tipo_indicador') }}
),

-- ODS 3.4 — tasa de suicidio
ods_suicidio as (
    select
          m.id_comunidad
        , m.id_periodo
        , o.id_meta
        , m.valor_indicador
        , o.valor_objetivo_2030    as valor_objetivo
    from mortalidad m
    cross join ods o
    where o.numero_meta = '3.4'
),

-- ODS 8.5 — tasa de paro
ods_paro as (
    select
          i.id_comunidad
        , i.id_periodo
        , o.id_meta
        , i.valor_indicador
        , o.valor_objetivo_2030    as valor_objetivo
    from indicadores i
    inner join tipo_indicador t on t.id_tipo_indicador = i.id_tipo_indicador
                                and t.nombre_indicador = 'Tasa de paro'
    cross join ods o
    where o.numero_meta = '8.5'
),

-- ODS 10.1 — PIB per cápita como proxy de desigualdad
ods_pib as (
    select
          i.id_comunidad
        , i.id_periodo
        , o.id_meta
        , i.valor_indicador
        , o.valor_objetivo_2030    as valor_objetivo
    from indicadores i
    inner join tipo_indicador t on t.id_tipo_indicador = i.id_tipo_indicador
                                and t.nombre_indicador = 'PIB per cápita'
    cross join ods o
    where o.numero_meta = '10.1'
),

unificado as (
    select * from ods_suicidio
    union all
    select * from ods_paro
    union all
    select * from ods_pib
),

final as (
    select
          {{ dbt_utils.generate_surrogate_key([
              'id_comunidad',
              'id_periodo',
              'id_meta'
          ]) }}                as id_seguimiento
        , id_comunidad
        , id_periodo
        , id_meta
        , valor_indicador
        , valor_objetivo
    from unificado
)

select * from final