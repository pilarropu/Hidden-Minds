
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
          {{ dbt_utils.generate_surrogate_key(['anio']) }}  as id_periodo
        , anio
        , case
            when anio < 2020    then 'Pre-pandemia'
            when anio <= 2022   then 'Pandemia'
            else                     'Post-pandemia'
          end                                               as periodo_pandemia
    from unificado
)

select * from final