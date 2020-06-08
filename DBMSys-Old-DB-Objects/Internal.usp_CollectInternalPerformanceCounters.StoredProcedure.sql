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
/****** Object:  StoredProcedure [Internal].[usp_CollectInternalPerformanceCounters]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Internal].[usp_CollectInternalPerformanceCounters]
as
declare @ClientID int,
		@IPC_ID int,
		@SystemID tinyint,
		@CategoryName nvarchar(128),
		@CounterName nvarchar(128),
		@FunctionName nvarchar(257),
		@TimestampTableName nvarchar(257),
		@LastHandledTimestamp binary(8),
		@CounterDateTime datetime2(3),
		@IsDryRun bit,
		@TimeStampColumn nvarchar(128),
		@MostRecentTimestamp binary(8),
		@SQL nvarchar(max),
		@Info xml,
		@ErrorMessage nvarchar(2000)

select @ClientID = cast(SET_Value as int)
from Management.Settings
where SET_Module = 'Management'
	and SET_Key = 'Client ID'

declare cInternalPerformanceCounters cursor static forward_only for
	select IPC_ID, IPC_CSY_ID, IPC_CategoryName, IPC_CounterName, IPC_FunctionName, IPC_TimestampTableName, isnull(PCL_LastTimestamp, 0), LastRunDate,
			case when PCL_LastRunDate is null
							and IPC_IsFirstRunDry = 1
						then 1
						else 0
					end
	from PerformanceData.InternalPerformanceCounters
		outer apply (select top 1 PCL_LastRunDate, PCL_LastTimestamp
						from Internal.PerformanceCountersLastValues
						where PCL_IPC_ID = IPC_ID) p
		cross apply Collect.fn_GetNextRunDate(IPC_IntervalType, IPC_IntervalPeriod, PCL_LastRunDate) n
	where IPC_IsActive = 1
		and (NextRunDate <= SYSDATETIME()
				or PCL_LastRunDate is null)

open cInternalPerformanceCounters
fetch next from cInternalPerformanceCounters into @IPC_ID, @SystemID, @CategoryName, @CounterName, @FunctionName,
													@TimestampTableName, @LastHandledTimestamp, @CounterDateTime, @IsDryRun
while @@fetch_status = 0
begin
	if @TimestampTableName is not null
	begin
		select @TimeStampColumn = name
		from sys.columns
		where object_id = object_id(@TimestampTableName)
		
		set @SQL = 'select @MostRecentTimestamp = max(' + @TimeStampColumn + ')' + CHAR(13)+CHAR(10)
					+ 'from ' + @TimestampTableName
					+ case when @LastHandledTimestamp is not null
							then CHAR(13)+CHAR(10) + 'where ' + @TimeStampColumn + ' > @LastHandledTimestamp'
							else ''
					end
		exec sp_executesql @SQL,
							N'@LastHandledTimestamp binary(8),
								@MostRecentTimestamp binary(8) output',
							@LastHandledTimestamp = @LastHandledTimestamp,
							@MostRecentTimestamp = @MostRecentTimestamp output
	end

	if @IsDryRun = 0
		and (@MostRecentTimestamp > @LastHandledTimestamp
				or @LastHandledTimestamp is null
				or @TimestampTableName is null)
	begin
		select @SQL =	'set transaction isolation level read uncommitted' + CHAR(13)+CHAR(10)
						+ 'select @ClientID, @CategoryName, @CounterName, 1, CounterDateTime, InstanceName, Value, ResultStatus, TRH_ID' + CHAR(13)+CHAR(10)
						+ 'from ' + @FunctionName + '(@LastHandledTimestamp, @MostRecentTimestamp, @CounterDateTime)' + CHAR(13)+CHAR(10)
						+ 'option(maxdop 1)'
		begin try
			begin transaction
				insert into Collect.VW_TST_PerformanceCounters(Metadata_ClientID, Category, [Counter], IsInternal, [DateTime], Instance, Value, [Status], Metadata_TRH_ID)
				exec sp_executesql @SQL,
									N'@ClientID int,
										@CategoryName nvarchar(128),
										@CounterName nvarchar(128),
										@LastHandledTimestamp binary(8),
										@MostRecentTimestamp binary(8),
										@CounterDateTime datetime2(3)',
									@ClientID,
									@CategoryName,
									@CounterName,
									@LastHandledTimestamp,
									@MostRecentTimestamp,
									@CounterDateTime
		end try
		begin catch
			set @ErrorMessage = ERROR_MESSAGE()
			set @MostRecentTimestamp = @LastHandledTimestamp
			if @@TRANCOUNT > 0
				rollback
			set @Info = (select 'Internal Counter Collection' [@Process], @CategoryName [@Category], @CounterName [@Counter]
							for xml path('Info'))
			exec Internal.usp_LogError @Info, @ErrorMessage
		end catch
	end
	merge Internal.PerformanceCountersLastValues d
		using (select @IPC_ID IPC_ID, sysdatetime() RunDate, @MostRecentTimestamp LastTimestamp, @ErrorMessage ErrorMessage) s
			on IPC_ID = PCL_IPC_ID
		when matched then update set
								PCL_LastTimestamp = isnull(LastTimestamp, PCL_LastTimestamp),
								PCL_LastRunDate = RunDate,
								PCL_LastErrorMessage = ErrorMessage
		when not matched then insert(PCL_IPC_ID, PCL_LastTimestamp, PCL_LastRunDate, PCL_LastErrorMessage)
								values(IPC_ID, LastTimestamp, RunDate, ErrorMessage);
	if @@TRANCOUNT > 0
		commit transaction

	fetch next from cInternalPerformanceCounters into @IPC_ID, @SystemID, @CategoryName, @CounterName, @FunctionName,
														@TimestampTableName, @LastHandledTimestamp, @CounterDateTime, @IsDryRun
end
close cInternalPerformanceCounters
deallocate cInternalPerformanceCounters
GO
