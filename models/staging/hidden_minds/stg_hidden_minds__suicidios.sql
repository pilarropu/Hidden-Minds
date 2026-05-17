-- Renombrado, casteado y limpieza básica sobre el source suicidio, 
-- filtro por filas de total nacional y convierto decimal con coma.


with src_suicidios as (
    select *
    from {{ source('hidden_minds', 'suicidios') }}
),

ccaa as (
    select * from {{ ref('ccaa') }}
),

renamed_casted as (
    select
          ccaa.id_comunidad
        , ccaa.nombre                                     as comunidad_autonoma
        , src.EDADES                                      as grupo_edad
        , src.SEXO                                        as sexo
        , src.PERIODO::int                                as anio
        , replace(src.TOTAL, ',', '.')::decimal(10,3)     as tasa_por_100k
    from src_suicidios src
    inner join ccaa on src.CCAA = ccaa.nombre_ine
    where src.CCAA is not null
      and src.CCAA != ''
      and src.TOTAL != '-'
      and src.SEXO != 'Total'
      and src.EDADES != 'Todas las edades'
      and src.CCAA != 'Total Nacional'
)

select * from renamed_casted