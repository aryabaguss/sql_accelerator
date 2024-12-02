select * from department_employee de 

-- Session 1 --

-- 1 --

select distinct 
	de.employee_id,
	concat(e.first_name,' ',e.last_name) as fullname,
	e.gender,
	d.dept_name ,
	max(s.amount) as new_salary
from employee e 
join department_employee de on de.employee_id  = e.id
join department d on d.id = de.department_id 
join salary s on s.employee_id = e.id 
where de.to_date = '9999-01-01'
group by de.employee_id,e.first_name ,e.last_name ,e.gender,d.dept_name 
order by new_salary desc limit 50

-- 2 -- avg_salary
select * from salary s 

select * from department_employee de 

select
		employee_id,
		max(amount) as new_salary,
		s.to_date
	from salary s 
	where s.to_date = '9999-01-01'
	group by s.employee_id,s.to_date 
	
with latest as(
	select
		employee_id,
		max(amount) as new_salary
	from salary s 
	where s.to_date = '9999-01-01'
	group by s.employee_id
),
temp as (
	select 
		count(distinct de.employee_id) as total_employee,
		count(distinct de.department_id) as total_department,
		sum(new_salary) / count(de.employee_id) as avg_salary
	from department_employee de 
	join latest l on l.employee_id = de.employee_id 
	where de.to_date = '9999-01-01'
)
select * from temp
	
-- 3 --
select * from title t 
where t.to_date = '9999-01-01'

select * from department_manager dm 
where dm.to_date = '9999-01-01'

select d.dept_name ,count(de.employee_id)
from department_employee de 
join employee e on e.id = de.employee_id 
join department_manager dm on dm.employee_id = e.id 
join department d on d.id = dm.department_id 
group by dm.department_id, d.dept_name 

with manager as(
	select 
		d.id as dept_id,
		d.dept_name,
		concat(e.first_name,' ',e.last_name) as fullname
	from department_manager dm 
	join employee e on e.id = dm.employee_id
	join department d on d.id = dm.department_id
	where dm.to_date = '9999-01-01'
),
total_emp as (
	select
		de.department_id,
		m.dept_name,
		m.fullname,
		count(de.employee_id) as total_employee
	from department_employee de 
	join manager m on m.dept_id = de.department_id
	where de.to_date = '9999-01-01'
	group by de.department_id,m.dept_name,m.fullname
	order by total_employee desc 
)
select
	dept_name,
	fullname,
	total_employee
from total_emp
	
-- 4 --
select 
	d.dept_name,
	e.gender,
	count(*) as total_employee
from department_employee de 
join employee e on e.id = de.employee_id 
join department d on d.id  = de.department_id 
where de.to_date = '9999-01-01'
group by d.dept_name,e.gender 
order by d.dept_name,e.gender 

-- 5 --
select 
	d.dept_name,
	count(case when e.gender = 'F' then 1 end) as woman_emp,
	count(*) as total_employee
from department_employee de 
join employee e on e.id = de.employee_id 
join department d on d.id  = de.department_id 
where de.to_date = '9999-01-01'
group by d.dept_name

with temp as(
	select 
		d.dept_name,
		count(case when e.gender = 'F' then 1 end) as woman_emp,
		count(*) as total_employee
	from department_employee de 
	join employee e on e.id = de.employee_id 
	join department d on d.id  = de.department_id 
	where de.to_date = '9999-01-01'
	group by d.dept_name
)
select
	dept_name,
	woman_emp,
	total_employee,
	(woman_emp::float / total_employee::float) as rate
from temp
order by rate desc 
	

-- 6 --
with manager as(
	select distinct 
		dm.employee_id,
		t.title,
		s.amount as new_salary,
		e.gender,
		e.hire_date,
		d.id as dept_id,
		d.dept_name,
		concat(e.first_name,' ',e.last_name) as fullname
	from department_manager dm 
	join employee e on e.id = dm.employee_id
	join department d on d.id = dm.department_id
	join title t on t.employee_id = e.id
	join salary s on s.employee_id = e.id
	where dm.to_date = '9999-01-01' and t.to_date = '9999-01-01' and s.to_date = '9999-01-01'
),
total_emp as (
	select
		m.fullname,
		m.title,
		m.new_salary,
		m.gender,
		m.hire_date,
		m.dept_name,
		count(de.employee_id) as total_employee
	from department_employee de 
	join manager m on m.dept_id = de.department_id
	where de.to_date = '9999-01-01'
	group by 1,2,3,4,5,6
	order by total_employee desc 
	limit 1
)
select * from total_emp

-- 7 -- 
select 
	de.employee_id,
	concat(e.first_name,' ',e.last_name) as fullname,
	e.gender,
	e.hire_date,
	t.title ,
	s.amount ,
	d.dept_name 
