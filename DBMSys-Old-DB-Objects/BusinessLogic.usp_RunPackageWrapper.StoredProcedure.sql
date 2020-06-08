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
/****** Object:  StoredProcedure [BusinessLogic].[usp_RunPackageWrapper]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [BusinessLogic].[usp_RunPackageWrapper]
as
set nocount on
declare @handle uniqueidentifier,
		@Body xml,
		@MessageType nvarchar(128),
		@LNP_ID int,
		@ContextInfo binary(4),
		@ClientID int,
		@PackageID int
		
;receive top (1) @handle = conversation_handle,
				@Body = cast(message_body as xml),
				@MessageType = message_type_name
from qRunPackageReceive

if @handle is not null
begin
	if @MessageType <> 'msgRunPackage' return
	
	set @LNP_ID = @Body.value('LaunchedPackageID[1]', 'int')

	end conversation @handle with cleanup	
	
	if @LNP_ID is not null
	begin
		update BusinessLogic.LaunchedPackages
		set @ClientID = LNP_ClientID,
			@PackageID = LNP_PKG_ID,
			LNP_LPS_ID = 2,
			LNP_InterceptionDate = SYSDATETIME()
		where LNP_ID = @LNP_ID

		set @ContextInfo = cast(@PackageID as binary(4))
		set context_info @ContextInfo

		exec BusinessLogic.usp_RunPackage @PackageID = @PackageID

		update BusinessLogic.LaunchedPackages
		set LNP_LPS_ID = 3,
			LNP_CompleteDate = SYSDATETIME()
		where LNP_ID = @LNP_ID

		set context_info 0x0
	end
end
GO
