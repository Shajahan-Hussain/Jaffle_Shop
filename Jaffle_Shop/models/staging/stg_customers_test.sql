{{ config(
    materialized='incremental',
    schema='staging',
    unique_key=["ID"],
    incremental_strategy='merge',
    pre_hook=[ 
        "{{ init_highwatermark('tbl_stg_customers_test') }}", 
        "{{ auditlog_pre('tbl_stg_customers_test') }}"
    ],
    post_hook=[ "{{ update_highwatermark('lcf.highwatermark','tbl_stg_customers_test', 'raw_customers_test', 'UPDATED_AT') }}",
        "{{ auditlog_post('tbl_stg_customers_test','raw_customers_test','UPDATED_AT') }}"
        
    ]
) }}


WITH highwatermark AS (
    SELECT *
    FROM lcf.highwatermark
    WHERE table_name = '{{ this.identifier }}'
),

ranked_customers AS (
    SELECT
        c.ID AS customer_id,
        c.NAME AS customer_name,
        c.UPDATED_AT AS updated_at,
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
    AND is_deleted= false
)
SELECT
    d.customer_id,
    d.customer_name,
    d.updated_at,
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
        WHEN existing.customer_id IS NULL THEN CONVERT_TIMEZONE('Asia/Kolkata', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ
        ELSE existing.InsertDate
    END AS InsertDate,

    CASE
        WHEN existing.customer_id IS NULL
             OR d.customer_name <> existing.customer_name
             OR d.updated_at <> existing.updated_at
             OR d.IS_DELETED <> existing.IS_DELETED
        THEN CONVERT_TIMEZONE('Asia/Kolkata', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ
        ELSE existing.ActionDate
    END AS ActionDate,

    CASE
        WHEN existing.customer_id IS NULL THEN 'I'
        WHEN d.customer_name <> existing.customer_name
             OR d.updated_at <> existing.updated_at
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
    ON d.customr_id = existing.customer_id
{% else %}
-- No join required on full refresh
{% endif %}