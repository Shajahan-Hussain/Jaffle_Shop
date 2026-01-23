{{ config(
    tags = ['ADO'],
    meta = {
        "ado_test_name": "Validate the perishible_value column does not contains values other than True/False in supplies table"
    }
) }}
 
{% do log("Warning: Some 'perishable' values are NULL or not TRUE/FALSE in raw_supplies.", info=True) %}
 
select *
from {{ source('ecom', 'raw_supplies') }}
where perishable not in (true, false)
   or perishable is null