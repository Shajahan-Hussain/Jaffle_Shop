-- Author: Sambit Nayak
-- Create Date: 12/09/2025
-- Description: Validates  product type contains only allowed values (Jaffle, Beverage).

-- Change History
-- Version   Date         User                Change
-- 0.1       12/09/2025   Sambit Nayak        Initial version
-- 1.0       12/09/2025   Sambit Nayak        Final version

SELECT *
FROM {{ ref('raw_products') }}
WHERE type NOT IN ('Jaffle', 'Beverage')
