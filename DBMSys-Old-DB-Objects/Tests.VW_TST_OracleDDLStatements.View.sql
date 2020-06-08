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
/****** Object:  View [Tests].[VW_TST_OracleDDLStatements]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_OracleDDLStatements]
AS
	SELECT TOP 0
		CAST(null as Nvarchar(255))		AS	ObjectOwner
		,CAST(null as NVARCHAR(255))	AS	ObjectName	
		,CAST(null as NVARCHAR(32) )	AS	ObjectType	
		,CAST(null as NVARCHAR(max))	AS	ObjectDDL	
		,CAST(null as datetime2(3) )	AS	InsertDate	
		,CAST(null as INT )				AS 	Metadata_TRH_ID
		,CAST(null as INT)				AS	Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_OracleDDLStatements]    Script Date: 6/8/2020 1:16:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TST_OracleDDLStatements] on [Tests].[VW_TST_OracleDDLStatements]
	INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE 
		@MOB_ID		int,
		@StartDate	datetime2(3)

	SELECT TOP 1
		@MOB_ID = H.TRH_MOB_ID,
		@StartDate = H.TRH_StartDate
	FROM 
		inserted AS I
		INNER JOIN Collect.TestRunHistory AS H 
			ON I.Metadata_TRH_ID = H.TRH_ID

	Delete from Inventory.OracleDDLStatements WHERE ODS_MOB_ID = @MOB_ID and @StartDate <> ODS_InsertDate

	INSERT INTO Inventory.OracleDDLStatements
		(
			ODS_Client_ID
			,ODS_MOB_ID
			,ODS_Owner
			,ODS_ObjectName	
			,ODS_ObjectType	
			,ODS_ObjectDDL
			,ODS_InsertDate
			,ODS_LastSeenDate
			,ODS_Last_TRH_ID
		)
	SELECT 
			Metadata_ClientID 
			,@MOB_ID
			,ObjectOwner
			,ObjectName
			,ObjectType
			,ObjectDDL
			,@StartDate
			,@StartDate
			,Metadata_TRH_ID
	FROM	inserted i
	
END
GO
