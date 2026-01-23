{{ config(
    tags=['ADO'],
    meta = {
        "ado_test_name": "Validate every sku in the seed has matching product id in the stg_products"
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
