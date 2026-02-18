-- Author: Kirti Sharma
-- Create Date: 16/10/2025
-- Description: Ensures all orders reference valid existing customers.

-- Change History
-- Version   Date         User                     Change
-- 0.1       16/10/2025   Kirti Sharma           Initial version
-- 1.0       16/10/2025   Kirti Sharma           Final version

{{ config(
    tags = ['ADO'],
    meta = {
        "ado_test_name": "Verify if any order refers to a non existing customers in stg_orders table"
    }
) }}
select o.order_id, o.customer_id
from {{ ref('stg_orders') }} o
left join {{ ref('stg_customers') }} c
  on o.customer_id = c.customer_id
where c.customer_id is null
