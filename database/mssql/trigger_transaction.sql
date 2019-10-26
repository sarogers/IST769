/** Transaction**/
BEGIN TRY
	BEGIN TRANSACTION
	-- data manipulation

	COMMIT -- save to db
END TRY
BEGIN CATCH
	print error_message()
	ROLLBACK --undo
END CATCH
