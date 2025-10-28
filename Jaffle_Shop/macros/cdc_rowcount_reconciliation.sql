{% test cdc_rowcount_reconciliation(model, source_model, staging_model, source_key, staging_key, updated_at_column, is_deleted_column) %}
 
with source_latest as (
    -- Take only the latest non-deleted record per ID
    select {{ source_key }} as id,
           max({{ updated_at_column }}) as latest_update
    from {{ source_model }}
    where {{ is_deleted_column }} = false
    group by {{ source_key }}
),
 
staging_latest as (
    -- Staging should already have only the latest record per ID
    select {{ staging_key }} as id
    from {{ staging_model }}
),
 
counts as (
    select
        (select count(*) from source_latest) as source_count,
        (select count(*) from staging_latest) as staging_count
)
 
select *
from counts
where source_count != staging_count
 
{% endtest %}
