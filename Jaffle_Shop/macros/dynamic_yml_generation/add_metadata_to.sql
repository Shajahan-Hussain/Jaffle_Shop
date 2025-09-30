{% macro add_metadata_to(
    data,
    group_key,
    table,
    column,
    description=None,
    test_type=None,
    test_config=None,
    test_description=None
) %}
  {% set table_entry = data.get(group_key, {}).get(table, {
      'columns': {},
      'table_tests': [],
      'description': ''
  }) %}

  {# --- Table-level description --- #}
  {% if description and not column and not test_type %}
    {% do table_entry.update({'description': description}) %}
  {% endif %}

  {# --- Column-level metadata --- #}
  {% if column %}
    {% set col_entry = table_entry['columns'].get(column, {
        'tests': [],
        'description': ''
    }) %}

    {% if description and not test_type %}
      {% do col_entry.update({'description': description}) %}
    {% endif %}

    {% if test_type %}
      {% set test_def = { test_type: {} } %}
      {% if test_config %}
        {% do test_def.update({ test_type: fromjson(test_config) }) %}
      {% endif %}
      {% if test_description %}
        {% do test_def[test_type].update({'description': test_description}) %}
      {% endif %}
      {% do col_entry['tests'].append(test_def) %}
    {% endif %}

    {% do table_entry['columns'].update({ column: col_entry }) %}

  {% else %}
    {# --- Table-level tests --- #}
    {% if test_type %}
      {% set test_def = { test_type: {} } %}
      {% if test_config %}
        {% do test_def.update({ test_type: fromjson(test_config) }) %}
      {% endif %}
      {% if test_description %}
        {% do test_def[test_type].update({'description': test_description}) %}
      {% endif %}
      {% do table_entry['table_tests'].append(test_def) %}
    {% endif %}
  {% endif %}

  {% set updated_group = data.get(group_key, {}) %}
  {% do updated_group.update({ table: table_entry }) %}
  {% do data.update({ group_key: updated_group }) %}
{% endmacro %}
