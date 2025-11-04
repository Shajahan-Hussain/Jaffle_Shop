Select * from raw.raw_customers_test

ALTER TABLE raw.raw_customers_test 
ADD COLUMN Effective_Date DATE;

ALTER TABLE raw.raw_customers_test 
ADD COLUMN Create_Date TIMESTAMP_NTZ(9);

UPDATE raw.raw_customers_test
SET Create_date = Updated_At





UPDATE raw.raw_customers_test
SET Effective_Date = TO_DATE(Updated_At);

UPDATE  lcf.AuditLog
SET Status='Failed'
WHERE TABLENAME = 'tbl_stg_customers'
  AND Status = 'In Progress';

  update lcf.highwatermark
SET start_date='1900-01-01 00:00:00.000'
where table_name='tbl_stg_customers'

  select * from staging.tbl_stg_customers

  select * from lcf.auditlog order by 1 desc

CREATE OR REPLACE TABLE RAW.RAW_CUSTOMERS_TEST CLONE RAW.RAW_CUSTOMERS;

Select * from RAW.RAW_CUSTOMERS_TEST

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE RAW.RAW_CUSTOMERS_TEST TO ROLE DATATESTER

select * from lcf.highwatermark

update lcf.auditlog
SET Status='Failed'
where tablename='tbl_stg_customers_test'

  update lcf.highwatermark
SET start_date='1900-01-01 00:00:00.000'
where table_name='tbl_stg_customers_test'

select * from lcf.auditlog order by 1 desc
select * from lcf.HIGHWATERMARK
select * from staging.tbl_stg_customers_test where ISLATEARRIVING='Y'

TRUNCATE TABLE staging.tbl_stg_customers_test

INSERT INTO RAW.RAW_CUSTOMERS_TEST (
    ID,
    NAME,
    UPDATED_AT,
    IS_DELETED,
    EFFECTIVE_DATE,
    CREATE_DATE
)
VALUES 
    ('50a2d1c4-d788-4498-a6f7-ac90m6gj933k', 'Roshan Lal', '2025-11-04 10:35:46.894', FALSE, '2025-11-03', '2025-11-04 10:35:46.894')
