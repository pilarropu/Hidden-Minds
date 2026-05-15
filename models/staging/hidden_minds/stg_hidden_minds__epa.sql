
--   Renombrado, casteado y limpieza básica sobre epa,
--   parseo del periodo trimestral (2024T1 → anio=2024, trimestre=1).

with src_epa as (
    select *
    from {{ source('hidden_minds', 'epa') }}
),

renamed_casted as (
    select
          CCAA                                        as comunidad_autonoma
        , EDAD                                        as grupo_edad
        , SEXO                                        as sexo
        , split_part(PERIODO, 'T', 1)::int            as anio
        , split_part(PERIODO, 'T', 2)::int            as trimestre
        , replace(TOTAL, ',', '.')::decimal(10,2)     as tasa_paro
    from src_epa
    where CCAA is not null
      and CCAA != ''
      and CCAA != 'Total Nacional'
      and TOTAL != '-'
      and TOTAL != '..'
      and EDAD != 'Total'
      and EDAD != 'Menores de 25 años'
      and EDAD != '25 y más años'
      and SEXO != 'Ambos sexos'
),

agregado_anual as (
    select
          comunidad_autonoma
        , grupo_edad
        , sexo
        , anio
        , round(avg(tasa_paro), 2)   as tasa_paro
    from renamed_casted
    group by comunidad_autonoma, grupo_edad, sexo, anio
)

select * from agregado_anual