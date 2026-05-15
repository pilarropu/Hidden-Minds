-- Renombrado, casteado y limpieza básica sobre el source suicidio, 
-- filtro por filas de total nacional y convierto decimal con coma.

with src_suicidios as (
    select *
    from {{ source('hidden_minds', 'suicidios') }}
),

renamed_casted as (
    select
          CCAA                                        as comunidad_autonoma
        , EDADES                                      as grupo_edad
        , SEXO                                        as sexo
        , PERIODO::int                                as anio
        , replace(TOTAL, ',', '.')::decimal(10,3)     as tasa_por_100k
    from src_suicidios
    where CCAA is not null
      and CCAA != ''
      and TOTAL != '-'
      and SEXO != 'Total'
      and GRUPO_EDAD != 'Todas las edades'
)

select * from renamed_casted