from employee e 
join department_employee de on de.employee_id  = e.id 
join title t on t.employee_id = e.id 
join salary s on s.employee_id = e.id 
join department d on d.id  = de.department_id 
where de.to_date = '9999-01-01' and t.to_date = '9999-01-01' and s.to_date = '9999-01-01'
order by e.hire_date asc ,fullname
limit 10

-- 8 --
select 
	t.title,
	round(sum(s.amount) / count(s.employee_id),2) as avg
from salary s 
join title t on t.employee_id = s.employee_id 
where t.to_date = '9999-01-01' and s.to_date = '9999-01-01' and t.title  != 'Manager'
group by 1
order by avg desc 

select 
	t.title,
	round(sum(s.amount) / count(s.employee_id),2) as avg
from salary s 
join employee e on e.id = s.employee_id 
join title t on t.employee_id = e.id 
join department_employee de on de.employee_id = e.id 
where t.to_date = '9999-01-01' and s.to_date = '9999-01-01' and de.to_date = '9999-01-01' and t.title  != 'Manager'
group by 1
order by avg desc 

-- 9 --
select 
	e.gender,
	count(e.id),
	round(avg(s.amount),2) as avg_salary
from employee e 
join department_employee de on de.employee_id = e.id 
join salary s on s.employee_id = e.id 
where de.to_date = '9999-01-01' and s.to_date = '9999-01-01'
group by 1
order by gender

-- 10 --
select 
	extract(month from e.hire_date) as month,
	count(*) total_hire
from employee e 
group by month
order by month 

-- 11 --
select 
	concat(e.first_name,' ',e.last_name) as fullname,
	t.title as from_title,
	t.from_date ,
	t.to_date,
	lead(t.title) over(partition by concat(e.first_name,' ',e.last_name) order by t.from_date) as to_tittle
from employee e 
join title t on t.employee_id = e.id 
join department_employee de on de.employee_id = e.id 
where de.to_date = '9999-01-01'
order by fullname, t.from_date 


-- 12 --
with manager as(
	select 
		dm.department_id as dept ,
		d.dept_name ,
		concat(e.first_name,' ',e.last_name) as fullname,
		s.amount as salary
	from department_manager dm
	join department d on d.id  = dm.department_id 
	join employee e on e.id  = dm.employee_id 
	join salary s on s.employee_id = e.id 
	--join department_employee de on de.employee_id  = e.id 
	where dm.to_date  = '9999-01-01' and s.to_date = '9999-01-01'
	order by s.amount desc 
)
select 
	dept,
	dept_name,
	fullname,
	salary,
	concat(e.first_name,' ',e.last_name) as fullname,
	e.hire_date 
from manager
join department_employee de ON de.department_id = dept
join employee e on e.id  = de.employee_id 
where de.to_date = '9999-01-01'
group by 1,2,3,4,e.first_name ,e.last_name ,e.hire_date 
order by salary desc ,e.hire_date desc 

-- 13 --
with stuck as (
	select t.employee_id,
		concat(e.first_name,' ',e.last_name) as fullname,
		count(*) as order_title
	from employee e 
	join title t on t.employee_id = e.id 
	join department_employee de on de.employee_id = e.id 
	where de.to_date = '9999-01-01'
	group by t.employee_id,e.first_name,e.last_name
	order by fullname asc
)
select 
	fullname,
	order_title,
	t.title,
	lead(t.title) over(partition by t.employee_id) as to_tittle,
	t.from_date ,
	t.to_date 
from stuck s
join title t on s.employee_id = t.employee_id 
where order_title > 1
order by fullname

-- KJ 13 --
with temp_title as (
	select 
		concat(e.first_name,' ',e.last_name) as fullname,
		de.department_id,
		t.title as from_title,
		t.from_date,
		t.to_date,
		lead(t.title) over(partition by concat(e.first_name,' ',e.last_name)
			order by t.from_date asc)
			as to_title
	from employee e 
	join title t on t.employee_id = e.id 
	join department_employee de on de.employee_id = e.id 
	where de.to_date = '9999-01-01'
)
select 
	d.dept_name ,
	--t.fullname,
	--t.from_title,
	--t.to_title,
	round(min((t.to_date - t.from_date)/365),3) as min_years,
	round(max((t.to_date - t.from_date)/365),3) as max_years,
	round(avg((t.to_date - t.from_date)/365),2) as avg_years
	--round((t.to_date - t.from_date)/365) as years
from temp_title t
join department d on d.id = t.department_id
where (t.from_title = 'Staff' and t.to_title = 'Senior Staff') or 
	  (t.from_title = 'Assistant Engineer' and t.to_title = 'Engineer')
