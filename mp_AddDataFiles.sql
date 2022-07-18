USE [DBA_Admin]
GO

/****** Object:  StoredProcedure [dbo].[mp_AddDataFiles]    Script Date: 9/13/2021 1:57:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/***********************************************************************************************
* Procedure Name      - mp_AddDataFiles
*------------------------
* Description         - Create the TSQL commands needed to add new datafiles to a drive when a current drive is running out of space.
*								
* Usage               - exec AddDataFiles @filelocation = '%Z:\Data_ContentDB\Disk13\sql_dat\%', @NewFileLocation = 'Z:\Data_ContentDB\Disk1\sql_dat',@flag = 1 or 2
 
*
* Author              - Sumit Kumar
* Created             - 2021-08-18
* 
* Major/Minor Changes
***********************************************************************************************/

CREATE PROCEDURE [dbo].[mp_AddDataFiles]
@FileLocation VARCHAR(max), @NewFileLocation VARCHAR(max), @flag int = 1
AS
DECLARE @filename VARCHAR(2000)
Declare @rownumber int
DECLARE @Addfile NVARCHAR(MAX)
SET NOCOUNT ON

BEGIN   
----- Creating Tables in DBA_Admin DB

/****** Object:  Table [dbo].[AddDataFiles]    Script Date: 9/6/2021 4:58:37 AM ******/

IF OBJECT_ID(N'[DBA_Admin].[dbo].[AddDataFiles]', N'U') IS NULL
	CREATE TABLE [DBA_Admin].[dbo].[AddDataFiles](
	[Entry_Date] [datetime] DEFAULT (getdate()),
	[DatabaseName] [sysname] NOT NULL,
	[NewLocation] [nvarchar](2000) NULL,
	[OldLocation] [nvarchar](2000) NULL,
	[Command] [nvarchar](max) NULL,
	[Task] [nvarchar](200) NULL,
	[Login_Name] [nvarchar](255) NULL DEFAULT (suser_sname())
) ON [User] TEXTIMAGE_ON [User]

--- Creating Cap Files Table
IF OBJECT_ID(N'[DBA_Admin].[dbo].[CapDataFiles]', N'U') IS NULL  
	CREATE TABLE [DBA_Admin].[dbo].[CapDataFiles](
	[Entry_Date] [datetime] DEFAULT (getdate()),
	[DatabaseName] [sysname] NOT NULL,
	[OldLocation] [nvarchar](2000) NULL,
	[Command] [nvarchar](max) NULL,
	[Task] [nvarchar](200) NULL,
	[Login_Name] [nvarchar](255) DEFAULT (suser_sname())
) ON [User] TEXTIMAGE_ON [User]

END
--SET @FileLocation = 'Z:\Data\Disk1\sql_dat\%'  --- Please Enter the Problematic FileSystem Path
--SET @NewFileLocation = 'Z:\Data\Disk1\sql2\'  --- Please Enter the New FileSystem Path'

--IF a drive letter for FileLocation, ignore. Else ensure proper '\' to drive string
SET @FileLocation = CASE WHEN LEN(@FileLocation) > 2 THEN 
									CASE 
									WHEN RIGHT(@FileLocation, 2) != '\%' and RIGHT(@FileLocation, 1) != '\' THEN @FileLocation + '\%' 
									WHEN RIGHT(@FileLocation, 1) = '\' THEN @FileLocation + '%' 
										 ELSE @FileLocation 
									END
							  ELSE @FileLocation 
						 END

--IF a drive letter for NewFileLocation, ignore. Else ensure proper '\' to drive string
SET @NewFileLocation = CASE WHEN LEN(@NewFileLocation) > 2 THEN 
									CASE WHEN RIGHT(@NewFileLocation, 1) != '\' THEN @NewFileLocation + '\' 
										 ELSE @NewFileLocation 
									END
							  ELSE @NewFileLocation 
						 END

