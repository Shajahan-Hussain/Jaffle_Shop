{% test incremental_update(
    model,
    source_table,
    key_column,
    business_columns,
    prev_timestamp,
    created_col,
    ref_col
) %}

{% set cols = business_columns.split(",") %}

with updated_stg as (
    select
        {{ key_column }} as id
        {% for col in cols %}
            , {{ col }} as {{ col }}
        {% endfor %}
    ,{{ ref_col }} as {{ ref_col }}
    from {{ source_table }}
),

tgt as (
    select
        {{ key_column }} as id
        {% for col in cols %}
            , {{ col }} as {{ col }}
        {% endfor %}
        , last_updated_at
        , {{ created_col }} as {{ created_col }}
        , {{ ref_col }} as {{ ref_col }}
    from {{ model }}
),

compare as (
    select t.*
    from tgt t
    join updated_stg s on t.id = s.id
    where
        (
          {% for col in cols %}
            s.{{ col }} = t.{{ col }}{% if not loop.last %} or {% endif %}
          {% endfor %}
        )
        and t.last_updated_at = timestamp '{{ prev_timestamp }}'
        and t.{{ created_col }} <> t.{{ ref_col }}
)

-- Invert result: test passes if records exist
select count(*) as passing_rows
from compare
having count(*) > 0

{% endtest %}
