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
/****** Object:  UserDefinedFunction [Tests].[fn_TST_TransactionalReplicationCheckTracerTokens]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Tests].[fn_TST_TransactionalReplicationCheckTracerTokens](@TST_ID int,
																	@MOB_ID int,
																	@Command nvarchar(max)) returns nvarchar(max)
begin
	declare @TokenToCheck nvarchar(max),
			@SecondsToWait int
	
	select @SecondsToWait = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Tests'
		and SET_Key = 'Transactional Replication Tracer Tokens TimeOut In Seconds'

	select @TokenToCheck = isnull(stuff((select ';begin try '
										+ 'insert into #TracerResults(distributor_latency, subscriber, subscriber_db, subscriber_latency, overall_latency) '
										+ 'exec distribution.dbo.sp_helptracertokenhistory @publication = ''' + TRP_Name + ''', @tracer_id = ' + CAST(TCT_TokenID as nvarchar(100))
																						+ ', @publisher = ''' + DID_Name + ''', @publisher_db = ''' + p.IDB_Name + ''' '
										+ 'update #TracerResults set TokenUID = ' + CAST(TCT_ID as nvarchar(100)) + ' where ID = SCOPE_IDENTITY() '
										+ 'end try '
										+ 'begin catch '
										+ 'set @ErrorMessage = ERROR_MESSAGE() '
										+ 'if @ErrorMessage like ''%could not be found%'' '
										+ 'insert into #TracerResults(TokenUID) '
										+ 'values(' + CAST(TCT_ID as nvarchar(100)) + ') '
										+ 'else '
										+ 'raiserror(@ErrorMessage, 16, 1) '
										+ 'end catch '
										+ 'begin try '
										+ 'exec distribution.sys.sp_deletetracertokenhistory @publication = ''' + TRP_Name + ''', @tracer_id = ' + CAST(TCT_TokenID as nvarchar(100))
																						+ ', @publisher = ''' + DID_Name + ''', @publisher_db = ''' + p.IDB_Name + ''' '
										+ 'end try '
										+ 'begin catch '
										+ 'end catch'
									from Activity.TracerTokens
										inner join Inventory.TransactionalReplicationPublications on TCT_TRP_ID = TRP_ID
										inner join Inventory.MonitoredObjects on TRP_MOB_ID = MOB_ID
										inner join Inventory.DatabaseInstanceDetails on MOB_PLT_ID = 1
																						and MOB_Entity_ID = DID_DFO_ID
										inner join Inventory.InstanceDatabases p on TRP_IDB_ID = p.IDB_ID
										inner join Inventory.InstanceDatabases d on TRP_Distributor_IDB_ID = d.IDB_ID
									where TCT_MOB_ID = @MOB_ID
										and TCT_DateClosed is null
										and TCT_DateSent <= DATEADD(second, -@SecondsToWait, sysdatetime())
								for xml path('')), 1, 1, ''), '')

				+ isnull((select ';begin try '
										+ 'exec distribution.sys.sp_deletetracertokenhistory @publication = ''' + TRP_Name + ''', @tracer_id = ' + CAST(TCT_TokenID as nvarchar(100))
																						+ ', @publisher = ''' + DID_Name + ''', @publisher_db = ''' + p.IDB_Name + ''' '
										+ 'end try '
										+ 'begin catch '
										+ 'end catch '
										+ 'insert into #TracerResults(TokenUID, is_deleted) values(' + CAST(TCT_ID as nvarchar(100)) + ', 1)'
									from Activity.TracerTokens
										inner join Inventory.TransactionalReplicationPublications on TCT_TRP_ID = TRP_ID
										inner join Inventory.MonitoredObjects on TRP_MOB_ID = MOB_ID
										inner join Inventory.DatabaseInstanceDetails on MOB_PLT_ID = 1
																						and MOB_Entity_ID = DID_DFO_ID
										inner join Inventory.InstanceDatabases p on TRP_IDB_ID = p.IDB_ID
									where TCT_MOB_ID = @MOB_ID
										and TCT_IsDeleted = 0
										and (TCT_IsClosed = 1
												or TCT_DateSent <= DATEADD(second, -@SecondsToWait*5, sysdatetime())
											)
								for xml path('')), '')
	return replace(@Command, '%TOKENSTOCHECK%', nullif(@TokenToCheck, ''))
end
GO
