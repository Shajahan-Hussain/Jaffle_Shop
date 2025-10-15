{% macro render_sources_yaml_block(sources_data) %}
version: 2
sources:
{%- for source_schema, tables in sources_data.items() %}
  - name: {{ source_schema | lower | replace('_', '') }}
    description: ''
    database: jaffle_shop
    schema: {{ source_schema }}
    tables:
      {%- for table_name, table_data in tables.items() %}
      - name: {{ table_name }}
        description: "{{ table_data.description if table_data.description else '' }}"
        {%- if table_data.table_tests %}
        tests:
          {%- for test in table_data.table_tests %}
            {%- for k, v in test.items() %}
          - {{ k }}:
                  {%- for vk, vv in v.items() %}
                    {%- if vk == 'tags' %}
              tags: [{{ vv | join(', ') }}]
                    {%- elif vv is iterable and vv is not string %}
              {{ vk }}:
                        {%- for item in vv %}
                    - {{ item }}
                        {%- endfor %}
                    {%- else %}
              {{ vk }}: {{ vv }}
                    {%- endif %}
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
                        {%- if vk == 'tags' %}
                tags: [{{ vv | join(', ') }}]
                        {%- elif vv is iterable and vv is not string %}
                {{ vk }}:
                            {%- for item in vv %}
                      - {{ item }}
                            {%- endfor %}
                        {%- else %}
                {{ vk }}: {{ vv }}
                        {%- endif %}
                      {%- endfor %}
                {%- endfor %}
              {%- endfor %}
            {%- endif %}
          {%- endfor %}
        {%- endif %}
      {%- endfor %}
{%- endfor %}
{% endmacro %}
