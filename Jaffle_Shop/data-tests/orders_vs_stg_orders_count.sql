-- Fail if record count between stg_orders and orders do not match
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