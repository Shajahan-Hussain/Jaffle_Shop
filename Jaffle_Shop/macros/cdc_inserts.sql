{% test cdc_inserts(model, source_model, staging_model) %}
 
with raw_inserts as (
    select id, updated_at
    from {{ source_model }}
    where is_deleted = false
),
 
missing_in_staging as (
    select r.id, r.updated_at
    from raw_inserts r
    left join {{ staging_model }} s
        on r.id = s.customer_id
    where s.customer_id is null
)
 
select * from missing_in_staging

{% endtest %}