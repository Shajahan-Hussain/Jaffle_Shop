-- Author: Kirti sharma
-- Create Date: 09/11/2025
-- Description: Validates max timestamp consistency between source and target.

-- Change History
-- Version   Date         User                     Change
-- 0.1       09/11/2025   Kirti sharma      Initial version
-- 1.0       09/11/2025   Kirti Sharma      Final version

{% test incremental_freshness(model, compare_model, column_name) %}
with source as (
    select max({{ column_name }}) as max_col from {{ compare_model }}
),
target as (
    select max({{ column_name }}) as max_col_tgt from {{ model }}
)
select *
from source s
join target t on 1=1
where t.max_col_tgt < s.max_col
{% endtest %}