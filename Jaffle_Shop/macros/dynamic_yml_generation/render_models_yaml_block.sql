{% macro render_models_yaml_block(grouped_data) %}
{%- for schema_name, tables in grouped_data.items() %}
  {%- for table_name, table_data in tables.items() %}
---
version: 2
models:
  - name: {{ table_name }}
    description: "{{ table_data.description if table_data.description else '' }}"
    {%- if table_data.table_tests %}
    tests:
      {%- for test in table_data.table_tests %}
        {%- for k, v in test.items() %}
      - {{ k }}:
              {%- for vk, vv in v.items() %}
          {{ vk }}: {{ vv }}
              {%- endfor %}
        {%- endfor %}
      {%- endfor %}
    {%- endif %}

    {%- if table_data.columns %}
    columns:
      {%- for col, col_data in table_data.columns.items() %}
      - name: {{ col }}
        description: "{{ col_data.description if col_data.description else '' }}"
        {%- if col_data.tests %}
        tests:
          {%- for test in col_data.tests %}
            {%- for k, v in test.items() %}
          - {{ k }}:
                  {%- for vk, vv in v.items() %}
              {{ vk }}: {{ vv }}
                  {%- endfor %}
            {%- endfor %}
          {%- endfor %}
        {%- endif %}
      {%- endfor %}
    {%- endif %}
  {%- endfor %}
{%- endfor %}
{% endmacro %}
