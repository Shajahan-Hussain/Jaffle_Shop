{% test incremental_freshness(model, compare_model, column_name) %}
with source as (
    select max({{ column_name }}) as max_col from {{ compare_model }}
),
target as (
    select max({{ column_name }}) as max_col_tgt from {{ model }}
)
select *
from source s
join target t on 1=1
where t.max_col_tgt < s.max_col
{% endtest %}