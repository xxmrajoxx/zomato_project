select * from customers
select * from deliveries
select * from orders
select * from restaurant
select * from riders;


alter table orders
add constraint fk_customer
foreign key(customer_id)
references customer(customer_id)

alter table orders
add constraints fk_delivery
foreign key (order_id)
references deliveries(order_id)

alter table deliveries
add constraint fk_riders
foreign key (rider_id)
references riders(rider_id)

alter table orders
add constraint fk_resturants
foreign key (resturant_id)
references resturants(resturant_id)


/*Q1. Top 5 Most Frequently Ordered Dishes
 Question:
 Write a query to find the top 5 most frequently 
 ordered dishes by the customer "Arjun Mehta" in
 the last 2 year.
*/

select * from customers --customer_id
select * from deliveries
select * from orders -- customer_id
select * from restaurant
select * from riders

select * from
(
select 
	c.customer_name,
	order_item,
	count(*) as amount,
	dense_rank() over(order by count(*) desc) as rank
from orders as o
join customers as c
on o.customer_id = c.customer_id
where customer_name ='Arjun Mehta'
and 
order_date >= (CURRENT_DATE - INTERVAL '2 Year')
group by 1,2
order by 3 desc
) as t1 
where rank <= 5
/*
Q2. Popular Time Slots
 Question:
 Identify the time slots during which the most
 orders are placed, based on 2-hour intervals.
*/

select *,
	case
		WHEN x = x then x
		else x
		end

SELECT 
	CASE
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
	END as time_slot,
	COUNT(*) AS order_count
FROM ORDERS 
group by time_slot
order by order_count desc

SELECT 00:59:59AM -- 0
SELECT 01:59:59AM -- 1

select 
	FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 as start_time,
	FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 + 2 as end_time,
	count(*) as total_orders
from orders
group by 1,2
order by 3 desc;


/*Q3. Order Value Analysis
 Question:
 Find the average order value (AOV) per customer who has 
 placed more than 750 orders.
 Return: customer_name, aov (average order value)
 */

select * from customers --customer_id
select * from deliveries
select * from orders -- customer_id
select * from restaurant
select * from riders


select
	customer_name,
	count(*),
	avg(total_amount) as ADV
from orders as o
join customers as c
on o.customer_id = c.customer_id
group by 1
having count(order_id) >750;



/* Q4. High-Value Customers
 Question:
 List the customers who have spent more 
 than 100K in total on food orders.
 Return: customer_name, customer_id.
 */

select * from customers --customer_id
select * from deliveries
select * from orders -- customer_id
select * from restaurant
select * from riders


select 
	c.customer_name,
	c.customer_id,
	sum(total_amount) as total_spent
from orders as o
join customers as c
on o.customer_id = c.customer_id
group by 1,2
having sum(o.total_amount) >100000;


/* Q5. Orders Without Delivery
 Question:
 Write a query to find orders that were placed but not delivered.
 Return: restaurant_name, city, and the number of not delivered orders
 */

select * from customers --customer_id
select * from deliveries -- order_id,
select * from orders -- customer_id, restaurant_id, order_id
select * from restaurant --restaurant_id
select * from riders

select 
	r.restaurant_name,
	r.city,
	count(*) as number_of_orders_not_deliveried
from orders as o
left join deliveries as d
on d.order_id = o.order_id
join restaurant as r
on r.restaurant_id = o.restaurant_id
--where order_status = 'Not Fulfilled'
where delivery_status is null
group by 1,2


/*Q6. Restaurant Revenue Ranking
Question:
 Rank restaurants by their total revenue from the last year.
 Return: restaurant_name, total_revenue,
 and their rank within their city.
 */

select * from customers --customer_id
select * from deliveries -- order_id,
select * from orders -- customer_id, restaurant_id, order_id
select * from restaurant --restaurant_id
select * from riders

with cte as
(
	select 
		r.city,
		r.restaurant_name,
		sum(total_amount) as total_revenue,
		DENSE_RANK() over(partition by r.city order by sum(total_amount) desc) as rank
	from orders as o
	join restaurant as r
	on o.restaurant_id = r.restaurant_id
	--where EXTRACT(year from order_date) > '2022'
	where order_date >= (CURRENT_DATE - INTERVAL '2 Year')
	group by 1,2
) 
select * from cte
where rank = 1


/* Q7. Most Popular Dish by City
 Question:
 Identify the most popular dish in each city based on 
 the number of orders
*/ 

