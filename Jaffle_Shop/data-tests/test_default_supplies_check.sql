-- Purpose: Verify default values in stg_supplies are correctly applied when raw data is missing.
 
with raw as (
    select 
        id,
        name,
        cost,
        perishable
    from {{ source('ecom', 'raw_supplies') }}
),
 
stg as (
    select 
        supply_id,
        supply_name,
        supply_cost,
        is_perishable_supply
    from {{ ref('stg_supplies') }}
),
 
joined as (
    select
        r.id as raw_id,
        r.name as raw_name,
        r.cost as raw_cost,
        r.perishable as raw_perishable,
        s.supply_name,
        s.supply_cost,
        s.is_perishable_supply
    from raw r
    left join stg s on r.id = s.supply_id
)
 
select *
from joined
where 
    -- ❌ CASE : Raw is NULL but staging failed to apply default
     (raw_name is null and supply_name != 'UNKNOWN')
    or (raw_cost is null and supply_cost != 0)
    or (raw_perishable is null and is_perishable_supply != FALSE)