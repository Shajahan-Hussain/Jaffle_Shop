{{ config(
    materialized='incremental',
    schema='staging',
    unique_key=["ID"],
    incremental_strategy='merge',
    pre_hook=[ 
        "{{ init_highwatermark('stg_customers_test') }}", 
        "{{ auditlog_pre('stg_customers_test') }}"
    ],
    post_hook=[ "{{ update_highwatermark('lcf.highwatermark','stg_customers_test', 'raw_customers_test', 'UPDATED_AT') }}",
        "{{ auditlog_post('stg_customers_test','raw_customers_test','UPDATED_AT') }}"
        
    ]
) }}


WITH highwatermark AS (
    SELECT *
    FROM lcf.highwatermark
    WHERE table_name = '{{ this.identifier }}'
),

ranked_customers AS (
    SELECT
        c.ID,
        c.NAME,
        c.UPDATED_AT,
        c.IS_DELETED,
        c.Effective_Date,
        c.Create_Date,
        ROW_NUMBER() OVER (
            PARTITION BY c.ID
            ORDER BY c.UPDATED_AT DESC
        ) AS rn
    FROM {{ source('ecom', 'raw_customers_test') }} c
    JOIN highwatermark h
      ON c.UPDATED_AT > h.start_date AND c.UPDATED_AT <= h.end_date
),

deduped AS (
    SELECT *
    FROM ranked_customers
    WHERE rn = 1
    and is_deleted = false   -- exclude soft-deleted records
)

SELECT
    d.ID,
    d.NAME,
    d.UPDATED_AT,
    d.IS_DELETED,
    d.Effective_Date,
-- Compare only DATE part for late arriving logic
    CASE
        WHEN DATE(d.Effective_Date) < DATE(d.Create_Date)
        THEN 'Y'
        ELSE 'N'
    END AS IsLateArriving,

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
