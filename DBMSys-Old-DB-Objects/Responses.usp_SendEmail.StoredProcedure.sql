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
/****** Object:  StoredProcedure [Responses].[usp_SendEmail]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Responses].[usp_SendEmail]
	@SPH_ID int,
	@Parameters xml,
	@Events ResponseProcessing.ttResponseEvents readonly,
	@IsClose bit,
	@IsRerun bit,
	@BlackBoxes xml,
	@IsCustomReport bit = 0
as
set nocount on
declare @ContactLists varchar(max),
		@AlternativeSubject nvarchar(max),
		@FormatType varchar(50),
		@PreferredMailProfile nvarchar(128),
		@Status tinyint,
		@Subject nvarchar(max),
		@Recipients nvarchar(max),
		@Body nvarchar(max),
		@ErrorMessage nvarchar(max),
		@Color varchar(10),
		@HasCloseDate bit,
		@Importance varchar(6),
		@SubjectSuffix nvarchar(1000)

select @ContactLists = nullif(max(isnull(p.value('(.[@Name="Contact Lists"]/@Value)', 'varchar(max)'), '')), ''),
		@AlternativeSubject = nullif(max(isnull(p.value('(.[@Name="Alternative Subject"]/@Value)', 'nvarchar(max)'), '')), ''),
		@FormatType = nullif(max(isnull(p.value('(.[@Name="Format Type"]/@Value)', 'varchar(50)'), '')), ''),
		@PreferredMailProfile = nullif(max(isnull(p.value('(.[@Name="Preferred Mail Profile"]/@Value)', 'nvarchar(128)'), '')), '')
from @Parameters.nodes('Parameters/Parameter') t(p)

if @PreferredMailProfile is null
	select @PreferredMailProfile = cast(SET_Value as nvarchar(128))
	from Management.Settings
	where SET_Module = 'Management'
		and SET_Key = 'Preferred Mail Profile'

select @SubjectSuffix = cast(SET_Value as nvarchar(1000)) + ' - ' + @@SERVERNAME
from Management.Settings
where SET_Module = 'Management'
	and SET_Key = 'Environment Name'

if @AlternativeSubject is not null
	set @Subject = @AlternativeSubject

set @Subject += ' ' + quotename(@SubjectSuffix)

set @Recipients = stuff((select ';' + CON_EmaillAddress
							from Infra.fn_SplitString(@ContactLists, ';') c
								inner join ResponseProcessing.ContactLists on Val = CLS_Name
								inner join ResponseProcessing.ContactLists_Contacts on CLS_ID = CLC_CLS_ID
								inner join ResponseProcessing.Contacts on CLC_CON_ID = CON_ID
							where CON_IsActive = 1
							for xml path(''))
							, 1, 1, '')

if @Recipients is null
begin
	raiserror('No Email recipients were supplied (Contact list = %s).', 16, 1, @ContactLists)
	return
end

IF @IsCustomReport = 1
BEGIN
	SELECT	TOP 1 
			@Body		= EventMessage
			,@Subject	= EventDescription
			,@Importance = ISNULL(ESV_EmailImportance, 'NORMAL')
	FROM	@Events e
	inner join EventProcessing.TrappedEvents t on t.TRE_ID = e.TRE_ID
	inner join EventProcessing.MonitoredEvents on MOV_ID = TRE_MOV_ID
	inner join EventProcessing.EventSeverities on ESV_ID = MOV_ESV_ID

	
END
ELSE
BEGIN

	set @Status = case @IsClose
						when 1 then 1
						else case (select min(cast(IsClosed as int))
									from @Events)
								when 0 then 0
								else 2
							end
					end

	select @Subject = case @IsRerun
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
					+ ' [Severity = ' + ESV_Name + ']' + isnull(' (' + ESV_Comment + ')', ''),
			@Importance = ISNULL(ESV_EmailImportance, 'NORMAL')
	from (select top 1 ESV_Name, ESV_Comment, ESV_EmailImportance
			from @Events e
				inner join EventProcessing.TrappedEvents t on t.TRE_ID = e.TRE_ID
				inner join EventProcessing.MonitoredEvents on MOV_ID = TRE_MOV_ID
				inner join EventProcessing.EventSeverities on ESV_ID = MOV_ESV_ID) t

	
	set @Color = case @Status
						when 0 then 'Red'
						when 1 then 'Green'
						when 2 then 'Blue'
					end

	if exists (select *
				from @Events
				where CloseDate is not null)
		set @HasCloseDate = 1
	else
		set @HasCloseDate = 0

	if @FormatType = 'Table'
		set @Body = '<TABLE BORDER=1>'
					+ replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
						(select '<FONT color=' + @Color + '>' + Col + '</FONT>'
								from (values('Monitored Object Name'),
											('Open Date'),
											('Close Date'),
											('Message')) td(Col)
								where @HasCloseDate = 1
									or Col <> 'Close Date'
								for xml auto, elements, root('tr'))
							+ case @HasCloseDate
								when 0 then
									(select isnull(MOB_Name, '[Internal]') td, convert(char(19), OpenDate, 121) td,
												replace(replace(BoldMessage, '"', '_+_'), '<', '&#60;') td
											from @Events e
												cross apply Infra.fn_MessageBolder(EventMessage)
												left join Inventory.MonitoredObjects m on m.MOB_ID = e.MOB_ID
											order by IsClosed, EventTimestamp desc
											for xml raw('tr'), elements xsinil
											)
								else
									(select isnull(MOB_Name, '[Internal]') td, convert(char(19), OpenDate, 121) td, convert(char(19), CloseDate, 121) td,
												replace(replace(BoldMessage, '"', '_+_'), '<', '&#60;') td
											from @Events e
												cross apply Infra.fn_MessageBolder(EventMessage)
												left join Inventory.MonitoredObjects m on m.MOB_ID = e.MOB_ID
											order by IsClosed, EventTimestamp desc
											for xml raw('tr'), elements xsinil
											)
							end
							, ' xsi:nil="true"/', '>&nbsp;</td'), ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', '')
							, '"/>', ''), '_+_', '"'), '_x0020_', ' ')
							, '&#x0D;', char(13)), '&#x0A;', char(10)), char(13)+char(10), '<br>'), char(13), '<br>'), char(10), '<br>')
							, '&amp;', '&'), '&gt;', '>'), '&lt;', '<')
							, '&#60;b>', '<b>'), '&#60;/b>', '</b>')
					+ '</TABLE>'
	else if @FormatType = 'SingleColumn'
		set @Body = '<TABLE BORDER=0>'
					+ replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
							(select [Monitored Object Name:], [Open Date:], [Close Date:], [Message:], '' Spacer999
								from (select isnull(MOB_Name, '[Internal]') [Monitored Object Name:], convert(char(19), OpenDate, 121) [Open Date:],
												convert(char(19), CloseDate, 121) [Close Date:],
												replace(replace(BoldMessage, '"', '_+_'), '<', '&#60;') [Message:], EventTimestamp, IsClosed
											from @Events e
												cross apply Infra.fn_MessageBolder(EventMessage)
												left join Inventory.MonitoredObjects m on m.MOB_ID = e.MOB_ID) upv123
											order by IsClosed, EventTimestamp desc
											for xml auto
											)
							, '" ', '</td></tr>' + char(13)+char(10) + '<tr><td><FONT color=' + @Color + '>')
																			, '="', '</FONT></td><td>'), 'Spacer999', '&nbsp;')
																			, '<upv123 ', '<tr><td><FONT color=' + @Color + '>')
																			, '"/>', ''), '_+_', '"'), '_x0020_', ' ')
																			, '&#x0D;', char(13)), '&#x0A;', char(10)), char(13)+char(10), '<br>'), char(13), '<br>'), char(10), '<br>')
																			, '&amp;', '&'), '&gt;', '>'), '&lt;', '<')
																			, '&#60;b>', '<b>'), '&#60;/b>', '</b>'), '<br><br>', '<br>')
							+ '</TABLE>'

	set @Body += isnull(ResponseProcessing.fn_ConvertBlackboxesToHTML(@BlackBoxes), '')
END

exec Infra.usp_DBA_SendMail @Recipients		= @Recipients,
							@Subject		= @Subject,
							@Body			= @Body,
							@ProfileName	= @PreferredMailProfile,
							@Importance		= @Importance
GO
