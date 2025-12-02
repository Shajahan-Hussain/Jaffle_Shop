{% test hwm_load_completeness(model, source_name, source_table, updated_at_col) %}

WITH hwm AS (
    SELECT start_date, end_date
    FROM metadata.highwatermark
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
        ON s.ID = t.customer_id
        AND s.UPDATED_AT = t.UPDATED_AT
    WHERE t.customer_id IS NULL
)

SELECT *
FROM missing_in_stg

{% endtest %}