group by d.dept_name 
order by avg_years 


-- 14 --
with stuck as (
	select t.employee_id,
		concat(e.first_name,' ',e.last_name) as fullname,
		count(*) as order_title
	from employee e 
	join title t on t.employee_id = e.id 
	join department_employee de on de.employee_id = e.id 
	where de.to_date = '9999-01-01'
	group by t.employee_id,e.first_name,e.last_name
	order by fullname asc
)
select 
	fullname,
	order_title,
	t.title,
	lead(t.title) over(partition by t.employee_id) as to_tittle,
	t.from_date ,
	t.to_date 
from stuck s
join title t on s.employee_id = t.employee_id 
where order_title = 1
order by fullname

select * from title t where t.employee_id  = 282527

-- 15 --
select 
	de.employee_id,
	concat(e.first_name,' ',e.last_name) as fullname,
	t.title ,
	d.dept_name ,
	e.gender,
	e.birth_date 
from employee e 
join department_employee de on de.employee_id  = e.id 
join title t on t.employee_id = e.id 
join department d on d.id  = de.department_id 
where de.to_date = '9999-01-01' and t.to_date = '9999-01-01'
order by e.birth_date asc 
limit 15


-- Session 2 --

-- 1 --
select 
	de.employee_id,
	concat(e.first_name,' ',e.last_name) as fullname,
	t.title ,
	d.dept_name ,
	e.gender,
	e.birth_date 
from employee e 
join department_employee de on de.employee_id  = e.id 
join title t on t.employee_id = e.id 
join department d on d.id  = de.department_id 
where de.to_date = '9999-01-01' and t.to_date = '9999-01-01'
order by e.birth_date desc 
limit 15

-- 2 --
select 
	de.employee_id,
	concat(e.first_name,' ',e.last_name) as fullname,
	t.title ,
	d.dept_name ,
	e.gender,
	round(extract(epoch from age(e.hire_date,e.birth_date)) / (24*3600*365),2) as age
	--extract(epoch from (e.hire_date - e.birth_date)) as age
from employee e 
join department_employee de on de.employee_id  = e.id 
join title t on t.employee_id = e.id 
join department d on d.id  = de.department_id 
where de.to_date = '9999-01-01' and t.to_date = '9999-01-01'
order by age asc 
limit 15

-- 3 --
with promote as(
	select 
		concat(e.first_name,' ',e.last_name) as fullname,
		t.title,
		t.from_date ,
		t.to_date ,
		lead(t.title) over(partition by t.employee_id) as to_tittle 
	from employee e 
	join department_employee de on de.employee_id  = e.id 
	join title t on t.employee_id = e.id 
	where de.to_date = '9999-01-01' 
	order by t.from_date 
)
select 
	fullname,
	title,
	from_date,
	to_date,
	to_tittle,
	(to_date - from_date) as total_days
from promote
where to_tittle is not null 
order by total_days asc ,fullname
limit 10

-- 4 --
select 
	de.employee_id,
	concat(e.first_name,' ',e.last_name) as fullname,
	e.gender,
	e.hire_date,
	t.title ,
	s.amount 
from employee e 
join department_employee de on de.employee_id  = e.id 
join title t on t.employee_id = e.id 
join salary s on s.employee_id = e.id 
where de.to_date = '9999-01-01' and t.to_date = '9999-01-01' and s.to_date = '9999-01-01'
order by e.hire_date desc 
limit 15

-- 5 --
select 
		concat(e.first_name,' ',e.last_name) as fullname,
		e.gender ,
		d.dept_name ,
		s.amount as new_salary
	from department_manager dm 
	join employee e on e.id = dm.employee_id
	join department d on d.id = dm.department_id
	join salary s on s.employee_id  = e.id 
	where dm.to_date = '9999-01-01' and s.to_date = '9999-01-01'
	order by new_salary desc 

	
-- 6 --
select 
	e.gender ,
	count(dm.employee_id) as total_manager,
	avg(s.amount)
from department_manager dm 
join employee e on e.id  = dm.employee_id 
join salary s on s.employee_id = e.id 
where dm.to_date = '9999-01-01' and s.to_date  = '9999-01-01'
group by e.gender 

-- 7 --
select * from employee e 

select * from department_employee de 

select  
	extract(month from de.to_date) as month,
	count(de.employee_id) total_hire
from employee e 
join department_employee de on e.id = de.employee_id
where de.to_date != '9999-01-01' and 
	de.employee_id not in (
		select employee_id
		from department_employee de  
		group by de.employee_id 
		having count(*) > 1
		)
group by month
order by month 

select 
	de.*
