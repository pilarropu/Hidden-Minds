

with anos_suicidios as (
    select distinct anio
    from {{ ref('stg_hidden_minds__suicidios') }}
),

anos_epa as (
    select distinct anio
    from {{ ref('stg_hidden_minds__epa') }}
),

anos_pib as (
    select distinct anio
    from {{ ref('stg_hidden_minds__pib_pc') }}
),

unificado as (
    select anio from anos_suicidios
    union
    select anio from anos_epa
    union
    select anio from anos_pib
),

final as (
    select
          row_number() over (order by anio)   as id_dim_tiempo
        , anio
        , case
            when anio between 2020 and 2022 then 'Pandemia'
            when anio < 2020                then 'Pre-pandemia'
            else                                 'Post-pandemia'
          end                                as periodo_pandemia
    from unificado
)

select * from final