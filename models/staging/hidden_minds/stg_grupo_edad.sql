

with grupos_suicidios as (
    select distinct grupo_edad
    from {{ ref('stg_hidden_minds__suicidios') }}
),

grupos_epa as (
    select distinct grupo_edad
    from {{ ref('stg_hidden_minds__epa') }}
),

unificado as (
    select grupo_edad from grupos_suicidios
    union
    select grupo_edad from grupos_epa
),

final as (
    select
          {{ dbt_utils.generate_surrogate_key(['grupo_edad']) }}  as id_grupo_edad
        , grupo_edad                                              as rango_edad
        , case grupo_edad
            when 'Menos de 15 años'  then 0
            when 'De 15 a 29 años'   then 15
            when 'De 16 a 19 años'   then 16
            when 'De 20 a 24 años'   then 20
            when 'De 25 a 54 años'   then 25
            when 'De 30 a 39 años'   then 30
            when 'De 40 a 44 años'   then 40
            when 'De 45 a 49 años'   then 45
            when 'De 50 a 54 años'   then 50
            when 'De 55 a 59 años'   then 55
            when 'De 55 y más años'  then 55
            when 'De 60 a 64 años'   then 60
            when 'De 65 a 69 años'   then 65
          end                                                     as edad_min
        , case grupo_edad
            when 'Menos de 15 años'  then 14
            when 'De 15 a 29 años'   then 29
            when 'De 16 a 19 años'   then 19
            when 'De 20 a 24 años'   then 24
            when 'De 25 a 54 años'   then 54
            when 'De 30 a 39 años'   then 39
            when 'De 40 a 44 años'   then 44
            when 'De 45 a 49 años'   then 49
            when 'De 50 a 54 años'   then 54
            when 'De 55 a 59 años'   then 59
            when 'De 55 y más años'  then 99
            when 'De 60 a 64 años'   then 64
            when 'De 65 a 69 años'   then 69
          end                                                     as edad_max
    from unificado
)

select * from final