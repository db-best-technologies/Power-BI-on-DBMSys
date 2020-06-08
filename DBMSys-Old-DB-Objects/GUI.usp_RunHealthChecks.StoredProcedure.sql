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
/****** Object:  StoredProcedure [GUI].[usp_RunHealthChecks]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [GUI].[usp_RunHealthChecks]
	@PackageID int = null
as
set nocount on
declare @ClientID int,
		@LNP_ID int,
		@handle uniqueidentifier,
		@Message xml

declare @ErrorMessage nvarchar(2000),
		@Info xml

if @PackageID is null
	select top 1 @PackageID = PKG_ID
	from BusinessLogic.Packages
		inner join BusinessLogic.PackageTypes on PKT_ID = PKG_PKT_ID
	where PKT_Name = 'Health Check'
	order by PKG_ID

begin try
	begin transaction

	update BusinessLogic.LaunchedPackages
	set LNP_LPS_ID = 4
	where LNP_LPS_ID = 2
		and (LNP_PKG_ID = @PackageID
			or @PackageID is null)
		and not exists (select *
						from sys.dm_exec_requests
						where context_info = cast(LNP_PKG_ID as binary(4))
						)

	delete BusinessLogic.LaunchedPackages
	where LNP_LPS_ID = 1
		and LNP_LaunchDate <= dateadd(second, -60, SYSDATETIME())
		and (LNP_PKG_ID = @PackageID
			or @PackageID is null)
		and (select COUNT(*)
				from BusinessLogic.LaunchedPackages
					inner join sys.dm_exec_requests on context_info = cast(LNP_PKG_ID as binary(4))
				where LNP_LPS_ID = 2
				) = 0

	if exists (select *
				from BusinessLogic.LaunchedPackages
				where LNP_LPS_ID in (1, 2)
					and (LNP_PKG_ID = @PackageID
						or @PackageID is null))
		set @PackageID = null
	
	commit transaction
end try
begin catch
	set @ErrorMessage = ERROR_MESSAGE()
	if @@TRANCOUNT > 0
		rollback
	set @Info = (select 'Package launcher' [@Process], 'Check running packages' [@Task] for xml path('Info'))
	exec Internal.usp_LogError @Info, @ErrorMessage
	set @PackageID = null
end catch

if @PackageID is not null
begin
	select @ClientID = cast(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Management'
		and SET_Key = 'Client ID'

	begin dialog conversation @handle
	from service srvRunPackageSend
	to service 'srvRunPackageReceive'
	on contract conRunPackage
	with encryption = off,
		lifetime = 3600

	begin try
		begin transaction
			insert into BusinessLogic.LaunchedPackages(LNP_ClientID, LNP_PKG_ID, LNP_LPS_ID, LNP_LaunchDate)
			values(@ClientID, @PackageID, 1, SYSDATETIME())

			set @LNP_ID = SCOPE_IDENTITY()

			select @Message = (select @LNP_ID LaunchedPackageID for xml path(''))

			;send on conversation @handle
				message type msgRunPackage(@Message)
			
		commit transaction
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		if @@TRANCOUNT > 0
			rollback
		set @Info = (select 'Package launcher' [@Process], @PackageID [@PackageID] for xml path('Info'))
		exec Internal.usp_LogError @Info, @ErrorMessage
	end catch

	end conversation @handle
end

if @ErrorMessage is not null
	raiserror(@ErrorMessage, 16, 1)
GO
