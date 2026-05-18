
with src as (
    select * from (values
        (1, 'Tasa de paro',   'Porcentaje', 'Mercado laboral'),
        (2, 'PIB per cápita', 'Euros',      'Economía')
    ) as t(id, nombre_indicador, unidad, categoria)
),

final as (
    select
          {{ dbt_utils.generate_surrogate_key(['id']) }}  as id_tipo_indicador
        , nombre_indicador
        , unidad
        , categoria
    from src
)

select * from final