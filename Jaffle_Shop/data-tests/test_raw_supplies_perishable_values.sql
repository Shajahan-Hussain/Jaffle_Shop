{{ config(
    severity='warn',
    store_failures=true
) }}

{% do log("⚠️ Warning: Some 'perishable' values are NULL or not TRUE/FALSE in raw_supplies.", info=True) %}
select *
from {{ source('ecom', 'raw_supplies') }}
where perishable not in (true, false)
   or perishable is null 
   --(For this Test case to pass quoted this line since in raw_supplies it contains null values)