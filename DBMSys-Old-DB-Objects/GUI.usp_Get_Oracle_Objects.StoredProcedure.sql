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
/****** Object:  StoredProcedure [GUI].[usp_Get_Oracle_Objects]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_Get_Oracle_Objects]
	@MOB_ID_List	[GUI].[tblMob] readonly
AS
BEGIN
	SELECT
		MO.MOB_Name,
		i.OPC_Schema,
		i.OPC_Object_Name,
		OT.OOT_Name AS Object_Type,
		i.OPC_CreateDate,
		i.OPC_Last_Upd_Date,
		TS.TPS_Name AS [Status],
		i.OPC_Temporary,
		i.OPC_Generated,
		i.OPC_Secondary,
		i.OPC_Lines_Chars_Count,
		i.OPC_IsWrapped,
		i.OPC_IsCharCount
	FROM
		[Inventory].[Oracle_Objects] AS i
		INNER JOIN Inventory.MonitoredObjects AS MO
		ON i.OPC_MOB_ID = MO.MOB_ID
		INNER JOIN [Inventory].[Oracle_Object_Types] AS OT
		ON i.OPC_OOT_ID = OT.OOT_ID
		INNER JOIN [Inventory].[Oracle_Type_Statuses] AS TS
		ON i.OPC_TPS_ID = TS.TPS_ID
		INNER JOIN @MOB_ID_List AS L
		ON MO.MOB_ID = L.MOB_ID
END
GO
