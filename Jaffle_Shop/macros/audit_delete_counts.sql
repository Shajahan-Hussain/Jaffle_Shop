-- Author: Harika
-- Create Date: 12/09/2025
-- Description: Validates that delete record counts match between source and audit model.

-- Change History
-- Version   Date         User                     Change
-- 0.1       12/09/2025   Harika Dharmapuri      Initial version
-- 0.2       06/02/2026   Harika Dharmapuri      updated the hardcoded values
-- 1.0       06/02/2026   Harika Dharmapuri      Final version

{% test audit_delete_counts(model, raw_table, src_key_column, stg_key_column, is_deleted_column, deleted_flag_value,audit_action_column, delete_action_value) %}

with raw_deleted as (
  select count(distinct {{ src_key_column }}) as raw_cnt
  from {{ raw_table }}
  where {{ is_deleted_column }} = {{ deleted_flag_value }}
),

audit_deleted as (
  select count(distinct {{ stg_key_column }}) as audit_cnt
  from {{ model }}
  where {{ audit_action_column }} = '{{ delete_action_value }}'
)

select r.raw_cnt, a.audit_cnt
from raw_deleted r
cross join audit_deleted a
where r.raw_cnt != a.audit_cnt

{% endtest %}
