# Brian M - UofI Associate Web Application Developer Code Test

### Prompt:
With three tables of normalized data named: Employees, Departments, Tickets. Assuming all the data you require exists within these tables, write a query to report the top employee in each department with the most resolved tickets last month.  (If you are able, return the top 3 from each department.)



### Solution One:

Below is an example of getting the three employess per department that closed the most tickets in the last ~30 days.

```sql
WITH ResolvedTickets AS (
    SELECT 
        e.employee_id,
        e.first_name,
        d.department_id,
        d.department_name,
        COUNT(t.ticket_id) AS resolved_count
    FROM 
        Employees e
    JOIN 
        Tickets t ON e.employee_id = t.employee_id
    JOIN 
        Departments d ON e.department_id = d.department_id
    WHERE 
        t.status = 'closed' 
        AND t.resolved_date >= DATEADD(month, -1, GETDATE())
    GROUP BY 
        e.employee_id, e.first_name, d.department_id, d.department_name
),
RankedEmployees AS (
    SELECT 
        employee_id,
        first_name,
        department_id,
        department_name,
        resolved_count,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY resolved_count DESC) AS rank
    FROM 
        ResolvedTickets
)
SELECT 
    employee_id,
    first_name,
    department_name,
    resolved_count
FROM 
    RankedEmployees
WHERE 
    rank <= 3
ORDER BY 
    department_id, rank;
```



### Solution Two:

Below is an example of getting the three employess per department that closed the most tickets last month. If we where to run this SQL during the month of Jan 2025 then we would only be looking at tickets closed during the month od Dev 2024.

```sql
With ranked_employees as (

    select 
        e.id as employee_id,
        concat(e.first_name, ' ', e.last_name) as employee_name,
        e.department_id,
        d.name as department_name,
                
       		(
         	select count(t.id) 
     	 		from tickets t 
         		where t.assigned_employee_id = e.id 
				and t.date_completed between concat(DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-01'), ' 00:00:00') and concat(LAST_DAY(CURDATE() - INTERVAL 1 MONTH), ' 23:59:59')
        	) as count_of_closed_tickets_last_month,

        ROW_NUMBER() OVER 
        (
		PARTITION BY e.department_id order by 
        	(
			select count(t.id) 
             		from tickets t 
             		where t.assigned_employee_id = e.id 
               		and t.date_completed between concat(DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-01'), ' 00:00:00') and concat(LAST_DAY(CURDATE() - INTERVAL 1 MONTH), ' 23:59:59')
			) desc
        ) as rank_in_department

    from employees e
    left join departments d on e.department_id = d.id
)

select
    employee_id,
    employee_name,
    department_id,
    department_name,
    count_of_closed_tickets_last_month,
    rank_in_department,
    concat(DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-01'), ' 00:00:00') as start_filter_date,
    concat(LAST_DAY(CURDATE() - INTERVAL 1 MONTH), ' 23:59:59') as end_filter_date
from ranked_employees
-- where rank_in_department in (1, 2, 3)
where rank_in_department <= 3
order by department_id ASC, rank_in_department asc;
```