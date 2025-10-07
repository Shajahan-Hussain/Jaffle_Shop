{% test reconciliation_name_check(model, raw_table, key_column, key_col_model, compare_column, compare_col_model) %}

with src as (
    select 
        {{ key_column }} as key_col,
        {{ compare_column }} as src_value
    from {{ raw_table }}
),
tgt as (
    select 
        {{ key_col_model }} as key_col,
        {{ compare_col_model }} as tgt_value
    from {{ model }}
),
diffs as (
    select 
        src.key_col,
        src.src_value as source_value,
        tgt.tgt_value as model_value
    from src
    inner join tgt
        on src.key_col = tgt.key_col
    where 
        src.src_value is distinct from tgt.tgt_value
)

select *
from diffs

{% endtest %}