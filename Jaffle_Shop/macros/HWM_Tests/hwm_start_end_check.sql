{% test hwm_start_end_check(model,source_name, source_table, hwm_table) %}

WITH max_updated AS (
    SELECT MAX(updated_at) AS max_updated
    FROM {{ source(source_name, source_table) }}
)

SELECT
    h.table_name,
    h.start_date,
    h.end_date,
    mu.max_updated
FROM {{ hwm_table }} h
CROSS JOIN max_updated mu
WHERE h.table_name = '{{ source_table }}'
  AND (
        -- 1️⃣ start_date should match max UPDATED_AT from source
        h.start_date <> mu.max_updated
        OR
        -- 2️⃣ end_date should always be 9999-12-31
        h.end_date <> '9999-12-31 00:00:00'
        OR
        -- 3️⃣ start_date must be less than end_date
        h.start_date >= h.end_date
      )

{% endtest %}