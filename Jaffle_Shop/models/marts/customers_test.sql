{{ config(
    materialized = 'table',
    schema = 'marts',
    pre_hook = auditlog_pre_marts('customers_test'),
    post_hook = auditlog_post_marts('customers_test','marts.customers_test')
) }}


WITH customers AS (

    SELECT * FROM {{ ref('stg_customers_test') }}

),

orders AS (

    SELECT * FROM {{ ref('orders') }}

),

customer_orders_summary AS (

    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS count_lifetime_orders,
        COUNT(DISTINCT o.order_id) > 1 AS is_repeat_buyer,
        MIN(o.ordered_at) AS first_ordered_at,
        MAX(o.ordered_at) AS last_ordered_at,
        SUM(o.subtotal) AS lifetime_spend_pretax,
        SUM(o.tax_paid) AS lifetime_tax_paid,
        SUM(o.order_total) AS lifetime_spend
    FROM orders o
    GROUP BY 1

),

joined AS (

    SELECT
        c.customer_id,
        c.customer_name,
        s.count_lifetime_orders,
        s.first_ordered_at,
        s.last_ordered_at,
        s.lifetime_spend_pretax,
        s.lifetime_tax_paid,
        s.lifetime_spend,

        CASE WHEN s.is_repeat_buyer THEN 'returning'
             ELSE 'new'
        END AS customer_type,

        -- audit columns
        'I' AS ActionType,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS InsertDate,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS ActionDate
    FROM customers c
    LEFT JOIN customer_orders_summary s
        ON c.customer_id = s.customer_id
)

SELECT * FROM joined
