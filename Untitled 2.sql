select * from  lcf.highwatermark

update lcf.highwatermark
set start_date='1900-01-01 03:13:01.386'

select * from lcf.auditlog order by loadstarttime desc

select * from staging.tbl_stg_customers where ID='5261268c-aa94-438a-921a-05efc0d414ac'

select * from raw.raw_customers where updated_at>'2025-09-11 03:13:01.386'

Select *  from testing.test_metadata_table



INSERT INTO testing.test_metadata_table (
    SCHEMA_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    TEST_TYPE,
    TEST_CONFIG
)
VALUES (
    'STG',
    'tbl_stg_customers',
    NULL,
    'source_to_target_range',
    '{
        "source_table": "\\"{{ source(\'ecom\', \'raw_customers\') }}\\"",
        "source_key_list": "[\'ID\']",
        "source_timestamp": "\'UPDATED_AT\'",
        "auditlog_table": "\'lcf.auditlog\'",
        "target_key": "\'ID\'"
    }'
);

