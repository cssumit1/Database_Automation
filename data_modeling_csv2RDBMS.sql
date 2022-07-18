SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @RecordKey varchar(100)
DECLARE @Record varchar(100)
DECLARE @tripid varchar(100)

IF OBJECT_ID('tempdb..#Records') IS NOT NULL
DROP TABLE #Records

CREATE TABLE #Records(
    [Title] [nvarchar](100) NULL,
    [Value] [nvarchar](100) NULL,
    [tripid] [nchar](100) NULL
) ON [PRIMARY]
GO

  
  ;With MyCTE0 as (
     select tripid, FlexDetails
  ,s =   Replace(FlexDetails, '|', '","') 
 ,s1 = Replace(FlexDetails, '|', '","') 
  from [Mytest].[dbo].['Air Offline11']
 ),
  MyCTE1 as (
  select tripid, s = '["' + Replace(s, '->', ':') + '"]'
  , s1 = '["' + Replace(s, '->', ':') + '"]'
     from MyCTE0
       ),
         MyCTE2 as (
  select tripid, s =  Replace(s, '","', ' ')
  ,  s1 =  Replace(s, '","', ' ')
     from MyCTE1
       ),
       MyCTE3 as (
      SELECT tripid,s, s1, k1 = t.[key], v1 = t.[value]
 FROM MyCTE1        
 CROSS APPLY OPENJSON (s, N'$') t
 )

INSERT INTO #Records SELECT     SUBSTRING(v1, 0, CHARINDEX(':', v1)), 
    SUBSTRING(v1, CHARINDEX(':', v1)  + 1, LEN(v1)), tripid
 FROM MyCTE3
CROSS APPLY (SELECT t1.[key] k2 , t1.[value] v2 FROM OPENJSON (s, N'$') t1 where t1.[key] = MyCTE3.k1) t
 --GO

--  INSERT INTO #Records 
--           ([Key]
--           ,[Value]
--           ,[tripid])
--     VALUES
--           (@RecordKey,@Record,@tripid);


select * from #Records where Title <>''