select * from customers --customer_id
select * from deliveries -- order_id,
select * from orders -- customer_id, restaurant_id, order_id
select * from restaurant --restaurant_id
select * from riders

select * from
(select 
	r.city,
	o.order_item,
	count(o.order_id),
	dense_rank() over(partition by city order by count(order_id) desc) as rank
from orders as o
join restaurant as r
on o.restaurant_id = r.restaurant_id
group by 1,2
) as t1
where rank = 1

select distinct(city) from restaurant

select * 
from orders as o
join restaurant as r
on o.restaurant_id = r.restaurant_id
where r.city = 'Amritsar'

/* Q8. Customer Churn
 Question:
 Find customers who haven’t placed an order in 2024 but did in 2023
 */

select * from customers --customer_id
select * from deliveries -- order_id,
select * from orders -- customer_id, restaurant_id, order_id
select * from restaurant --restaurant_id
select * from riders

WITH CTE_2023 AS
(select 
	customer_name,
	c.customer_id,
	count(c.customer_id) as orders_in_2023
from orders as o
join customers as c
on o.customer_id = c.customer_id
where EXTRACT(year from order_date) = '2023'
group by 1,2
),
CTE_2024 AS 
(
select 
	customer_name,
	count(c.customer_id) as orders_in_2024
from orders as o
join customers as c
on o.customer_id = c.customer_id
where EXTRACT(year from order_date) = '2024'
group by 1
)
SELECT
	cte_2023.customer_name,
	customer_id,
	orders_in_2023,
	orders_in_2024
from cte_2023 
left join cte_2024
on cte_2023.customer_name = cte_2024.customer_name
where orders_in_2024 is null;


/* Q9. Cancellation Rate Comparison
 Question:
 Calculate and compare the order 
 cancellation rate for each restaurant between the current year
 and the previous year*/
 
select distinct(order_status) from orders
select * from deliveries -- 
select * from restaurant

WITH Completed_2023 as
(
select 
	restaurant_name,
	r.restaurant_id,
	count(order_status) as Completed_2023
from orders as o
left join deliveries as d
on o.order_id = d.order_id
join restaurant as r
on o.restaurant_id = r.restaurant_id
	where order_status = 'Completed'
	and EXTRACT (Year from order_date) = '2023'
group by 1,2
),
Not_Fulfiled_2023 as
(
select 
	restaurant_name,
	count(order_status) as Not_Fulfilled_2023
from orders as o
left join deliveries as d
on o.order_id = d.order_id
join restaurant as r
on o.restaurant_id = r.restaurant_id
	where order_status = 'Not Fulfilled'
	and EXTRACT (Year from order_date) = '2023'
group by 1
),
Completed_2024 as
(
select 
	restaurant_name,
	count(order_status) as Completed_2024
from orders as o
left join deliveries as d
on o.order_id = d.order_id
join restaurant as r
on o.restaurant_id = r.restaurant_id
	where order_status = 'Completed'
	and EXTRACT (Year from order_date) = '2024'
group by 1
),
Not_Fulfiled_2024 as
(
select 
	restaurant_name,
	count(order_status) as Not_Fulfilled_2024
from orders as o
left join deliveries as d
on o.order_id = d.order_id
join restaurant as r
on o.restaurant_id = r.restaurant_id
	where order_status = 'Not Fulfilled'
	and EXTRACT (Year from order_date) = '2024'
group by 1
)
select 
	Completed_2023.Restaurant_name,
	Completed_2023.restaurant_id,
    COALESCE(Completed_2023.Completed_2023, 0) AS Completed_2023,
    COALESCE(Not_Fulfiled_2023.Not_Fulfilled_2023, 0) AS Not_Fulfilled_2023,
    COALESCE(Not_Fulfiled_2023.Not_Fulfilled_2023, 0)::NUMERIC / COALESCE(Completed_2023.Completed_2023, 0)::NUMERIC  as cancellation_rate_2023,
    COALESCE(Completed_2024.Completed_2024, 0) AS Completed_2024,
    COALESCE(Not_Fulfiled_2024.Not_Fulfilled_2024, 0) AS Not_Fulfilled_2024,
   COALESCE(Not_Fulfiled_2024.Not_Fulfilled_2024, 0)::NUMERIC / COALESCE(Completed_2024.Completed_2024, 0)::NUMERIC  as cancellation_rate_2024
