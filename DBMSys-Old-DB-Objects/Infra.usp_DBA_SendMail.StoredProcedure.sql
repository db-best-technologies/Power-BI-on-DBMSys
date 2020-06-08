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
/****** Object:  StoredProcedure [Infra].[usp_DBA_SendMail]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Infra].[usp_DBA_SendMail]
	@Recipients varchar(4000),
	@Subject varchar(255) = null,
	@Query nvarchar(max) = null,
	@Body nvarchar(max) = null,
	@ProfileName nvarchar(128) = null,
	@Attachments nvarchar(max) = null,
	@SendEmailEvenIfQueryReturnsNoResults bit = 1,
	@CC varchar(4000) = null,
	@Importance varchar(6) = 'NORMAL'
as

SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @l_Body varchar(Max),
	@l_Query nvarchar(max),
	@Columns nvarchar(4000)

set @l_Body = isnull(@Body + '<BR>', '')
if not @Query is null
begin
	set @l_Query = replace(replace(replace(replace(@Query, char(13)+char(10), ' '), '[', ' '), ']', ' '), '  ', ' ')
	set @Columns = substring(@l_Query, charindex('select ', @l_Query, 1) + 7, charindex('from ', @l_Query, 1) - 7 - charindex('select ', @l_Query, 1))

	set @l_Body = @l_Body + '<TABLE BORDER=1><FONT color=#0000ff>'
	set @l_Body = @l_Body + cast(	(select rtrim(ltrim(Val))
									 from Infra.fn_SplitString(rtrim(ltrim(@Columns)), ',') TD
									 for xml auto, elements, type, root('TR'))
								 as nvarchar(4000))
	set @l_Body = @l_Body + '</FONT>'

	set @l_Query = replace(replace(@l_Query, ',', ' td,'), ' from ', ' td from ')
	set @l_Query = @l_Query + ' for xml raw(''tr''), elements XSINIL, type'

	create table #XML_Result(Result xml)

	insert into #XML_Result
	exec sp_executesql @l_Query

	select @l_Body = @l_Body
			+ replace(replace(cast(Result as nvarchar(max)), ' xsi:nil="true"/', '>&nbsp;</td'), ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', '')
			+ '</TABLE>'
	from #XML_Result

	drop table #XML_Result

	if @l_Body is null and @SendEmailEvenIfQueryReturnsNoResults = 0
		return
end
EXEC msdb.dbo.sp_send_dbmail @profile_name = @ProfileName,
							@recipients = @Recipients,
							@body = @l_Body,
							@subject = @Subject,
							@body_format = 'HTML',
							@file_attachments = @Attachments,
							@copy_recipients = @CC,
							@importance = @Importance
GO
