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
/****** Object:  View [Tests].[VM_TST_DBMILimitingFeatures]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VM_TST_DBMILimitingFeatures]
AS
	SELECT 
		CAST(NULL AS NVARCHAR(255))		AS EntityId			
		,CAST(NULL AS NVARCHAR(255))	AS Entityname			
		,CAST(NULL AS NVARCHAR(255))	AS EntityChildID		
		,CAST(NULL AS NVARCHAR(255))	AS EntityChildName		
		,CAST(NULL AS NVARCHAR(255))	AS LimitedF				
		,CAST(NULL AS NVARCHAR(255))	AS EntityValue	
		,CAST(NULL AS INT)				AS Metadata_TRH_ID	
		,CAST(NULL AS INT)				AS Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VM_TST_DBMILimitingFeatures]    Script Date: 6/8/2020 1:15:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VM_TST_DBMILimitingFeatures] ON [Tests].[VM_TST_DBMILimitingFeatures]
	INSTEAD OF INSERT
AS
	SET NOCOUNT ON;
	
	DECLARE 
			@MOBID		INT
			,@SeenDate	DATETIME2(3)
	
	SELECT 
			@MOBID		= TRH_MOB_ID
			,@SeenDate	= TRH_InsertDate
	FROM	inserted i
	JOIN	Collect.TestRunHistory ON Metadata_TRH_ID = TRH_ID		

	;WITH DBMILF AS 
	(
		SELECT 
				*
		FROM	Inventory.DBMILimitingFeatures
		WHERE	DLF_MOB_ID = @MOBID
	)

	MERGE DBMILF d
		USING (
				SELECT 
						*
				FROM	inserted
				)i
			ON 
				 DLF_EntityId			= EntityId		
			 AND DLF_Entityname			= Entityname		
			 AND ISNULL(DLF_EntityChildID,'')		= ISNULL(EntityChildID,'')	
			 AND ISNULL(DLF_EntityChildName,'')	= ISNULL(EntityChildName,'')
			 AND DLF_LimitedF			= LimitedF		
	WHEN MATCHED THEN UPDATE SET
			DLF_EntityValue		= EntityValue	
			,DLF_IsDeleted		= 0	
			,DLF_Last_TRH_ID	= Metadata_TRH_ID
			,DLF_LastSeenDate	= @SeenDate
	WHEN NOT MATCHED THEN INSERT(DLF_MOB_ID,DLF_EntityId,DLF_Entityname,DLF_EntityChildID,DLF_EntityChildName,DLF_LimitedF,DLF_EntityValue,DLF_IsDeleted,DLF_Last_TRH_ID,DLF_LastSeenDate)
	VALUES(@MOBID,EntityId,Entityname,EntityChildID,EntityChildName,LimitedF,EntityValue,0,Metadata_TRH_ID,@SeenDate)
	WHEN NOT MATCHED BY SOURCE  THEN
		UPDATE SET
			DLF_IsDeleted = 1;
GO
