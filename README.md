# U of I Associate Web Application Developer Code Test - Brian Meyer

## Prompt:
With three tables of normalized data named: Employees, Departments, Tickets. Assuming all the data you require exists within these tables, write a query to report the top employee in each department with the most resolved tickets last month.  (If you are able, return the top 3 from each department.)

</br>
</br>
 
## Solution One:

Here’s an example of retrieving the top three employees per department who resolved the highest number of tickets in the past ~30 days.

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

</br>

### Here is the result of the query executed on January 24, 2025.

| employee_id | employee_name | department_id | department_name | resolved_ticket_count | rank_in_department | start_filter_date       | end_filter_date         |
|-------------|---------------|---------------|-----------------|-----------------------|--------------------|-------------------------|-------------------------|
| 1           | Brian Meyer   | 1             | Web Services    | 9                     | 1                  | 2024-12-24 23:39:32.113| 2025-01-24 23:39:32.113|
| 7           | Hannah Mazze  | 1             | Web Services    | 5                     | 2                  | 2024-12-24 23:39:32.113| 2025-01-24 23:39:32.113|
| 2           | Jeremy Bird   | 1             | Web Services    | 4                     | 3                  | 2024-12-24 23:39:32.113| 2025-01-24 23:39:32.113|
| 9           | Genny Goodman | 2             | IT Services     | 10                    | 1                  | 2024-12-24 23:39:32.113| 2025-01-24 23:39:32.113|
| 3           | Joe Smith     | 2             | IT Services     | 9                     | 2                  | 2024-12-24 23:39:32.113| 2025-01-24 23:39:32.113|
| 4           | Alex Rogers   | 2             | IT Services     | 7                     | 3                  | 2024-12-24 23:39:32.113| 2025-01-24 23:39:32.113|
| 5           | Julian Smith  | 3             | Networking      | 12                    | 1                  | 2024-12-24 23:39:32.113| 2025-01-24 23:39:32.113|
| 6           | Ginger Meyer  | 3             | Networking      | 10                    | 2                  | 2024-12-24 23:39:32.113| 2025-01-24 23:39:32.113|
| 11          | Mark Korte    | 3             | Networking      | 6                     | 3                  | 2024-12-24 23:39:32.113| 2025-01-24 23:39:32.113|



</br>
</br>

## Solution Two:

The following example demonstrates how to retrieve the top three employees per department who resolved the most tickets in the previous month. If this SQL query is executed during January 2025, it will focus exclusively on tickets closed in December 2024.

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

</br>

### Here is the output generated by the query, executed on January 24, 2025.

| employee_id | employee_name | department_id | department_name | resolved_ticket_count | rank_in_department | start_filter_date       | end_filter_date         |
|-------------|---------------|---------------|-----------------|-----------------------|--------------------|-------------------------|-------------------------|
| 1           | Brian Meyer   | 1             | Web Services    | 9                     | 1                  | 2024-12-01 00:00:00    | 2024-12-31 23:59:59    |
| 7           | Hannah Mazze  | 1             | Web Services    | 5                     | 2                  | 2024-12-01 00:00:00    | 2024-12-31 23:59:59    |
| 2           | Jeremy Bird   | 1             | Web Services    | 4                     | 3                  | 2024-12-01 00:00:00    | 2024-12-31 23:59:59    |
| 3           | Joe Smith     | 2             | IT Services     | 6                     | 1                  | 2024-12-01 00:00:00    | 2024-12-31 23:59:59    |
| 9           | Genny Goodman | 2             | IT Services     | 5                     | 2                  | 2024-12-01 00:00:00    | 2024-12-31 23:59:59    |
| 4           | Alex Rogers   | 2             | IT Services     | 4                     | 3                  | 2024-12-01 00:00:00    | 2024-12-31 23:59:59    |
| 5           | Julian Smith  | 3             | Networking      | 6                     | 1                  | 2024-12-01 00:00:00    | 2024-12-31 23:59:59    |
| 6           | Ginger Meyer  | 3             | Networking      | 5                     | 2                  | 2024-12-01 00:00:00    | 2024-12-31 23:59:59    |
| 11          | Mark Korte    | 3             | Networking      | 3                     | 3                  | 2024-12-01 00:00:00    | 2024-12-31 23:59:59    |

</br>
</br>

## Dev Notes:
I have attached SQL and CSV exports of the test data used for this query. You are welcome to import the test data into your own database environment and execute the queries.