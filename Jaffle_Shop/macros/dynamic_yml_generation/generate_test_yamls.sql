{% macro generate_test_yamls(
    include_descriptions=true,
    include_tests=true,
    model_names=None,
    database_name=None
) %}

{# =================== DESCRIPTIONS =================== #}
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

{# =================== TEST METADATA =================== #}
{% if include_tests %}
  {% set test_query %}
      SELECT schema_name, table_name, column_name, test_type, test_config, description, tags
      FROM JAFFLE_SHOP.TESTING.TEST_METADATA_CLONE
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

{# =================== INIT STRUCTURES =================== #}
{% set models_data = {} %}
{% set sources_data = {} %}

{# dbt models list #}
{% set dbt_models = graph.nodes.values()
    | selectattr('resource_type', 'equalto', 'model')
    | map(attribute='alias')
    | list %}

{# =================== PREPARE LOWERCASE MODEL LIST =================== #}
{% set lower_models = [] %}

{% if model_names %}
  {% if model_names is string %}
    {% set cleaned = model_names | replace("'", '"') %}
    {% if cleaned.startswith('[') %}
      {% set parsed = fromjson(cleaned) %}
      {% set lower_models = parsed | map('lower') | list %}
    {% else %}
      {% set lower_models = [cleaned | lower] %}
    {% endif %}
  {% else %}
    {% set lower_models = model_names | map('lower') | list %}
  {% endif %}
{% endif %}

{# =================== APPLY DESCRIPTIONS =================== #}
{% for row in desc_metadata %}
  {% set schema = row[0] %}
  {% set table = row[1] %}
  {% set column = row[2] %}
  {% set description = row[3] %}

  {% if not model_names or table | lower in lower_models %}
    {% if table | lower in dbt_models | map('lower') | list %}
      {% do add_metadata_to(models_data, schema, table, column, description=description) %}
    {% else %}
      {% do add_metadata_to(sources_data, schema, table, column, description=description) %}
    {% endif %}
  {% endif %}
{% endfor %}

{# =================== APPLY TESTS =================== #}
{% for row in test_metadata %}
  {% set schema = row[0] %}
  {% set table = row[1] %}
  {% set column = row[2] %}
  {% set test_type = row[3] %}
  {% set test_config = row[4] %}
  {% set test_description = row[5] %}
  {% set tags = row[6] %}

  {# --- Clean tags to list --- #}
  {% set clean_tags = [] %}
  {% if tags is string %}
    {% set tag_str = tags | trim %}
    {% if tag_str[0:1] == '[' %}
      {% set _parsed = tag_str | replace("'", '"') %}
      {% do clean_tags.extend(fromjson(_parsed)) %}
    {% elif ',' in tag_str %}
      {% for t in tag_str.split(',') %}
        {% do clean_tags.append(t | trim) %}
      {% endfor %}
    {% else %}
      {% do clean_tags.append(tag_str) %}
    {% endif %}
  {% else %}
    {% set clean_tags = tags %}
  {% endif %}

  {% if not model_names or table | lower in lower_models %}
    {% if table | lower in dbt_models | map('lower') | list %}
      {% do add_metadata_to(models_data, schema, table, column,
                           test_type=test_type,
                           test_config=test_config,
                           test_description=test_description,
                           tags=clean_tags) %}
    {% else %}
      {% do add_metadata_to(sources_data, schema, table, column,
                           test_type=test_type,
                           test_config=test_config,
                           test_description=test_description,
                           tags=clean_tags) %}
    {% endif %}
  {% endif %}
{% endfor %}

{# =================== RENDER YAML =================== #}
version: 2

{% set full_sources_yaml = render_sources_yaml_block(sources_data, database_name=database_name) %}
{{ log("=== SOURCES YAML ===", info=True) }}
{{ log(full_sources_yaml, info=True) }}

{% set models_yaml = render_models_yaml_block(models_data) %}
{{ log("=== MODELS YAML ===", info=True) }}
{{ log(models_yaml, info=True) }}

{{ full_sources_yaml }}
{{ models_yaml }}
{% endmacro %}
