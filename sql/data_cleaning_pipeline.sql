-- =========================================
-- PHASE 1: Profiling and measuring the mess
-- =========================================

select * 
from C01_l01_ecommerce_retail_data_table
limit 20

select customer_segment,count(customer_segment) count
from C01_l01_ecommerce_retail_data_table
group by customer_segment
order by count(customer_segment) desc

select payment_method,count(payment_method) as count
from C01_l01_ecommerce_retail_data_table
group by payment_method
order by count(payment_method) desc

select distinct(hour_of_day)
from C01_l01_ecommerce_retail_data_table

--count nulls

select
  count(*) as total_rows,
  sum(case when customer_segment is null then 1 else 0 end) as null_customer_segment,
  sum(case when order_amount_old is null then 1 else 0 end) as null_order_amount,
  sum(case when cost is null then 1 else 0 end) as null_cost,
  sum(case when is_return is null then 1 else 0 end) as null_is_return,
  sum(case when payment_method is null then 1 else 0 end) as null_payment_method,
  sum(case when hour_of_day is null then 1 else 0 end) as null_hour_of_day
from C01_l01_ecommerce_retail_data_table



-- =========================================
-- PHASE 2: Parsing and typing (silver layer)
-- =========================================

--multi-format date parsing for legacy data using COALESCE + try_strptime.

create or replace temp view silver_parsed as
select
  row_id,
  lower(trim(customer_segment)) as customer_segment_raw,
  coalesce(
    try_strptime(replace(date,'.','-'),'%Y-%m-%d'),
    try_strptime(replace(date,'.','-'),'%d-%m-%Y')
  ) as parsed_date,
  try_cast(order_amount_old as DOUBLE) as order_amount_old,
  try_cast(cost as DOUBLE) as cost,
  try_cast(is_return as INTEGER) as is_return,
  payment_method,
  try_cast(hour_of_day as INTEGER) as hour_of_day,
from C01_l01_ecommerce_retail_data_table;
  
  --check
  select count(*) as total_rows,
  sum(case when parsed_date is null then 1 else 0 end) as date_parse_failure
  from silver_parsed



--silver normalised

create or replace temp view silver_normalised as
select
  row_id,
  parsed_date as date,
  case
    when customer_segment_raw = 'standrad' then 'standard'
    when customer_segment_raw = 'platnum' then 'platinum'
    when customer_segment_raw = 'premuim' then 'premium'
    else customer_segment_raw
  end as customer_segment,
  order_amount_old,
  cost,
  is_return,
  payment_method,
  hour_of_day
from silver_parsed;


-- =========================================
-- PHASE 3: Business rules and filtering
-- =========================================
  

create or replace temp view silver_filtered as
select * 
from silver_normalised
where
  date is not null and
  order_amount_old is not null and 
  order_amount_old>=5 and
  cost >0;

--number of distinct rows
select count(*) as distinct_rows
from (
  select distinct row_id,	date,	customer_segment,	order_amount_old,	cost,	is_return,	payment_method,	hour_of_day
  from silver_filtered
)



-- =========================================
-- PHASE 4: Deduplication and gold layer
-- =========================================

-- deduplicate on full business key to avoid merging different orders.
create or replace temp view clean_table as
select 
  distinct row_id,date,customer_segment,order_amount_old,cost,is_return,payment_method,hour_of_day
from silver_filtered;









