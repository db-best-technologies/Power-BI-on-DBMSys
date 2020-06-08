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
/****** Object:  StoredProcedure [Collect].[usp_GetOracleDDLStatements]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collect].[usp_GetOracleDDLStatements]
--DECLARE 
		@MOB_ID INT
AS

DECLARE @MOB_NAME NVARCHAR(255)
SELECT @MOB_NAME = MOB_Name FROM Inventory.MonitoredObjects WHERE MOB_ID = @MOB_ID

select isnull(stuff((SELECT char(13) + char(10) + ODS_ObjectDDL
					FROM Inventory.OracleDDLStatements
					WHERE	ODS_MOB_ID = @MOB_ID
					ORDER by ODS_Owner,ODS_ObjectType,ODS_ObjectName
			        FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'),1,2,N''),N'') as ODS_ObjectDDL
					,@MOB_NAME as MOB_NAME
GO
