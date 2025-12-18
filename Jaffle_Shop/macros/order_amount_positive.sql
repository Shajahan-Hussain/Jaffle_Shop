{% test order_amount_positive(model, column_name) %}
-- to check the no negative values in the amount
     select *
     from {{ model }}
     where {{ column_name }} <= 0
{% endtest %}
