{% snapshot scd_tipo_indicador %}

{{
    config(
        target_schema='dbt_prodriguez',
        unique_key='id_tipo_indicador',
        strategy='check',
        check_cols=['nombre_indicador', 'unidad', 'categoria'],
        invalidate_hard_deletes=True
    )
}}

select * from {{ ref('stg_tipo_indicador') }}

{% endsnapshot %}