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
/****** Object:  StoredProcedure [ManagementInterface].[usp_DefinedObjects_AddUpdate]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ManagementInterface].[usp_DefinedObjects_AddUpdate]
	@ID int = null,
	@Name nvarchar(128),
	@PlatformID varchar(1000),
	@IsWindowsAuthentication bit,
	@CredentialID int
as
set nocount on
declare @ClientID int
if @ID is null
begin
	select @ClientID = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Management'
		and SET_Key = 'Client ID'

	insert into Management.DefinedObjects(DFO_ClientID, DFO_Name, DFO_PLT_ID, DFO_IsWindowsAuthentication, DFO_SLG_ID)
	values(@ClientID, @Name, @PlatformID, @IsWindowsAuthentication, @CredentialID)
	
	set @ID = SCOPE_IDENTITY()
end
else
	update Management.DefinedObjects
	set DFO_Name = @Name,
		DFO_PLT_ID = @PlatformID,
		DFO_IsWindowsAuthentication = @IsWindowsAuthentication,
		DFO_SLG_ID = @CredentialID
	where DFO_ID = @ID

select @ID ID
GO
