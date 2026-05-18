--   Renombrado y normalización del PIB, 
--   viene transpuesto (una columna por año), lo convertimos a formato largo (una fila por año).
--   Normalizado el nombre de CCAA usando la seed ccaa por nombre_pib.


with src_pib as (
    select *
    from {{ source('hidden_minds', 'pib_pc') }}
),

ccaa as (
    select * from {{ ref('ccaa') }}
),

unpivoted as (
    select ccaa.id_comunidad, ccaa.nombre as comunidad_autonoma, 2018 as anio, "2018"::int as pib_per_capita from src_pib inner join ccaa on src_pib.CCAA = ccaa.nombre_pib where "2018" is not null
    union all
    select ccaa.id_comunidad, ccaa.nombre, 2019, "2019"::int from src_pib inner join ccaa on src_pib.CCAA = ccaa.nombre_pib where "2019" is not null
    union all
    select ccaa.id_comunidad, ccaa.nombre, 2020, "2020"::int from src_pib inner join ccaa on src_pib.CCAA = ccaa.nombre_pib where "2020" is not null
    union all
    select ccaa.id_comunidad, ccaa.nombre, 2021, "2021"::int from src_pib inner join ccaa on src_pib.CCAA = ccaa.nombre_pib where "2021" is not null
    union all
    select ccaa.id_comunidad, ccaa.nombre, 2022, "2022"::int from src_pib inner join ccaa on src_pib.CCAA = ccaa.nombre_pib where "2022" is not null
    union all
    select ccaa.id_comunidad, ccaa.nombre, 2023, "2023"::int from src_pib inner join ccaa on src_pib.CCAA = ccaa.nombre_pib where "2023" is not null
    union all
    select ccaa.id_comunidad, ccaa.nombre, 2024, "2024"::int from src_pib inner join ccaa on src_pib.CCAA = ccaa.nombre_pib where "2024" is not null
),

final as (
    select
          {{ dbt_utils.generate_surrogate_key(['id_comunidad']) }}  as id_comunidad
        , comunidad_autonoma
        , anio
        , pib_per_capita
    from unpivoted
)

select * from final