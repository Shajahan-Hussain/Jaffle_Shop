{{ config(
    materialized='incremental',
    schema='marts',
    unique_key=["customer_id"],
    incremental_strategy='merge'
) }}

WITH src AS (
    SELECT *
    FROM {{ ref('tbl_stg_customers') }}
)

SELECT
    customer_id,
    customer_name,
    updated_at,
    is_deleted,
    effective_date,

    -- Always use current timestamp for InsertDate in marts
    CONVERT_TIMEZONE('Asia/Kolkata', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS InsertDate

FROM src
