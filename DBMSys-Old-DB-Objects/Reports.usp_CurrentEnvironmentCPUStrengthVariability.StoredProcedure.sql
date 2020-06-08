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
/****** Object:  StoredProcedure [Reports].[usp_CurrentEnvironmentCPUStrengthVariability]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Reports].[usp_CurrentEnvironmentCPUStrengthVariability]
as
set nocount on

;with Results as
	(select min(CPF_SingleCPUScore) MinValue,
			max(CPF_SingleCPUScore) MaxValue,
			sum(iif(CPF_SingleCPUScore < 2000, 1, 0))*100/count(*) VeryOldCPUPercentage
		from Consolidation.CPUFactoring
		where exists (select *
						from Consolidation.ParticipatingDatabaseServers
						where PDS_Server_MOB_ID = CPF_MOB_ID)
	)
select top 1
		case when MaxValue - MinValue < 3000 then 'The CPU types in the assessed environment is rather unified'
			else 'There is a wide range of CPU types in the assessed environment'
		end Fact
from Results
union all
select concat(VeryOldCPUPercentage, '% of the CPUs are very old and very weak - modernization can cut down the number of cores') Fact
from Results
where VeryOldCPUPercentage > 0
GO
