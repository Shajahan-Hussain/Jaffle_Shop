/*this test returns a row (and fails) if today’s counts don’t match.
Pass → today’s rows match between stg_orders and orders.
Fail → something in the incremental load missed inserts for today.
*/
{% test incremental_rowcount_today(model, compare_model, date_column) %}

with src as (
  select * from {{ compare_model }}
  where {{ date_column }}::date = current_date
),
tgt as (
  select * from {{ model }}
  where {{ date_column }}::date = current_date
),
diff as (
  select
    (select count(*) from src) as src_cnt,
    (select count(*) from tgt) as tgt_cnt
)
select * from diff
where src_cnt <> tgt_cnt

{% endtest %}
