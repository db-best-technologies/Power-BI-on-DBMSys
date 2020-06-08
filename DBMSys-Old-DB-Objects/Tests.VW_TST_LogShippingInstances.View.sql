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
/****** Object:  View [Tests].[VW_TST_LogShippingInstances]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_LogShippingInstances]
as
select top 0 CAST(null as bit) IsPrimary,
			CAST(null as nvarchar(128)) database_name,
			CAST(null as nvarchar(128)) opposite_server,
			CAST(null as nvarchar(128)) opposite_database,
			CAST(null as datetime) last_backup_date,
			CAST(null as datetime) last_copied_date,
			CAST(null as datetime) last_restored_date,
			CAST(null as int) last_restored_latency,
			CAST(null as datetime) CurrentDateTime,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_LogShippingInstances]    Script Date: 6/8/2020 1:16:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_LogShippingInstances] on [Tests].[VW_TST_LogShippingInstances]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@Primary_MOB_ID int,
		@Secondary_MOB_ID int,
		@StartDate datetime2(3)

select top 1 @MOB_ID = l.TRH_MOB_ID,
			@StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory l on Metadata_TRH_ID = l.TRH_ID

select @Primary_MOB_ID = case IsPrimary
							when 1 then @MOB_ID
							when 0 then MOB_ID
						end,
		@Secondary_MOB_ID = case IsPrimary
							when 1 then MOB_ID
							when 0 then @MOB_ID
						end
from inserted
	inner join Inventory.DatabaseInstanceDetails on DID_Name = opposite_server
	inner join Inventory.MonitoredObjects on MOB_PLT_ID = 1
											and MOB_Entity_ID = DID_DFO_ID

merge Inventory.LogShippingInstances d
	using (select IsPrimary, p.IDB_ID Primary_IDB_ID, s.IDB_ID Secondary_IDB_ID, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.InstanceDatabases p on p.IDB_MOB_ID = @Primary_MOB_ID
															and p.IDB_Name = case IsPrimary
																					when 1 then database_name
																					when 0 then opposite_database
																				end
				inner join Inventory.InstanceDatabases s on s.IDB_MOB_ID = @Secondary_MOB_ID
															and s.IDB_Name = case IsPrimary
																					when 1 then opposite_database
																					when 0 then database_name
																				end
			where IsPrimary = 1
			) s
		on LSI_Primary_MOB_ID = @Primary_MOB_ID
			and LSI_Primary_IDB_ID = Primary_IDB_ID
			and LSI_Secondary_MOB_ID = @Secondary_MOB_ID
			and LSI_Secondary_IDB_ID = Secondary_IDB_ID
	when matched then update set
							LSI_IsReportedFromPrimary = case IsPrimary
															when 1 then 1
															else LSI_IsReportedFromPrimary
														end,
							LSI_IsReportedFromSecondary = case IsPrimary
															when 0 then 1
															else LSI_IsReportedFromSecondary
														end,
							LSI_LastSeenDate = @StartDate,
							LSI_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(LSI_ClientID, LSI_Primary_MOB_ID, LSI_Primary_IDB_ID, LSI_Secondary_MOB_ID, LSI_Secondary_IDB_ID, LSI_IsReportedFromPrimary,
								LSI_IsReportedFromSecondary, LSI_InsertDate, LSI_LastSeenDate, LSI_Last_TRH_ID)
						values(Metadata_ClientID, @Primary_MOB_ID, Primary_IDB_ID, @Secondary_MOB_ID, Secondary_IDB_ID,
								case IsPrimary
									when 1 then 1
									else 0
								end,
								case IsPrimary
									when 0 then 1
									else 0
								end, @StartDate, @StartDate, Metadata_TRH_ID);

insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, [Status], Metadata_TRH_ID, Metadata_ClientID)
select 'Log Shipping', GNC_CounterName,
		left(pm.MOB_Name + ' (' + p.IDB_Name + ') --> ' + sm.MOB_Name + ' (' + s.IDB_Name + ')', 850) Instance,
		case GNC_CounterName
				when 'Minutes Since Last Backup' then DATEDIFF(minute, last_backup_date, CurrentDateTime)
				when 'Minutes Since Last Copy' then DATEDIFF(minute, last_copied_date, CurrentDateTime)
				when 'Minutes Since Last Restore' then DATEDIFF(minute, last_restored_date, CurrentDateTime)
				when 'Restore Latency (Minutes)' then last_restored_latency
		end Value, null [Status], Metadata_TRH_ID, Metadata_ClientID
from inserted
	inner join Inventory.InstanceDatabases p on p.IDB_MOB_ID = @Primary_MOB_ID
												and p.IDB_Name = case IsPrimary
																		when 1 then database_name
																		when 0 then opposite_database
																	end
	inner join Inventory.InstanceDatabases s on s.IDB_MOB_ID = @Secondary_MOB_ID
												and s.IDB_Name = case IsPrimary
																		when 1 then opposite_database
																		when 0 then database_name
																	end
	inner join Inventory.MonitoredObjects pm on pm.MOB_ID = @Primary_MOB_ID
	inner join Inventory.MonitoredObjects sm on sm.MOB_ID = @Secondary_MOB_ID
	inner join (select GNC_CounterName, GNC_CSY_ID, GNC_ID
				from PerformanceData.GeneralCounters
				where GNC_CategoryName = 'Log Shipping') g
		on (IsPrimary = 1 and GNC_CounterName = 'Minutes Since Last Backup')
			or (IsPrimary = 0 and GNC_CounterName <> 'Minutes Since Last Backup')
GO
