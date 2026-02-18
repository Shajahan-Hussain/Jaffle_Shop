-- Author: Harika
-- Create Date: 12/09/2025
-- Description: Validates latest updates in source are reflected in the staging model.

-- Change History
-- Version   Date         User                     Change
-- 0.1       12/09/2025   Harika Dharmapuri      Initial version
-- 0.2       06/02/2026   Harika Dharmapuri      updated the hardcoded values
-- 1.0       06/02/2026   Harika Dharmapuri      Final version

{% test cdc_updates(model, source_model, staging_model, src_key_column, stg_key_column, is_deleted_column, updated_at_column,active_flag_value, key_alias) %}
 
with source_latest as (
    -- pick the latest version per key from source
    select
        {{ src_key_column }} as {{ key_alias }},
        max({{ updated_at_column }}) as latest_update
    from {{ source_model }} where {{ is_deleted_column }}= {{ active_flag_value }}
    group by {{ src_key_column }}
),
 
staging_latest as (
    -- pick the latest version per key from staging
    select
        {{ stg_key_column }} as {{ key_alias }},
        max({{ updated_at_column }}) as latest_update
    from {{ model }}
    group by {{ stg_key_column }}
),
 
mismatches as (
    select
        s.{{ key_alias }},
        s.latest_update as source_latest_update,
        t.latest_update as staging_latest_update
    from source_latest s
    left join staging_latest t
      on  s.{{ key_alias }} = t.{{ key_alias }}
    where t.latest_update is null
       or t.latest_update < s.latest_update
)
 
select * from mismatches
 
{% endtest %}
