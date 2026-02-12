{% test table_exist_check(model, database_name, schema_name, table_name,metadata_table_name) %}

SELECT
    1
FROM {{ database_name }}.INFORMATION_SCHEMA.{{ metadata_table_name }}
WHERE TABLE_SCHEMA = '{{ schema_name }}'
  AND TABLE_NAME = '{{ table_name }}'
HAVING COUNT(*) = 0

{% endtest %}
