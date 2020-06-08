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
/****** Object:  StoredProcedure [Infra].[usp_RunCommandAsJob]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Infra].[usp_RunCommandAsJob]
	@Command nvarchar(max),
	@SubSystemName nvarchar(128), --The options are 'TSQL' or 'CmdExec'
	@ErrorNumber int = null output,
	@ErrorMessage nvarchar(2000) = null output,
	@Message nvarchar(max) = null output
as
set nocount on
if @Command is null return

declare @job_name sysname,
		@job_id uniqueidentifier

select @ErrorNumber = null,
		@ErrorMessage = null,
		@Message = null

set @job_name = cast(newid() as nvarchar(100))

while exists (select 1 from msdb..sysjobs where name = @job_name)
	set @job_name += 'A'

DECLARE @JobID BINARY(16)
DECLARE @ReturnCode INT

SELECT @ReturnCode = 0	

begin try
	if not exists (select *
					from sys.sysprocesses 
					where [program_name] = N'SQLAgent - Generic Refresher')
		raiserror('The SQL Server Agent isn''t running', 16, 1)

	if not exists (SELECT 1 FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]')
		exec msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'
		
	exec @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT,
		@job_name = @job_name,
		@owner_login_name = N'sa',
		@description = N'No description available.',
		@category_name = N'[Uncategorized (Local)]',
		@enabled = 0,
		@notify_level_email = 0,
		@notify_level_page = 0,
		@notify_level_netsend = 0,
		@notify_level_eventlog = 2,
		@delete_level = 0

	if @ReturnCode <> 0
		raiserror('Error creating job', 16, 1)

	exec @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID,
												@step_id = 1,
												@step_name = N'Run Command',
												@command = @Command,
												@database_name = N'master',
												@server = N'',
												@database_user_name = N'',
												@subsystem = @SubsystemName,
												@cmdexec_success_code = 0,
												@flags = 0,
												@retry_attempts = 0,
												@retry_interval = 1,
												@output_file_name = N'',
												@on_success_step_id = 0,
												@on_success_action = 1,
												@on_fail_step_id = 0,
												@on_fail_action = 2
	if @ReturnCode <> 0
		raiserror('Error adding job step', 16, 1)

	exec @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID,
												 @start_step_id = 1

	if @ReturnCode <> 0
		raiserror('Error setting startup step', 16, 1)

	exec @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID,
									@server_name = N'(local)'

	if @ReturnCode <> 0
		raiserror('Error adding job server', 16, 1)

	select @job_id = job_id
	from msdb..sysjobs
	where name = @job_name

	exec msdb..sp_start_job @job_name = @job_name, @output_flag = 0

	while not exists (select * from msdb..sysjobhistory where job_id = @job_id and step_id = 1)
		waitfor delay '00:00:00.5'

	select top 1 @Message = [Message]
	from msdb..sysjobhistory
	where job_id = @job_id and step_id = 1
	order by instance_id desc

	if @Message like '%The step succeeded%'
		select @ErrorNumber = 0,
				@ErrorMessage = null
	else
	begin
		;With ErrorParse1 as
			(select substring(@Message, charindex('.', @Message, 1) + 2, 2000) ErrorMessage)
			,ErrorParse2 as
			(select ErrorMessage,
				substring(ErrorMessage,
						charindex('(Error ', ErrorMessage, 1) + len('(Error ') + 1, 100) ErrorNumber
			from ErrorParse1)
		select @ErrorMessage = case when @SubSystemName = 'CmdExec' and ErrorMessage like '%(reason:%'
									then replace(stuff(ErrorMessage, 1, CHARINDEX('(reason: ', ErrorMessage, 1) + LEN('(reason: '), ''), ').  The step failed.', '')
									else replace(ErrorMessage, '.  The step failed.', '')
								end,
				@ErrorNumber = case when @SubSystemName = 'TSQL'
									then case when isnumeric(left(ErrorNumber, charindex(')', ErrorNumber, 1) - 1)) = 1
											then cast(left(ErrorNumber, charindex(')', ErrorNumber, 1) - 1) as int)
											else -1
										end
									else -1
								end
		from ErrorParse2
	end
end try
begin catch
	select @ErrorNumber = ERROR_NUMBER(),
			@ErrorMessage = ERROR_MESSAGE()
end catch
if exists (select * from msdb..sysjobs where name = @job_name)
	exec msdb..sp_delete_job @job_name = @job_name
GO
