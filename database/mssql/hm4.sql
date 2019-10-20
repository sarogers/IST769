/** Performance, Security, **/

/**
1.	Create a non-clustered index on the timesheets table in the demo database. The index you create should be designed to improve the following query:
select  employee_id, employee_firstname, employee_lastname, sum(timesheet_hourlyrate*timesheet_hours)
from timesheets
group by employee_id, employee_firstname, employee_lastname;
**/



/**
2.	Write an SQL Select query which uses the index you created in the first question but does an index seek instead of an index scan. 
**/



/**
3.	Create a single columnstore index on the timesheets table in the demo database which will improve the following queries:
select employee_department, sum(timesheet_hours) 
	from timesheets group by employee_department

select employee_jobtitle, avg(timesheet_hourlyrate) 
from timesheets group by employee_jobtitle
**/


/**
4.	Create an indexed view named v_employees on the timesheets table in the demo database which lists the employee id, first name, last name, job title, and department columns values and one row per employee (essentially re-building the employee table). Then set a unique clustered index on the view and finish by writing an SQL Select query which uses the indexed view.
**/




/**
5.	Output the following query in JSON format: Display the employee id, first name, last name, count of timesheets, total hours worked, and average timesheet hourly rate.
**/