with source as (

    select * 
    from {{ source('ecom', 'raw_customers') }}

),

deduplicated as (

    -- keep only the latest record per customer_id
    select
        id as customer_id,
        name as customer_name,
        updated_at,
        is_deleted,
        row_number() over (partition by id order by updated_at desc) as row_num
    from source

),

final as (

    select
        customer_id,
        customer_name,
        updated_at
    from deduplicated
    where row_num = 1          -- keep only latest version
      and is_deleted = false   -- exclude soft-deleted records

)

select * from final
