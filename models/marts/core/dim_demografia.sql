

with sexo as (
    select * from {{ ref('stg_sexo') }}
),

grupo_edad as (
    select * from {{ ref('stg_grupo_edad') }}
),

final as (
    select
          {{ dbt_utils.generate_surrogate_key(['s.id_sexo', 'g.id_grupo_edad']) }}  as id_demografia
        , s.id_sexo
        , g.id_grupo_edad
        , s.nombre                                                                   as sexo
        , g.rango_edad
        , g.edad_min
        , g.edad_max
    from sexo s
    cross join grupo_edad g
)

select * from final
