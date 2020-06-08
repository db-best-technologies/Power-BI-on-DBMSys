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
/****** Object:  StoredProcedure [ResponseProcessing].[usp_RunResponse]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ResponseProcessing].[usp_RunResponse]
	@SPH_ID int,
	@ProcedureName nvarchar(257),
	@Parameters xml,
	@RGT_ID tinyint,
	@NewEvents ResponseProcessing.ttResponseEvents readonly,
	@IsClose bit,
	@IsRerun bit,
	@IsCustomReport bit = 0
as
set nocount on
declare @Events ResponseProcessing.ttResponseEvents,
		@ESP_ID int,
		@TRE_ID int,
		@MOB_ID int,
		@EventInstanceName varchar(850),
		@SQL nvarchar(max),
		@SQLParameters nvarchar(max),
		@DateTime datetime2(3),
		@Blackboxes xml,
		@isExistsCustomReportparameter bit = 0

		
		IF EXISTS(select * from sys.parameters where object_id = OBJECT_ID(@ProcedureName) and name ='@IsCustomReport') and isnull(@IsCustomReport,0) = 1
		 set @isExistsCustomReportparameter = 1

set @SQL = 'exec ' + @ProcedureName + ' @SPH_ID = @SPH_ID,' + CHAR(13)+CHAR(10)
			+ '							@Parameters = @Parameters,' + CHAR(13)+CHAR(10)
			+ '							@Events = @Events,' + CHAR(13)+CHAR(10)
			+ '							@IsClose = @IsClose,' + CHAR(13)+CHAR(10)
			+ '							@IsRerun = @IsRerun,' + CHAR(13)+CHAR(10)
			+ '							@BlackBoxes = @BlackBoxes'
+ case when @isExistsCustomReportparameter = 1 then ',' + CHAR(13)+CHAR(10)
			+ '							@IsCustomReport = 1'
			else '' end

set @SQLParameters = N'@SPH_ID int,' + CHAR(13)+CHAR(10)
						+ '@Parameters xml,' + CHAR(13)+CHAR(10)
						+ '@Events ResponseProcessing.ttResponseEvents readonly,' + CHAR(13)+CHAR(10)
						+ '@IsClose bit,'
						+ '@IsRerun bit,'
						+ '@BlackBoxes xml'
if @RGT_ID = 0
begin
	select @ESP_ID  = SPH_ESP_ID
	from ResponseProcessing.SubscriptionProcessingHistory
	where SPH_ID = @SPH_ID

	declare cNewEvents cursor static forward_only for
		select TRE_ID, MOB_ID, EventInstanceName, OpenDate
		from @NewEvents
		order by EventTimestamp
	open cNewEvents
	fetch next from cNewEvents into @TRE_ID, @MOB_ID, @EventInstanceName, @DateTime
	while @@fetch_status = 0
	begin
		insert into @Events(TRE_ID, EventDescription, ClientID, IsClosed, MOB_ID, EventInstanceName, OpenDate, CloseDate,
								EventMessage, AllEventData, TimesProcessed, EventTimestamp)
		select TRE_ID, EventDescription, ClientID, IsClosed, MOB_ID, EventInstanceName, OpenDate, CloseDate, EventMessage, AllEventData, TimesProcessed, EventTimestamp
		from @NewEvents
		where TRE_ID = @TRE_ID
		
		if @IsClose = 0
			exec ResponseProcessing.usp_ExtractBlackBoxInfo @ESP_ID = @ESP_ID,
															@MOB_ID = @MOB_ID,
															@EventInstanceName = @EventInstanceName,
															@DateTime = @DateTime,
															@Blackboxes = @Blackboxes output
		else
			set @Blackboxes = null

		exec sp_executesql @SQL,
							@SQLParameters,
							@SPH_ID = @SPH_ID,
							@Parameters = @Parameters,
							@Events = @Events,
							@IsClose = @IsClose,
							@IsRerun = @IsRerun,
							@Blackboxes = @Blackboxes
		
		delete @Events
		fetch next from cNewEvents into @TRE_ID, @MOB_ID, @EventInstanceName, @DateTime
	end
	close cNewEvents
	deallocate cNewEvents
end
else if @RGT_ID = 1
begin
	declare cNewEvents cursor static forward_only for
		select distinct MOB_ID
		from @NewEvents
	open cNewEvents
	fetch next from cNewEvents into @MOB_ID
	while @@fetch_status = 0
	begin
		insert into @Events(TRE_ID, EventDescription, ClientID, IsClosed, MOB_ID, EventInstanceName, OpenDate, CloseDate,
								EventMessage, AllEventData, TimesProcessed, EventTimestamp)
		select TRE_ID, EventDescription, ClientID, IsClosed, MOB_ID, EventInstanceName, OpenDate, CloseDate, EventMessage, AllEventData, TimesProcessed, EventTimestamp
		from @NewEvents
		where MOB_ID = @MOB_ID
		
		exec sp_executesql @SQL,
							@SQLParameters,
							@SPH_ID = @SPH_ID,
							@Parameters = @Parameters,
							@Events = @Events,
							@IsClose = @IsClose,
							@IsRerun = @IsRerun,
							@Blackboxes = @Blackboxes
		
		delete @Events
		fetch next from cNewEvents into @MOB_ID
	end
	close cNewEvents
	deallocate cNewEvents
end
else if @RGT_ID = 2
begin
	insert into @Events(TRE_ID, EventDescription, ClientID, IsClosed, MOB_ID, EventInstanceName, OpenDate, CloseDate,
							EventMessage, AllEventData, TimesProcessed, EventTimestamp)
	select TRE_ID, EventDescription, ClientID, IsClosed, MOB_ID, EventInstanceName, OpenDate, CloseDate, EventMessage, AllEventData, TimesProcessed, EventTimestamp
	from @NewEvents
	order by EventTimestamp

	exec sp_executesql @SQL,
						@SQLParameters,
						@SPH_ID = @SPH_ID,
						@Parameters = @Parameters,
						@Events = @Events,
						@IsClose = @IsClose,
						@IsRerun = @IsRerun,
						@Blackboxes = @Blackboxes
end
GO
