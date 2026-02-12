-- Test: hwm_start_end_check
-- Description:
-- Validates High Watermark (HWM) table by checking:
-- 1) HWM start matches MAX(updated_at) from source table
-- 2) HWM end equals the default sentinel end date
-- 3) HWM start is always less than HWM end

{% test hwm_start_end_check(model,source_name, source_table, hwm_table,updated_at_column,hwm_start_column,hwm_end_column,Default_end_date) %}

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
        -- 1️⃣ start_date should match max UPDATED_AT from source
       h.{{ hwm_start_column }} <> mu.max_updated
        OR
        -- 2️⃣ end_date should always be 9999-12-31
       h.{{ hwm_end_column }} <> '{{ Default_end_date }}'
        OR
        -- 3️⃣ start_date must be less than end_date
        h.{{ hwm_start_column }} >= h.{{ hwm_end_column }}
      )

{% endtest %}