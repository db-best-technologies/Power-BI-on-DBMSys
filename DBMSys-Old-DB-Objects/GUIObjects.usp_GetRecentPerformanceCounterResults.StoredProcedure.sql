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
/****** Object:  StoredProcedure [GUIObjects].[usp_GetRecentPerformanceCounterResults]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUIObjects].[usp_GetRecentPerformanceCounterResults]
	@ParentCode varchar(50),
	@ParentID int,
	@ParentName varchar(900)
as
set transaction isolation level read uncommitted
set nocount on
declare @MOB_ID int,
		@InstanceName varchar(900),
		@SQL nvarchar(max)

if @ParentCode = 'Volumes'
begin
	select @MOB_ID = DSK_MOB_ID
	from Inventory.Disks
	where DSK_ID = @ParentID

	set @InstanceName = @ParentName
end
else
	set @MOB_ID = @ParentID

set @SQL =
'select CategoryName Category, CounterName [Counter], CIN_Name Instance, CRS_DateTime [Date],
		cast(CRS_Value/ISNULL(IPF_DivideBy, 1) as decimal(38, 4)) Value
from GUIObjects.InterestingPerformanceCounters
	inner join PerformanceData.VW_Counters on IPF_SystemID = SystemID
											and IPF_CounterID = CounterID
	cross apply (select top 1 *
					from PerformanceData.CounterResults
						left join PerformanceData.CounterInstances on CRS_InstanceID = CIN_ID
					where CRS_MOB_ID = @MOB_ID
						and CRS_SystemID = IPF_SystemID
						and CRS_CounterID = IPF_CounterID
						and (CIN_Name = IPF_InstanceName
								or CIN_Name = @InstanceName
								or IPF_InstanceName is null)
					order by CRS_DateTime desc) c
where IPF_Code = @ParentCode
	and IPF_IsVisible = 1
order by IPF_ID'

exec sp_executesql @SQL,
					N'@ParentCode varchar(50),
						@MOB_ID int,
						@InstanceName varchar(900)',
					@ParentCode = @ParentCode,
					@MOB_ID = @MOB_ID,
					@InstanceName = @InstanceName
GO
