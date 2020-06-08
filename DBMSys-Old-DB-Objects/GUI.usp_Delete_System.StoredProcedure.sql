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
/****** Object:  StoredProcedure [GUI].[usp_Delete_System]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_Delete_System] 
	@Sys_Id int
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		
		IF NOT EXISTS (
			SELECT 1 
			FROM 
				Inventory.SystemHosts AS SH 
				INNER JOIN Inventory.MonitoredObjects AS MO
				ON SH.SHS_MOB_ID = MO.MOB_ID
			WHERE 
				SH.SHS_SYS_ID = @Sys_Id 
				AND MO.MOB_OOS_ID <> 3)
		BEGIN
			-- Drop refferences between System and SystemHosts if all hosts are in status 3
			UPDATE Inventory.SystemHosts
			SET SHS_SYS_ID = NULL
			WHERE SHS_SYS_ID = @Sys_Id

		END 

		DELETE Inventory.Systems WHERE Sys_ID = @Sys_Id;
	END TRY
	BEGIN CATCH
		declare @Sys_Name sysname = (select Sys_Name from Inventory.Systems WHERE Sys_ID = @Sys_Id);
		declare @msg nvarchar(max) = formatmessage(51008,  @Sys_Name);
		throw 51008, @msg, 1;
	END CATCH
END
GO
