{% test order_amount_positive(model, column_name) %}
-- to test the column has no negative values
    select *
    from {{ model }}
    where {{ column_name }} <= 0
{% endtest %}
