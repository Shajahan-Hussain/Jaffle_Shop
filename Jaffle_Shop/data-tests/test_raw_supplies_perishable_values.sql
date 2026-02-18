-- Author: Sambit Nayak
-- Create Date: 12/09/2025
-- Description: Validates that the perishable column contains only TRUE or FALSE values.

-- Change History
-- Version   Date         User                Change
-- 0.1       16/10/2025   Sambit Nayak        Initial version
-- 1.0       16/10/2025   Sambit Nayak        Final version

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