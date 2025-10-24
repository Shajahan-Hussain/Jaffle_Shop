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
  {% set table_entry = data.get(group_key, {}).get(table, {
      'columns': {},
      'table_tests': [],
      'description': ''
  }) %}

  {# =================== TABLE DESCRIPTION =================== #}
  {% if description and not column and not test_type %}
    {% do table_entry.update({'description': description}) %}
  {% endif %}

  {# =================== COLUMN-LEVEL SECTION =================== #}
  {% if column %}
    {% set col_entry = table_entry['columns'].get(column, {
        'tests': [],
        'description': ''
    }) %}

    {# --- Column description --- #}
    {% if description and not test_type %}
      {% do col_entry.update({'description': description}) %}
    {% endif %}

    {# --- Build or merge tests map --- #}
    {% set merged_tests = {} %}
    {% for t in col_entry['tests'] %}
      {% set tname = t.keys() | list | first %}
      {% set merged_tests = merged_tests.update({ tname: t[tname] }) or merged_tests %}
    {% endfor %}

    {% if test_type %}
      {% set new_conf = fromjson(test_config) if test_config else {} %}
      {% set new_tags = (tags or []) | list %}
      {% set existing = merged_tests.get(test_type, {}) %}

      {# --- Merge config --- #}
      {% for k, v in new_conf.items() %}
        {% do existing.update({ k: v }) %}
      {% endfor %}

      {# --- Merge tags safely --- #}
      {% set safe_existing_tags = existing.get('tags', []) | list %}
      {% set merged_tags = (safe_existing_tags + new_tags) | unique | list %}
      {% do existing.update({'tags': merged_tags}) %}

      {# --- Keep first description --- #}
      {% if not existing.get('description') and test_description %}
        {% do existing.update({'description': test_description}) %}
      {% endif %}

      {% do merged_tests.update({ test_type: existing }) %}
    {% endif %}

    {# --- Rebuild col_entry['tests'] --- #}
    {% set final_tests = [] %}
    {% for k, v in merged_tests.items() %}
      {% do final_tests.append({ k: v }) %}
    {% endfor %}
    {% do col_entry.update({'tests': final_tests}) %}

    {% do table_entry['columns'].update({ column: col_entry }) %}

  {# =================== TABLE-LEVEL SECTION =================== #}
  {% else %}
    {% set merged_tests = {} %}
    {% for t in table_entry['table_tests'] %}
      {% set tname = t.keys() | list | first %}
      {% set merged_tests = merged_tests.update({ tname: t[tname] }) or merged_tests %}
    {% endfor %}

    {% if test_type %}
      {% set new_conf = fromjson(test_config) if test_config else {} %}
      {% set new_tags = (tags or []) | list %}
      {% set existing = merged_tests.get(test_type, {}) %}

      {% for k, v in new_conf.items() %}
        {% do existing.update({ k: v }) %}
      {% endfor %}

      {% set safe_existing_tags = existing.get('tags', []) | list %}
      {% set merged_tags = (safe_existing_tags + new_tags) | unique | list %}
      {% do existing.update({'tags': merged_tags}) %}

      {% if not existing.get('description') and test_description %}
        {% do existing.update({'description': test_description}) %}
      {% endif %}

      {% do merged_tests.update({ test_type: existing }) %}
    {% endif %}

    {% set final_tests = [] %}
    {% for k, v in merged_tests.items() %}
      {% do final_tests.append({ k: v }) %}
    {% endfor %}
    {% do table_entry.update({'table_tests': final_tests}) %}
  {% endif %}

  {# --- Update global structure --- #}
  {% set updated_group = data.get(group_key, {}) %}
  {% do updated_group.update({ table: table_entry }) %}
  {% do data.update({ group_key: updated_group }) %}
{% endmacro %}
