/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.1601)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2016
    Target Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Target Database Engine Type : Standalone SQL Server
*/
USE [DBMSYS_CityofTucson_City_of_Tucson]
GO
/****** Object:  StoredProcedure [GUI].[usp_SetOperationConfigurations]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_SetOperationConfigurations]
--DECLARE 
		@OCF_ID TINYINT --= 2
AS
DECLARE 
		@xml		XML
		,@xml_tmp	XML 



SELECT	@xml = OCF_XML from Management.OperationConfigurations where OCF_ID = @OCF_ID

IF OBJECT_ID('tempdb..#TABLES') is not null
	DROP TABLE #TABLES

CREATE TABLE #TABLES
(
	T_ID	INT IDENTITY(1,1)
	,T_MOD	NVARCHAR(255)
	,T_CMD	NVARCHAR(MAX)
)

;WITH tbls AS
(
	SELECT 
			T.UpdTbl.query('.') AS xml_part 
			,t.UpdTbl.value('@Name[1]','nvarchar(255)') as tbl_name
		
	--INTO	#TABLES
	FROM	@xml.nodes('/Configuration/Tables/Table') T(UpdTbl)  
),

rws as (
SELECT 
		tbl_name
		,t.r.value('@FilterColumn[1]','nvarchar(255)') as col
		,t.r.value('@Operator[1]','nvarchar(255)') as Oper
		,t.r.value('@Value[1]','nvarchar(255)') as ID
		,t.r.query('.') as column_nodes
FROM	tbls
CROSS APPLY xml_part.nodes('/Table/Row') t(r)
)

INSERT INTO #TABLES(T_MOD,T_CMD)
select 
		'TABLES'
		,'update ' + tbl_name + ' set ' + t2.c.value('@Name','nvarchar(255)') + ' = ''' + t2.c.value('@Value','nvarchar(255)') + ''' where ' + col + ' ' +  oper + ID

from	rws
CROSS APPLY column_nodes.nodes('Row/Column') t2(c)



INSERT INTO #TABLES(T_MOD,T_CMD)
SELECT 
			'SETTINGS'
			,'UPDATE Management.Settings SET SET_Value = ' + t.UpdTbl.value('@Value[1]','nvarchar(255)') + ' WHERE SET_Module = ''' + t.UpdTbl.value('@Module[1]','nvarchar(255)') + ''' AND SET_Key = ''' + t.UpdTbl.value('@Key[1]','nvarchar(255)')  + ''''
FROM	@xml.nodes('/Configuration/Settings/Setting') T(UpdTbl)  


INSERT INTO #TABLES(T_MOD,T_CMD)
SELECT 
			'JOBS'
			,REPLACE('IF EXISTS (SELECT * FROM msdb.dbo.sysjobs where name = N''%DBMSYSDBNAME%_AggregateResults'') exec msdb.dbo.sp_update_job @job_name = ''' + t.UpdTbl.value('@Name[1]','nvarchar(255)') + ''',@enabled = ' + t.UpdTbl.value('@IsEnabled[1]','nvarchar(255)'),'%DBMSYSDBNAME%',DB_NAME())
FROM	@xml.nodes('/Configuration/Jobs/Job') T(UpdTbl)  

begin try
	begin tran 
	

	declare 
			@cmd	NVARCHAR(MAX)
		
	declare cCommands cursor local static for
		SELECT 
				T_CMD
		FROM	#TABLES
		ORDER BY T_ID

	open cCommands
	fetch next from cCommands into @cmd
	while @@fetch_status = 0
	begin
	
		print @cmd
		exec(@cmd)
		fetch next from cCommands into @cmd
	end
	close cCommands
	deallocate cCommands
	commit tran 
end try
begin catch
	if @@trancount>0
		rollback;
	Throw;
end catch
GO
