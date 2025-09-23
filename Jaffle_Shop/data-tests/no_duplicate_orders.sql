-- Fail if duplicate order_id exists in stg_orders
select order_id, count(order_id) as occurrences
from {{ ref('stg_orders') }}
group by order_id
having count(order_id) > 1
