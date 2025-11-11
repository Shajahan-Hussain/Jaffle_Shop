--Delete one record from staging.tbl_stg_customers
Delete from staging.tbl_stg_customers where ID='d18e4429-67b8-4ac0-8d74-6c1d026d15a7'
--Delete from staging.tbl_stg_customers where ID='50a2d1c4-d788-4498-a6f7-dd75d4db588f'
--Delete from staging.tbl_stg_customers where ID='5261268c-aa94-438a-921a-05efc0d414ax'

--update one records in source - raw.raw_customers
UPDATE raw.raw_customers
SET is_deleted='FALSE'
where ID='50a2d1c4-d788-4498-a6f7-dd75d4db588f' 

--uPDATE hwm
Select * from lcf.highwatermark
Select MAX(updated_at) from raw.raw_customers --2025-09-11 03:13:01.386

update lcf.highwatermark
SET start_date='2024-09-08 00:00:00.000'
where table_name='tbl_stg_customers'

Select MAX(updated_at) from raw.raw_customers

2025-09-11 03:13:01.386

Select * from raw.raw_customers where updated_at>'2025-09-11 03:13:01.386'

Select * from lcf.auditlog order by loadstarttime desc

update lcf.highwatermark
SET start_date='2025-09-08 00:00:00.000'
where table_name='tbl_stg_customers'

Select * from raw.raw_customers where updated_at>'2025-09-08 00:00:00.000'
Select * from lcf.auditlog order by loadstarttime desc
update lcf.auditlog
set status='Failed' where status='In Progress'


2025-09-08 03:35:46.894


--Revert back the record in source  - raw.raw_customers
UPDATE raw.raw_customers
SET is_deleted='FALSE'
where ID='50a2d1c4-d788-4498-a6f7-dd75d4db588f' 

Select * from raw.raw_customers where ID IN ('50a2d1c4-d788-4498-a6f7-dd75d4db588f' ,'d18e4429-67b8-4ac0-8d74-6c1d026d15a7')

select * from staging.tbl_stg_customers where ID IN ('50a2d1c4-d788-4498-a6f7-dd75d4db588f' ,'d18e4429-67b8-4ac0-8d74-6c1d026d15a7')

SELECT startdateas start_date, enddate as end_date
    select * FROM lcf.AuditLog
    WHERE TableName = '{{ model_name }}'
      AND Status = 'In Progress'
    ORDER BY LoadStartTime DESC
    LIMIT 1

Delete from staging.tbl_stg_customers where ID='50a2d1c4-d788-4498-a6f7-dd75d4db588f'

Select * from lcf.fct_dbt__test_executions

DELETE FROM lcf.AuditLog
WHERE ModelName = 'tbl_stg_customers'
  AND Status = 'In Progress';

  Select * from lcf.fct_dbt__test_executions

  Select * from staging.stg_customers
  2347081e-7ae5-4085-a0d6-d1f551721f69

  update staging.stg_customers
  SET CUSTOMER_ID='2347081e-7ae5-4085-a0d6-d1f551721f69'
  Where CUSTOMER_NAME='Henry Strickland'
  and CUSTOMER_ID='2347081e-7ae5-4085-a0d6-d1f551721f69'

  SELECT
  ROW_NUMBER() OVER (ORDER BY SEQ4()) AS ID,
  
  d.name         AS test_name,
  t.status,
  t.Message
  
FROM jaffle_shop.lcf.fct_dbt__test_executions t
LEFT JOIN jaffle_shop.lcf.dim_dbt__tests d
  ON t.test_Execution_id = d.test_Execution_id
ORDER BY t.run_started_at DESC
LIMIT 100;

DESC TABLE jaffle_shop.lcf.fct_dbt__test_executions;
DESC TABLE jaffle_shop.lcf.dim_dbt__tests;

------------------------
WITH latest_tests AS (
  SELECT
      t.NODE_ID,
      d.NAME AS TEST_NAME,
      t.STATUS,
      t.MESSAGE,
      t.RUN_STARTED_AT,
      ROW_NUMBER() OVER (
          PARTITION BY t.NODE_ID
          ORDER BY t.RUN_STARTED_AT DESC
      ) AS rn
  FROM jaffle_shop.lcf.fct_dbt__test_executions t
  LEFT JOIN jaffle_shop.lcf.dim_dbt__tests d
      ON t.NODE_ID = d.NODE_ID
      AND t.COMMAND_INVOCATION_ID = d.COMMAND_INVOCATION_ID
)
SELECT
    ROW_NUMBER() OVER (ORDER BY RUN_STARTED_AT DESC) AS ID,
    TEST_NAME,
    STATUS,
    MESSAGE,
FROM latest_tests
WHERE rn = 1
ORDER BY ID
LIMIT 100;

---------------------------------------
INSERT INTO jaffle_shop.lcf.TestCaseExecution (
    ID,
    TEST_NAME,
    STATUS,
    MESSAGE
)
SELECT
    ROW_NUMBER() OVER (ORDER BY RUN_STARTED_AT DESC) AS ID,
    TEST_NAME,
    STATUS,
    MESSAGE
FROM (
    WITH latest_tests AS (
        SELECT
            t.NODE_ID,
            d.NAME AS TEST_NAME,
            t.STATUS,
            t.MESSAGE,
            t.RUN_STARTED_AT,
            ROW_NUMBER() OVER (
                PARTITION BY t.NODE_ID
                ORDER BY t.RUN_STARTED_AT DESC
            ) AS rn
        FROM jaffle_shop.lcf.fct_dbt__test_executions t
        LEFT JOIN jaffle_shop.lcf.dim_dbt__tests d
            ON t.NODE_ID = d.NODE_ID
            AND t.COMMAND_INVOCATION_ID = d.COMMAND_INVOCATION_ID
    )
    SELECT
        TEST_NAME,
        STATUS,
        MESSAGE,
        RUN_STARTED_AT
    FROM latest_tests
    WHERE rn = 1
    ORDER BY RUN_STARTED_AT DESC
    LIMIT 100
) AS final;



CREATE OR REPLACE TABLE jaffle_shop.lcf.TestCaseExecution (
  ID INT,
  TEST_NAME STRING,
  STATUS STRING,
  MESSAGE STRING
);



