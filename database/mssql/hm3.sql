/**
1.	1. In the demo database, create two tables:
a.	The first table players should have columns player id (int pk), player name (varchar), shots attempted (int) shots made (int)
b.	The second table shots should have columns shot id (int pk), player id (int fk to players), clock time (datetime) shot made (bit)
c.	Add two players to the players table. Mary and Sue initialize the players with 0 shots attempted and made.

**/

USE[demo]

GO
IF OBJECT_ID('dbo.shots') IS NOT NULL
	DROP TABLE dbo.shots;
GO
IF OBJECT_ID('dbo.players') IS NOT NULL
	BEGIN
		ALTER TABLE dbo.players SET (SYSTEM_VERSIONING = OFF);
		DROP TABLE dbo.players
	END

GO
IF OBJECT_ID('dbo.write_shot') IS NOT NULL
	DROP PROCEDURE dbo.write_shot;
GO


CREATE TABLE dbo.players(
	player_id INT NOT NULL IDENTITY,
	player_name VARCHAR(80) NOT NULL,
	shots_attemted INT,
	shots_made INT,
	CONSTRAINT players_PK PRIMARY KEY (player_id)
);

CREATE TABLE dbo.shots(
	shot_id INT NOT NULL IDENTITY PRIMARY KEY,
	player_id INT NOT NULL FOREIGN KEY REFERENCES dbo.players(player_id),
	clock_time DATETIME NOT NULL,
	shot_made BIT NOT NULL
);

GO

INSERT INTO players (player_name, shots_attemted, shots_made)
VALUES ('Mary', 0, 0),('Sue',0,0)


GO

SELECT * from dbo.players;

/**
2.	Write transaction safe code as a stored procedure which when given a player id, 
clock time, and whether the shot was made (bit value) will add the record to the shots table and 
update the player record in the players table. For example, If Mary takes a shot and makes it, 
then misses the next one, there would be two records in the shots table and her row in the players
table should have 2 attempt and 1 shot made. Execute the stored procedure to demonstrate the transaction is ACID compliant.

**/
GO

CREATE PROCEDURE dbo.write_shot(
	@player_id INT,
	@clock_time datetime,
	@shot_made bit
	)
AS
BEGIN TRY
	BEGIN TRANSACTION
	INSERT dbo.shots (player_id, clock_time, shot_made)
	VALUES (@player_id, @clock_time,@shot_made)
	if @@ROWCOUNT <> 1 THROW 50005, 'Failed to update shots table, zero rows affected',0;
	

	UPDATE dbo.players
		SET shots_attemted = COALESCE (shots_attemted, 0) + 1,
			shots_made = CASE @shot_made WHEN 1 THEN COALESCE (shots_made, 0) + 1
							ELSE  shots_made END
	WHERE player_id = @player_id
	if @@ROWCOUNT <> 1 THROW 50006,'Failed to insert into player table, zero rows affected',0;

	COMMIT 
END TRY
BEGIN CATCH
	select  error_number() as error, error_message() as message 
	print 'Rolling back'
	rollback

END CATCH

GO



/**
3.	Alter the players table to be a system-versioned temporal table.

**/

GO
ALTER TABLE dbo.players
ADD StartTime DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN DEFAULT GETUTCDATE(),
EndTime  DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
PERIOD FOR SYSTEM_TIME (StartTime, EndTime);

GO
​
ALTER TABLE dbo.players
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE=dbo.player_history));
GO




/**
4.	Execute your stored procedure from part 2 to create at least 15 shot records over a 
5-minute period. Make sure there are records in the first ½ of the 5-minute period and at few in the last minute 
of the 5-minute period.

**/
GO

EXEC dbo.write_shot 2, SYSTEM_TIME ,1;
WAITFOR DELAY '00:00:05';
EXEC dbo.write_shot 1, SYSTEM_TIME ,0;

GO

SELECT * FROM dbo.players

GO


/**
5.	Write SQL queries to show:
a.	The player statistics at the end of the 5-minute period (current statistics).
b.	The player statistics exactly 2 minutes and 30 seconds into the period.
c.	The player statistics in the last minute of the period.

**/
GO


SELECT *
	FROM dbo.players
	FOR SYSTEM_TIME  BETWEEN '2019-10-19 11:00:00.0000000' AND '2019-10-19 11:05:00.0000000'
GO

SELECT *
	FROM dbo.players
	FOR SYSTEM_TIME  BETWEEN '2019-10-19 11:00:00.0000000' AND '2019-10-19 11:00:30.0000000'
GO
SELECT *
	FROM dbo.players
	FOR SYSTEM_TIME  BETWEEN '2019-10-19 11:05:00.0000000' AND '2019-10-19 11:05:00.0000000'

GO
