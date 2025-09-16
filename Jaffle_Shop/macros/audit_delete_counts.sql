{% test Audit_delete_counts(model, raw_table, key_column) %}

with raw_deleted as (
  select count(distinct {{ key_column }}) as raw_cnt
  from {{ raw_table }}
  where is_deleted = true
),

audit_deleted as (
  select count(distinct customer_id) as audit_cnt
  from {{ model }}
  where audit_action = 'DELETE'
)

select r.raw_cnt, a.audit_cnt
from raw_deleted r cross join audit_deleted a
where r.raw_cnt != a.audit_cnt

{% endtest %}
