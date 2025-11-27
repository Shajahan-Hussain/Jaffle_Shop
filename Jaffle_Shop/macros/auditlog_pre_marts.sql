{% macro auditlog_pre_marts(model_name) %}

-- Check if model is already running
{% set in_progress_query %}
    SELECT COUNT(*) AS cnt
    FROM lcf.AuditLog
    WHERE TableName = '{{ model_name }}' AND Status = 'In Progress'
{% endset %}

{% set result = run_query(in_progress_query) %}
{% if result and result.columns[0].values()[0] | int > 0 %}
    {% do exceptions.raise_compiler_error("Model '{{ model_name }}' is already in progress.") %}
{% endif %}

INSERT INTO lcf.AuditLog (
    TableName,
    StartDate,
    EndDate,
    LoadStartTime,
    Status,
    LoadedBy
)
VALUES (
    '{{ model_name }}',
    NULL,
    NULL,
    CONVERT_TIMEZONE('Asia/Kolkata', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ,
    'In Progress',
    CURRENT_USER()
);

{% endmacro %}
