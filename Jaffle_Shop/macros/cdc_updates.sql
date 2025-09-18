{% test cdc_updates(model, source_model, staging_model, src_key_column, stg_key_column, is_deleted_column, updated_at_column) %}
 
with source_latest as (
    -- pick the latest version per key from source
    select
        {{ src_key_column }} as id,
        max({{ updated_at_column }}) as latest_update
    from {{ source_model }} where {{ is_deleted_column }}='false'
    group by {{ src_key_column }}
),
 
staging_latest as (
    -- pick the latest version per key from staging
    select
        {{ stg_key_column }} as id,
        max({{ updated_at_column }}) as latest_update
    from {{ model }}
    group by {{ stg_key_column }}
),
 
mismatches as (
    select
        s.id,
        s.latest_update as source_latest_update,
        t.latest_update as staging_latest_update
    from source_latest s
    left join staging_latest t
      on s.id = t.id
    where t.latest_update is null
       or t.latest_update < s.latest_update
)
 
select * from mismatches
 
{% endtest %}
