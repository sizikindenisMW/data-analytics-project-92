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

/*Первый отчет о десятке лучших продавцов. Таблица состоит из трех колонок - данных о продавце, 
суммарной выручке с проданных товаров и количестве проведенных сделок, и отсортирована по убыванию выручки:
name — имя и фамилия продавца
operations - количество проведенных сделок
income — суммарная выручка продавца за все время*/

select 
	concat(e.first_name, ' ', e.last_name) as name,
	count(s.sales_id) as operations,
	round(sum(p.price*s.quantity),0) as income
from employees e
inner join sales s on s.sales_person_id = e.employee_id 
inner join products p using(product_id)
group by concat(e.first_name, ' ', e.last_name)
order by sum(p.price*s.quantity) desc 
limit 10

/*Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. 
Таблица отсортирована по выручке по возрастанию.
name — имя и фамилия продавца
average_income — средняя выручка продавца за сделку с округлением до целого*/

with avg_income as (
	select 
	round(avg(p.price*s.quantity),0) as avg_income
	from sales s 
	inner join products p using(product_id)
)
select 
	concat(e.first_name, ' ', e.last_name) as name,
	round(avg(p.price*s.quantity),0) as income
from employees e
inner join sales s on s.sales_person_id = e.employee_id 
inner join products p using(product_id)
group by concat(e.first_name, ' ', e.last_name)
having round(avg(p.price*s.quantity),0) < (
	select *
	from avg_income
	)
order by income

/*Третий отчет содержит информацию о выручке по дням недели. Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку. 
Отсортируйте данные по порядковому номеру дня недели и name
name — имя и фамилия продавца
weekday — название дня недели на английском языке
income — суммарная выручка продавца в определенный день недели, округленная до целого числа*/

with cte_tab as (
	select 
		concat(e.first_name, ' ', e.last_name) as name,
		extract(ISODOW from s.sale_date) as dayweek,
		to_char(s.sale_date, 'Day') as weekday,
		(p.price*s.quantity) as income
	from employees e
	inner join sales s on s.sales_person_id = e.employee_id 
	inner join products p using(product_id)
	order by weekday
)
select
	name,
	weekday,
	round(sum(income),0) as income
from cte_tab
group by weekday, dayweek, name 
order by dayweek, name

-- Задания с шага №6
-- Задание №1
/*Само задание: количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+. 
Итоговая таблица должна быть отсортирована по возрастным группам и содержать следующие поля:
age_category - возрастная группа
count - количество человек в группе*/
with cte_tab as (
select 
	age,
	case 
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		when age > 40 then '40+'
	end as age_category
from customers c
)
select
	age_category,
	count(age) as count
from cte_tab
group by age_category
order by age_category

-- Задание №2
/*Во втором отчете предоставьте данные по количеству уникальных покупателей и выручке, которую они принесли. 
Сгруппируйте данные по дате, которая представлена в числовом виде ГОД-МЕСЯЦ. 
Итоговая таблица должна быть отсортирована по дате по возрастанию и содержать следующие поля:
date - дата в указанном формате
total_customers - количество покупателей
income - принесенная выручка*/
select 
	to_char(
		sale_date,
		'YYYY-MM'
	) date,
	count(distinct customer_id) as total_customers,
	round(sum(quantity*price),0) as income
from sales s 
inner join products p using(product_id)
group by date
order by date 

-- Задание №3
/*Третий отчет следует составить о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0). 
Итоговая таблица должна быть отсортирована по id покупателя. Таблица состоит из следующих полей:
customer - имя и фамилия покупателя
sale_date - дата покупки
seller - имя и фамилия продавца*/
--создаю CTE, с основными атрибутами, которые понадобятся для вывода целевого результата
--оконную функцию использую для окна покупателя, чтобы определить дату его первой покупки 

with cte_tab as (
select 
	c.customer_id,
	concat(c.first_name,' ',c.last_name) as customer,
	p.price,
	s.sale_date, 
	concat(e.first_name,' ',e.last_name) as seller,
	dense_rank() over (partition by concat(c.first_name,' ',c.last_name) order by s.sale_date) as rn
from customers c
inner join sales s using(customer_id)
inner join products p using(product_id)
inner join employees e on e.employee_id = s.sales_person_id
where price = 0
)
select 
	distinct customer,
	sale_date,
	seller
from cte_tab
where rn = 1
