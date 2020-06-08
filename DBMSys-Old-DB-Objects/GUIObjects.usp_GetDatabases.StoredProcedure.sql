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
/****** Object:  StoredProcedure [GUIObjects].[usp_GetDatabases]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUIObjects].[usp_GetDatabases]
	@ParentCode varchar(50) = null,
	@ParentID int,
	@ParentName varchar(900) = null,
	@SearchString varchar(1000) = null
as
set transaction isolation level read uncommitted
set nocount on
declare @SQL nvarchar(max)
set @SQL =
'select IDB_ID ID, IDB_Name Name, IDS_Name [Status], IDB_Name [Accessibility], INL_Name [Owner],
	[Source Database Name],
	IDB_CreateDate [Date created], IDB_CompatibilityLevel [Compatibility level], CLT_Name [Collation],
	case when IDB_Name in (''model'', ''tempdb'', ''master'', ''msdb'') or IDB_IsDistributor = 1
		then ''Y''
		else ''N''
	end [System database],
	case IDB_IsReadOnly
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Read only],
	case IDB_IsAutoCloseOn
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Auto close],
	case IDB_IsAutoShrinkOn
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Auto shrink],
	case IDB_SnapshotIsolationState
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Snapshot Isolation enabled],
	case IDB_IsReadCommittedSnapshotOn
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Read Committed Snapshot enabled],
	RCM_Name [Recovery model],
	PVO_Name [Page verification option],
	case IDB_IsAutoCreateStatsOn
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Auto create statistics enabled],
	case IDB_IsAutoUpdateStatsOn
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Auto update statistics enabled],
	case IDB_IsAutoUpdateStatsAsyncOn
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Auto update statistics async enabled],
	case IDB_IsRecursiveTriggersOn
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Recursive triggers enabled],
	case IDB_IsTrustworthyOn
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Trust worthy],
	case IDB_IsDatabaseChainingOn
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Database chaining enabled],
	case IDB_IsParameterizationForced
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Forced parameterization enabled],	
	stuff(case IDB_IsDistributor
				when 1 then '', Distributor''
				else ''''
			end
				+ case IDB_IsPublished
					when 1 then '', Transactional publisher''
					else ''''
				end
				+ case IDB_IsSubscribed
					when 1 then '', Transactional subscriber''
					else ''''
				end
				+ case IDB_IsMergePublished
					when 1 then '', Merge publisher''
					else ''''
				end, 1, 2, '''') [Replication roles],
	case IDB_IsBrokerEnabled
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Service Broker enabled],	
	case IDB_IsCDCEnabled
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Change Data Capture enabled],
	case IDB_IsEncrypted
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [TDE Encrypted],
	case IDB_IsDateCorrelationOn
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Date Correlation enabled],
	IDB_LastFullBackupDate [Last Full backup date],
	IDB_AvgFullBackupInterval [Avg. Full backup interval],
	IDB_AvgLogBackupInterval [Avg. Log backup interval],
	IDB_AvgBackupCompressionRatio [Avg. backup compression ratio]
from Inventory.InstanceDatabases d
	inner join Inventory.CollationTypes on CLT_ID = IDB_CLT_ID
	inner join Inventory.InstanceDatabaseStates on IDS_ID = IDB_IDS_ID
	inner join Inventory.RecoveryModels on RCM_ID = IDB_RCM_ID
	inner join Inventory.PageVerificationOptions on PVO_ID = IDB_PVO_ID
	inner join Inventory.DatabaseAccessibilityType on DAT_ID = IDB_DAT_ID
	left join Inventory.InstanceLogins on INL_ID = IDB_Owner_INL_ID
	outer apply (select d1.IDB_Name [Source Database Name]
					from Inventory.InstanceDatabases d1
					where d.IDB_Source_IDB_ID = d1.IDB_ID) d1
where IDB_MOB_ID = @ParentID'
+ case when @SearchString is not null
		then + char(13)+char(10) + '	and (IDB_Name like ''%'' + @SearchString + ''%'')'
		else ''
	end
+ char(13)+char(10) + 'order by [System database] desc, IDB_Name'
exec sp_executesql @SQL,
					N'@ParentID int,
						@SearchString varchar(1000)',
					@ParentID = @ParentID,
					@SearchString = @SearchString
GO
