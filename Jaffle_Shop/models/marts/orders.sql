{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge',
    merge_exclude_columns = ['created_at'],
    
) }}

with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('order_items') }}
),

order_items_summary as (
    select
        order_id,
        sum(supply_cost) as order_cost,
        sum(product_price) as order_items_subtotal,
        count(order_item_id) as count_order_items,
        sum(case when is_food_item then 1 else 0 end) as count_food_items,
        sum(case when is_drink_item then 1 else 0 end) as count_drink_items
    from order_items
    group by order_id
),

compute_booleans as (
    select
        o.*,
        s.order_cost,
        s.order_items_subtotal,
        s.count_food_items,
        s.count_drink_items,
        s.count_order_items,
        s.count_food_items > 0 as is_food_order,
        s.count_drink_items > 0 as is_drink_order
    from orders o
    left join order_items_summary s on o.order_id = s.order_id
),

customer_order_count as (
    select
        *,
        row_number() over (
            partition by customer_id
            order by ordered_at asc
        ) as customer_order_number
    from compute_booleans
),

final as (
    select
        *,
        ordered_at as created_at,
        --current_timestamp() as last_updated_at
        --cast(null as timestamp) as last_updated_at   -- NULL for inserts updated on 12-09-2025 16:55
        {% if is_incremental() %}
            current_timestamp() as last_updated_at   -- update path
        {% else %}
            cast(null as timestamp) as last_updated_at   -- insert path
        {% endif %}
    from customer_order_count
)

select * from final

{% if is_incremental() %}
where order_id not in (select order_id from {{ this }})
   or ordered_at > (select max(ordered_at) from {{ this }})
{% endif %}