

with src as (
    select * from {{ ref('stg_ccaa') }}
),

final as (
    select
          id_comunidad
        , codigo_ine
        , nombre
        , region_geografica
    from src
)

select * from final