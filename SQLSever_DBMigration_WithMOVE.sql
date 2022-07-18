SET NOCOUNT ON
DECLARE @dbname varchar(2000)
DECLARE @dbsize decimal(18,3)
DECLARE @path varchar(2000)
DECLARE @logpath varchar(2000)
SET @dbname = 'WSS_Content_d8abf0b794c542c0bc1a1fdbf25bfb6e'
SET @path = 'W:\Data\Disk1\sql_dat\'
SET @logpath = 'W:\Log\Disk1\sql_dat\'                   --- @logpath should end with backslash(\) 
SELECT @dbsize = CAST(SUM(F.size*8.0)/1024/1024 AS decimal(18,3))
FROM sys.master_files F INNER JOIN sys.databases D ON D.database_id = F.database_id
where D.name = @dbname



PRINT '--Database Name: ' + @dbname
PRINT '--Database Size: ' +CAST(@dbsize AS nvarchar(max)) + ' GB'

SELECT 'ALTER DATABASE ['++@dbname++ '] MODIFY FILE (NAME = [' + f.name + '],'
+ CASE WHEN f.type = 1 THEN ' FILENAME = '''+@logpath+ f.name ELSE ' FILENAME = '''+@path+ f.name END
+ CASE WHEN f.type = 1 THEN '.ldf' WHEN f.file_id = 1 THEN '.mdf' ELSE '.ndf' END
+ ''');'
FROM sys.master_files f
WHERE f.database_id = DB_ID(@dbname);


SELECT 'USE Master' + CHAR(10) + 'ALTER DATABASE ['++@dbname++ '] SET OFFLINE WITH ROLLBACK IMMEDIATE'


SELECT 'EXEC xp_cmdshell ''copy ' + f.physical_name + ''
+ ' '+ CASE WHEN f.type = 1 THEN @logpath ELSE @path END + f.name
+ CASE WHEN f.type = 1 THEN '.ldf' WHEN f.file_id =1 THEN '.mdf' ELSE '.ndf' END
+ ''';'
FROM sys.master_files f
WHERE f.database_id = DB_ID(@dbname);



SELECT 'USE Master' + CHAR(10) + 'ALTER DATABASE ['++@dbname++ '] SET ONLINE'
