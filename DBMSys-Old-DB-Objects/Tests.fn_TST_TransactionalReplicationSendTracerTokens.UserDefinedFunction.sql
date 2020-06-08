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
/****** Object:  UserDefinedFunction [Tests].[fn_TST_TransactionalReplicationSendTracerTokens]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Tests].[fn_TST_TransactionalReplicationSendTracerTokens](@TST_ID int,
																	@MOB_ID int,
																	@Command nvarchar(max)) returns nvarchar(max)
begin
	declare @TokenToSend nvarchar(max)
	
	select @TokenToSend = stuff((select ';set @tokenID = NULL '
									+ 'begin try '
									+ 'EXEC ' + QUOTENAME(IDB_Name) + '.sys.sp_posttracertoken @publication = ''' + TRP_Name + ''', @tracer_token_id = @tokenID OUTPUT '
									+ 'insert into #Tokens values(' + CAST(TRP_ID as nvarchar(10)) + ', @tokenID) '
									+ 'end try '
									+ 'begin catch '
									+ 'if ERROR_NUMBER() != 18757 '
									+ 'begin '
									+ 'set @ErrorMessage = ERROR_MESSAGE() '
									+ 'raiserror(@ErrorMessage, 16, 1) '
									+ 'end '
									+ 'end catch'
								from Inventory.TransactionalReplicationPublications
									inner join Inventory.MonitoredObjects on MOB_ID = TRP_MOB_ID
									inner join Inventory.DatabaseInstanceDetails on DID_DFO_ID = MOB_Entity_ID
																					and MOB_PLT_ID = 1
									inner join Inventory.InstanceDatabases on TRP_IDB_ID = IDB_ID
								where TRP_MOB_ID = @MOB_ID
									and exists (select *
												from Inventory.TransactionalReplicationSubscriptions
												where TRB_TRP_ID = TRP_ID)
									and not exists (select *
													from Activity.TracerTokens
													where TCT_TRP_ID = TRP_ID
														and TCT_IsClosed = 0)
								for xml path('')), 1, 1, '')

	return replace(@Command, '%TOKENSTOSEND%', @TokenToSend)
end
GO
