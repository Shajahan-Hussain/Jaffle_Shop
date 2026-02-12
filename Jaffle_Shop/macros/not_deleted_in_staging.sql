{% test not_deleted_in_staging(model, raw_table, src_key_column,stg_key_column,is_deleted_column,deleted_flag_value) %}

with raw_deleted as (
    select {{ src_key_column }}
    from {{ raw_table }}
    where {{ is_deleted_column }} = {{ deleted_flag_value }}
),

staging as (
    select {{ stg_key_column }}
    from {{ model }}
)

select r.{{ src_key_column }}
from raw_deleted r
join staging s
  on r.{{ src_key_column }} = s.{{ stg_key_column }}

{% endtest %}
