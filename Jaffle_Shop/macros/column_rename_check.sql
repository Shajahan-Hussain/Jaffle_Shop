{% test column_rename_check(model, source_model, mappings) %}

{% set union_queries = [] %}

{% for src_col, tgt_col in mappings.items() %}
  {% set query %}
    SELECT
      'Mismatch in {{ src_col }} → {{ tgt_col }}' AS issue,
      s.{{ src_col }} AS source_value,
      t.{{ tgt_col }} AS target_value
    FROM {{ source_model }} s
    FULL OUTER JOIN {{ model }} t
      ON s.{{ src_col }} = t.{{ tgt_col }}
    WHERE s.{{ src_col }} IS DISTINCT FROM t.{{ tgt_col }}
  {% endset %}
  {% do union_queries.append(query) %}
{% endfor %}

WITH results AS (
  {{ union_queries | join("\nUNION ALL\n") }}
)
SELECT * FROM results

{% endtest %}
