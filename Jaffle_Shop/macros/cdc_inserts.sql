-- Author: Harika
-- Create Date: 12/09/2025
-- Description: Validates all active source records are loaded to staging model.

-- Change History
-- Version   Date         User                     Change
-- 0.1       12/09/2025   Harika Dharmapuri      Initial version
-- 0.2       06/02/2026   Harika Dharmapuri      updated the hardcoded values
-- 1.0       06/02/2026   Harika Dharmapuri      Final version

{% test cdc_inserts(model, source_model, staging_model, src_key_column, stg_key_column, updated_at_column, is_deleted_column, active_flag_value) %}
 
with raw_inserts as (
    select {{ src_key_column }}, {{ updated_at_column }}
    from {{ source_model }}
    where {{ is_deleted_column }} = {{ active_flag_value }}
),
 
missing_in_staging as (
    select r.{{ src_key_column }}, r.{{ updated_at_column }}
    from raw_inserts r
    left join {{ staging_model }} s
        on r.{{ src_key_column }} = s.{{ stg_key_column }}
    where s.{{ stg_key_column }} is null
)
 
select * from missing_in_staging

{% endtest %}
