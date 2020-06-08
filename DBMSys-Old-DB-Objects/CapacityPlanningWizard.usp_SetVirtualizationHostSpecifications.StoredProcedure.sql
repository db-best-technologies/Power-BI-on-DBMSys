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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_SetVirtualizationHostSpecifications]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [CapacityPlanningWizard].[usp_SetVirtualizationHostSpecifications]
	@ServerType varchar(100),
	@CPUName varchar(100),
	@NumberOfCPUSockets int,
	@MemoryGB int,
	@NetworkSpeedGbit int
as
set nocount on

truncate table Consolidation.VirtualizationESXServers

insert into Consolidation.VirtualizationESXServers(VES_ServerType, VES_CPUName, VES_NumberOfCPUSockets, VES_MemoryMB, VES_NetworkSpeedMbit, VES_IsActive)
values(@ServerType, @CPUName, @NumberOfCPUSockets, @MemoryGB*1024, @NetworkSpeedGbit*1024, 1)
GO
