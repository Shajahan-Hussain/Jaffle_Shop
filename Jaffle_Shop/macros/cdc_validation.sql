{% test cdc_validations(model, raw_table, src_key_column, stg_key_column, updated_at_col) %}

-- 1. Get latest non-deleted records from raw
with raw_latest as (
    select
        {{ src_key_column }} as id,
        max({{ updated_at_col }}) as max_updated_at
    from {{ raw_table }}
    where is_deleted = false
    group by {{ key_column }}
),

-- 2. Staging records
staging as (
    select
        {{ stg_key_column }} as id,
        {{ updated_at_col }} as updated
    from {{ model }}
)

-- 3. Check two conditions:
--   a) Missing IDs (present in raw but not staging)
--   b) Outdated records (staging has older updated_at than raw)
select
    r.id,
    r.max_updated_at,
    s.updated
from raw_latest r
left join staging s
    on r.id = s.id
where s.id is null              -- (a) missing record
   or s.updated_at < r.max_updated_at  -- (b) outdated record

{% endtest %}
