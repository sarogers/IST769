/**
1.	Use built in SQL functions to write an SQL Select statement on fudgemart_products which derives a product_category column by extracting the last word in the product name. For example 
a.	for a product named ‘Leather Jacket’ the product category would be ‘Jacket’
b.	for a product named ‘Straight Claw Hammer’ the category would be ‘Hammer’
Your select statement should include product id, product name, product category and product department.
**/
USE[fudgemart_v3]

SELECT product_id
	,product_name
	,product_department
	,CASE
			WHEN CHARINDEX(' ', product_name) = 0 THEN product_name
			ELSE RIGHT(product_name, CHARINDEX(' ', REVERSE(product_name))-1)
	END AS product_category
FROM fudgemart_products

GO

/**
Write a user defined function called f_total_vendor_sales which calculates the sum of the wholesale
price * quantity of all products sold for that vendor. There should be one number associated with each 
vendor id, which is the input into the function.  Demonstrate the function works by executing an SQL
select statement over all vendors calling the function.

**/
GO
	DROP FUNCTION IF EXISTS dbo.f_total_vendor_sales
GO

CREATE FUNCTION  f_total_vendor_sales(
					@vendor_id FLOAT
					)
RETURNS FLOAT AS
	BEGIN
	   DECLARE @ret FLOAT
	   SET @ret = (
					SELECT SUM(t.product_wholesale_price * o.order_qty)
					FROM fudgemart_vendors AS f
					FULL OUTER JOIN fudgemart_products AS t 
						ON (f.vendor_id = t.product_vendor_id)
					FULL OUTER JOIN fudgemart_order_details AS o 
						ON (o.product_id = t.product_id)
					WHERE f.vendor_id = @vendor_id
				)

		RETURN @ret

	END            

GO

SELECT vendor_name,dbo.f_total_vendor_sales (vendor_id) AS Total_Sales
FROM fudgemart_vendors
ORDER BY vendor_name

GO

/**
Write a stored procedure called p_write_vendor which when given a required vendor name, 
phone and optional website, will look up the vendor by name first. If the vendor exists,
it will update the phone and website. If the vendor does not exist, it will add the info to the table.
Write code to demonstrate the procedure works by executing the procedure twice so that it adds
a new vendor and then updates that vendor’s information.
**/
GO
IF OBJECT_ID('bo.p_write_vendor') IS NOT NULL
	DROP PROCEDURE dbo.p_write_vendor
GO

CREATE PROCEDURE dbo.p_write_vendor(
					@vendor_name VARCHAR,
					@phone VARCHAR,
					@website VARCHAR
				)
AS
BEGIN

	IF EXISTS( SELECT * FROM fudgemart_vendors WHERE vendor_name = @vendor_name)
		UPDATE dbo.fudgemart_vendors
		SET vendor_phone = @phone,
			vendor_website = @website
		WHERE vendor_name = @vendor_name
	ELSE
		INSERT dbo.fudgemart_vendors (vendor_name,vendor_phone,vendor_website)
		VALUES (@vendor_name, @phone, @website)
	
END
GO

EXEC dbo.p_write_vendor 'Vendor name', '92234555', 'www.syr.edu'

/**
Create a view based on the logic you completed in question 1 or 2. 
Your SQL script should be programmed so that the entire script works every time, 
dropping the view if it exists, and then re-creating it. 

**/
GO
DROP VIEW IF EXISTS  dbo.vw_vendor_sales
GO

CREATE VIEW dbo.vw_vendor_sales
	AS(
	SELECT vendor_name,dbo.f_total_vendor_sales (vendor_id) AS Total_Sales
	FROM fudgemart_vendors

	)

GO

SELECT * FROM dbo.vw_vendor_sales

/**
Write a table valued function f_employee_timesheets which when provided an employee_id will output the employee id, 
name, department, payroll date, hourly rate on the timesheet, hours worked, and gross pay (hourly rate times hours worked).

**/
GO
   DROP FUNCTION IF EXISTS dbo.f_employee_timesheets

GO

CREATE FUNCTION dbo.f_employee_timesheets(
	@employee_id INT
)
RETURNS TABLE
AS
	RETURN (
					SELECT e.employee_id, e.employee_lastname, e.employee_firstname, e.employee_department, t.timesheet_payrolldate,
					t.timesheet_hours * t.timesheet_hourlyrate AS grosspay
					FROM fudgemart_employee_timesheets AS t
					INNER JOIN fudgemart_employees AS e ON e.employee_id = t.timesheet_employee_id
					WHERE e.employee_id = @employee_id

	);
 GO