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
/****** Object:  StoredProcedure [GUI].[usp_DeleteMaintenanceWindows]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_DeleteMaintenanceWindows]
--DECLARE
	@MWG_ID Inventory.SystemHosts_List readonly
AS
UPDATE	m
SET		MTW_IsDeleted = 1
FROM	Operational.MaintenanceWindows m join @MWG_ID w on m.MTW_MWG_ID = w.SHS_MOB_ID
GO
