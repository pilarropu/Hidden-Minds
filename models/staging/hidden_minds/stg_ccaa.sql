with src as (
    select * from {{ ref('ccaa') }}
),

final as (
    select
          {{ dbt_utils.generate_surrogate_key(['id_comunidad']) }}  as id_comunidad
        , codigo_ine
        , nombre
        , region_geografica
    from src
)

select * from final