-- Author: Sambit Nayak
-- Create Date: 16/09/2025
-- Description: Validates modified source records are correctly updated in target.

-- Change History
-- Version   Date         User                     Change
-- 0.1       16/09/2025   Sambit Nayak           Initial version
-- 0.2       06/02/2026   Harika Dharmapuri      updated the hardcoded values
-- 1.0       06/02/2026   Harika Dharmapuri      Final version

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
    from t\gt t
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