from employee e 
join department_employee de on e.id = de.employee_id
--where de.to_date != '9999-01-01'
order by de.employee_id asc 

select de.employee_id ,count(*) as total
from department_employee de  
group by de.employee_id 
having count(*) > 1
order by de.employee_id 

select string_agg(cast(de.employee_id as text), ',') as total
from department_employee de  
group by de.employee_id 
having count(*) > 1
order by de.employee_id 

select * from department_employee de where de.employee_id = 37526

-- 8 --
with temp as (
	select distinct 
		de.employee_id ,
		concat(e.first_name,' ',e.last_name) as fullname,
		e.hire_date ,
		de.to_date ,
		max(s.amount) as amount
	from department_employee de
	join employee e on e.id  = de.employee_id 
	join salary s on s.employee_id = de.employee_id
	where de.to_date != '9999-01-01'
	group by de.employee_id,e.first_name,e.last_name,e.hire_date,de.to_date
)
select 
	employee_id,
	fullname,
	hire_date,
	to_date, 
	(to_date - hire_date) as len_of_employment,
	amount
from temp 
order by len_of_employment asc 
limit 15

select * from salary s where s.employee_id  = 285052

-- 9 --
select 
	d.dept_name ,
	count(dm.employee_id) as total_manager
from department_manager dm 
join department d on d.id = dm.department_id 
group by d.dept_name 
order by total_manager desc, dept_name

-- 10 --
select 
	concat(e.first_name,' ',e.last_name) as fullname,
	e.gender,
	e.hire_date,
	d.dept_name ,
	round(extract(epoch from age(e.hire_date,e.birth_date)) / (24*3600*365),2) as age
from employee e 
join department_manager dm on dm.employee_id  = e.id 
join department d on d.id  = dm.department_id 
order by age asc 
limit 15

-- 11 --
select 
	de.department_id ,
	d.dept_name ,
	sum(s.amount)
from department_employee de 
join department d on d.id  = de.department_id 
join salary s on s.employee_id = de.employee_id 
where de.to_date = '9999-01-01' and s.to_date = '9999-01-01'
group by de.department_id ,d.dept_name 
order by de.department_id 

-- 12 --

select 
	s.employee_id ,
	concat(e.first_name,' ',e.last_name) as fullname,
	s.from_date ,
	s.to_date ,
	s.amount ,
	lead(s.amount) over(partition by s.employee_id order by s.from_date)
from salary s 
join employee e on e.id  = s.employee_id 
join department_employee de on de.employee_id = e.id 
where de.to_date = '9999-01-01'
order by s.employee_id ,s.from_date 

-- 13 --
select 
	de.department_id ,
	d.dept_name ,
	sum(s.amount)
from department_employee de 
join department d on d.id  = de.department_id 
join salary s on s.employee_id = de.employee_id 
where de.to_date = '9999-01-01' and s.to_date = '9999-01-01'
group by de.department_id ,d.dept_name 
order by de.department_id 

with salary as(
	select 
		s.employee_id ,
		concat(e.first_name,' ',e.last_name) as fullname,
		s.from_date ,
		s.to_date ,
		s.amount ,
		lead(s.amount) over(partition by s.employee_id order by s.from_date) as next_salary
	from salary s 
	join employee e on e.id  = s.employee_id 
	join department_employee de on de.employee_id = e.id 
	where de.to_date = '9999-01-01'
	order by s.from_date 
)
select *,
	(next_salary - amount) as diff
from salary
order by fullname,from_date 

-- 14 --
with salary as(
	select 
		s.employee_id ,
		concat(e.first_name,' ',e.last_name) as fullname,
		s.from_date ,
		s.to_date ,
		s.amount ,
		lead(s.amount) over(partition by s.employee_id order by s.from_date) as next_salary
	from salary s 
	join employee e on e.id  = s.employee_id 
	join department_employee de on de.employee_id = e.id 
	where de.to_date = '9999-01-01'
	order by s.from_date 
)
select *,
	(next_salary - amount) as diff
from salary
order by diff asc 

-- 15 --
with salary as(
	select 
		s.employee_id ,
		concat(e.first_name,' ',e.last_name) as fullname,
		s.from_date ,
		s.to_date ,
		s.amount ,
		lead(s.amount) over(partition by s.employee_id order by s.from_date) as next_salary
	from salary s 
	join employee e on e.id  = s.employee_id 
	join department_employee de on de.employee_id = e.id 
	where de.to_date = '9999-01-01'
	order by s.from_date 
)
select *,
	round(((next_salary - amount)/ amount)* 100.0 ,2) as percentage
from salary
where next_salary is not null 
order by percentage desc, fullname desc 
limit 10