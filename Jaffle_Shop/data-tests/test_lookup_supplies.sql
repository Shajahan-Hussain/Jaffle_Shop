-- Author: Harika Dharmapuri
-- Create Date: 16/10/2025
-- Description: Validates that all SKUs from seed data exist as product IDs in the staging

-- Change History
-- Version   Date         User                     Change
-- 0.1       16/10/2025   Harika Dharmapuri        Initial version
-- 1.0       16/10/2025   Harika Dharmapuri        Final version

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
