-- Author: Sambit Nayak
-- Create Date: 12/09/2025
-- Description: Validates SKU format follows the pattern AAA-999.

-- Change History
-- Version   Date         User                Change
-- 0.1       12/09/2025   Sambit Nayak        Initial version
-- 1.0       12/09/2025   Sambit Nayak        Final version

{{ config(
    tags = ['Demo1'],
    meta = {
        "ado_test_name": "Validate raw_supplies sku pattern"
    }
) }}
select *
from {{ source('ecom', 'raw_supplies') }}
where not regexp_like(sku, '^[A-Z]{3}-[0-9]{3}$')
