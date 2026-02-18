-- Author: Harika
-- Create Date: 15/10/2025
-- Description: Ensures aggregated cost values match after scaling adjustment.

-- Change History
-- Version   Date         User                     Change
-- 0.1       15/10/2025   Harika Dharmapuri      Initial version
-- 0.2       06/02/2026   Harika Dharmapuri      updated the hardcoded values
-- 1.0       06/02/2026   Harika Dharmapuri      Final version

{% test supply_cost_check( 
      model, 
      raw_table, 
      key_column, 
      key_col_model, 
      raw_cost_col, 
      staging_cost_col, 
      scale_factor, 
      tolerance 

) %} 

with raw_agg as ( 
    select  
        {{ key_column }} as key_col, 
        sum({{ raw_cost_col }}) as raw_total_cost 
    from {{ raw_table }} 
    group by {{ key_column }} 
), 

stg_agg as ( 
    select  
        {{ key_col_model }} as key_col, 
        sum({{ staging_cost_col }} * {{ scale_factor }}) as stg_total_cost 
    from {{ model }} 
    group by {{ key_col_model }} 
), 

 

compare as ( 
    select 
        r.key_col, 
        r.raw_total_cost, 
        s.stg_total_cost, 
        abs(r.raw_total_cost - s.stg_total_cost) as diff 
    from raw_agg r 
    inner join stg_agg s 
        on r.key_col = s.key_col 
    where abs(r.raw_total_cost - s.stg_total_cost) > {{ tolerance }} 

) 

select * 
from compare 

{% endtest %} 

 