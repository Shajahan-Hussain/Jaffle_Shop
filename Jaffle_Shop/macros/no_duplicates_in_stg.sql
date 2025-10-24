{% test no_duplicates_in_stg(model, columns) %}

WITH grouped AS (
    SELECT
        {{ columns | join(', ') }} ,
        COUNT(*) AS record_count
    FROM {{ model }}
    GROUP BY {{ columns | join(', ') }}
    HAVING COUNT(*) > 1
)

SELECT *
FROM grouped

{% endtest %}
