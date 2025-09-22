select * from  lcf.highwatermark

update lcf.highwatermark
set start_date='1900-01-01 03:13:01.386'

select * from lcf.auditlog order by loadstarttime desc

select * from staging.tbl_stg_customers where ID='5261268c-aa94-438a-921a-05efc0d414ac'

select * from raw.raw_customers where updated_at>'2025-09-11 03:13:01.386'

TRUNCATE TABLE staging.tbl_stg_customers




