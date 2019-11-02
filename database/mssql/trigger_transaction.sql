/** Transaction**/
use demo
GO
BEGIN TRY
	BEGIN TRANSACTION
	-- data manipulation
	SELECT 1/0
	PRINT 'Committing'
	COMMIT -- save to db
END TRY
BEGIN CATCH
	print error_message()
	print 'Rolling back'
	ROLLBACK --undo
END CATCH

GO
IF EXISTS (SELECT * FROM SYS.objects WHERE name='accounts')
	DROP TABLE dbo.accounts
GO
CREATE TABLE dbo.accounts (
	account varchar(50) NOT NULL,
	balance money NOT NULL
	CONSTRAINT Ck_account_balance_not_less_than_zero CHECK(balance >=0)
	CONSTRAINT PK_primary_key PRIMARY KEY (account)
)
GO
-- starting balance
insert into accounts values ('checking', 1000)
insert into accounts values ('saving', 1000)

GO
SELECT * from accounts
GO
IF EXISTS (SELECT * FROM SYS.objects where name = 'p_transfer_money')
	DROP PROCEDURE p_transfer_money
GO
-- Transaction
CREATE PROCEDURE p_transfer_money(
	@from varchar(50),
	@to varchar(50),
	@amount money

) AS

BEGIN TRY
	BEGIN TRANSACTION
	UPDATE accounts set balance = balance - @amount where account = @from
	if @@ROWCOUNT <> 1 THROW 50001,'Zero rows affeted to account table update',0
	UPDATE accounts set balance = balance + @amount where account = @to
	if @@ROWCOUNT <> 1 THROW 50001, 'update to account table, zero rows affected',0
	print 'committing'

	COMMIT
END TRY

BEGIN CATCH
	SELECT error_number() as error, error_message() as message
	print 'Rolling back'
	ROLLBACK
END CATCH

GO
SELECT * from accounts

EXEC p_transfer_money @from='checking',@to='saving',@amount=500
SELECT * from accounts

GO

/** concorrency control **/

/** Trigger **/
GO
CREATE TRIGGER trigger_name
	ON table_name
		AFTER | INSTEAD OF
		{[INSERT] [,] [UPDATE] ['] [DELETE]}
	BEGIN
		sql Statements
	END
GO
-- DEMO
IF EXISTS (SELECT * FROM sys.objects where name='t_accounts_trigger_demo')
	DROP TRIGGER t_accounts_trigger_demo
GO
CREATE TRIGGER t_accounts_trigger_demo
 ON accounts
 AFTER INSERT,UPDATE,DELETE AS
 BEGIN
	SELECT 'inserted table:', * from inserted
	SELECT 'deleted table:', * from deleted 
END

Go
update accounts set balance= balance + 500

GO
EXEC p_transfer_money @from='checking',@to='saving',@amount=500
GO
/** Time stamping with triggers **/

Select current_user as users, getdate() as date

GO
IF EXISTS (SELECT * FROM sys.objects where name='t_accounts_block_locked')
	DROP TRIGGER t_accounts_block_locked
GO
CREATE TRIGGER t_accounts_block_locked
	ON accounts
	INSTEAD OF UPDATE AS
	BEGIN
		if exists (select * from inserted where locked=1)
			BEGIN
				;
				THROW 50005, 'NO changes permitted, one of the rows used a locked account',1
				rollback
			END
		ELSE
			BEGIN
				update accounts set accounts.balance = inserted.balance
				from inserted 
				where accounts.account = inserted.account
			END

	END
GO

/** Temporal Table **/
-- indexing
-- cluster index : sequencial in nature, narrow key size as possible, ever increasing, and unique.
GO
ALTER DATABASE demo ADD FILEGROUP TESTING
GO
ALTER DATABASE demo ADD FILE (
	NAME = N'testing',
	FILENAME= '/var/opt/mssql/data/testing.ndf',
	SIZE=819KB, FILEGROWTH=65536KB
) TO FILEGROUP TESTING
GO
-- create table with primary key in different file group
IF EXISTS (SELECT * FROM sys.objects where name='accounts2')
	DROP TABLE accounts2
GO
CREATE TABLE accounts2 (
	account varchar(50) NOT NULL,
	balance money NOT NULL,
	CONSTRAINT pk_primary_key_account2 PRIMARY KEY NONCLUSTERED (account ASC ON TESTING) ON PRIMARY
)
GO

-- NONclustered index: secondary index
CREATE [UNIQUE] INDEX index_name
	ON table_name (column,[_])
	INCLUDE (column,[_])
GO

use fudgemart_v3
select * into emp_test from fudgemart_employees
select * from emp_test

GO
CREATE VIEW view_name 
	WITH SCHEMABINDING
AS
    sql select statments
GO
