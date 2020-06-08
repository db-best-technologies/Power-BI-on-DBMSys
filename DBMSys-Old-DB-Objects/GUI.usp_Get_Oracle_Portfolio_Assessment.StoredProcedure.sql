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
/****** Object:  StoredProcedure [GUI].[usp_Get_Oracle_Portfolio_Assessment]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_Get_Oracle_Portfolio_Assessment]
	@MOB_ID_List	[GUI].[tblMob] readonly
AS
BEGIN
	SELECT
		M.Mob_ID,
		M.MOB_Name,
		D.ODL_Schema,
		D.ODL_Packages,
		D.ODL_UDT,
		D.ODL_Procedures,
		D.ODL_Functions,
		D.ODL_Views,
		D.ODL_Tables,
		D.ODL_Synonyms
	FROM
		[Inventory].[MonitoredObjects] AS M
		INNER JOIN [Inventory].[Oracle_Portfolio_Assessment] AS D
		ON M.MOB_ID = D.ODL_MOB_ID
		INNER JOIN @MOB_ID_List AS L
		ON M.MOB_ID = L.MOB_ID
END
GO
