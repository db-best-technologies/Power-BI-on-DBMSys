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
/****** Object:  View [Tests].[VW_TST_DBInstance_Portfolio_Assessment]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_DBInstance_Portfolio_Assessment]
AS
SELECT	TOP 0
		CAST('' AS NVARCHAR(255))	AS DatabaseName	
		,CAST('' AS NVARCHAR(255))	AS SchemaName		
		,CAST('' AS NVARCHAR(255))	AS ObjectType		
		,CAST(0 AS INT)				AS ObjectCount		
		,CAST(null as int)			AS Metadata_TRH_ID
		,CAST(null as int)			AS Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_DBInstance_Portfolio_Assessment]    Script Date: 6/8/2020 1:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TST_DBInstance_Portfolio_Assessment] on [Tests].[VW_TST_DBInstance_Portfolio_Assessment]
	INSTEAD OF INSERT
AS
BEGIN
	
	MERGE Inventory.DBInstancePortfolioAssessment
	USING (
			SELECT	Metadata_ClientID,TRH_MOB_ID,DatabaseName,SchemaName,ObjectType,ObjectCount,TRH_ID
			FROM	inserted i
			JOIN	Collect.TestRunHistory trh ON i.Metadata_TRH_ID = TRH_ID
			)ins ON SPA_MOB_ID = ins.TRH_MOB_ID AND ISNULL(SPA_DatabaseName,'') = ISNULL(DatabaseName,'') AND ISNULL(SPA_SchemaName,'') = ISNULL(SchemaName,'') AND SPA_ObjectType = ObjectType
	WHEN MATCHED THEN
	UPDATE
	SET		
			SPA_ObjectCount = ObjectCount
			,SPA_LastTRH_ID = TRH_ID
	WHEN NOT MATCHED THEN INSERT(SPA_ClientID,SPA_MOB_ID,SPA_DatabaseName,SPA_SchemaName,SPA_ObjectType,SPA_ObjectCount,SPA_LastTRH_ID)
	VALUES(Metadata_ClientID,TRH_MOB_ID,DatabaseName,SchemaName,ObjectType,ObjectCount,TRH_ID);

END
GO
