

with indicadores as (
    select * from {{ ref('stg_indicador_socioeconomico') }}
),

tipo as (
    select * from {{ ref('stg_tipo_indicador') }}
),

paro as (
    select
          i.id_comunidad
        , i.id_periodo
        , avg(i.valor)   as tasa_paro
    from indicadores i
    inner join tipo t on t.id_tipo_indicador = i.id_tipo_indicador
                     and t.nombre_indicador = 'Tasa de paro'
    group by i.id_comunidad, i.id_periodo
),

pib as (
    select
          i.id_comunidad
        , i.id_periodo
        , avg(i.valor)   as pib_per_capita
    from indicadores i
    inner join tipo t on t.id_tipo_indicador = i.id_tipo_indicador
                     and t.nombre_indicador = 'PIB per cápita'
    group by i.id_comunidad, i.id_periodo
),

final as (
    select
          {{ dbt_utils.generate_surrogate_key(['paro.id_comunidad', 'paro.id_periodo']) }}  as id_contexto
        , paro.id_comunidad
        , paro.id_periodo
        , paro.tasa_paro
        , pib.pib_per_capita
        , {{ clasificar_riesgo('paro.tasa_paro') }}     as nivel_paro
    from paro
    left join pib on pib.id_comunidad = paro.id_comunidad
                 and pib.id_periodo   = paro.id_periodo
)

select * from final