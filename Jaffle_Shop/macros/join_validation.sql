-- Author: Kirti Sharma
-- Create Date: 04/11/2025
-- Description: Validates referential completeness between models.

-- Change History
-- Version   Date         User                     Change
-- 0.1       04/11/2025   Kirti Sharma           Initial version
-- 0.2       06/02/2026   Harika Dharmapuri      updated the hardcoded values
-- 1.0       06/02/2026   Harika Dharmapuri      Final version

{% test join_validation(model, compare_model, join_key, key_alias) %}
-- Join Validation Test: checks for missing matches across models

WITH main AS (
    SELECT {{ join_key }} AS {{ key_alias }}
    FROM {{ model }}
),
compare AS (
    SELECT {{ join_key }} AS {{ key_alias }}
    FROM {{ compare_model }}
)

SELECT
    m.{{ key_alias }} AS missing_in_compare
FROM main m
LEFT JOIN compare c USING ({{ key_alias }})
WHERE c.{{ key_alias }} IS NULL

{% endtest %}
