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
/****** Object:  StoredProcedure [Responses].[usp_SendSMS]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Responses].[usp_SendSMS]
	@SPH_ID int,
	@Parameters xml,
	@Events ResponseProcessing.ttResponseEvents readonly,
	@IsClose bit,
	@IsRerun bit,
	@BlackBoxes xml
as
set nocount on
declare @ContactLists varchar(max),
		@SMSSendingCommand varchar(max),
		@EnvironmentName varchar(1000),
		@Status tinyint,
		@Message varchar(4000),
		@Recipients varchar(1000),
		@Command varchar(8000),
		@ErrorNumber int,
		@ErrorMessage nvarchar(2000)

select @ContactLists = nullif(max(isnull(p.value('(.[@Name="Contact Lists"]/@Value)', 'varchar(max)'), '')), '')
from @Parameters.nodes('Parameters/Parameter') t(p)

select @SMSSendingCommand = cast(SET_Value as varchar(1000))
from Management.Settings
where SET_Module = 'Responses'
	and SET_Key = 'SMS Sending Command'

select @EnvironmentName = cast(SET_Value as varchar(1000))
from Management.Settings
where SET_Module = 'Management'
	and SET_Key = 'Environment Name'

set @Status = case @IsClose
					when 1 then 1
					else case (select min(cast(IsClosed as int))
								from @Events)
							when 0 then 0
							else 2
						end
				end

select @Message = ISNULL('Environment = ' + @EnvironmentName + '\n ', '')
				+ case @IsRerun
					when 0 then ''
					else 'Reminder: '
				end
				+ case @Status
						when 0 then 'Open'
						when 1 then 'Closed'
						when 2 then 'Open and Shut'
					end
				+ ' event(s): '
				+ (select top 1 EventDescription
					from @Events)
				+ isnull(' on '
							+ stuff((select distinct ';' + MOB_Name
										from @Events e
											inner join Inventory.MonitoredObjects m on e.MOB_ID = m.MOB_ID
										for xml path('')), 1, 1, ''), ' [Internal]')
				+ isnull('(' + stuff((select distinct ',' + EventInstanceName
										from @Events e
											inner join Inventory.MonitoredObjects m on e.MOB_ID = m.MOB_ID
										where EventInstanceName is not null
										for xml path('')), 1, 1, '') + ')', '')
				+ ' [Severity = ' + ESV_Name + ']'
from (select top 1 ESV_Name, ESV_Comment, ESV_EmailImportance
		from @Events e
			inner join EventProcessing.TrappedEvents t on t.TRE_ID = e.TRE_ID
			inner join EventProcessing.MonitoredEvents on MOV_ID = TRE_MOV_ID
			inner join EventProcessing.EventSeverities on ESV_ID = MOV_ESV_ID) t

set @Recipients = stuff((select ';' + CON_PhoneNumber
							from Infra.fn_SplitString(@ContactLists, ';') c
								inner join ResponseProcessing.ContactLists on Val = CLS_Name
								inner join ResponseProcessing.ContactLists_Contacts on CLS_ID = CLC_CLS_ID
								inner join ResponseProcessing.Contacts on CLC_CON_ID = CON_ID
							where CON_IsActive = 1
							for xml path(''))
							, 1, 1, '')

if @Recipients is null
begin
	raiserror('No phone numbers were supplied (Contact list = %s).', 16, 1, @ContactLists)
	return
end

set @Command = replace(replace(@SMSSendingCommand, '%%PhoneNumbers%%', @Recipients), '%%Message%%', @Message)
if @Command is null
begin
	raiserror('Empty SMS Sending command', 16, 1)
	return
end

exec Infra.usp_RunCommandAsJob
	@Command = @Command,
	@SubSystemName = 'CmdExec',
	@ErrorNumber = @ErrorNumber output,
	@ErrorMessage = @ErrorMessage output

if @ErrorNumber <> 0
begin
	raiserror('Error running SMS sending utility (%d): %s).', 16, 1, @ErrorNumber, @ErrorMessage)
	return
end
GO
