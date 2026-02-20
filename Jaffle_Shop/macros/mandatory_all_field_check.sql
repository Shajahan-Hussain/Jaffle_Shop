-- Author: Sambit Nayak
-- Create Date: 25/09/2025
-- Description: Validates mandatory fields are not null or empty in the model.

-- Change History
-- Version   Date         User                     Change
-- 0.1       25/09/2025   Sambit Nayak      Initial version
-- 1.0       25/09/2025   Sambit Nayak      Final version

{% test mandatory_fields_check(model, columns) %}

select
    *,
    -- dynamically create a column listing which fields failed
    array_construct_compact(
    {% for col in columns %}
        case when {{ col }} is null or trim({{ col }}) = '' then '{{ col }}' end
        {% if not loop.last %}, {% endif %}
    {% endfor %}
    ) as failed_columns
from {{ model }}
where
{% for col in columns %}
    {{ col }} is null or trim({{ col }}) = ''
    {% if not loop.last %} or {% endif %}
{% endfor %}

{% endtest %}
