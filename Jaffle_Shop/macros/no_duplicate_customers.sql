-- Author: Kirti Sharma
-- Create Date: 07/10/2025
-- Description: Ensures no duplicate records exist for specified key column.

-- Change History
-- Version   Date         User                     Change
-- 0.1       07/10/2025   Kirti Sharma           Initial version
-- 1.0       07/10/2025   Kirti Sharma           Final version

{% test no_duplicate_customers(model, key_column) %}

select {{ key_column }}
from {{ model }}
group by {{ key_column }}
having count(*) > 1

{% endtest %}
