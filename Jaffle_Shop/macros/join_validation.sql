{% test join_validation(model, compare_model, join_key) %}
-- Join Validation Test: checks for missing matches across models

WITH main AS (
    SELECT {{ join_key }} AS id
    FROM {{ model }}
),
compare AS (
    SELECT {{ join_key }} AS id
    FROM {{ compare_model }}
)

SELECT
    m.id AS missing_in_compare
FROM main m
LEFT JOIN compare c USING (id)
WHERE c.id IS NULL

{% endtest %}
