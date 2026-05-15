

with epa as (
    select
          comunidad_autonoma
        , anio
        , round(avg(tasa_paro), 2)   as tasa_paro
    from {{ ref('stg_hidden_minds__epa') }}
    group by comunidad_autonoma, anio
),

pib as (
    select
          comunidad_autonoma
        , anio
        , pib_per_capita
    from {{ ref('stg_hidden_minds__pib_pc') }}
),

ccaa as (
    select * from {{ ref('ccaa') }}
),

joined as (
    select
          ccaa.id_comunidad
        , epa.anio
        , epa.tasa_paro
        , pib.pib_per_capita
    from ccaa
    left join epa on epa.comunidad_autonoma = ccaa.nombre_ine
    left join pib on pib.comunidad_autonoma = ccaa.nombre_ine
               and pib.anio = epa.anio
),

final as (
    select
          row_number() over (order by id_comunidad, anio)  as id_dim_contexto
        , id_comunidad
        , anio                                             as id_periodo
        , tasa_paro
        , pib_per_capita
        , case
            when tasa_paro >= 20 then 'Alto'
            when tasa_paro >= 10 then 'Medio'
            else                      'Bajo'
          end                                             as nivel_paro
        , case
            when pib_per_capita >= 30000 then 'Alto'
            when pib_per_capita >= 20000 then 'Medio'
            else                               'Bajo'
          end                                             as nivel_renta
    from joined
    where tasa_paro is not null
       or pib_per_capita is not null
)

select * from final