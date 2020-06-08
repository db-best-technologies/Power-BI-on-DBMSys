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
/****** Object:  StoredProcedure [EventProcessing].[usp_RunAnalyticalProcedure]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [EventProcessing].[usp_RunAnalyticalProcedure]
	@PRC_ID int,
	@MOV_ID int,
	@EventDescription nvarchar(1000),
	@ClientID int,
	@ProcedureName nvarchar(max)
as
declare @SQL nvarchar(max),
		@ErrorMessage nvarchar(max)

begin try
	if OBJECT_ID('tempdb..#NewEvents') is not null
		drop table #NewEvents

	create table #NewEvents(MOB_ID int,
							InstanceName varchar(850),
							AlertMessage nvarchar(max),
							AlertEventData xml)

	set @SQL = 'exec ' + @ProcedureName + ' @EventDescription = @EventDescription'
	insert into #NewEvents
	exec sp_executesql @SQL,
						N'@EventDescription nvarchar(1000)',
						@EventDescription = @EventDescription
		
	delete #NewEvents
	where exists (select *
					from EventProcessing.EventIncludeExclude
					where EIE_MOV_ID = @MOV_ID
						and EIE_IsInclude = 0
						and (EIE_MOB_ID = MOB_ID
								or EIE_MOB_ID is null)
						and (EIE_InstanceName = InstanceName
								or (EIE_UseLikeForInstanceName = 1
										and InstanceName like '%' + EIE_InstanceName + '%')
								or EIE_InstanceName is null
							)
				)

	if exists (select *
				from EventProcessing.EventIncludeExclude
				where EIE_MOV_ID = @MOV_ID
					and EIE_IsInclude = 1)
		delete #NewEvents
		where not exists (select *
							from EventProcessing.EventIncludeExclude
							where EIE_MOV_ID = @MOV_ID
								and EIE_IsInclude = 1
								and (EIE_MOB_ID = MOB_ID
										or EIE_MOB_ID is null)
								and (EIE_InstanceName = InstanceName
										or (EIE_UseLikeForInstanceName = 1
												and InstanceName like '%' + EIE_InstanceName + '%')
										or EIE_InstanceName is null
									)
						)

	merge EventProcessing.TrappedEvents d
		using #NewEvents s
			on TRE_MOV_Id = @MOV_ID
				and TRE_MOB_ID = MOB_ID
				and (TRE_EventInstanceName = InstanceName
						or (TRE_EventInstanceName is null
							and InstanceName is null)
					)
				and TRE_IsClosed = 0
		when not matched then insert(TRE_ClientID, TRE_MOB_ID, TRE_MOV_ID, TRE_IsClosed, TRE_IsOpenAndShut, TRE_EventInstanceName, TRE_OpenDate,
										TRE_AlertMessage, TRE_AlertEventData)
								values(@ClientID, MOB_ID, @MOV_ID, 0, 0, InstanceName, sysdatetime(), AlertMessage, AlertEventData)
		when not matched by source and TRE_MOV_ID = @MOV_ID
											and TRE_IsClosed = 0 then update set
								TRE_IsClosed = 1,
								TRE_CloseDate = sysdatetime(),
								TRE_TEC_ID = 1,
								TRE_OKMessage = 'The events didn''t appear in the last analysis',
								TRE_OKEventData = (select 'The events didn''t appear in the last analysis' [@Message]
													for xml path('Resolution'), root('Resolutions'), type);
end try
begin catch
	set @ErrorMessage = ERROR_MESSAGE()
end catch

update EventProcessing.ProcessCycles
set PRC_EndDate = sysdatetime(),
	PRC_ErrorMessage = @ErrorMessage
where PRC_ID = @PRC_ID
GO
