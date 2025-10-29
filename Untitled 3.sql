Select * from raw.raw_customers

ALTER TABLE raw.raw_customers 
ADD COLUMN Effective_Date DATE;

UPDATE raw.raw_customers
SET Effective_Date = TO_DATE(Updated_At);

UPDATE  lcf.AuditLog
SET Status='Failed'
WHERE TABLENAME = 'tbl_stg_customers'
  AND Status = 'In Progress';

  update lcf.highwatermark
SET start_date='1900-01-01 00:00:00.000'
where table_name='tbl_stg_customers'

  select * from staging.tbl_stg_customers