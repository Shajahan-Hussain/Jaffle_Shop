{% test validate_lookup_against_master(model, lookup_table, key_column, compare_columns) %}

{# 
    model: the raw table (model or source)
    lookup_table: the lookup/master table (ref or source)
    key_column: column used to join (e.g., 'id')
    compare_columns: list of columns to compare between raw and lookup
#}

with raw as (
    select 
        {{ key_column }},
        {% for col in compare_columns %}
        {{ col }} as raw_{{ col }}{% if not loop.last %},{% endif %}
        {% endfor %}
    from {{ model }}
),

lookup as (
    select
        {{ key_column }} as lookup_{{ key_column }},
        {% for col in compare_columns %}
        {{ col }} as lookup_{{ col }}{% if not loop.last %},{% endif %}
        {% endfor %}
    from {{ lookup_table }}
),

joined as (
    select
        r.{{ key_column }},
        {% for col in compare_columns %}
        r.raw_{{ col }},
        l.lookup_{{ col }}{% if not loop.last %},{% endif %}
        {% endfor %}
    from raw r
    left join lookup l
        on r.{{ key_column }} = l.lookup_{{ key_column }}
)

select *
from joined
where 
    l.lookup_{{ key_column }} is null
    {% for col in compare_columns %}
    or r.raw_{{ col }} is distinct from l.lookup_{{ col }}
    {% endfor %}

{% endtest %}
