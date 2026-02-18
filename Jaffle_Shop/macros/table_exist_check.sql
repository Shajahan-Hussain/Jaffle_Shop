-- Author: Harika
-- Create Date: 18/11/2025
-- Description: Checks existence of required table in target schema.

-- Change History
-- Version   Date         User                     Change
-- 0.1       18/11/2025   Harika Dharmapuri      Initial version
-- 0.2       06/02/2026   Harika Dharmapuri      updated the hardcoded values
-- 1.0       06/02/2026   Harika Dharmapuri      Final version

{% test table_exist_check(model, database_name, schema_name, table_name,metadata_table_name) %}

SELECT
    1
FROM {{ database_name }}.INFORMATION_SCHEMA.{{ metadata_table_name }}
WHERE TABLE_SCHEMA = '{{ schema_name }}'
  AND TABLE_NAME = '{{ table_name }}'
HAVING COUNT(*) = 0

{% endtest %}
