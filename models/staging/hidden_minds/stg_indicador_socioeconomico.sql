

with epa as (
    select * from {{ ref('stg_hidden_minds__epa') }}
),

pib as (
    select * from {{ ref('stg_hidden_minds__pib_pc') }}
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

tipo_indicador as (
    select * from {{ ref('stg_tipo_indicador') }}
),

epa_normalizado as (
    select
          epa.id_comunidad
        , p.id_periodo
        , s.id_sexo
        , g.id_grupo_edad
        , t.id_tipo_indicador
        , epa.tasa_paro                  as valor
    from epa
    inner join periodo     p on p.anio       = epa.anio
    inner join sexo        s on s.nombre     = epa.sexo
    inner join grupo_edad  g on g.rango_edad = epa.grupo_edad
    inner join tipo_indicador t on t.nombre_indicador = 'Tasa de paro'
),

pib_normalizado as (
    select
          pib.id_comunidad
        , p.id_periodo
        , s.id_sexo
        , g.id_grupo_edad
        , t.id_tipo_indicador
        , pib.pib_per_capita::decimal(10,2) as valor
    from pib
    cross join sexo        s
    cross join grupo_edad  g
    inner join periodo     p on p.anio = pib.anio
    inner join tipo_indicador t on t.nombre_indicador = 'PIB per cápita'
),

unificado as (
    select * from epa_normalizado
    union all
    select * from pib_normalizado
),

final as (
    select
          {{ dbt_utils.generate_surrogate_key([
              'id_comunidad',
              'id_periodo',
              'id_sexo',
              'id_grupo_edad',
              'id_tipo_indicador'
          ]) }}                as id_indicador
        , id_comunidad
        , id_periodo
        , id_sexo
        , id_grupo_edad
        , id_tipo_indicador
        , valor
    from unificado
)

select * from final