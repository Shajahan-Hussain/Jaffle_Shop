{% macro add_metadata_to(data, group_key, table, column, description=None, test_type=None, test_config=None) %}
  {% set table_entry = data.get(group_key, {}).get(table, {
      'columns': {},
      'table_tests': [],
      'description': ''
  }) %}

  {# --- Table-level description --- #}
  {% if description is not none and description|trim != '' and not column %}
    {% do table_entry.update({'description': description}) %}
  {% endif %}

  {# --- Column-level metadata --- #}
  {% if column %}
    {% set col_entry = table_entry['columns'].get(column, {
        'tests': [],
        'description': ''
    }) %}

    {% if description is not none and description|trim != '' %}
      {% do col_entry.update({'description': description}) %}
    {% endif %}

    {% if test_type is not none and test_type|trim != '' %}
      {% if test_config is not none and test_config|trim != '' %}
        {% do col_entry['tests'].append({ test_type: fromjson(test_config) }) %}
      {% else %}
        {% do col_entry['tests'].append(test_type) %}
      {% endif %}
    {% endif %}

    {% do table_entry['columns'].update({ column: col_entry }) %}

  {% else %}
    {# --- Table-level tests --- #}
    {% if test_type is not none and test_type|trim != '' %}
      {% if test_config is not none and test_config|trim != '' %}
        {% do table_entry['table_tests'].append({ test_type: fromjson(test_config) }) %}
      {% else %}
        {% do table_entry['table_tests'].append(test_type) %}
      {% endif %}
    {% endif %}
  {% endif %}

  {% set updated_group = data.get(group_key, {}) %}
  {% do updated_group.update({ table: table_entry }) %}
  {% do data.update({ group_key: updated_group }) %}
{% endmacro %}
