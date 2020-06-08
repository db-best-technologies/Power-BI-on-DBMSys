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
/****** Object:  View [Tests].[VW_TST_ServerMachineDetails]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_ServerMachineDetails]
AS
SELECT 
		TOP 0	
		CAST(null as bit)				AutomaticManagedPagefile
		,CAST(null as varchar(200))		Domain
		,CAST(null as int)				DomainRole
		,CAST(null as bit)				HypervisorPresent
		,CAST(null as varchar(200))		Manufacturer
		,CAST(null as varchar(200))		Model
		,CAST(null as INT)				NumberOfLogicalProcessors
		,CAST(null as INT)				NumberOfProcessors
		,CAST(null as varchar(1000))	OEMStringArray
		,CAST(null as varchar(200))		Workgroup
		,CAST(null as int)				Metadata_TRH_ID
		,CAST(null as int)				Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_ServerMachineDetails]    Script Date: 6/8/2020 1:16:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_ServerMachineDetails] on [Tests].[VW_TST_ServerMachineDetails]
	instead of insert
as
set nocount on

merge Inventory.DomainNames d
	using (select distinct Domain
			from inserted
			where Domain is not null
				and DomainRole not in (0, 2)
			) s
		on DMN_Name = Domain
	when not matched then insert(DMN_Name)
							values(Domain);

merge Inventory.MachineManufacturers d
	using (select distinct Manufacturer
			from inserted
			where Manufacturer is not null
			) s
		on MMN_Name = Manufacturer
	when not matched then insert(MMN_Name)
							values(Manufacturer);

merge Inventory.MachineManufacturerModels d
	using (select distinct Model
			from inserted
			where Model is not null
			) s
		on MMD_Name = Model
	when not matched then insert(MMD_Name)
							values(Model);

merge Inventory.ServerOEMArrays d
	using (select distinct OEMStringArray
			from inserted
			where OEMStringArray is not null
			) s
		on SOA_ArrayHashed = hashbytes('MD5',left(CONVERT([varchar](max),OEMStringArray,(0)),(8000)))
	when not matched then insert(SOA_Array)
							values(OEMStringArray);

merge Inventory.WorkgroupNames d
	using (select distinct Workgroup
			from inserted
			where Workgroup is not null
				and DomainRole in (0, 2)
			) s
		on WGN_Name = Workgroup
	when not matched then insert(WGN_Name)
							values(Workgroup);

;with NewRows as
		(select MOB_ID, AutomaticManagedPageFile, DMN_ID, DomainRole, HypervisorPresent, MMN_ID, MMD_ID, NumberOfLogicalProcessors, NumberOfProcessors, SOA_ID, WGN_ID, ISNULL(IsVirtual,0) AS IsVirtual
			from inserted
				inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
				inner join Inventory.MonitoredObjects on TRH_MOB_ID = MOB_ID
				left join Inventory.DomainNames on DMN_Name = Domain
														and DomainRole not in (0, 2)
				left join Inventory.MachineManufacturers on MMN_Name = Manufacturer
				left join Inventory.MachineManufacturerModels on MMD_Name = Model
				left join Inventory.ServerOEMArrays on SOA_ArrayHashed = hashbytes('MD5',left(CONVERT([varchar](max),OEMStringArray,(0)),(8000)))
				left join Inventory.WorkgroupNames on WGN_Name = Workgroup
														and DomainRole in (0, 2)
				OUTER APPLY (SELECT 
										1 as IsVirtual
								FROM	Inventory.OSServers
								JOIN	Inventory.MachineManufacturers ON MMN_ID = OSS_MMN_ID
								JOIN	Inventory.MachineManufacturerModels ON MMD_ID = OSS_MMD_ID
								JOIN	Management.VirtualMachineManufacturers ON MMD_Name = VMM_ModelName AND MMN_Name = VMM_ManufacturerName
								WHERE	OSS_MOB_ID = MOB_ID
							)isv
			)
update Inventory.OSServers
set OSS_IsAutomaticManagedPageFile = AutomaticManagedPageFile,
	OSS_DMN_ID = DMN_ID,
	OSS_DRL_ID = DomainRole,
	OSS_IsHypervisorPresent = HypervisorPresent,
	OSS_MMN_ID = MMN_ID,
	OSS_MMD_ID = MMD_ID,
	OSS_NumberOfLogicalProcessors = NumberOfLogicalProcessors,
	OSS_NumberOfProcessors = NumberOfProcessors,
	OSS_SOA_ID = SOA_ID,
	OSS_WGN_ID = WGN_ID,
	OSS_IsVirtualServer = IsVirtual

from NewRows
where OSS_MOB_ID = MOB_ID
GO
