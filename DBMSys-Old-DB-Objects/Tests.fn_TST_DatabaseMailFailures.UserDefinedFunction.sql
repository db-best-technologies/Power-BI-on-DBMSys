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
/****** Object:  UserDefinedFunction [Tests].[fn_TST_DatabaseMailFailures]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Tests].[fn_TST_DatabaseMailFailures](@TST_ID int,
								@MOB_ID int,
								@Command nvarchar(max)) returns nvarchar(max)
begin
	declare @OutputCommand nvarchar(max),
			@FailedInstances nvarchar(max)
	set @OutputCommand = Collect.fn_InsertTestObjectLastValue(@TST_ID, @MOB_ID, @Command)
	
	select @FailedInstances = replace(stuff((select 'and (' + 'sent_account_id = ' + cast(DMF_AccountID as varchar(10))
														+ ' and sent_date > ''' + convert(char(23), DMF_LastFailureDate, 121) + ''''
														+ ')'
										from Activity.DatabaseMailFailures
											left join Activity.DatabaseMailRecipients on DMF_DMR_ID = DMR_ID
										where DMF_MOB_ID = @MOB_ID
											and DMF_IsClosed = 0
										for xml path('')), 1, 4, ''), '&gt;', '>')

	set @OutputCommand = replace(@OutputCommand, '%FAILEDINSTANCES%', isnull(@FailedInstances, '1 <> 1'))
	return @OutputCommand
end
GO
