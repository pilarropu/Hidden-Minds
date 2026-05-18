
--   Renombrado, casteado y limpieza básica sobre epa,
--   parseo del periodo trimestral (2024T1 → anio=2024, trimestre=1).

with src_epa as (
    select *
    from {{ source('hidden_minds', 'epa') }}
),

ccaa as (
    select * from {{ ref('ccaa') }}
),

renamed_casted as (
    select
          {{ dbt_utils.generate_surrogate_key(['ccaa.id_comunidad']) }}  as id_comunidad
        , ccaa.nombre                                     as comunidad_autonoma
        , src.EDAD                                        as grupo_edad
        , src.SEXO                                        as sexo
        , split_part(src.PERIODO, 'T', 1)::int            as anio
        , split_part(src.PERIODO, 'T', 2)::int            as trimestre
        , replace(src.TOTAL, ',', '.')::decimal(10,2)     as tasa_paro
    from src_epa src
    inner join ccaa on src.CCAA = ccaa.nombre_ine
    where src.CCAA is not null
      and src.CCAA != ''
      and src.CCAA != 'Total Nacional'
      and src.TOTAL != '-'
      and src.TOTAL != '..'
      and src.EDAD != 'Total'
      and src.EDAD != 'Menores de 25 años'
      and src.EDAD != '25 y más años'
      and src.SEXO != 'Ambos sexos'
),

agregado_anual as (
    select
          id_comunidad
        , comunidad_autonoma
        , grupo_edad
        , sexo
        , anio
        , round(avg(tasa_paro), 2)   as tasa_paro
    from renamed_casted
    group by id_comunidad, comunidad_autonoma, grupo_edad, sexo, anio
)

select * from agregado_anual