{% test customer_id_unique(model, column_name) %}
-- Fail if duplicate customer_ids exist
select {{ column_name }}, count(*) as occurrences
from {{ model }}
group by {{ column_name }}
having count(*) > 1
{% endtest %}
