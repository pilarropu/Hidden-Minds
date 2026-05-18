
with src as (
    select distinct sexo
    from {{ ref('stg_hidden_minds__suicidios') }}
),

final as (
    select
          {{ dbt_utils.generate_surrogate_key(['sexo']) }}  as id_sexo
        , sexo                                              as nombre
    from src
)

select * from final