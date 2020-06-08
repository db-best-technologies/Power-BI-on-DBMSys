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
/****** Object:  StoredProcedure [RuleChecks].[usp_DiskWithBlockSizeSmallerThan64K]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_DiskWithBlockSizeSmallerThan64K]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

;with Disks as
		(select DSK_MOB_ID, DSK_ID, DSK_Path,
					cast(stuff((select ', ' + Purpose
						from (select distinct 'Backup' Purpose
								from Inventory.BackupLocations 
								where BKL_DSK_ID = DSK_ID
								union all
								select distinct
									case when IDB_Name in ('master', 'model', 'msdb') then 'System Databases'
										when IDB_Name = 'tempdb' then 'tempdb'
										else 'User Databases'
									end
									+ ' (' + DFT_Name + ')'
									Purpose
								from Inventory.DatabaseFiles
									inner join Inventory.InstanceDatabases on DBF_IDB_ID = IDB_ID
									inner join Inventory.DatabaseFileTypes on DBF_DFT_ID = DFT_ID
								where DBF_DSK_ID = DSK_ID) t
						for xml path('')), 1, 2, '') as varchar(8000)) Purposes, DSK_BlockSize
		from Inventory.Disks
				inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
				inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
																	and PRM_MOB_ID = DSK_MOB_ID
		where DSK_BlockSize < 65536
		)
select @ClientID, @PRR_ID, DSK_MOB_ID, DSK_ID, DSK_Path, Purposes, DSK_BlockSize
from Disks
where Purposes is not null
	and Purposes like '%(Rows)%'
GO
