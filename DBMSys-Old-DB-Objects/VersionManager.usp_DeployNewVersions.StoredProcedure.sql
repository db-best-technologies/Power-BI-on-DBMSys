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
/****** Object:  StoredProcedure [VersionManager].[usp_DeployNewVersions]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [VersionManager].[usp_DeployNewVersions]
as
declare @SCR_ID int,
		@Script nvarchar(max),
		@ScriptSection nvarchar(max),
		@ErrorMessage nvarchar(max)

declare cScripts cursor static forward_only for
	select SCR_ID, SCR_Script
	from VersionManager.Scripts
	where SCR_ID > (select CAST(SET_Value as decimal(10, 4))*1000
					from Management.Settings
					where SET_Module = 'Version Manager'
						and SET_Key = 'Current Version')
	order by SCR_ID

open cScripts

fetch next from cScripts into @SCR_ID, @Script
while @@fetch_status = 0
begin
	set @ErrorMessage = null
	declare cScriptSections cursor static forward_only for
		select Val
		from Infra.fn_SplitString(@Script, CHAR(10) + 'GO' + CHAR(13))
		order by Id
	
	begin transaction
	begin try
		open cScriptSections
		fetch next from cScriptSections into @ScriptSection
		while @@fetch_status = 0
		begin
			exec(@ScriptSection)
			fetch next from cScriptSections into @ScriptSection
		end
		close cScriptSections
		deallocate cScriptSections
		
		commit transaction
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		if @@TRANCOUNT > 0
			rollback transaction
		begin try
			close cScriptSections
			deallocate cScriptSections
		end try
		begin catch
		end catch
	end catch
	
	begin try
		begin transaction

		update VersionManager.Scripts
		set SCR_DeploymentAttempts += 1,
			SCR_LastDeploymentAttemptDate = sysdatetime(),
			SCR_IsDeployed = case when @ErrorMessage is null then 1 else 0 end,
			SCR_LastDeploymentErrorMessage = @ErrorMessage
		where SCR_ID = @SCR_ID
		
		if @ErrorMessage is null
			update Management.Settings
			set SET_Value = CAST(CAST(@SCR_ID as decimal(10, 4))/1000 as decimal(10, 4))
			where SET_Module = 'Version Manager'
				and SET_Key = 'Current Version'
		commit transaction
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		if @@TRANCOUNT > 0
			rollback transaction
		raiserror(@ErrorMessage, 16, 1)
	end catch
	
	fetch next from cScripts into @SCR_ID, @Script
end
close cScripts
deallocate cScripts
GO
