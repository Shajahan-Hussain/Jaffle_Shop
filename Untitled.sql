Select * from jaffle_shop.staging.test_metadata_table

INSERT INTO TASTY_BYTES_DBT_DB.TESTING.TEST_METADATA_TABLE 
VALUES (
  'STAGING',                                         -- LAYER / CONTEXT
  'STG_ORDERS',                                     -- MODEL NAME
  NULL,                                              -- ADDITIONAL INFO (if any)
  'NO_DUPLICATES_IN_STG',                            -- TEST TYPE / TEST NAME
  '{"test_name": "no_duplicates_in_stg",
    "description": "Verify no duplicate records are introduced after staging transformations.",
    "columns": ["ORDER_ID", "CUSTOMER_ID"],
    "model": "\"{{ ref(\'stg_orders\') }}\""
  }'
);