

with src as (
    select * from {{ ref('stg_periodo') }}
),

final as (
    select
          id_periodo
        , anio
        , periodo_pandemia
    from src
)

select * from final