--   Renombrado y normalización del PIB, 
--   viene transpuesto (una columna por año), lo convertimos a formato largo (una fila por año).

with src_pib as (
    select *
    from {{ source('hidden_minds', 'pib_pc') }}
),

unpivoted as (
    select CCAA as comunidad_autonoma, 2018 as anio, "2018"::int as pib_per_capita from src_pib where "2018" is not null
    union all
    select CCAA, 2019, "2019"::int from src_pib where "2019" is not null
    union all
    select CCAA, 2020, "2020"::int from src_pib where "2020" is not null
    union all
    select CCAA, 2021, "2021"::int from src_pib where "2021" is not null
    union all
    select CCAA, 2022, "2022"::int from src_pib where "2022" is not null
    union all
    select CCAA, 2023, "2023"::int from src_pib where "2023" is not null
    union all
    select CCAA, 2024, "2024"::int from src_pib where "2024" is not null
)

select * from unpivoted