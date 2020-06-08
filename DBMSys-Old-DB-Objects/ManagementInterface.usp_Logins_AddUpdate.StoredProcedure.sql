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
/****** Object:  StoredProcedure [ManagementInterface].[usp_Logins_AddUpdate]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ManagementInterface].[usp_Logins_AddUpdate]
	@ID int = null,
	@Description varchar(1000),
	@Login nvarchar(255),
	@Password nvarchar(255),
	@IsDefault bit
as
set nocount on
if @ID is null
begin
	insert into SYL.SqlLogins(SLG_Description, SLG_Login, SLG_Password, SLG_IsDefault)
	values(@Description, @Login, @Password, @IsDefault)
	
	set @ID = SCOPE_IDENTITY()
end
else
	update SYL.SqlLogins
	set SLG_Description = @Description,
		SLG_Login = @Login,
		SLG_Password = case when @Password is null
							then SLG_Password
							else SYL.udf_EncryptPassword(@Password)
						end,
		SLG_IsDefault = @IsDefault
	where SLG_ID = @ID

if @IsDefault = 1
	update SYL.SqlLogins
	set SLG_IsDefault = 0
	where SLG_ID <> @ID
		and SLG_IsDefault = 1

select @ID ID
GO
