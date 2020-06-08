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
/****** Object:  StoredProcedure [GUI].[usp_Edit_System]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [GUI].[usp_Edit_System]
	@SYS_ID		INT, 
	@SYS_NAME	NVARCHAR(255),
	@SYS_Descr	NVARCHAR(255) = null
as
set nocount on;

begin try

	if not exists (select 1 from Inventory.Systems where SYS_NAME = @SYS_NAME AND SYS_ID != @SYS_ID)
		update Inventory.Systems SET SYS_NAME = @SYS_NAME, SYS_Description = @SYS_Descr WHERE SYS_ID = @SYS_ID;
end try
begin catch
	return;
end catch
GO
