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