{% macro generate_test_yamls(
    include_descriptions=true,
    include_tests=true,
    test_scope='all',
    model_name=None
) %}

{# ================= Descriptions ================= #}
{% if include_descriptions %}
  {% set desc_query %}
      SELECT schema_name, table_name, column_name, description
      FROM JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA
      ORDER BY schema_name, table_name, column_name
  {% endset %}

  {% set desc_metadata = run_query(desc_query) %}
  {% if desc_metadata %}
    {% set desc_metadata = desc_metadata.rows %}
  {% else %}
    {% set desc_metadata = [] %}
  {% endif %}
{% else %}
  {% set desc_metadata = [] %}
{% endif %}

{# ================= Tests ================= #}
{% if include_tests %}
  {% set test_query %}
      SELECT schema_name, table_name, column_name, test_type, test_config, description, scope
      FROM JAFFLE_SHOP.TESTING.TEST_METADATA
      ORDER BY schema_name, table_name, column_name
  {% endset %}

  {% set test_metadata = run_query(test_query) %}
  {% if test_metadata %}
    {% set test_metadata = test_metadata.rows %}
  {% else %}
    {% set test_metadata = [] %}
  {% endif %}
{% else %}
  {% set test_metadata = [] %}
{% endif %}

{# ================= Init data holders ================= #}
{% set models_data = {} %}
{% set sources_data = {} %}

{# dbt models in project #}
{% set dbt_models = graph.nodes.values()
    | selectattr('resource_type', 'equalto', 'model')
    | map(attribute='alias')
    | list %}

{# ================= Apply Descriptions ================= #}
{% for row in desc_metadata %}
  {% set schema = row[0] %}
  {% set table = row[1] %}
  {% set column = row[2] %}
  {% set description = row[3] %}

  {% if not model_name or table | lower == model_name | lower %}
    {% if table | lower in dbt_models | map('lower') %}
      {% do add_metadata_to(models_data, schema, table, column, description=description) %}
    {% else %}
      {% do add_metadata_to(sources_data, schema, table, column, description=description) %}
    {% endif %}
  {% endif %}
{% endfor %}

{# ================= Apply Tests ================= #}
{% for row in test_metadata %}
  {% set schema = row[0] %}
  {% set table = row[1] %}
  {% set column = row[2] %}
  {% set test_type = row[3] %}
  {% set test_config = row[4] %}
  {% set test_description = row[5] %}
  {% set scope = row[6] %}

  {# --- Respect test_scope param --- #}
  {% if test_scope and test_scope|lower != 'all' %}
    {% if scope is none or scope|lower != test_scope|lower %}
      {% continue %}
    {% endif %}
  {% endif %}

  {% if not model_name or table | lower == model_name | lower %}
    {% if table | lower in dbt_models | map('lower') %}
      {% do add_metadata_to(models_data, schema, table, column,
                           test_type=test_type,
                           test_config=test_config,
                           test_description=test_description) %}
    {% else %}
      {% do add_metadata_to(sources_data, schema, table, column,
                           test_type=test_type,
                           test_config=test_config,
                           test_description=test_description) %}
    {% endif %}
  {% endif %}
{% endfor %}

{# ================= Render YAML ================= #}
version: 2

{% set full_sources_yaml = render_sources_yaml_block(sources_data) %}
{{ log("=== SOURCES YAML ===", info=True) }}
{{ log(full_sources_yaml, info=True) }}

{% set models_yaml = render_models_yaml_block(models_data) %}
{{ log("=== MODELS YAML ===", info=True) }}
{{ log(models_yaml, info=True) }}

{{ full_sources_yaml }}
{{ models_yaml }}
{% endmacro %}
