{% test created_last_updated(model, created_col, updated_col) %}
 
with violations as (
 
    select

        order_id,

        {{ created_col }} as created_at,

        {{ updated_col }} as last_updated_at

    from {{ model }}
 
    where (

        -- created_at should never change (must always be less or equal to last_updated_at)

        {{ updated_col }} < {{ created_col }}

        or

        -- created_at must not be null

        {{ created_col }} is null

    )
 
)
 
select * from violations
 
{% endtest %}
 