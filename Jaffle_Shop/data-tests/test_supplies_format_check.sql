-- Author: Harika Dharmapuri
-- Create Date: 13/10/2025
-- Description: Validate format standardisation for stg_supplies

-- Change History
-- Version   Date         User                     Change
-- 0.1       13/10/2025   Harika Dharmapuri        Initial version
-- 1.0       13/10/2025   Harika Dharmapuri        Final version

{{ config(
    tags=['ADO'],
    meta = {
        "ado_test_name": "Verify that supply_uuid, supply_id, product_id, supply_name, supply_cost, is_perishable_supply columns in stg_supplies follow the expected standardised formats"
    }
) }}
with data as (
    select *
    from {{ ref('stg_supplies') }}
)

select *
from data
where
    --  UUID check (32-char hex string)
    supply_uuid not regexp '^[0-9a-f]{32}$'

    --  Supply ID check (non-null, matches SUP-001 pattern)
    or supply_id is null
    or supply_id not regexp '^SUP-[0-9]{3}$'

    --  Product ID check (non-null, matches JAF-001 pattern)
    or product_id is null
    or product_id not regexp '^(JAF|BEV|ORG)-[0-9]{3}$'

   -- 4️⃣ Supply name check (non-null, not numeric-only)
    or supply_name is null
    or trim(supply_name) = ''
    or supply_name regexp '^[0-9]+$'
    
    -- 5️⃣ Supply cost check (numeric, < 0)
    or supply_cost is null
    or supply_cost < 0

    -- 6️⃣ Boolean flag check
    or is_perishable_supply not in ('TRUE','FALSE')
