{% test active_counts_match(model, source_table, key_column, is_deleted_column, active_flag_value) %}

with raw_active as (
    select count(distinct {{ key_column }}) as cnt
    from {{ source_table }}
    where {{ is_deleted_column }} = {{ active_flag_value }}
),

staging as (
    select count(*) as cnt
    from {{ model }}
)

select
    r.cnt as raw_count,
    s.cnt as staging_count
from raw_active r
join staging s on 1=1
where r.cnt != s.cnt

{% endtest %}
