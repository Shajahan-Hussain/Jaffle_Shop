{% macro generate_test_yamls() %}

{# --- Union query for descriptions + tests --- #}
{% set metadata_query %}
    SELECT schema_name,
           table_name,
           column_name,
           description,
           NULL AS test_type,
           NULL AS test_config
    FROM JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA

    UNION ALL

    SELECT schema_name,
           table_name,
           column_name,
           NULL AS description,
           test_type,
           test_config
    FROM JAFFLE_SHOP.TESTING.TEST_METADATA

    ORDER BY schema_name, table_name, column_name
{% endset %}

{% set metadata = run_query(metadata_query) %}
{% if metadata %}
  {% set metadata = metadata.rows %}
{% else %}
  {% set metadata = [] %}
{% endif %}

{% set models_data = {} %}
{% set sources_data = {} %}

{# dbt models in project #}
{% set dbt_models = graph.nodes.values()
    | selectattr('resource_type', 'equalto', 'model')
    | map(attribute='alias') 
    | list %}

{# --- Apply metadata (descriptions + tests together) --- #}
{% for row in metadata %}
  {% set schema = row[0] %}
  {% set table = row[1] %}
  {% set column = row[2] %}
  {% set description = row[3] %}
  {% set test_type = row[4] %}
  {% set test_config = row[5] %}

  {% if table | lower in dbt_models | map('lower') %}
    {% do add_metadata_to(models_data, schema, table, column, description=description, test_type=test_type, test_config=test_config) %}
  {% else %}
    {% do add_metadata_to(sources_data, schema, table, column, description=description, test_type=test_type, test_config=test_config) %}
  {% endif %}
{% endfor %}

{# --- Render YAML --- #}
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
