-- tests/test_format_stg_supplies.sql
-- Purpose: Validate format standardisation for stg_supplies

with data as (
    select *
    from {{ ref('stg_supplies') }}
)

select *
from data
where
    -- 1️⃣ UUID check (32-char hex string)
    supply_uuid not regexp '^[0-9a-f]{32}$'

    -- 2️⃣ Supply ID check (non-null, matches SUP-001 pattern)
    or supply_id is null
    or supply_id not regexp '^SUP-[0-9]+$'

    -- 3️⃣ Product ID check (non-null, matches JAF-001 pattern)
    or product_id is null
    or product_id not regexp '^(JAF|BEV)-[0-9]+$'

   -- 4️⃣ Supply name check (non-null, not numeric-only)
    or supply_name is null
    or trim(supply_name) = ''
    or supply_name regexp '^[0-9]+$'
    
    -- 5️⃣ Supply cost check (numeric, < 0)
    or supply_cost is null
    or supply_cost < 0

    -- 6️⃣ Boolean flag check
    or is_perishable_supply not in ('TRUE','FALSE')
