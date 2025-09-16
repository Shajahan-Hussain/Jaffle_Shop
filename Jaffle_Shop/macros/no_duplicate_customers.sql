{% test no_duplicate_customers(model, key_column) %}

select {{ key_column }}
from {{ model }}
group by {{ key_column }}
having count(*) > 1

{% endtest %}
