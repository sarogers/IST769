/** Create login and create user from login. The login and user can be named differently. both are named the same for demostration**/

USE master
GO
CREATE login testuser with password=N'testing123'
	,DEFAULT_DATABASE=demo
	,CHECK_POLICY=OFF
	,CHECK_EXPIRATION=OFF
GO
USE demo
CREATE USER testuser FROM login testuser
GO

/** Permission and Security**/
-- Grant access to testuser
GRANT SELECT ON SCHEMA::dbo to testuser
GO
-- make a selection od tables to check access for testuser
SELECT * FROM INFORMATION_SCHEMA.TABLES
GO
-- check database perission
SELECT * FROM sys.database_permissions

GO

/** NoSQL Features in RDMS **/

IF EXISTS (SELECT * FROM sys.objects WHERE name='products'
	DROP TABLE products
GO

CREATE TABLE products(
	id INT NOT NULL PRIMARY KEY
	,name VARCHAR(50) NOT NULL
	,price money NOT NULL
	,reviews varchar(max) null
	,CONSTRAINT ck_product_review_is_json check(isjson(reviews)>0)
)
GO
--make a selection as json: produced a json output
SELECT id, name, price, JSON_QUERY(reviews) as Reviews FROM products FOR JSON AUTO

GO



