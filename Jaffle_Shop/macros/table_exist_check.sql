{% test table_exist_check(model, schema_name, table_name) %}

SELECT
    1
FROM {{ target.database }}.INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = '{{ schema_name }}'
  AND TABLE_NAME = '{{ table_name }}'
HAVING COUNT(*) = 0

{% endtest %}
