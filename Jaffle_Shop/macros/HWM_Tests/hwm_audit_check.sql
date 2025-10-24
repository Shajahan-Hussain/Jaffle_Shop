{% test hwm_audit_check(model, hwm_table, audit_table, target_table) %}

{{ config(severity='error') }}

-- Step 1: Get the latest high watermark for the target table
WITH latest_hwm AS (
    SELECT 
        table_name,
        MAX(start_date) AS latest_start_date
    FROM {{ hwm_table }}
    WHERE (table_name) = ('{{ target_table }}')
    GROUP BY table_name
),

-- Step 2: Check audit log entries for the latest high watermark
audit_check AS (
    SELECT 
        a.tablename,
        a.startdate,
        a.loadstarttime,
        a.loadendtime,
        a.status
    FROM {{ audit_table }} a
    JOIN latest_hwm h
      ON (a.tablename) = (h.table_name)
     AND CAST(a.startdate AS DATE) = CAST(h.latest_start_date AS DATE)
)

-- Step 3: Return a failure row only if the audit log entry is missing
SELECT 
    '❌ No audit log entry found for {{ target_table }} for the latest high watermark run.' AS error_message
WHERE NOT EXISTS (
    SELECT 1 FROM audit_check
)

{% endtest %}