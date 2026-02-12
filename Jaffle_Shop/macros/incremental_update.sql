{% test incremental_update(
    model,
    source_table,
    key_column,
    business_columns,
    prev_timestamp,
    created_col,
    ref_col,
    updated_at_col,
    key_alias
) %}

{% set cols = business_columns.split(",") %}

with updated_stg as (
    select
        {{ key_column }} as {{ key_alias }}
        {% for col in cols %}
            , {{ col }} as {{ col }}
        {% endfor %}
        , {{ ref_col }} as {{ ref_col }}
    from {{ source_table }}
),

tgt as (
    select
        {{ key_column }} as {{ key_alias }}
        {% for col in cols %}
            , {{ col }} as {{ col }}
        {% endfor %}
        , {{ updated_at_col }} as {{ updated_at_col }}
        , {{ created_col }} as {{ created_col }}
        , {{ ref_col }} as {{ ref_col }}
    from {{ model }}
),

compare as (
    select
        t.{{ key_alias }},
        t.{{ updated_at_col }},
        {% for col in cols %}
            t.{{ col }} as {{ col }}{% if not loop.last %},{% endif %}
        {% endfor %}
    from tgt t
    join updated_stg s
      on t.{{ key_alias }} = s.{{ key_alias }}
    where
        (
          {% for col in cols %}
            s.{{ col }} <> t.{{ col }}{% if not loop.last %} or {% endif %}
          {% endfor %}
        )
        and t.{{ updated_at_col }} = '{{ prev_timestamp }}'
        and t.{{ created_col }} <> t.{{ ref_col }}
)

select *
from compare

{% endtest %}