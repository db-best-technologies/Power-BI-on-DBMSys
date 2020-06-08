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
/****** Object:  View [Tests].[VW_TableIdentityLimited]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TableIdentityLimited]
AS
	SELECT 
			CAST(NULL AS NVARCHAR(255))		AS DatabaseName	
			,CAST(NULL AS NVARCHAR(255))	AS TableName		
			,CAST(NULL AS NVARCHAR(255))	AS ColumnName	
			,CAST( NULL AS NVARCHAR(255))	AS ColumnType	
			,CAST(NULL AS FLOAT)			AS MaxValue		
			,CAST(NULL AS FLOAT)			AS CurrValue		
			,CAST(NULL AS FLOAT)			AS IdentityIncr	
			,CAST(NULL AS FLOAT)			AS IdentCurr		
			,CAST(NULL AS DATETIME)			AS CreatedDate		
			,CAST(NULL AS INT)				AS Metadata_TRH_ID	
			,CAST(NULL AS INT)				AS Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TableIdentityLimited]    Script Date: 6/8/2020 1:15:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TableIdentityLimited] ON [Tests].[VW_TableIdentityLimited]
	INSTEAD OF INSERT
AS
	DECLARE 
			@MOBID		INT
			,@SeenDate	DATETIME

	SELECT 
			@MOBID		= TRH_MOB_ID
			,@SeenDate	= TRH_StartDate
	FROM	inserted i
	JOIN	Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
	
	;WITH IdentTabl AS 
	(
		SELECT 
				*
		FROM	Activity.TableIdentityLimited
		WHERE	TIL_MOB_ID = @MOBID
	)

	MERGE IdentTabl
	USING (
			SELECT 
					DatabaseName	
					,TableName		
					,ColumnName	
					,ColumnType	
					,MaxValue		
					,CurrValue		
					,IdentityIncr	
					,IdentCurr		
					,GETUTCDATE() AS CreatedDate		
					,Metadata_TRH_ID	
			FROM	inserted 
			)i
			ON i.DatabaseName = TIL_DatabaseName
				AND i.TableName = TIL_TableName	
				AND i.ColumnName = TIL_ColumnName	
				AND i.ColumnType = TIL_ColumnType

		WHEN MATCHED THEN UPDATE SET
				TIL_LastSeenDate = @SeenDate
				,TIL_MaxValue	 =  MaxValue		
				,TIL_CurrValue	 =  CurrValue		
				,TIL_IdentityIncr =  IdentityIncr	
				,TIL_IdentCurr	 =  IdentCurr		
		WHEN NOT MATCHED THEN INSERT(TIL_MOB_ID,TIL_IsDeleted,TIL_DatabaseName,TIL_TableName,TIL_ColumnName,TIL_ColumnType,TIL_MaxValue,TIL_CurrValue,TIL_IdentityIncr,TIL_IdentCurr,TIL_CreatedDate,TIL_Last_TRH_ID,TIL_LastSeenDate)
		VALUES(@MOBID,0,DatabaseName,TableName,ColumnName,ColumnType,MaxValue,CurrValue,IdentityIncr,IdentCurr,CreatedDate,Metadata_TRH_ID,@SeenDate)
		WHEN NOT MATCHED BY SOURCE  THEN
		UPDATE SET
			TIL_IsDeleted = 1;
GO
