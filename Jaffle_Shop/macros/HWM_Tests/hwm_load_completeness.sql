-- Author: Harika
-- Create Date: 24/10/2025
-- Description: Checks for missing records between source and target within HWM period.

-- Change History
-- Version   Date         User                     Change
-- 0.1       24/10/2025   Harika Dharmapuri      Initial version
-- 0.2       06/02/2026   Harika Dharmapuri      updated the hardcoded values
-- 1.0       06/02/2026   Harika Dharmapuri      Final version


{% test hwm_load_completeness(model, source_name, source_table, updated_at_col,highwatermark_table,id_column,name_column,is_deleted_column,target_key_column,updated_at_alias,hwm_start_column,hwm_end_column) %}

WITH hwm AS (
    SELECT {{ hwm_start_column }}, {{ hwm_end_column }}
    FROM {{ highwatermark_table }}
    WHERE table_name = '{{ model.identifier }}'
),

eligible_source AS (
    SELECT
        r.{{ id_column }} AS id,
        r.{{ name_column }} AS name,
        r.{{ updated_at_col }} AS {{ updated_at_alias }},
        r.{{ is_deleted_column }} AS is_deleted
    FROM {{ source(source_name, source_table) }} r
    CROSS JOIN hwm
    WHERE r.{{ updated_at_col }} > hwm.{{ hwm_start_column }}
      AND r.{{ updated_at_col }} <= hwm.{{ hwm_end_column }}
),

missing_in_stg AS (
    SELECT s.*
    FROM eligible_source s
    LEFT JOIN {{ model }} t
        ON s.id = t.{{ target_key_column }}
        AND s.{{ updated_at_alias }} = t.{{ updated_at_alias }}
    WHERE t.{{ target_key_column }} IS NULL
)

SELECT *
FROM missing_in_stg

{% endtest %}