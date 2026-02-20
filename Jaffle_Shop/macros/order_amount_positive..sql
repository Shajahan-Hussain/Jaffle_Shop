{% test order_amount_positive(model, column_name) %}
-- This test will validate the amount is posiotive or not
    select *
    from {{ model }}
    where {{ column_name }} <= 0
{% endtest %}
