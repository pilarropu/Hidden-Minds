

with src_ccaa as (
    select *
    from {{ ref('ccaa') }}
),

final as (
    select
          id_comunidad                                    as id_dim_comunidad
        , codigo_ine
        , nombre                                          as nombre
        , region_geografica
    from src_ccaa
)

select * from final