-- Validating Free space in New Disk Location:
declare @NewDisklocation varchar(max)
set @NewDisklocation =  @NewFileLocation
--IF a drive letter for NewFileLocation, ignore. Else ensure proper '\' to drive string
SET @NewDisklocation = CASE WHEN LEN(@NewDisklocation) > 2 THEN 
									CASE 
									WHEN RIGHT(@NewDisklocation, 8) = '\sql_dat' THEN LEFT(@NewDisklocation, LEN(@NewDisklocation)-7)
									WHEN RIGHT(@NewDisklocation, 8) = 'sql_dat\' THEN LEFT(@NewDisklocation, LEN(@NewDisklocation)-8)
									ELSE @NewDisklocation 
									END
							  ELSE @NewDisklocation 
						 END

declare @sql varchar(400)
declare @svrName varchar(255)

declare @FreeSpaceNewDisk int
set @svrName = @@SERVERNAME

set @sql = 'powershell.exe -c "Get-WmiObject -ComputerName ' + QUOTENAME(@svrName,'''') + ' -Class Win32_Volume -Filter ''DriveType = 3'' | select name,capacity,freespace | foreach{$_.name+''|''+$_.capacity/1048576+''%''+$_.freespace/1048576+''*''}"'

IF OBJECT_ID('tempdb..#checkspace') IS NOT NULL
DROP TABLE #checkspace

CREATE TABLE #checkspace (line varchar(255))

insert #checkspace
EXEC xp_cmdshell @sql
--script to retrieve the values in MB from PS Script output
--select rtrim(ltrim(SUBSTRING(line,1,CHARINDEX('|',line) -1))) as drivename
--   ,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('|',line)+1,
--   (CHARINDEX('%',line) -1)-CHARINDEX('|',line)) )) as Float),0) as 'capacity(MB)'
--   ,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('%',line)+1,
--   (CHARINDEX('*',line) -1)-CHARINDEX('%',line)) )) as Float),0) as 'freespace(MB)'
--from #checkspace

select @FreeSpaceNewDisk = round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('%',line)+1,
   (CHARINDEX('*',line) -1)-CHARINDEX('%',line)) )) as Float),0) from #checkspace 
   where rtrim(ltrim(SUBSTRING(line,1,CHARINDEX('|',line) -1))) = @NewDisklocation

IF @FreeSpaceNewDisk < 51200
BEGIN
RAISERROR ('Free space is less than 50G on new location, you must select different disk with enough free space to proceed.', 11, 0);
RETURN; -- This will skip over the script and go to Skipper
END

-- Proceed Further if we have enough Free space available in New Disk location

SET @filename = '_'+cast(datepart(hh, getdate()) as varchar(100))+cast(datepart(MINUTE, getdate()) as varchar(100))+
'_'+cast(datepart(dd, getdate()) as varchar(100))++cast(datepart(mm, getdate()) as varchar(100))++cast(datepart(yyyy, getdate()) as varchar(100))

---- Check Filegroup Names:

IF OBJECT_ID('tempdb..#filegroupname') IS NOT NULL
DROP TABLE #filegroupname
CREATE TABLE #filegroupname([DBName][varchar](2000),[dbid] [int] NULL,[groupid] [int] NULL,[groupname] [nvarchar](2000) NULL,[growth] [int] NULL,[filename]  [nvarchar](400) NULL) ON [PRIMARY]
SET NOCOUNT ON
DECLARE @I INT
SET @I=0
DECLARE @Count INT
SELECT @Count=COUNT([Name]) FROM SYS.DATABASES
IF OBJECT_ID('tempdb..#DBNAME') IS NOT NULL
DROP TABLE #DBNAME

CREATE TABLE #DBNAME
(ID int identity(1,1),[Name] VARCHAR(2000))
INSERT #DBNAME
([Name])
SELECT DISTINCT DB_NAME(dbid)
FROM SYS.sysaltfiles
WHILE (@I<=@Count)
BEGIN
DECLARE @SQL_FG varchar(4000)
DECLARE @DatabaseName VARCHAR(4000)
SET @I=@I+1
SELECT @DatabaseName=[Name]
FROM #DBNAME
WHERE ID=@I
SET @SQL_FG=N'USE ['+@DatabaseName+']
insert into #filegroupname select db_name(),DB_ID(),groupid,groupname,null,null FROM sys.sysfilegroups'
execute (@SQL_FG)
END
-- UNION sysaltfiles table with #filegroupname to #Records table

IF OBJECT_ID('tempdb..#Records') IS NOT NULL
DROP TABLE #Records
Select growth, filename,dbid,groupid into #Records FROM sys.sysaltfiles
 UNION ALL
 SELECT growth, filename,dbid,groupid
 FROM #filegroupname where groupid<>0

-- Adding Another Column for #Records (to Add Filegroupname)
 ALTER TABLE #Records ADD groupname varchar(4000);

 -- Updating Filegroupname to #Records
 DECLARE @dbidGrowth int
 DECLARE @groupidGrowth int
 DECLARE @groupname varchar(4000)
--select growth, filename,dbid,groupid from #Records i inner join #filegroupname f on i.dbid
DECLARE db_cursor_growth CURSOR FOR
select DISTINCT dbid,groupid from #Records;

OPEN db_cursor_growth
FETCH NEXT FROM db_cursor_growth into @dbidGrowth,@groupidGrowth;
WHILE @@FETCH_STATUS = 0
BEGIN  
select @groupname = groupname FROM #filegroupname where dbid = @dbidGrowth and groupid = @groupidGrowth;

UPDATE #Records SET groupname = @groupname where dbid = @dbidGrowth and groupid = @groupidGrowth;
FETCH NEXT FROM db_cursor_growth into @dbidGrowth,@groupidGrowth;
END

CLOSE db_cursor_growth  
DEALLOCATE db_cursor_growth

declare @NewDisklocationCheck varchar(max)
set @NewDisklocationCheck =  @NewFileLocation

--IF a drive letter for FileLocation, ignore. Else ensure proper '\' to drive string
SET @NewDisklocationCheck = CASE WHEN LEN(@NewDisklocationCheck) > 2 THEN 
									CASE WHEN RIGHT(@NewDisklocationCheck, 2) != '\%' THEN @NewDisklocationCheck + '%' 
										 ELSE @NewDisklocationCheck 
									END
							  ELSE @NewDisklocationCheck 
						 END

IF OBJECT_ID('tempdb..#NewFileLocationGrowth') IS NOT NULL
DROP TABLE #NewFileLocationGrowth

select distinct dbid, groupid into #NewFileLocationGrowth from sys.sysaltfiles where filename like @NewDisklocationCheck and growth>0
--select * from  #NewFileLocationGrowth
--print @NewDisklocationCheck
--select distinct  databaseid,groupid from #addfiless --where Record like @NewDisklocationCheck

IF OBJECT_ID('tempdb..#addfiless') IS NOT NULL
DROP TABLE #addfiless
CREATE TABLE #addfiless([dbid] [int] NULL,[groupid] [int] NULL,[Record] [nvarchar](MAX) NULL) ON [PRIMARY]
--DECLARE @Counter INT
DECLARE @dbname Varchar(4000)
--insert into #addfiless 
insert into #addfiless SELECT dbid, groupid,'Alter Database ['+db_name(dbid)+']'+' ADD FILE '+'(NAME = N'''+db_name(dbid)+''+'_'+''+CAST(groupid as varchar(10))+''+''+@filename+''', FILENAME = '+CHAR(39)+@NewFileLocation+''+db_name(dbid)+''+'_'+''+CAST(groupid as varchar(10))+''+''+@filename+''+'.ndf'+CHAR(39)+ ', SIZE = 262144KB , FILEGROWTH = 262144KB ) TO FILEGROUP ['+groupname+']' from #Records where filename like @FileLocation and growth>0--i inner join #filegroupname f on i.dbid = f.dbid where i.filename like @FileLocation and i.growth>0

------

-- Getting the Files into #CommonFiles, which already growing in new location

IF OBJECT_ID('tempdb..#CommonFiles') IS NOT NULL
DROP TABLE #CommonFiles
Select dbid, groupid into #CommonFiles
 FROM #addfiless
INTERSECT  
 SELECT dbid, groupid
 FROM #NewFileLocationGrowth

 --- Checking Space utilization:

Declare @FilesNumber int
select @FilesNumber = count(*) FROM #addfiless;

print Cast(@FilesNumber as varchar(4000))+ ' Files eligible to add and '+ CAST(@FilesNumber*256 as varchar(4000)) + ' MB disk space will be utilized.' 
IF @Flag=1
Begin
PRINT ''
PRINT 'Please review the Pre-Execution Summary below, you can run store procedure with @flag = 2 for automation.'
print '	 exec mp_AddDataFiles '''+@FileLocation+''','''+@NewFileLocation+''',2'
PRINT ''
end
IF @Flag=2
Begin
PRINT ''
PRINT 'Database Add File Operation was initiated with @flag=2, it will automatically add files to new destination.'
PRINT ''
end
print 'Once completed, Please review the status tables mentioned below.'
print 'select * FROM [DBA_Admin].[dbo].[AddDataFiles]'
print 'select * FROM [DBA_Admin].[dbo].[CapDataFiles]'
PRINT ''

declare @FilesinNewPath int
select @FilesinNewPath = count(*) from #CommonFiles
IF (@FilesinNewPath >0)
		Begin
        print 'Cannot add the duplicate files, DB files already have growth enable to New Location Provided.'
		print ''
        declare @RecordNewPath varchar(4000)
        declare @NewLocationDBname varchar(4000)
        DECLARE db_cursor_growth CURSOR FOR
        select DISTINCT dbid,groupid from #CommonFiles;

        OPEN db_cursor_growth
        FETCH NEXT FROM db_cursor_growth into @dbidGrowth,@groupidGrowth;
        WHILE @@FETCH_STATUS = 0
        BEGIN  
        select @RecordNewPath = Record, @NewLocationDBname = DB_NAME(dbid) FROM #addfiless where dbid = @dbidGrowth and groupid = @groupidGrowth;
        declare @task varchar(100)
		IF @Flag=1
		Begin
		SET @task = 'Duplicate'
		print @RecordNewPath
		INSERT INTO DBA_Admin.dbo.AddDataFiles(DatabaseName,NewLocation,OldLocation,Command,Task) VALUES(@NewLocationDBname,@NewFileLocation,@FileLocation,@RecordNewPath,@task);
		END
		IF @Flag=2
		Begin
		print @RecordNewPath
		END
        FETCH NEXT FROM db_cursor_growth into @dbidGrowth,@groupidGrowth;
        END
        CLOSE db_cursor_growth
        DEALLOCATE db_cursor_growth
		end
ELSE
       Print 'No Duplicate files in New Location';


-- Adding Files Tasks
print ''
print '--Add Data Files.';
print ''
--select * from #addfiless
Declare @DISTINCTdbid int
Declare @DISTINCTgroupid int
----SET  @DISTINCTRecordCount = (select DISTINCT Databaseid from #addfiless) -- GROUP BY Databaseid;
DECLARE db_cursor CURSOR FOR
select distinct dbid,groupid FROM #addfiless except SELECT dbid, groupid FROM #CommonFiles
--select ROW_NUMBER() OVER(ORDER BY name ASC) from #addfiless
OPEN db_cursor
FETCH NEXT FROM db_cursor into @DISTINCTdbid,@DISTINCTgroupid;

WHILE @@FETCH_STATUS = 0 
BEGIN  
select @Addfile = record FROM #addfiless where dbid = @DISTINCTdbid and groupid = @DISTINCTgroupid;

declare @filesCount int
select @filesCount = count(*) from #addfiless
--select * from  #addfiless
select @dbname = db_name(@DISTINCTdbid) FROM #addfiless
IF @Flag=1
Begin
SET @task = 'Pre-check'
print @Addfile
--EXECUTE (@Addfile)
INSERT INTO DBA_Admin.dbo.AddDataFiles(DatabaseName,NewLocation,OldLocation,Command,Task) VALUES(@dbname,@NewFileLocation,@FileLocation,@Addfile,@task);
end
IF @Flag=2
Begin
SET @task = 'Executed'
print @Addfile
--print 'this part will execute the command also'
EXECUTE (@Addfile)
INSERT INTO DBA_Admin.dbo.AddDataFiles(DatabaseName,NewLocation,OldLocation,Command,Task) VALUES(@dbname,@NewFileLocation,@FileLocation,@Addfile,@task);
end
FETCH NEXT FROM db_cursor into @DISTINCTdbid,@DISTINCTgroupid;
END
CLOSE db_cursor  
DEALLOCATE db_cursor

--select * from #addfiless;
--drop table #addfiless
declare @Counter int
PRINT ''
PRINT '--Cap Data Files.';
IF OBJECT_ID('tempdb..#CapFiless') IS NOT NULL
DROP TABLE #CapFiless

CREATE TABLE #CapFiless([ROWNO] [bigint] NULL, [Databaseid] [int] NULL,	[Record] [nvarchar](MAX) NULL) ON [PRIMARY]
DECLARE @Capfile varchar(max) 
SET @Counter=1
WHILE ( @Counter <= @FilesNumber)
BEGIN
    ;with Records( ROWNO,Databaseid, Record) as  
   (SELECT ROW_NUMBER() OVER(ORDER BY name ASC) AS Rows, dbid, 'ALTER DATABASE ['+db_name(dbid)+']'+' MODIFY FILE '+'(NAME = N'''+name+''', FILEGROWTH = 0)' from sys.sysaltfiles where filename like @FileLocation and growth>0
    )
--select * from records
INSERT into #CapFiless select ROWNO,Databaseid, Record FROM Records where ROWNO=@Counter
--CROSS APPLY ()
--exec 'SELECT record FROM Records where ROWNO=@Counter'
SET @Counter  = @Counter  + 1
END

--- where --where ROW_NUMBER() OVER(ORDER BY ROWNO ASC)
Declare @RecordCount int
--SET  @DISTINCTRecordCount = (select DISTINCT Databaseid from #addfiless) -- GROUP BY Databaseid;
DECLARE db_cursor CURSOR FOR
select ROWNO from #CapFiless;

OPEN db_cursor  
FETCH NEXT FROM db_cursor into @RecordCount
WHILE @@FETCH_STATUS = 0  
BEGIN
select @Capfile = record FROM #CapFiless where ROWNO=@RecordCount
--set @dbname = ''
select @dbname = db_name(Databaseid) FROM #CapFiless where ROWNO=@RecordCount
--print @dbname
--PRINT ''
IF @Flag=1
Begin
set @task = 'Pre-Checks'
print @Capfile
--EXECUTE (@Capfile)
INSERT INTO DBA_Admin.dbo.CapDataFiles(DatabaseName,OldLocation,Command,Task) VALUES(@dbname,@FileLocation,@Capfile,@task);
end
IF @Flag=2
Begin
set @task = 'Executed'
print @Capfile
--print 'this part will execute the code also'
EXECUTE (@Capfile)
INSERT INTO DBA_Admin.dbo.CapDataFiles(DatabaseName,OldLocation,Command,Task) VALUES(@dbname,@FileLocation,@Capfile,@task);
end
FETCH NEXT FROM db_cursor into @RecordCount
END

CLOSE db_cursor  
DEALLOCATE db_cursor

GO

