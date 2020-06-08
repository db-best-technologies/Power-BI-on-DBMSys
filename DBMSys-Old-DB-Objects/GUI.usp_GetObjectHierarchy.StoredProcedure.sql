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
/****** Object:  StoredProcedure [GUI].[usp_GetObjectHierarchy]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_GetObjectHierarchy]
as
;with ActiveMonitoredObjects as
	(select MOB_ID, MOB_Name, OBT_ID MOB_OBT_ID, MOB_Entity_ID, VER_Name, MOB_Engine_EDT_ID, OBT_Name MOB_OBT_Name
		from Inventory.MonitoredObjects
			inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
			inner join Management.PlatformCategories on PLC_ID = PLT_PLC_ID
			inner join Inventory.Versions on VER_ID = MOB_VER_ID
			cross apply (select top 1 OBT_ID, OBT_Name
					from BusinessLogic.ObjectTypes
					where OBT_PLC_ID = PLC_ID
					order by OBT_ID) o
		where MOB_OOS_ID = 1
	)	
select MOB_ID ID, MOB_OBT_ID ObjectTypeID, cast(null as int) ParentObjectTypeID, cast(null as int) ParentID, MOB_Name Name, 1 [Level],
		(select (select 'Edition' [@Name],
						cast(EDT_Name as sql_variant)
					for xml path('Col'), type),
				(select 'Version' [@Name],
						cast(Ver_Name as sql_variant)
					for xml path('Col'), type),
				(select 'Product level' [@Name],
						cast(PRL_Name as sql_variant)
					for xml path('Col'), type),
				(select 'Architechture' [@Name],
						cast(cast(OSS_Architecture as varchar(10)) + 'bit' as sql_variant)
					for xml path('Col'), type),
				(select 'Cluster node' [@Name],
						cast(case OSS_IsClusterNode
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Virtual Server' [@Name],
						cast(case OSS_IsVirtualServer
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Physical Memory' [@Name],
						cast(cast(ceiling(OSS_TotalPhysicalMemoryMB/1024.) as varchar(10)) + 'GB' as sql_variant)
					for xml path('Col'), type),
				(select '32bit memory flags' [@Name],
						cast(case when OSS_Architecture = 32
									then stuff(case OSS_IsPAEEnabled
														when 1 then ', PAE'
														else ''
													end
												+ case when OSS_MaxProcessMemorySizeMB > 2150400
														then ', 3GB'
														else ''
													end, 1, 2, '')
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Is Page File Mananged By System' [@Name],
						cast(case OSS_IsAutomaticManagedPageFile
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Power Plan' [@Name],
						cast(PPT_Name as sql_variant)
					for xml path('Col'), type)
		for xml path('Columns'), type) [Additional Data]
from ActiveMonitoredObjects
	inner join Inventory.OSServers o on MOB_ID = OSS_MOB_ID
	inner join Inventory.Editions on MOB_Engine_EDT_ID = EDT_ID
	left join Inventory.ProductLevels on OSS_PRL_ID = PRL_ID
	inner join Management.PlatformTypes on OSS_PLT_ID = PLT_ID
	left join Inventory.OSProductTypes on OSS_OPT_ID = OPT_ID
	left join Inventory.PowerPlanTypes on OSS_PPT_ID = PPT_ID
where MOB_OBT_Name = 'OS Server'
union all
select MOB_ID ID, MOB_OBT_ID ObjectTypeID, cast(null as int) ParentObjectTypeID, cast(null as int) ParentID, MOB_Name Name, 1 [Level],
	(select (select 'Edition' [@Name],
						cast(EDT_Name as sql_variant)
					for xml path('Col'), type),
				(select 'Version' [@Name],
						cast(Ver_Name as sql_variant)
					for xml path('Col'), type),
				(select 'Product level' [@Name],
						cast(PRL_Name as sql_variant)
					for xml path('Col'), type),
				(select 'Architechture' [@Name],
						cast(cast(DID_Architecture as varchar(10)) + 'bit' as sql_variant)
					for xml path('Col'), type),
				(select 'Clustered' [@Name],
						cast(case DID_IsClustered
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Authentication method' [@Name],
						cast(case DID_IsIntegratedSecurityOnly
									when 1 then 'Integrated Security only'
									when 0 then 'Integrated Security and SQL Authentication'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Port' [@Name],
						cast(isnull(DID_Port, DID_DynamicPort) as sql_variant)
					for xml path('Col'), type),
				(select 'Dynamic Port' [@Name],
						cast(case when DID_DynamicPort is not null
									then 'Y'
									else 'N'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Collation' [@Name],
						cast(CLT_Name as sql_variant)
					for xml path('Col'), type),
				(select 'Service Last Start Date' [@Name],
						cast(DID_LastRestartDate as sql_variant)
					for xml path('Col'), type),
				(select 'Enabled Network Protocols' [@Name],
						cast(STUFF(case DID_IsTcpEnabled
											when 1 then ', TCP'
											else ''
									end
									+ case DID_IsNamedPipesEnabled
											when 1 then ', Named Pipes'
											else ''
										end
									+ case DID_IsNamedPipesEnabled
											when 1 then ', Named Pipes'
											else ''
										end
									+ case DID_IsViaEnabled
											when 1 then ', Via'
											else ''
										end, 1, 2, '') as sql_variant)
					for xml path('Col'), type),
				(select 'Allow Lock Pages In Memory' [@Name],
						cast(DID_AllowLockPagesInMemory as sql_variant)
					for xml path('Col'), type)
		for xml path('Columns'), type) [Additional Data]
from ActiveMonitoredObjects
	inner join Inventory.DatabaseInstanceDetails on DID_DFO_ID = MOB_Entity_ID
	inner join Inventory.Editions on DID_EDT_ID = EDT_ID
	inner join Inventory.OSServers on DID_OSS_ID = OSS_ID
	inner join Inventory.ProductLevels on DID_PRL_ID = PRL_ID
	inner join Inventory.CollationTypes on DID_CLT_ID = CLT_ID
where MOB_OBT_Name = 'SQL Instacne'
union all
select IDB_ID ID, OBT_ID ObjectTypeID, MOB_OBT_ID ParentObjectTypeID, IDB_MOB_ID ParentID, IDB_Name Name, 2 [Level],
	(select (select 'Status' [@Name],
						cast(IDS_Name as sql_variant)
					for xml path('Col'), type),
				(select 'Accessibility' [@Name],
						cast(DAT_Name as sql_variant)
					for xml path('Col'), type),
				(select 'Owner' [@Name],
						cast(INL_Name as sql_variant)
					for xml path('Col'), type),
				(select 'Source Database Name' [@Name],
						cast([Source Database Name] as sql_variant)
					for xml path('Col'), type),
				(select 'Date created' [@Name],
						cast(IDB_CreateDate as sql_variant)
					for xml path('Col'), type),
				(select 'Compatibility Level' [@Name],
						cast(IDB_CompatibilityLevel as sql_variant)
					for xml path('Col'), type),
				(select 'Collation' [@Name],
						cast(CLT_Name as sql_variant)
					for xml path('Col'), type),
				(select 'System Database' [@Name],
						cast(case when IDB_Name in ('model', 'tempdb', 'master', 'msdb') or IDB_IsDistributor = 1
									then 'Y'
									else 'N'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Read Only' [@Name],
						cast(case IDB_IsReadOnly
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Auto Close' [@Name],
						cast(case IDB_IsAutoCloseOn
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Auto Shrink' [@Name],
						cast(case IDB_IsAutoShrinkOn
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Snapshot Isolation Enabled' [@Name],
						cast(case IDB_SnapshotIsolationState
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Read Committed Snapshot Enabled' [@Name],
						cast(case IDB_IsReadCommittedSnapshotOn
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Recovery Model' [@Name],
						cast(RCM_Name as sql_variant)
					for xml path('Col'), type),
				(select 'Page Verification Option' [@Name],
						cast(PVO_Name as sql_variant)
					for xml path('Col'), type),
				(select 'Auto Create Statistics Enabled' [@Name],
						cast(case IDB_IsAutoCreateStatsOn
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Auto Update Statistics Enabled' [@Name],
						cast(case IDB_IsAutoUpdateStatsOn
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Auto Update Statistics Async Enabled' [@Name],
						cast(case IDB_IsAutoUpdateStatsAsyncOn
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Recursive Triggers Enabled' [@Name],
						cast(case IDB_IsRecursiveTriggersOn
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Trust Worthy' [@Name],
						cast(case IDB_IsTrustworthyOn
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Database Chaining Enabled' [@Name],
						cast(case IDB_IsDatabaseChainingOn
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Forced Parameterization Enabled' [@Name],
						cast(case IDB_IsParameterizationForced
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Replication Roles' [@Name],
						cast(stuff(case IDB_IsDistributor
										when 1 then ', Distributor'
										else ''
									end
										+ case IDB_IsPublished
											when 1 then ', Transactional publisher'
											else ''
										end
										+ case IDB_IsSubscribed
											when 1 then ', Transactional subscriber'
											else ''
										end
										+ case IDB_IsMergePublished
											when 1 then ', Merge publisher'
											else ''
										end, 1, 2, '') as sql_variant)
					for xml path('Col'), type),
				(select 'Service Broker Enabled' [@Name],
						cast(case IDB_IsBrokerEnabled
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Change Data Capture Enabled' [@Name],
						cast(case IDB_IsCDCEnabled
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Encrypted' [@Name],
						cast(case IDB_IsEncrypted
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Date Correlation Enabled' [@Name],
						cast(case IDB_IsDateCorrelationOn
									when 1 then 'Y'
									when 0 then 'N'
									else 'N/A'
								end as sql_variant)
					for xml path('Col'), type),
				(select 'Last Full Backup Date' [@Name],
						cast(IDB_LastFullBackupDate as sql_variant)
					for xml path('Col'), type),
				(select 'Avg. Full Backup Interval' [@Name],
						cast(IDB_AvgFullBackupInterval as sql_variant)
					for xml path('Col'), type),
				(select 'Avg. Log Backup Interval' [@Name],
						cast(IDB_AvgLogBackupInterval as sql_variant)
					for xml path('Col'), type),
				(select 'Avg. backup Compression Ratio' [@Name],
						cast(IDB_AvgBackupCompressionRatio as sql_variant)
					for xml path('Col'), type)
		for xml path('Columns'), type) [Additional Data]
from Inventory.InstanceDatabases d
	inner join ActiveMonitoredObjects on IDB_MOB_ID = MOB_ID
	inner join BusinessLogic.ObjectTypes on OBT_Name = 'SQL Server Database'
	inner join Inventory.CollationTypes on CLT_ID = IDB_CLT_ID
	inner join Inventory.InstanceDatabaseStates on IDS_ID = IDB_IDS_ID
	inner join Inventory.RecoveryModels on RCM_ID = IDB_RCM_ID
	inner join Inventory.PageVerificationOptions on PVO_ID = IDB_PVO_ID
	inner join Inventory.DatabaseAccessibilityType on DAT_ID = IDB_DAT_ID
	left join Inventory.InstanceLogins on INL_ID = IDB_Owner_INL_ID
	outer apply (select d1.IDB_Name [Source Database Name]
					from Inventory.InstanceDatabases d1
					where d.IDB_Source_IDB_ID = d1.IDB_ID) d1
GO
