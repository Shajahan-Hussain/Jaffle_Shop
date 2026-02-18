-- Author: Kirti Sharma
-- Create Date: 16/10/2025
-- Description: Ensures record counts match between stg_orders and orders.

-- Change History
-- Version   Date         User                     Change
-- 0.1       16/10/2025   Kirti Sharma           Initial version
-- 1.0       16/10/2025   Kirti Sharma           Final version

{{ config(
    tags = ['Demo1'],
    meta = {
        "ado_test_name": "Validate orders_vs_stg_orders_count"
    }
) }}
with stg_count as (
    select count(*) as cnt from {{ ref('stg_orders') }}
),
orders_count as (
    select count(*) as cnt from {{ ref('orders') }}
)
select
    stg_count.cnt as stg_orders_count,
    orders_count.cnt as orders_count
from stg_count, orders_count
where stg_count.cnt != orders_count.cnt