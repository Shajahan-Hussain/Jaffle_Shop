{% test hwm_load_completeness(model, source_name, source_table, updated_at_col) %}

-- Purpose: Validate that all eligible rows from the source
--          are captured in the incremental staging table after load
-- Inputs:
--   model → target model (e.g., ref('tbl_stg_customers'))
--   source_name → source definition (e.g., 'ecom')
--   source_table → table in source (e.g., 'raw_customers')
--   updated_at_col → column name for last updated timestamp (e.g., 'UPDATED_AT')

WITH hwm AS (
    SELECT start_date, end_date
    FROM lcf.highwatermark
    WHERE table_name = '{{ model.identifier }}'
),

eligible_source AS (
    SELECT
        r.ID,
        r.NAME,
        r.{{ updated_at_col }} AS UPDATED_AT,
        r.IS_DELETED
    FROM {{ source(source_name, source_table) }} r
    CROSS JOIN hwm
    WHERE r.{{ updated_at_col }} > hwm.start_date
      AND r.{{ updated_at_col }} <= hwm.end_date
),

missing_in_stg AS (
    SELECT s.*
    FROM eligible_source s
    LEFT JOIN {{ model }} t
        ON s.ID = t.ID
        AND s.UPDATED_AT = t.UPDATED_AT
    WHERE t.ID IS NULL
)

SELECT *
FROM missing_in_stg

{% endtest %}