{% test customer_id_not_empty(model, column_name) %}
-- Fail if customer_id is null or empty
select *
from {{ model }}
where {{ column_name }} is null
   or trim({{ column_name }}) = ''
{% endtest %}
