# Brian M - UofI Associate Web Application Developer Code Test

### Prompt:
With three tables of normalized data named: Employees, Departments, Tickets. Assuming all the data you require exists within these tables, write a query to report the top employee in each department with the most resolved tickets last month.  (If you are able, return the top 3 from each department.)



### Solution One:

Below is an example of getting the three employess per department that closed the most tickets in the last ~30 days.

```sql
with resolved_tickets as (
    select 
        e.employee_id,
        concat(e.first_name, ' ', e.last_name) as employee_name,
        d.department_id,
        d.department_name,
        count(t.ticket_id) as resolved_ticket_count
    from employees e
    join tickets t on e.employee_id = t.employee_id
    join Departments d on e.department_id = d.department_id
    where 
		t.status = 'closed' and t.resolved_date >= DATEADD(month, -1, GETDATE())
    group by e.employee_id, e.first_name, e.last_name, d.department_id, d.department_name
),
ranked_employees as (
    select 
        employee_id,
        employee_name,
        department_id,
        department_name,
        resolved_ticket_count,
        ROW_NUMBER() OVER (PARTITION BY department_id order by resolved_ticket_count desc) as rank_in_department
    from resolved_tickets
)

select 
    employee_id,
    employee_name,
	department_id,
    department_name,
    resolved_ticket_count,
	rank_in_department,
	DATEADD(month, -1, GETDATE()) as start_filter_date,
	GETDATE() as end_filter_date
from ranked_employees
where rank_in_department <= 3
order by department_id, rank_in_department;
```



### Solution Two:

Below is an example of getting the three employess per department that closed the most tickets last month. If we where to run this SQL during the month of Jan 2025 then we would only be looking at tickets closed during the month od Dev 2024.

```sql
With ranked_employees as (

    select 
        e.employee_id,
        concat(e.first_name, ' ', e.last_name) as employee_name,
        e.department_id,
        d.department_name,
                
       	(
         	select count(t.ticket_id) 
     	 	from tickets t 
         	where t.employee_id = e.employee_id 
			and t.resolved_date between concat(format(dateadd(MONTH, -1, CAST(GETDATE() AS DATE)), 'yyyy-MM-01'), ' 00:00:00') and concat(format(EOMONTH(GETDATE(), -1), 'yyyy-MM-dd'), ' 23:59:59')
        ) as resolved_ticket_count,

        ROW_NUMBER() OVER 
        (
		PARTITION BY e.department_id order by 
        	(
			select count(t.ticket_id) 
             		from tickets t 
             		where t.employee_id = e.employee_id 
               		and t.resolved_date between concat(format(dateadd(MONTH, -1, CAST(GETDATE() as date)), 'yyyy-MM-01'), ' 00:00:00') and concat(format(EOMONTH(GETDATE(), -1), 'yyyy-MM-dd'), ' 23:59:59')
			) desc
        ) as rank_in_department

    from employees e
    left join departments d on e.department_id = d.department_id
)

select
    employee_id,
    employee_name,
    department_id,
    department_name,
    resolved_ticket_count,
    rank_in_department,
    concat(format(dateadd(MONTH, -1, CAST(GETDATE() as date)), 'yyyy-MM-01'), ' 00:00:00') as start_filter_date,
    concat(format(EOMONTH(GETDATE(), -1), 'yyyy-MM-dd'), ' 23:59:59') as end_filter_date
from ranked_employees
-- where rank_in_department in (1, 2, 3)
where rank_in_department <= 3
order by department_id asc, rank_in_department asc;
```