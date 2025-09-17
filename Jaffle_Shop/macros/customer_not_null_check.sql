{% test column_not_null_check(model, column_name) %}
-- Fail if customer_name is null or empty
select *
from {{ model }}
where {{ column_name }} is null
   or trim({{ column_name }}) = ''
{% endtest %}