from Completed_2023 
left join Not_Fulfiled_2023
on Completed_2023.restaurant_name = Not_Fulfiled_2023.restaurant_name
left join Not_Fulfiled_2024
on Completed_2023.restaurant_name = Not_Fulfiled_2024.restaurant_name
left join Completed_2024 
on Completed_2023.restaurant_name = Completed_2024.restaurant_name
order by 3 desc

select 
restaurant_id,
total_orders,
not_delivered,
not_delivered::NUMERIC/total_orders::NUMERIC * 100 as cancalation_rate
from
(
select 
	o.restaurant_id,
	count(o.order_id) as total_orders,
	count(case when d.delivery_status is NULL then 1 END) as not_delivered
from orders as o
left join deliveries as d
on o.order_id = d.order_id
where extract(year from o.order_date) = 2023
group by 1
order by 2 desc
) as t1


/* Q10. Rider Average Delivery Time
 Question:
 Determine each rider's average delivery time.
*/


select * from customers --customer_id
select * from deliveries -- order_id,
select * from orders -- customer_id, restaurant_id, order_id
select * from restaurant --restaurant_id
select * from riders -- rider_id

SELECT 
	rider_name,
	r.rider_id,
	avg(delivery_time) as avg_delivery_time
FROM deliveries as d
join riders as r
on d.rider_id = r.rider_id
where delivery_time is not null
group by 1,2

/*Q11. Monthly Restaurant Growth Ratio
 Question:
 Calculate each restaurant's growth ratio based
 on the total number of delivered orders since its
 joining.
 */


current month - last month / last month

with cte as
(
select 
	r.restaurant_id,
	TO_CHAR(order_date, 'mm-yy') as month,
	count(o.order_id) as current,
	lag(count(o.order_id),1) over(partition by r.restaurant_id order by TO_CHAR(order_date, 'mm-yy')) as previous
from orders as o
join restaurant as r
on o.restaurant_id = r.restaurant_id
join deliveries as d
on o.order_id = d.order_id
where d.delivery_status = 'Delivered'
group by 1,2
order by 1,2
) select
restaurant_id,
month, 
current,
previous,
(current - previous)::numeric/previous::numeric * 100
from cte



/*
 -- Q12. Customer Segmentation
 Question:
 Segment customers into 'Gold' or 'Silver' groups
 based on their total spending compared to the
average order value (AOV). If a customer's
total spending exceeds the AOV, label them as
 'Gold'; otherwise, label them as 'Silver'.
 Return: The total number of orders and total revenue for each segment
*/

with cte as
(
select 
	CUSTOMER_ID,
	sum(total_amount) as total_amount,
	count(orders) as total_orders,
	CASE
		WHEN sum(total_amount) > avg(total_amount) THEN 'gold'
		ELSE 'silver'
		END AS CATEGORY
	--customer_id,
	--sum(total_amount) as total_sales,
	--avg(total_amount) as AOV
from orders
where order_status = 'Completed'
group by 1
)
select 
	category,
	sum(total_amount),
	sum(total_orders)
from cte
group by 1

/*Q13. Rider Monthly Earnings
 Question:
 Calculate each rider's total monthly earnings, 
 assuming they earn 8% of the order amount.
*/

select * from customers --customer_id
select * from deliveries -- order_id,
select * from orders -- customer_id, restaurant_id, order_id
select * from restaurant --restaurant_id
select * from riders -- rider_id

select 
	rider_name,
	r.rider_id,
	TO_CHAR(order_date, 'MM-YY') as months,
	sum(total_amount)*0.08 as total_earnings
from orders as o
left join deliveries as d
on o.order_id = d.order_id
join riders as r
on r.rider_id = d.rider_id
where delivery_status = 'Delivered'
group by 1,2,3
order by 2,3 asc;


/* Q14. Rider Ratings Analysis
 Question:
 Find the number of 5-star, 4-star, and 3-star ratings each rider has.
 Riders receive ratings based on delivery time:
 ● 5-star: Delivered in less than 15 minutes
 ● 4-star: Delivered between 15 and 20 minutes
 ● 3-star: Delivered after 20 minutes
 */


select * from customers --customer_id
select * from deliveries -- order_id,
select * from orders -- customer_id, restaurant_id, order_id
select * from restaurant --restaurant_id
select * from riders -- rider_id

select * from deliveries -- order_id,
select * from orders 

