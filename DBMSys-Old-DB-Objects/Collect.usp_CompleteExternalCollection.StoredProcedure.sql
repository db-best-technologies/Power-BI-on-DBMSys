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
/****** Object:  StoredProcedure [Collect].[usp_CompleteExternalCollection]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collect].[usp_CompleteExternalCollection]
	@TRH_ID			int,
	@ErrorMessage	nvarchar(max)
as
declare @TST_ID int,
		@MOB_ID int,
		@SCT_ID int,
		@OutputTable nvarchar(257),
		@DeleteObsoleteFromTables xml,
		@InsertToOutputTableOnError bit,
		@SQL nvarchar(max),
		@Info xml,
		@ClientID int

select
	@SCT_ID = TRH_SCT_ID,
	@MOB_ID = TRH_MOB_ID,
	@TST_ID = TRH_TST_ID,
	@OutputTable = ISNULL(TSV_OutputTable, TST_OutputTable),
	@DeleteObsoleteFromTables = TST_DeleteObsoleteFromTables,
	@InsertToOutputTableOnError = TST_InsertToOutputTableOnError,
	@ClientID = TRH_ClientID
from Collect.TestRunHistory with (rowlock)
join Collect.ScheduledTests with (rowlock) on TRH_SCT_ID = SCT_ID
join Collect.TestVersions on SCT_TSV_ID = TSV_ID
join Collect.Tests on SCT_TST_ID = TST_ID	
where TRH_ID = @TRH_ID

if exists (select *
			from Collect.IngoreErrorMessages
			where IEM_IsActive = 1
				and @ErrorMessage like IEM_ErrorMessage)
	set @ErrorMessage = null

begin try
	begin transaction
		update Collect.TestRunHistory with (rowlock)
		set TRH_TRS_ID = case when @ErrorMessage is null
								then 3
								else 4
							end,
			TRH_EndDate = case when TRH_StartDate is not null
								then sysdatetime()
								else null
							end,
			--TRH_RUN_ID = @RUN_ID,
			TRH_ErrorMessage = @ErrorMessage
		where TRH_ID = @TRH_ID

		update Collect.ScheduledTests with (rowlock)
		set SCT_ProcessEndDate = sysdatetime(),
			SCT_STS_ID = 4
		where SCT_ID = @SCT_ID
	commit transaction

	if @ErrorMessage is not null and @InsertToOutputTableOnError = 1
	begin
		set @SQL = 'insert into ' + @OutputTable + '(Metadata_TRH_ID, Metadata_ClientID)' + CHAR(13)+CHAR(10)
					+ 'values(@TRH_ID, @ClientID)'
		exec sp_executesql @SQL,
							N'@TRH_ID int,
								@ClientID int',
							@TRH_ID = @TRH_ID,
							@ClientID = @ClientID
	end
	if @ErrorMessage is null
		exec Collect.usp_DeleteObsoleteItems @MOB_ID, @DeleteObsoleteFromTables, @TRH_ID
end try
begin catch
	set @ErrorMessage = ERROR_MESSAGE()
	if @@TRANCOUNT > 0
		rollback
	set @Info = (select 'Test Running' [@Process], @TST_ID [@TestID], @MOB_ID [@MOB_ID]
					for xml path('Info'))
	exec Internal.usp_LogError @Info,
								@ErrorMessage
end catch
GO
