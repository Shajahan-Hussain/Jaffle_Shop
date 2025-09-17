{{ config(
    materialized='incremental',
    schema='stg',
    unique_key=["ID"],
    incremental_strategy='merge',
    pre_hook=[ 
        "{{ init_highwatermark('tbl_stg_customer') }}", 
        "{{ auditlog_pre('tbl_stg_customer') }}"
    ],
    post_hook=[ 
        "{{ update_highwatermark('lcf.highwatermark','tbl_stg_customer', 'CUSTOMER', 'UPDATED_AT') }}", 
        "{{ auditlog_post('tbl_stg_customer','CUSTOMER','UPDATED_AT') }}"
    ]
) }}

WITH highwatermark AS (
    SELECT *
    FROM {{ source('lcf', 'highwatermark') }}
    WHERE table_name = '{{ this.identifier }}'
),

ranked_customers AS (
    SELECT
        c.ID,
        c.NAME,
        c.UPDATED_AT,
        c.IS_DELETED,
        ROW_NUMBER() OVER (
            PARTITION BY c.ID
            ORDER BY c.UPDATED_AT DESC
        ) AS rn
    FROM {{ ref('raw_customer') }} c
    JOIN highwatermark h
      ON c.UPDATED_AT >= h.start_date AND c.UPDATED_AT < h.end_date
),

deduped AS (
    SELECT *
    FROM ranked_customers
    WHERE rn = 1
)

SELECT
    d.ID,
    d.NAME,
    d.UPDATED_AT,
    d.IS_DELETED,

    {% if is_incremental() %}
    CASE
        WHEN existing.ID IS NULL THEN CONVERT_TIMEZONE('Asia/Kolkata', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ
        ELSE existing.InsertDate
    END AS InsertDate,

    CASE
        WHEN existing.ID IS NULL
             OR d.NAME <> existing.NAME
             OR d.UPDATED_AT <> existing.UPDATED_AT
             OR d.IS_DELETED <> existing.IS_DELETED
        THEN CONVERT_TIMEZONE('Asia/Kolkata', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ
        ELSE existing.ActionDate
    END AS ActionDate,

    CASE
        WHEN existing.ID IS NULL THEN 'I'
        WHEN d.NAME <> existing.NAME
             OR d.UPDATED_AT <> existing.UPDATED_AT
             OR d.IS_DELETED <> existing.IS_DELETED THEN 'U'
        ELSE 'I'
    END AS ActionType

    {% else %}

    CONVERT_TIMEZONE('Asia/Kolkata', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS InsertDate,
    CONVERT_TIMEZONE('Asia/Kolkata', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS ActionDate,
    'I' AS ActionType

    {% endif %}

FROM deduped d

{% if is_incremental() %}
LEFT JOIN {{ this }} existing
    ON d.ID = existing.ID
{% else %}
-- No join required on full refresh
{% endif %}
