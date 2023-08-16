INSERT INTO "/*Запрос показывает топ-3 продавцов в каждом месяце по сумме продаж и процент их продаж от общей месячной выручки */
/*К сожалению, были проблемы с CTE, так как база не давала её создать - поэтому запрос выглядит громоздко из-за подзапроса*/
select 
	employee_name,
	sale_month,
	sale_amount,
	round(month_sale,0) as month_revenue,
	round(sale_amount/month_sale*100,1) as month_percent
from (
	select 
		concat(e.first_name, ' ', e.last_name) as employee_name, 
		date_part('month', s.sale_date) as sale_month,
		round(sum(s.quantity * p.price),0) as sale_amount,
		sum(sum(s.quantity * p.price)) over (partition by date_part('month', s.sale_date)) as month_sale,
		row_number() over (partition by date_part('month', s.sale_date) order by sum(s.quantity * p.price) desc) as top_salesman
	from sales s 
	inner join employees e on e.employee_id = s.sales_person_id
	inner join products p on p.product_id = s.product_id
	group by date_part('month', s.sale_date), concat(e.first_name, ' ', e.last_name)
	) as sub_table
where top_salesman <= 3" (employee_name,sale_month,sale_amount,month_revenue,month_percent) VALUES
	 ('Dirk Stringer',9.0,468717163,2618930332,17.9),
	 ('Michel DeFrance',9.0,332744512,2618930332,12.7),
	 ('Albert Ringer',9.0,274425500,2618930332,10.5),
	 ('Dirk Stringer',10.0,1580325061,8358113699,18.9),
	 ('Michel DeFrance',10.0,1021875496,8358113699,12.2),
	 ('Albert Ringer',10.0,861544244,8358113699,10.3),
	 ('Dirk Stringer',11.0,1453636642,8031353738,18.1),
	 ('Michel DeFrance',11.0,998819836,8031353738,12.4),
	 ('Albert Ringer',11.0,804210270,8031353738,10.0),
	 ('Dirk Stringer',12.0,1422459067,7708189847,18.5);
INSERT INTO "/*Запрос показывает топ-3 продавцов в каждом месяце по сумме продаж и процент их продаж от общей месячной выручки */
/*К сожалению, были проблемы с CTE, так как база не давала её создать - поэтому запрос выглядит громоздко из-за подзапроса*/
select 
	employee_name,
	sale_month,
	sale_amount,
	round(month_sale,0) as month_revenue,
	round(sale_amount/month_sale*100,1) as month_percent
from (
	select 
		concat(e.first_name, ' ', e.last_name) as employee_name, 
		date_part('month', s.sale_date) as sale_month,
		round(sum(s.quantity * p.price),0) as sale_amount,
		sum(sum(s.quantity * p.price)) over (partition by date_part('month', s.sale_date)) as month_sale,
		row_number() over (partition by date_part('month', s.sale_date) order by sum(s.quantity * p.price) desc) as top_salesman
	from sales s 
	inner join employees e on e.employee_id = s.sales_person_id
	inner join products p on p.product_id = s.product_id
	group by date_part('month', s.sale_date), concat(e.first_name, ' ', e.last_name)
	) as sub_table
where top_salesman <= 3" (employee_name,sale_month,sale_amount,month_revenue,month_percent) VALUES
	 ('Michel DeFrance',12.0,906800990,7708189847,11.8),
	 ('Albert Ringer',12.0,760147928,7708189847,9.9);
