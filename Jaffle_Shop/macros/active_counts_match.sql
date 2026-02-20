-- Author: Harika
-- Create Date: 12/09/2025
-- Description: Validates that the count of active records matches between source and target layers.

-- Change History
-- Version   Date         User                     Change
-- 0.1       12/09/2025   Harika Dharmapuri      Initial version
-- 0.2       06/02/2026   Harika Dharmapuri      updated the hardcoded values
-- 1.0       06/02/2026   Harika Dharmapuri      Final version


{% test active_counts_match(model, source_table, key_column, is_deleted_column, active_flag_value) %}

with raw_active as (
    select count(distinct {{ key_column }}) as cnt
    from {{ source_table }}
    where {{ is_deleted_column }} = {{ active_flag_value }}
),

staging as (
    select count(*) as cnt
    from {{ model }}
)

select
    r.cnt as raw_count,
    s.cnt as staging_count
from raw_active r
join staging s on 1=1
where r.cnt != s.cnt

{% endtest %}