with cte as
	(
	Select 
		rider_id,
		delivery_took_time,
			CASE
				WHEN delivery_took_time < 15 THEN '5-star'
				WHEN delivery_took_time  Between 15 and 20 THEN '4-star' 
				ELSE '3-star'
		END as stars
	from
	(
		select 
			o.order_id,
			o.order_time,
			d.delivery_time,
			EXTRACT(EPOCH FROM (d.delivery_time - o.order_time +
			CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
			ELSE INTERVAL '0 day'END
			))/60 AS delivery_took_time,
			d.rider_id
		from orders as o 
		join deliveries as d
		on o.order_id = d.order_id
		where delivery_status = 'Delivered'
	) as t1
	group by 1 ,2 
	) 
select 
	rider_id,
	stars,
	count(stars)
	from cte
	group by 1,2
	order by 1



/*
Q15. Order Frequency by Day
 Question:
 Analyze order frequency per day of
 the week and identify the peak day for each restaurant.
*/

select * from 
(
select 
	r.restaurant_name,
	--o.order_date,
	TO_CHAR(o.order_date, 'Day') as day,
	count(o.order_id),
	rank() over(partition by r.restaurant_name order by count(o.order_id) desc) as rank
from orders as o
join restaurant as r
on o.restaurant_id = r.restaurant_id
group by 1,2
order by 1,3 desc
) as t1 
where rank = 1


/*
 Q16. Customer Lifetime Value (CLV)
 Question:
 Calculate the total revenue generated 
 by each customer over all their orders
*/

select * from customers --customer_id
select * from deliveries -- order_id,
select * from orders -- customer_id, restaurant_id, order_id
select * from restaurant --restaurant_id
select * from riders -- rider_id

select 
	customer_name, 
	--order_item,
	sum(total_amount) as CLV
from orders as o
join customers as c
on o.customer_id = c.customer_id
group by 1 


/*
 Q17. Monthly Sales Trends
 Question:
 Identify sales trends by comparing each month's 
 total sales to the previous month
*/

select 
	EXTRACT(month from order_date) as month,
	EXTRACT(year from order_date) as year,
	sum(total_amount) as current_month_sales,
	lag(sum(total_amount),1) over(order by EXTRACT(year from order_date), EXTRACT(month from order_date)) as previous_month_sales
from orders
group by 1,2

lag(count(o.order_id),1) over(partition by r.restaurant_id order
by TO_CHAR(order_date, 'mm-yy')) as previous


/*
 Q18. Rider Efficiency
Question:
 Evaluate rider efficiency by determining average
 delivery times and identifying those with the
 lowest and highest averages
 */

with cte as
(
	select 
		--*,
		d.rider_id as rider_id,
		EXTRACT(EPOCH from delivery_time - order_time 
			+ case when delivery_time < order_time THEN 
			INTERVAL '1 day' ELSE INTERVAL '0 day' END)/60 as time_it_took_deliveried
	--	order_time,
	--	delivery_time
	from orders as o
	join deliveries as d
	on o.order_id = d.order_id
	WHERE D.delivery_status = 'Delivered'
), cte2 as 
(
	select 
		rider_id,
		avg(time_it_took_deliveried) as average
	from cte
	group by 1
)
select
max(average),
min(average)
from  cte2

/*
 Q19. Order Item Popularity
 Question:
 Track the popularity of specific order 
 items over time and identify seasonal demand spikes.
 */

with cte as
(
select 
	order_item,
	extract(month from order_date) as month,
 	CASE
	 	WHEN extract(month from order_date) in (1,2,3) THEN 'autumn' 
		WHEN extract(month from order_date) in (4,5,6) THEN 'winter'
		WHEN extract(month from order_date) in (7,8,9) THEN 'spring'
		ELSE 'summer' 
		end as season,
	count(order_id) as number_of_orders
from orders
group by 1,2,3
)
select 
	order_item,
	number_of_orders,
	season,
	rank() over(partition by order_item order by number_of_orders desc )
from cte

/*
 Q20. City Revenue Ranking
 Question:
 Rank each city based on the total revenue for the last year (2023)
*/

select * from customers --customer_id
select * from deliveries -- order_id,
select * from orders -- customer_id, restaurant_id, order_id
select * from restaurant --restaurant_id
select * from riders -- rider_id

select 
	r.city,
	sum(o.total_amount) as total_sales,
	dense_rank() over(order by sum(o.total_amount) desc)

from orders as o
join restaurant as r
on o.restaurant_id = r.restaurant_id
where EXTRACT(year from order_date) = 2023
group by 1



