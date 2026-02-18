-- Author: Harika
-- Create Date: 12/09/2025
-- Description: Checks row count reconciliation between source and staging tables.

-- Change History
-- Version   Date         User                     Change
-- 0.1       12/09/2025   Harika Dharmapuri      Initial version
-- 0.2       06/02/2026   Harika Dharmapuri      updated the hardcoded values
-- 1.0       06/02/2026   Harika Dharmapuri      Final version

{% test cdc_rowcount_reconciliation(model, source_model, staging_model, source_key, staging_key, updated_at_column, is_deleted_column,deleted_flag_value,key_alias) %}
 
with source_latest as (
    -- Take only the latest non-deleted record per ID
    select {{ source_key }} as {{ key_alias }},
           max({{ updated_at_column }}) as latest_update
    from {{ source_model }}
    where {{ is_deleted_column }} = {{ deleted_flag_value }}
    group by {{ source_key }}
),
 
staging_latest as (
    -- Staging should already have only the latest record per ID
    select {{ staging_key }} as {{ key_alias }}
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
