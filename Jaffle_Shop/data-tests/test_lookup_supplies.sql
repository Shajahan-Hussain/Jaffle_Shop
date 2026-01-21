{{ config(
    tags=['ADO'],
    meta = {
        "ado_test_name": "Verify the lookup test, that every SKU in the raw_supplies seed has a matching product_id in the stg_products staging model"
    }
) }}
with supplies as (
    select distinct sku
    from {{ ref('raw_supplies') }}   -- seed (lookup)
),

products as (
    select distinct product_id
    from {{ ref('stg_products') }}   -- staging model
)

select
    s.sku
from supplies s
inner join products p
    on s.sku = p.product_id
where p.product_id is null
