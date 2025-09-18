{% test incremental_updates(model, source_table, key_column, compare_columns) %}
 
{# split the compare_columns list into individual columns #}
{% set cols = compare_columns.split(",") %}
 
with source_latest as (
    select
        {{ key_column }} as id,
        {% for col in cols %}
            {{ col }} as {{ col }}{% if not loop.last %},{% endif %}
        {% endfor %}
    from {{ source_table }}
),
 
target as (
    select
        {{ key_column }} as id,
        {% for col in cols %}
            {{ col }} as {{ col }}{% if not loop.last %},{% endif %}
        {% endfor %}
    from {{ model }}
),
 
compare as (
    select s.id
        {% for col in cols %}
            , s.{{ col }} as source_{{ col }}
            , t.{{ col }} as target_{{ col }}
        {% endfor %}
    from source_latest s
    join target t on s.id = t.id
)
 
-- Fail rows where any column mismatches
select *
from compare
where
    {% for col in cols %}
        source_{{ col }} != target_{{ col }}
        {% if not loop.last %} or {% endif %}
    {% endfor %}
 
{% endtest %}