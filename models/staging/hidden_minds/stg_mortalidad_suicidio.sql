{{
    config(
        materialized='incremental',
        unique_key='id_mortalidad'
    )
}}

with src as (
    select * from {{ ref('stg_hidden_minds__suicidios') }}
),

periodo as (
    select * from {{ ref('stg_periodo') }}
),

sexo as (
    select * from {{ ref('stg_sexo') }}
),

grupo_edad as (
    select * from {{ ref('stg_grupo_edad') }}
),

final as (
    select
          {{ dbt_utils.generate_surrogate_key([
              'src.id_comunidad',
              'p.id_periodo',
              's.id_sexo',
              'g.id_grupo_edad'
          ]) }}                   as id_mortalidad
        , src.id_comunidad
        , p.id_periodo
        , s.id_sexo
        , g.id_grupo_edad
        , src.tasa_por_100k
        , src.anio
    from src
    inner join periodo    p  on p.anio       = src.anio
    inner join sexo       s  on s.nombre     = src.sexo
    inner join grupo_edad g  on g.rango_edad = src.grupo_edad

    {% if is_incremental() %}
        where src.anio > (select max(t.anio) from {{ this }} t)
    {% endif %}
)

select * from final

