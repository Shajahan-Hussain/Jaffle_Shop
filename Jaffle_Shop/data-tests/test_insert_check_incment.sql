WITH recent_raw AS (
    SELECT *
    FROM {{ source('ecom', 'raw_orders') }}
    WHERE ordered_at >= DATEADD(DAY, -7, CURRENT_DATE)   -- check last 1 day
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
)
-- dbt passes if this returns 0 rows
SELECT *
        --id,
       --ordered_at,
       --record_status
FROM check_missing
WHERE record_status != 'Present in All Layers'