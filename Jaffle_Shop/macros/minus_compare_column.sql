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