{% test audit_delete_counts(model, raw_table, src_key_column, stg_key_column, is_deleted_column) %}

with raw_deleted as (
  select count(distinct {{ src_key_column }}) as raw_cnt
  from {{ raw_table }}
  where {{ is_deleted_column }} = true
),

audit_deleted as (
  select count(distinct {{ stg_key_column }}) as audit_cnt
  from {{ model }}
  where audit_action = 'DELETE'
)

select r.raw_cnt, a.audit_cnt
from raw_deleted r
cross join audit_deleted a
where r.raw_cnt != a.audit_cnt

{% endtest %}
