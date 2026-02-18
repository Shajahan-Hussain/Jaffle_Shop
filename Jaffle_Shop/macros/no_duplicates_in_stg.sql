-- Author: Kirti Sharma
-- Create Date: 07/10/2025
-- Description: Identifies duplicate records across selected columns.

-- Change History
-- Version   Date         User                     Change
-- 0.1       07/10/2025   Kirti Sharma           Initial version
-- 1.0       07/10/2025   Kirti Sharma           Final version

{% test no_duplicates_in_stg(model, columns) %}

WITH grouped AS (
    SELECT
        {{ columns | join(', ') }} ,
        COUNT(*) AS record_count
    FROM {{ model }}
    GROUP BY {{ columns | join(', ') }}
    HAVING COUNT(*) > 1
)

SELECT *
FROM grouped

{% endtest %}
