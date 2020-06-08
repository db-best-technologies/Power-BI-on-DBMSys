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
/****** Object:  StoredProcedure [Management].[usp_InsertDefinedObject]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Management].[usp_InsertDefinedObject]
	@PlatformID tinyint,
	@Name nvarchar(128),
	@IsWindowsAuthentication bit,
	@EncryptedLoginID int
as
declare @ClientID int

select @ClientID = cast(SET_Value as int)
from Management.Settings
where SET_Module = 'Management'
	and SET_Key = 'Client ID'

insert into Management.DefinedObjects(DFO_ClientID, DFO_PLT_ID, DFO_Name, DFO_IsWindowsAuthentication, DFO_SLG_ID)
values(@ClientID, @PlatformID, @Name, @IsWindowsAuthentication, @EncryptedLoginID)
GO
