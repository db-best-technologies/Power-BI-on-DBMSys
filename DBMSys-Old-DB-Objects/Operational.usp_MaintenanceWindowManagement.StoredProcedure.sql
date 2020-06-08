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
/****** Object:  StoredProcedure [Operational].[usp_MaintenanceWindowManagement]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Operational].[usp_MaintenanceWindowManagement]
as
set nocount on
declare @MTW_ID int,
		@MOB_ID int,
		@OOS_ID int,
		@MWL_ID int,
		@ErrorMessage nvarchar(max),
		@Info xml

declare cMaintenanceWindows cursor static forward_only for
	select MTW_ID, MOB_ID, MOB_OOS_ID
	from Operational.MaintenanceWindows
	    inner join Operational.MaintenanceWindowGroups on MWG_ID = MTW_MWG_ID
		inner join Inventory.MonitoredObjects on MOB_ID = MTW_MOB_ID
		
	where SWITCHOFFSET (MWG_StartTime, '+00:00' ) <= SWITCHOFFSET ( SYSDATETIMEOFFSET(), '+00:00' )
		and SWITCHOFFSET (MWG_EndTime, '+00:00' ) > SWITCHOFFSET ( SYSDATETIMEOFFSET(), '+00:00' )
		and not exists (select *
							from Operational.MaintenanceWindowLog
							where MWL_MTW_ID = MTW_ID
								and MWL_IsClosed = 0)
		and MTW_IsDeleted = 0
		and MOB_OOS_ID not in (3,4)

open cMaintenanceWindows
fetch next from cMaintenanceWindows into @MTW_ID, @MOB_ID, @OOS_ID
while @@fetch_status = 0
begin
	select @MTW_ID, @MOB_ID, @OOS_ID
	begin try
		begin transaction
			update Inventory.MonitoredObjects
			set MOB_OOS_ID = 2
			where MOB_ID = @MOB_ID
			
			insert into Operational.MaintenanceWindowLog(MWL_MTW_ID, MWL_Start_OOS_ID, MWL_IsClosed)
			values(@MTW_ID, @OOS_ID, 0)
		commit transaction
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		if @@TRANCOUNT > 0
			rollback
		set @Info = (select 'Maintenance Window Management' [@Process], 'Open Windows' [@Task] for xml path('Info'))
		exec Internal.usp_LogError @Info, @ErrorMessage
	end catch
	fetch next from cMaintenanceWindows into @MTW_ID, @MOB_ID, @OOS_ID
end
close cMaintenanceWindows
deallocate cMaintenanceWindows


declare cMaintenanceWindows cursor static forward_only for
		select MWL_ID, MTW_MOB_ID, MWL_Start_OOS_ID
	from Operational.MaintenanceWindows w
		inner join Operational.MaintenanceWindowGroups on MWG_ID = MTW_MWG_ID
		inner join Operational.MaintenanceWindowLog on MWL_MTW_ID = MTW_ID
	where (SWITCHOFFSET (MWG_EndTime, '+00:00' ) <= SWITCHOFFSET ( SYSDATETIMEOFFSET(), '+00:00' ) OR SWITCHOFFSET (MWG_StartTime, '+00:00' ) >= SWITCHOFFSET ( SYSDATETIMEOFFSET(), '+00:00' ) or MTW_IsDeleted = 1)--MTW_EndTime <= SYSDATETIME()
		and MWL_IsClosed = 0
		and not exists (select MWL_ID, MTW_MOB_ID, MWL_Start_OOS_ID,MWG_ID
						from Operational.MaintenanceWindows w1
							inner join Operational.MaintenanceWindowGroups on MWG_ID = MTW_MWG_ID
							inner join Operational.MaintenanceWindowLog on MWL_MTW_ID = MTW_ID
						where (SWITCHOFFSET (MWG_EndTime, '+00:00' ) > SWITCHOFFSET ( SYSDATETIMEOFFSET(), '+00:00' ) 
						AND SWITCHOFFSET (MWG_StartTime, '+00:00' ) < SWITCHOFFSET ( SYSDATETIMEOFFSET(), '+00:00' )
						)
							and MWL_IsClosed = 0 and w.MTW_MOB_ID = w1.MTW_MOB_ID and w1.MTW_IsDeleted = 0 
						)

open cMaintenanceWindows
fetch next from cMaintenanceWindows into @MWL_ID, @MOB_ID, @OOS_ID
while @@fetch_status = 0
begin
	select @MTW_ID, @MOB_ID, @OOS_ID
	begin try
		begin transaction

			IF @OOS_ID = 2
				select 
						@OOS_ID =  MWL_Start_OOS_ID
				from	Operational.MaintenanceWindowLog
				join	Operational.MaintenanceWindows on MTW_ID = MWL_MTW_ID
				where	MTW_MOB_ID = @MOB_ID and MWL_Start_OOS_ID <> 2
				order by MWL_InsertDate desc

			update Inventory.MonitoredObjects
			set MOB_OOS_ID = @OOS_ID
			where MOB_ID = @MOB_ID and MOB_OOS_ID not in (3,4)
			
			update Operational.MaintenanceWindowLog
			set MWL_IsClosed = 1
			where MWL_ID = @MWL_ID
		commit transaction
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		if @@TRANCOUNT > 0
			rollback
		set @Info = (select 'Maintenance Window Management' [@Process], 'Open Windows' [@Task] for xml path('Info'))
		exec Internal.usp_LogError @Info, @ErrorMessage
	end catch
	fetch next from cMaintenanceWindows into @MWL_ID, @MOB_ID, @OOS_ID
end
close cMaintenanceWindows
deallocate cMaintenanceWindows
GO
