-- Lab 7 Unit 3 
-- 1. Get number of monthly active customers.
with cte_monthly_active_users as 
(select date_format(payment_date, '%Y-%m') as month, count(distinct customer_id) as active_customers
from sakila.payment
group by month)
select month, active_customers from cte_monthly_active_users
order by month;

-- 2. Active users in the previous month.
with cte_active_users as 
(select date_format(payment_date,'%Y-%m') as month, count(distinct customer_id) as active_customers
from sakila.payment
group by month)
select month, active_customers, lag(active_customers) over (order by month) as active_customers_previous_month, (active_customers - lag(active_customers) over (order by month)) as difference from cte_active_users
order by month;

-- 3. Percentage change in the number of active customers.
with cte_active_users as 
(select date_format(payment_date,'%Y-%m') as month, count(distinct customer_id) as active_customers
from sakila.payment
group by month)
, cte_active_users_prev as 
(select month, active_customers, lag(active_customers) over (order by month) as active_customers_previous_month from cte_active_users)
select *,
	(active_customers - active_customers_previous_month) as difference,
    concat(round((active_customers - active_customers_previous_month)/active_customers*100), "%") as percent_difference
from cte_active_users_prev;

-- 4. Retained customers every month.

-- Step 1: Get distinct active customers per month
with cte_payments as (
    select
        customer_id as active_id,
        year(payment_date) as activity_year,
        month(payment_date) as activity_month
    from
        sakila.payment
)
select distinct
    active_id,
    activity_year,
    activity_month
from
    cte_payments
order by
    active_id, activity_year, activity_month;

--

with cte_payments as (
    select
        customer_id as active_id,
        year(payment_date) as activity_year,
        month(payment_date) as activity_month
    from
        sakila.payment
), recurrent_payments as (
    select distinct
        active_id,
        activity_year,
        activity_month
    from
        cte_payments
    order by
        active_id, activity_year, activity_month
)
select
    rec1.active_id,
    rec1.activity_year,
    rec1.activity_month,
    rec2.activity_month as previous_month
from
    recurrent_payments rec1
join
    recurrent_payments rec2
on
    rec1.activity_year = rec2.activity_year
    and rec1.activity_month = rec2.activity_month + 1
    and rec1.active_id = rec2.active_id
order by
    rec1.active_id, rec1.activity_year, rec1.activity_month;
