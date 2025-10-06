{% test late_arriving_source(model, timestamp_column, table_name, highwatermark_model) %}

WITH watermark AS (
    SELECT START_DATE
    FROM {{ highwatermark_model }}
    WHERE TABLE_NAME = '{{ table_name }}'
),

late_records AS (
    SELECT *
    FROM {{ model }} s, watermark w
    WHERE s.{{ timestamp_column }} < w.START_DATE
)

SELECT *
FROM late_records

{% endtest %}
