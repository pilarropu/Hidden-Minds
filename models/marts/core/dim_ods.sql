

with src_ods as (
    select *
    from {{ ref('ods_meta') }}
),

final as (
    select
          id_meta                as id_dim_ods
        , numero_ods
        , numero_meta
        , descripcion
        , indicador_ods
        , unidad_medida
        , valor_objetivo_2030
    from src_ods
)

select * from final