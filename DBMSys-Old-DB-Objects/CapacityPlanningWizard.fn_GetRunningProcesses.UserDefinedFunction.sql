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
/****** Object:  UserDefinedFunction [CapacityPlanningWizard].[fn_GetRunningProcesses]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [CapacityPlanningWizard].[fn_GetRunningProcesses]() returns table  
as  
return  
 select er.session_id, PSP_ID  
 from sys.dm_exec_requests er   
  cross apply sys.dm_exec_sql_text(er.sql_handle) st  
  inner join CapacityPlanningWizard.ProcessSteps on object_id(PSP_ProcedureName) = st.objectid  
 where /*er.database_id replaced by */st.dbid = db_id()
GO
