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
/****** Object:  StoredProcedure [Reports].[usp_CurrentEnvironmentPhysicalAndVirtualVariability]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Reports].[usp_CurrentEnvironmentPhysicalAndVirtualVariability]
as
set nocount on

;with Results as
	(select sum(cast(CPF_IsVM as int))*100/count(*) Value
		from Consolidation.CPUFactoring
		where exists (select *
						from Consolidation.ParticipatingDatabaseServers
						where PDS_Server_MOB_ID = CPF_MOB_ID)
	)
select top 1
		case Value
			when 0 then 'There is no virtualization in the assessed environment'
			when 100 then 'The assessed environment is fully virtualized'
			else concat('The assessed environment is ', Value, '% virtualized')
		end Value
from Results
GO
