{% macro add_metadata_to(
    data,
    group_key,
    table,
    column,
    description=None,
    test_type=None,
    test_config=None,
    test_description=None,
    tags=None
) %}
  {# --- Convert stringified tags (from Snowflake arrays) to proper list --- #}
  {% if tags is string %}
    {% set clean_tags = tags | replace('[', '') | replace(']', '') | replace('"', '') | replace("'", '') | replace(' ', '') | split(',') %}
    {% set tags = clean_tags %}
  {% endif %}

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
      {% set existing_tests = col_entry['tests'] %}
      {% set found = false %}

      {% for existing_test in existing_tests %}
        {% for existing_type, existing_details in existing_test.items() %}
          {% if existing_type == test_type %}
            {% set found = true %}
            {% set merged_details = existing_details.copy() %}

            {# Merge tags uniquely #}
            {% set old_tags = existing_details.get('tags', []) %}
            {% set new_tags = (old_tags + (tags or [])) | unique %}
            {% do merged_details.update({'tags': new_tags}) %}

            {# Merge configs if available #}
            {% if test_config %}
              {% do merged_details.update(fromjson(test_config)) %}
            {% endif %}

            {# Update description if new one is provided #}
            {% if test_description %}
              {% do merged_details.update({'description': test_description}) %}
            {% endif %}

            {% do existing_test.update({test_type: merged_details}) %}
          {% endif %}
        {% endfor %}
      {% endfor %}

      {% if not found %}
        {% set test_def = { test_type: {} } %}
        {% if test_config %}
          {% do test_def.update({ test_type: fromjson(test_config) }) %}
        {% endif %}
        {% if test_description %}
          {% do test_def[test_type].update({'description': test_description}) %}
        {% endif %}
        {% if tags %}
          {% do test_def[test_type].update({'tags': tags}) %}
        {% endif %}
        {% do existing_tests.append(test_def) %}
      {% endif %}
    {% endif %}

    {% do table_entry['columns'].update({ column: col_entry }) %}

  {% else %}
    {# --- Table-level tests --- #}
    {% if test_type %}
      {% set existing_tests = table_entry['table_tests'] %}
      {% set found = false %}

      {% for existing_test in existing_tests %}
        {% for existing_type, existing_details in existing_test.items() %}
          {% if existing_type == test_type %}
            {% set found = true %}
            {% set merged_details = existing_details.copy() %}

            {% set old_tags = existing_details.get('tags', []) %}
            {% set new_tags = (old_tags + (tags or [])) | unique %}
            {% do merged_details.update({'tags': new_tags}) %}

            {% if test_config %}
              {% do merged_details.update(fromjson(test_config)) %}
            {% endif %}
            {% if test_description %}
              {% do merged_details.update({'description': test_description}) %}
            {% endif %}

            {% do existing_test.update({test_type: merged_details}) %}
          {% endif %}
        {% endfor %}
      {% endfor %}

      {% if not found %}
        {% set test_def = { test_type: {} } %}
        {% if test_config %}
          {% do test_def.update({ test_type: fromjson(test_config) }) %}
        {% endif %}
        {% if test_description %}
          {% do test_def[test_type].update({'description': test_description}) %}
        {% endif %}
        {% if tags %}
          {% do test_def[test_type].update({'tags': tags}) %}
        {% endif %}
        {% do existing_tests.append(test_def) %}
      {% endif %}
    {% endif %}
  {% endif %}

  {# --- Update final grouped data structure --- #}
  {% set updated_group = data.get(group_key, {}) %}
  {% do updated_group.update({ table: table_entry }) %}
  {% do data.update({ group_key: updated_group }) %}
{% endmacro %}
