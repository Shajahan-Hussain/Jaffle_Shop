{% test incremental_insert_check(model) %}
WITH recent_raw AS (
    SELECT *
    FROM {{ ref('raw_orders') }}
    WHERE ordered_at >= DATEADD(DAY, -{{ var('days_back', 1) }}, CURRENT_DATE)
),
checks AS (
    SELECT r.id,
           CASE 
                WHEN s.order_id IS NULL THEN 'Missing in Staging'
                WHEN m.order_id IS NULL THEN 'Missing in Marts'
                ELSE 'Present in All Layers'
           END AS record_status
    FROM recent_raw r
    LEFT JOIN {{ ref('stg_orders') }} s 
           ON r.id = s.order_id
    LEFT JOIN {{ ref('orders') }} m 
           ON r.id = m.order_id
)
-- dbt test should only FAIL when there are problems
SELECT record_status,
       COUNT(*) AS issue_count
FROM checks
WHERE record_status IN ('Missing in Staging', 'Missing in Marts')
GROUP BY record_status;

{% endtest %}
