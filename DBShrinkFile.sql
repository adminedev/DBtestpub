USE [maintenance]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--todo 
	--1. 

--exec [dbo].[DBShrinkFile] 0, 'INTRANET_TEST_kontakt_v1' 
--exec [dbo].[DBShrinkFile] 1, 'INTRANET_TEST_kontakt_v1' 
--DBCC SHRINKFILE na bazie @P_DBname z obciêciem logów do 0!

CREATE OR ALTER   procedure [dbo].[DBShrinkFile]
	@Mode as tinyint = 0,
	@P_DBname as nvarchar(250) =''
		-- 0 - listuje informacje skrypt do DBCC SHRINKFILE na bazie @P_DBname z obciêciem logów do 0!
		-- 1 - DBCC SHRINKFILE na bazie @P_DBname z obciêciem logów do 0!
AS
begin

declare @debug tinyint = 0

declare @top10 varchar(10) = ''

declare @query as nvarchar(max)
set @query = ''
declare @Logname as nvarchar(250) = ''
DECLARE @Logparams NVARCHAR(255) = '@Log nvarchar(250) OUTPUT'
declare @Modelname as nvarchar(10) = ''
DECLARE @Modelparams NVARCHAR(255) = '@Model nvarchar(10) OUTPUT'

set @query = 'select @Log = name from '+@P_DBname+'.sys.database_files where type_desc =''LOG'''
exec sp_executesql @query,  @LOGparams, @LOG = @Logname OUTPUT

set @query = 'select @Model = recovery_model_desc from msdb.sys.databases where name = '''+@P_DBname+''''
exec sp_executesql @query,  @Modelparams, @Model = @Modelname OUTPUT

set @query  =   
'USE '+@P_DBname+'
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE '+@P_DBname+'
SET RECOVERY SIMPLE;
-- Shrink the truncated log file to creation size.
DBCC SHRINKFILE ('''+@LOGname+ ''', 0);
-- Reset the database recovery model.
ALTER DATABASE '+@P_DBname+'
SET RECOVERY '+@Modelname+';
'

end

if @Mode = 0 print @query
if @Mode = 1 exec sp_executesql @query

GO


