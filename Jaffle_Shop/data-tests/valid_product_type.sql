-- tests/valid_product_type.sql
SELECT *
FROM {{ ref('raw_products') }}
WHERE type NOT IN ('Jaffle', 'Beverage')
