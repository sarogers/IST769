/** Performance, Security, **/

/**
1.	Create a non-clustered index on the timesheets table in the demo database. The index you create should be designed to improve the following query:
select  employee_id, employee_firstname, employee_lastname, sum(timesheet_hourlyrate*timesheet_hours)
from timesheets
group by employee_id, employee_firstname, employee_lastname;
**/
--1
use demo
GO
CREATE nonclustered index t_timesheet_index_nonclus 
	ON employee_timesheets (employee_id)
INCLUDE  (employee_firstname, employee_lastname, timesheet_hourlyrate,timesheet_hours)

GO

select  employee_id, employee_firstname, employee_lastname, sum(timesheet_hourlyrate*timesheet_hours) as salary
from timesheets
group by employee_id, employee_firstname, employee_lastname;


GO



/**
2.	Write an SQL Select query which uses the index you created in the first question but does an index seek instead of an index scan. 
**/
select  employee_id, employee_firstname, employee_lastname, sum(timesheet_hourlyrate*timesheet_hours)
from timesheets 
where employee_id IN (1,2,3,4)
group by employee_id, employee_firstname, employee_lastname;


/**
3.	Create a single columnstore index on the timesheets table in the demo database which will improve the following queries:
select employee_department, sum(timesheet_hours) 
	from timesheets group by employee_department

select employee_jobtitle, avg(timesheet_hourlyrate) 
from timesheets group by employee_jobtitle
**/

GO

CREATE nonclustered columnstore index t_timesheets_index_colstore 
	ON employee_timesheets
--WITH (drop existing = on)

GO
select employee_department, sum(timesheet_hours) 
	from employee_timesheets group by employee_department
GO
select employee_jobtitle, avg(timesheet_hourlyrate) 
from timesheets group by employee_jobtitle


/**
4.	Create an indexed view named v_employees on the timesheets table in the demo database which lists the 
employee id, first name, last name, job title, and department columns values and one row per employee (essentially re-building the employee table). 
Then set a unique clustered index on the view and finish by writing an SQL Select query which uses the indexed view.
**/
GO
CREATE VIEW  v_employees
	WITH schemabinding 
AS
	SELECT employee_id, first_name, last_name, job_title, employee_department from timesheets
GO

CREATE UNIQUE clustered index v_timesheet_uniq_clus
	ON timesheets
GO

SELECT * FROM v_employees

GO

/**
5.	Output the following query in JSON format: Display the employee id, first name, last name, count of timesheets, total hours worked, and average timesheet hourly rate.
**/

GO
select 
	employee_id, 
	first_name, 
	last_name, 
	count(timesheet) as counts, 
	sum(total_hours) as total_hours,
	AVG(timesheet_hour_rate) as avgrate
from timesheets
group by employee_id, first_name, last_name
FOR JSON AUTO
GO
