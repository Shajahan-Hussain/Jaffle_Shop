-- Author: Harika
-- Create Date: 24/10/2025
-- Description: Ensures HWM control table reflects the latest source update timestamp.
 
-- Change History
-- Version   Date         User                     Change
-- 0.1       24/10/2025   Harika Dharmapuri      Initial version
-- 0.2       06/02/2026   Harika Dharmapuri      updated the hardcoded values
-- 1.0       06/02/2026   Harika Dharmapuri      Final version
 
 
{% test hwm_start_end_check(model,source_name, source_table, hwm_table,
updated_at_column,hwm_start_column,hwm_end_column,Default_end_date) %}
 
WITH max_updated AS (
    SELECT MAX({{ updated_at_column }}) AS max_updated
    FROM {{ source(source_name, source_table) }}
)
 
SELECT
    h.table_name,
    h.{{ hwm_start_column }},
    h.{{ hwm_end_column }},
    mu.max_updated
FROM {{ hwm_table }} h
CROSS JOIN max_updated mu
WHERE h.table_name = '{{ source_table }}'
  AND (
       h.{{ hwm_start_column }} <> mu.max_updated
       OR
       h.{{ hwm_end_column }} <> '{{ Default_end_date }}'
       OR
       h.{{ hwm_start_column }} >= h.{{ hwm_end_column }}
      )
 
{% endtest %}