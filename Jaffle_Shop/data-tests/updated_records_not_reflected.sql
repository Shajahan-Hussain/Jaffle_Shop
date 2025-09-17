
-- tests/updated_records_not_reflected.sql
select src.order_id
from (
    select order_id, max(ordered_at) as ordered_at
    from {{ ref('stg_orders') }}
    group by order_id
) src
join {{ ref('orders') }} tgt
  on src.order_id = tgt.order_id
where src.ordered_at > tgt.ordered_at
