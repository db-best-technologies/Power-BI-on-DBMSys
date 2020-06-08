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
/****** Object:  StoredProcedure [GUI].[usp_Edit_SystemHost_List]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_Edit_SystemHost_List]
	@MOB_List	[GUI].[tblMob] READONLY,
	@SLG_ID		int
AS
BEGIN
	UPDATE MO
	SET
		MOB_SLG_ID = @SLG_ID
	FROM 
		Inventory.MonitoredObjects AS MO
		INNER JOIN @MOB_List AS ML
		ON MO.MOB_ID = ML.MOB_ID
END
GO
