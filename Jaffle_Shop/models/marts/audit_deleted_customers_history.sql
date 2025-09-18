{{
  config(
    materialized='incremental',
    schema = 'DBT_TEST__AUDIT',
    unique_key='Audit_key'
  )
}}

with raw_deleted as (
  select
    id,
    name,
    updated_at
  from {{ source('ecom', 'raw_customers') }}
  where is_deleted = true
)

select
  id as customer_id,
  name as customer_name,
  updated_at,
  true as is_deleted,
  'DELETE' as audit_action,
  current_timestamp() as audit_inserted_at,
  -- synthetic unique key to allow incremental upsert (id + updated_at)
  concat(id, '|' , to_varchar(updated_at)) as audit_key
from raw_deleted

{% if is_incremental() %}
  where updated_at > (select coalesce(max(updated_at), '1900-01-01') from {{ this }})
{% endif %}
