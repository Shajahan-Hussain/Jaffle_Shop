{% macro select_except(source_relation, exclude_columns) %}
    {% set columns = adapter.get_columns_in_relation(source_relation) %}
    {% set included_columns = [] %}

    {% for col in columns %}
        {% if col.name not in exclude_columns %}
            {% do included_columns.append(adapter.quote_identifier(col.name)) %}
        {% endif %}
    {% endfor %}

    {{ included_columns | join(', ') }}
{% endmacro %}