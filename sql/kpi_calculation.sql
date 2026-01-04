--AOV
create or replace temp view kpi_1 as
select
  'AOV' as kpi_name,
  cast(round(avg(order_amount_old),2) as VARCHAR) as kpi_value,
  cast(null as VARCHAR) as kpi_key
from clean_table;



--Gross margin %
create or replace temp view kpi_2 as
select 
  'Gross margin %' as kpi_name,
  cast(round(sum(order_amount_old-cost)/sum(order_amount_old),4)*100 as VARCHAR) as kpi_value,
  cast(null as VARCHAR) as kpi_key
from clean_table;



--Return rate
create or replace temp view kpi_3 as
select
  'return rate' as kpi_name,
  round(sum(is_return)/count(order_amount_old)*100,2) as kpi_value,
  cast(null as VARCHAR) as kpi_key
  from clean_table;



--median order amunt
create or replace temp view kpi_4 as
select
  'median order' as kpi_name,
  round(median(order_amount_old),2) as kpi_value,
  cast(null as VARCHAR) as kpi_key
  from clean_table;




--return rate by payment method
create or replace temp view kpi_5 as
select 
  'return rate by payment method' as kpi_name,
  round(sum(is_return)/count(order_amount_old)*100,2) as kpi_value,
  payment_method as kpi_key
  from clean_table
  group by payment_method;



--High-Value Segment GMV Share
create or replace temp view kpi_6 as
select 
  'High value GMV share' as kpi_name,
  round(count(customer_segment)/(select count(*) from clean_table),4)*100 as kpi_value,
  customer_segment as kpi_key
  from clean_table
  where customer_segment!= 'standard'
  group by customer_segment;


--Below target margin rate
create or replace temp view kpi_7 as 
  with cte_profit(customer_segment,profit) as(
    select 
      customer_segment,
       (order_amount_old-cost)/order_amount_old*100
    from clean_table
    
  )
  select 
    'Below target margin rate' as kpi_name,
    round(sum(case 
      when customer_segment ='standard' and profit <40 then 1 
      when customer_segment ='premium' and profit <30 then 1 
      when customer_segment ='platinum' and profit <=25 then 1 
      else 0
      end )/count(*),4)*100 as kpi_value,
    cast(null as VARCHAR) as kpi_key
    from cte_profit;

--Top GMV month
create or replace temp view kpi_8 as
select 
  'Top GMV month' as kpi_name,
   x as kpi_value,
   cast(null as VARCHAR) as kpi_key
  from (
    select date_trunc('month',date) as x,
    sum(order_amount_old) 
    from clean_table
    group by x
    order by sum(order_amount_old) desc
  )t
limit 1;

--Latest Month-on-Month (MoM) GMV Growth %
create or replace temp view kpi_9 as
  with cte_lag(month_key,gmv_current, gmv_prev) as(
    select month(date), 
      sum(order_amount_old) as total,
      lag(total,1) over(order by month(date))
    from clean_table
    group by month(date)
  )
  select 
    'Latest Month-on-Month (MoM) GMV Growth %' as kpi_name,
    (gmv_current-gmv_prev)/gmv_prev*100 as kpi_value,
    cast(null as VARCHAR) as kpi_key
  from cte_lag
  order by month_key desc
  limit 1;

--Max Month-to-Month Payment-Method Share Shift (pp)

create or replace temp view kpi_10 as
with cte_count as (
  select 
    month(date) as month_key,
    payment_method,
    count(*) as n
  from clean_table
  group by month_key,payment_method
  order by month_key desc
),
cte_total as(
  select 
    month_key,
    sum(n) as total
  from cte_count
  group by month_key
),
cte_share as(
  select 
    c.month_key,
    payment_method,
    c.n/total*100 as share
  from cte_count c
  left join cte_total t
  on c.month_key=t.month_key
),
cte_lag as(
  select 
    month_key,
    payment_method,
    share as latest_share,
    lag(share,1) over(partition by payment_method order by month_key ) prev_share
  from cte_share
),
cte_diff as(
  select
    month_key,
    payment_method,
    abs(latest_share-prev_share) as share_diff
    from cte_lag
    order by share_diff desc
)
  select 
  'Max Month-to-Month Payment-Method Share Shift (pp)' as kpi_name,
   share_diff as kpi_value,
   cast(null as VARCHAR) as kpi_key
  from cte_diff
  limit 1;



--KPI results table 

create or replace table kpi_results as
select * from kpi_1
union all select * from kpi_2
union all select * from kpi_3
union all select * from kpi_4
union all select * from kpi_5
union all select * from kpi_6
union all select * from kpi_7
union all select * from kpi_8
union all select * from kpi_9
union all select * from kpi_10;

select * from kpi_results;



