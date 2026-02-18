-- Author: Sambit Nayak
-- Create Date: 12/09/2025
-- Description: Validate format standardisation for stg_supplies

-- Change History
-- Version   Date         User                Change
-- 0.1       12/09/2025   Sambit Nayak        Initial version
-- 1.0       12/09/2025   Sambit Nayak        Final version

{{ config(
    tags=['ADO'],
    meta = {
        "ado_test_name": "Verify that columns in stg_supplies follow the expected standardised formats"
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

   --  Supply name check (non-null, not numeric-only)
    or supply_name is null
    or trim(supply_name) = ''
    or supply_name regexp '^[0-9]+$'
    
    --  Supply cost check (numeric, < 0)
    or supply_cost is null
    or supply_cost < 0

    --  Boolean flag check
    or is_perishable_supply not in ('TRUE','FALSE')
