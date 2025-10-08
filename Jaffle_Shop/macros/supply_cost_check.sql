{% test supply_cost_check(model, raw_table, key_column, key_col_model, raw_cost_col, staging_cost_col) %}

with raw as (
    select 
        {{ key_column }} as key_col,
        {{ raw_cost_col }} as raw_cost
    from {{ raw_table }}
),
stg as (
    select 
        {{ key_col_model }} as key_col,
        {{ staging_cost_col }} as stg_cost
    from {{ model }}
),
compare as (
    select
        raw.key_col,
        raw.raw_cost as raw_value,
        (stg.stg_cost * 100) as staging_value
    from raw
    join stg on raw.key_col = stg.key_col
    where abs(raw.raw_cost - (stg.stg_cost * 100)) > 0.5  -- small tolerance for rounding
)

select * from compare

{% endtest %}
