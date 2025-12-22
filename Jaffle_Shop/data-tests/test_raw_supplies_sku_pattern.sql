{{ config(
    tags = ['Demo1'],
    meta = {
        "ado_test_name": "Validate raw_supplies sku pattern"
    }
) }}
select *
from {{ source('ecom', 'raw_supplies') }}
where not regexp_like(sku, '^[A-Z]{3}-[0-9]{3}$')
