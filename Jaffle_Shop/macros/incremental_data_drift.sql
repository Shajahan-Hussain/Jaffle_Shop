-- Author: Kirti sharma
-- Create Date: 09/11/2025
-- Description: Validates incremental target records are up-to-date with source data.

-- Change History
-- Version   Date         User                     Change
-- 0.1       09/11/2025   Kirti sharma      Initial version
-- 1.0       09/11/2025   Kirti Sharma      Final version


{% test incremental_data_drift(model, compare_model, unique_key, updated_at, src_updated_at) %}

with source as (
    select * from {{ compare_model }}
),
target as (
    select * from {{ model }}
),

mismatched as (
    select
        t.{{ unique_key }},
        t.{{ updated_at }} as target_updated,
        s.{{ src_updated_at }} as source_updated
    from target t
    join source s
      on t.{{ unique_key }} = s.{{ unique_key }}
    where t.{{ updated_at }} < s.{{ src_updated_at }}
)

select * from mismatched

{% endtest %}
