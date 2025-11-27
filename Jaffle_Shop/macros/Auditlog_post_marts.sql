{% macro auditlog_post_marts(model_name, table_ref) %}

-- 🟢 auditlog_post_marts started for model: {{ model_name }}

UPDATE lcf.AuditLog
SET
    LoadEndTime = CURRENT_TIMESTAMP()::TIMESTAMP_NTZ,
    TotalRecords = (SELECT COUNT(*) FROM {{ table_ref }}),
    RecordsInserted = (SELECT COUNT(*) FROM {{ table_ref }} WHERE ActionType = 'I'),
    RecordsUpdated = (SELECT COUNT(*) FROM {{ table_ref }} WHERE ActionType = 'U'),
    RecordsDeleted = (SELECT COUNT(*) FROM {{ table_ref }} WHERE ActionType = 'D'),
    Status = 'Completed',
    Error = NULL
WHERE TableName = '{{ model_name }}'
  AND Status = 'In Progress'
  AND LoadStartTime = (
      SELECT MAX(LoadStartTime)
      FROM lcf.AuditLog
      WHERE TableName = '{{ model_name }}'
        AND Status = 'In Progress'
  );

-- 🟢 auditlog_post_marts completed for model: {{ model_name }}

{% endmacro %}
