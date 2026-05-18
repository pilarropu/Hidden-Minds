-- Test singular: verifica que la tasa de paro está siempre entre 0 y 100.

select
      id_indicador
    , id_comunidad
    , id_periodo
    , valor
from {{ ref('stg_indicador_socioeconomico') }}
where id_tipo_indicador = (
    select id_tipo_indicador
    from {{ ref('stg_tipo_indicador') }}
    where nombre_indicador = 'Tasa de paro'
)
and (valor < 0 or valor > 100)