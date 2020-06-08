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
/****** Object:  View [Tests].[VW_TST_AIXProcessors]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_AIXProcessors]
as
select top 0 CAST(null as varchar(100)) [Processor Type],
			CAST(null as varchar(100)) [Processor Implementation Mode],
			CAST(null as varchar(100)) [Processor Version],
			CAST(null as int) [Number Of Processors],
			CAST(null as varchar(20)) [Processor Clock Speed],
			CAST(null as varchar(100)) [Model Implementation],
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_AIXProcessors]    Script Date: 6/8/2020 1:15:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_AIXProcessors] on [Tests].[VW_TST_AIXProcessors]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted

merge Inventory.ProcessorNames d
	using (select distinct [Processor Type] + ' ' + [Processor Implementation Mode] + ' ' + [Processor Version] Name
			from inserted
			where [Processor Type] + ' ' + [Processor Implementation Mode] + ' ' + [Processor Version] is not null) s
	on Name = PSN_Name
	when not matched then insert(PSN_Name)
							values(Name);

merge Inventory.ProcessorCaptions d
	using (select distinct [Model Implementation] Caption
			from inserted
			where [Model Implementation] is not null) s
	on Caption = PCA_Caption
	when not matched then insert(PCA_Caption)
							values(Caption);


merge Inventory.ProcessorManufacturers d
	using (select distinct case when [Processor Implementation Mode] like '%POWER%' then 'IBM' end Manufacturer
			from inserted
			where case when [Processor Implementation Mode] like '%POWER%' then 'IBM' end is not null) s
	on Manufacturer = PMN_Name
	when not matched then insert(PMN_Name)
							values(Manufacturer);

merge Inventory.Processors d
	using (select TRH_MOB_ID MOB_ID, 'CPU' + CAST(Num as varchar(10)) DeviceID, PSN_ID, PCA_ID, PMN_ID,
				cast(replace([Processor Clock Speed], ' MHz', '') as int) ClockSpeed, OSS_Architecture, TRH_ID, Metadata_ClientID, TRH_StartDate
			from inserted
				inner join Collect.TestRunHistory l on TRH_ID = Metadata_TRH_ID
				inner join Infra.Numbers on [Number Of Processors] <= Num
				inner join Inventory.OSServers on OSS_MOB_ID = TRH_MOB_ID
				left join Inventory.ProcessorNames on PSN_Name = [Processor Type] + ' ' + [Processor Implementation Mode] + ' ' + [Processor Version]
				left join Inventory.ProcessorCaptions on PCA_Caption = [Model Implementation]
				left join Inventory.ProcessorManufacturers on PMN_Name = case when [Processor Implementation Mode] like '%POWER%' then 'IBM' end
			) s
		on PRS_MOB_ID = MOB_ID
			and PRS_DeviceID = DeviceID
	when matched then update set
						PRS_PSN_ID = PSN_ID,
						PRS_PCA_ID = PCA_ID,
						PRS_PMN_ID = PMN_ID,
						PRS_MaxClockSpeed = ClockSpeed,
						PRS_DataWidth = OSS_Architecture,
						PRS_LastSeenDate = TRH_StartDate,
						PRS_Last_TRH_ID = TRH_ID
	when not matched then insert(PRS_ClientID, PRS_MOB_ID, PRS_DeviceID, PRS_PSN_ID, PRS_PCA_ID, PRS_PMN_ID, PRS_MaxClockSpeed, PRS_DataWidth,
									PRS_InsertDate, PRS_LastSeenDate, PRS_Last_TRH_ID)
							values(Metadata_ClientID, MOB_ID, DeviceID, PSN_ID, PCA_ID, PMN_ID, ClockSpeed, OSS_Architecture, TRH_StartDate, TRH_StartDate,
									TRH_ID);
GO
