

with src as (
    select * from {{ ref('ods_meta') }}
),

final as (
    select
          {{ dbt_utils.generate_surrogate_key(['id_meta']) }}  as id_meta
        , numero_ods
        , numero_meta
        , descripcion
        , indicador_ods
        , unidad_medida
        , valor_objetivo_2030
    from src
)

select * from final