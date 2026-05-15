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
        , round(avg(tasa_paro), 2) as tasa_paro
    from renamed_casted
    group by comunidad_autonoma, grupo_edad, sexo, anio
),

src_pib as (
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

select
      e.comunidad_autonoma
    , e.grupo_edad
    , e.sexo
    , e.anio
    , e.tasa_paro
    , p.pib_per_capita
from agregado_anual e
left join unpivoted p
    on  e.comunidad_autonoma = p.comunidad_autonoma
    and e.anio               = p.anio