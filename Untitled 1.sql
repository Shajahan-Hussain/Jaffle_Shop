select Id, NAME
from raw.raw_customers
except
select Customer_id, customer_name
from staging.stg_customers


select Customer_id, customer_name
from staging.stg_customers
except
select Id, NAME
from raw.raw_customers

Select top 10 * from stg_customers
Select top 10 * from stg_locations
Select top 10 * from stg_order_items
Select top 10 * from stg_orders
select top 10 * from stg_products
Select top 10 * from stg_supplies

SELECT * FROM TASTY_BYTES_DBT_DB.TESTING.TEST_METADATA_TABLE

INSERT INTO TASTY_BYTES_DBT_DB.TESTING.TEST_METADATA_TABLE (
    SCHEMA_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    TEST_TYPE,
    TEST_CONFIG
)
VALUES (
    'dev',
    'raw_pos_country',
    'COUNTRY_ID',
    'source_vs_target',
    '{"source_name": "tb_101", "source_table": "COUNTRY", "source_key": "COUNTRY_ID", "target_key": "COUNTRY_ID"}'
);

SELECT Top 5* FROM RAW.raw_customers



SELECT * FROM dev.raw_pos_country
