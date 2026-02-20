-- Author: Kirti sharma
-- Create Date: 15/10/2025
-- Description: Validates that derived column values align with the defined calculation logic.

-- Change History
-- Version   Date         User                     Change
-- 0.1       15/10/2025   Kirti sharma      Initial version
-- 1.0       15/10/2025   Kirti Sharma      Final version

{% test derived_column_validation(model, expression, column_name) %}

-- Derived Column Validation Test
-- Compares derived column value against expected formula calculation.

SELECT
    '{{ column_name }}' AS column_tested,
    {{ column_name }} AS actual_value,
    {{ expression }} AS expected_value
FROM {{ model }}
WHERE {{ column_name }} IS DISTINCT FROM {{ expression }}

{% endtest %}
