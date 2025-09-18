with source as (

    select * 
    from {{ source('ecom', 'raw_orders') }}

),

renamed as (

    select
        ----------  ids
        id as order_id,
        store_id as location_id,
        customer as customer_id,

        ---------- numerics
        subtotal as subtotal_cents,
        tax_paid as tax_paid_cents,
        order_total as order_total_cents,
        {{ cents_to_dollars('subtotal') }} as subtotal,
        {{ cents_to_dollars('tax_paid') }} as tax_paid,
        {{ cents_to_dollars('order_total') }} as order_total,

        ---------- timestamps
        CAST(ordered_at AS TIMESTAMP_NTZ(3)) AS ordered_at

    from source
),

deduped as (
    select *
    from (
        select
            r.*,
            row_number() over (
                partition by r.order_id
                order by r.ordered_at desc   --uses full timestamp
            ) as row_num
        from renamed r
    )
    where row_num = 1
)

select * 
from deduped
