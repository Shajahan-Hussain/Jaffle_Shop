-- Author: Kirti Sharma
-- Create Date: 16/09/2025
-- Description: Validates column-level value consistency between two models.

-- Change History
-- Version   Date         User                     Change
-- 0.1       16/09/2025   Kirti Sharma           Initial version
-- 1.0       16/09/2025   Kirti Sharma           Final version
{% test minus_compare_column(model, compare_model, column_name) %}

WITH validation_errors AS (
    -- Rows in `model` that are not in `compare_model`
    SELECT {{ column_name }} FROM {{ model }}
    MINUS
    SELECT {{ column_name }} FROM {{ compare_model }}
    
    UNION ALL
    
    -- Rows in `compare_model` that are not in `model`
    SELECT {{ column_name }} FROM {{ compare_model }}
    MINUS
    SELECT {{ column_name }} FROM {{ model }}
)

SELECT * FROM validation_errors

{% endtest %}