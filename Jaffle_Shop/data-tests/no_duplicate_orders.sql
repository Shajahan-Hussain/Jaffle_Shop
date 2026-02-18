-- Author: Kirti sharma
-- Create Date: 16/10/2025
-- Description: Ensures no duplicate order_id records exist in orders model.

-- Change History
-- Version   Date         User                Change
-- 0.1       16/10/2025   Kirti sharma        Initial version
-- 1.0       16/10/2025   Kirti sharma        Final version

select order_id,
       count(order_id) as occurrences
from {{ ref('orders') }}
group by order_id
having count(order_id) > 1