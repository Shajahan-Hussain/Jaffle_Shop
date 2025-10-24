WITH recent_raw AS (
    SELECT *
    FROM {{ source('ecom', 'raw_orders') }}
    WHERE ordered_at >= DATEADD(DAY, -7, CURRENT_DATE)
),
check_missing AS (
    SELECT r.id,
           r.ordered_at,
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
),
failing AS (
    SELECT *
    FROM check_missing
    WHERE record_status != 'Present in All Layers'
),
failing_count AS (
    SELECT COUNT(*) AS cnt
    FROM failing
),
summary AS (
    SELECT record_status, COUNT(*) AS missing_count
    FROM failing
    GROUP BY record_status
)
-- dbt passes if this returns 0 rows
SELECT 
    CASE 
        WHEN fc.cnt > 10 THEN 'Too many failures: ' || fc.cnt || ' records missing'
        ELSE f.record_status
    END AS failure_message,
    CASE 
        WHEN fc.cnt > 10 THEN NULL ELSE f.id
    END AS id,
    CASE 
        WHEN fc.cnt > 10 THEN NULL ELSE f.ordered_at
    END AS ordered_at,
    CASE 
        WHEN fc.cnt > 10 THEN s.record_status ELSE NULL
    END AS summary_layer,
    CASE 
        WHEN fc.cnt > 10 THEN s.missing_count ELSE NULL
    END AS summary_count
FROM failing f
CROSS JOIN failing_count fc
LEFT JOIN summary s ON fc.cnt > 10
