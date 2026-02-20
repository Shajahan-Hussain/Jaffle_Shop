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
          {% set config_keys = v.keys() | reject("in", ["description", "tags"]) | list %}
          {%- if config_keys | length == 0 and not v.get('description') and (not v.get('tags') or v.get('tags') | length == 0) %}
      - {{ k }}
          {%- else %}
      - {{ k }}:
            {%- if v.get('description') %}
            description: "{{ v.get('description') }}"
            {%- endif %}
            {%- if v.get('tags') is iterable and v.get('tags') is not string and v.get('tags') | length > 0 %}
            tags: [{% for tag in v.get('tags') if tag %}'{{ tag }}'{% if not loop.last %}, {% endif %}{% endfor %}]
            {%- endif %}
            {%- for vk, vv in v.items() if vk not in ['description', 'tags'] %}
              {%- if vv is mapping %}
            {{ vk }}:
                {%- for subk, subv in vv.items() %}
              {{ subk }}: {{ subv }}
                {%- endfor %}
              {%- elif vv is iterable and vv is not string %}
            {{ vk }}:
                {%- for item in vv %}
              - {{ item }}
                {%- endfor %}
              {%- else %}
            {{ vk }}: {{ vv }}
              {%- endif %}
            {%- endfor %}
          {%- endif %}
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
              {% set config_keys = v.keys() | reject("in", ["description", "tags"]) | list %}
              {%- if config_keys | length == 0 and not v.get('description') and (not v.get('tags') or v.get('tags') | length == 0) %}
          - {{ k }}
              {%- else %}
          - {{ k }}:
                {%- if v.get('description') %}
                description: "{{ v.get('description') }}"
                {%- endif %}
                {%- if v.get('tags') is iterable and v.get('tags') is not string and v.get('tags') | length > 0 %}
                tags: [{% for tag in v.get('tags') if tag %}'{{ tag }}'{% if not loop.last %}, {% endif %}{% endfor %}]
                {%- endif %}
                {%- for vk, vv in v.items() if vk not in ['description', 'tags'] %}
                  {%- if vv is mapping %}
                {{ vk }}:
                    {%- for subk, subv in vv.items() %}
                  {{ subk }}: {{ subv }}
                    {%- endfor %}
                  {%- elif vv is iterable and vv is not string %}
                {{ vk }}:
                    {%- for item in vv %}
                   - {{ item }}
                    {%- endfor %}
                  {%- else %}
                {{ vk }}: {{ vv }}
                  {%- endif %}
                {%- endfor %}
              {%- endif %}
            {%- endfor %}
          {%- endfor %}
        {%- endif %}
      {%- endfor %}
    {%- endif %}
  {%- endfor %}
{%- endfor %}
{% endmacro %}
