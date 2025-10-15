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
