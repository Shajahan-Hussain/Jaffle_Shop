select *
from {{ source('ecom', 'raw_supplies') }}
where perishable not in (true, false)
   or perishable is null
