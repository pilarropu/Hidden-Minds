
--   Tabla de hechos principal del proyecto. Granularidad: una fila por
--   CCAA + año + sexo + grupo de edad.
--   Incluye métricas calculadas: nivel de riesgo, variación interanual
--   y porcentaje de cumplimiento ODS.

with mortalidad as (
    select * from {{ ref('stg_mortalidad_suicidio') }}
),

dim_comunidad as (
    select * from {{ ref('dim_comunidad') }}
),

dim_periodo as (
    select * from {{ ref('dim_periodo') }}
),

dim_demografia as (
    select * from {{ ref('dim_demografia') }}
),

dim_contexto as (
    select * from {{ ref('dim_contexto_socioeconomico') }}
),

dim_ods as (
    select * from {{ ref('dim_ods') }}
    where numero_meta = '3.4'
),

final as (
    select
          {{ dbt_utils.generate_surrogate_key([
              'm.id_comunidad',
              'm.id_periodo',
              'm.id_sexo',
              'm.id_grupo_edad'
          ]) }}                                                        as id_suicidio
        , dc.id_comunidad
        , dp.id_periodo
        , dd.id_demografia
        , ctx.id_contexto
        , ods.id_meta
        , m.tasa_por_100k
        , {{ clasificar_riesgo('m.tasa_por_100k') }}                  as nivel_riesgo
        , round(
            (m.tasa_por_100k - lag(m.tasa_por_100k) over (
                partition by m.id_comunidad, m.id_sexo, m.id_grupo_edad
                order by m.anio
            )) / nullif(lag(m.tasa_por_100k) over (
                partition by m.id_comunidad, m.id_sexo, m.id_grupo_edad
                order by m.anio
            ), 0) * 100
          , 2)                                                         as variacion_interanual
        , round(
            (ods.valor_objetivo_2030 - m.tasa_por_100k)
            / nullif(ods.valor_objetivo_2030, 0) * 100
          , 2)                                                         as pct_cumplimiento_ods
    from mortalidad m
    inner join dim_comunidad  dc  on dc.id_comunidad  = m.id_comunidad
    inner join dim_periodo    dp  on dp.id_periodo    = m.id_periodo
    inner join dim_demografia dd  on dd.id_sexo       = m.id_sexo
                                 and dd.id_grupo_edad = m.id_grupo_edad
    left join  dim_contexto   ctx on ctx.id_comunidad = m.id_comunidad
                                 and ctx.id_periodo   = m.id_periodo
    cross join dim_ods        ods
)

select * from final