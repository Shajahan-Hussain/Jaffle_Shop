-- Fail if duplicate order_id exists in stg_orders
select order_id, count(*) as occurrences
from {{ ref('stg_orders') }}
group by order_id
having count(*) > 1
