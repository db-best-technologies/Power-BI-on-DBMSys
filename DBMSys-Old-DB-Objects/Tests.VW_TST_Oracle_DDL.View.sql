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
/****** Object:  View [Tests].[VW_TST_Oracle_DDL]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_Oracle_DDL]
AS
	SELECT TOP 0
		CAST(NULL AS nvarchar(255)) AS [Schema],
		CAST(NULL AS int) AS Packages,
		CAST(NULL AS int) AS UDT,
		CAST(NULL AS int) AS [Procedures],
		CAST(NULL AS int) AS Functions,
		CAST(NULL AS int) AS [Views],
		CAST(NULL AS int) AS [Tables],
		CAST(NULL AS int) AS [Synonyms],
		CAST(NULL AS int) AS Metadata_TRH_ID,
		CAST(NULL AS int) AS Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_Oracle_DDL]    Script Date: 6/8/2020 1:16:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TST_Oracle_DDL] on [Tests].[VW_TST_Oracle_DDL]
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

	INSERT INTO [Inventory].[Oracle_DDL] (
		ODL_Client_ID, ODL_MOB_ID, 
		ODL_Schema, ODL_Packages, ODL_Procedures, ODL_Functions, ODL_Tables, ODL_UDT, ODL_Views, ODL_Synonyms, 
		ODL_InsertDate, ODL_LastSeenDate, ODL_Last_TRH_ID)
	SELECT
		Metadata_ClientID, @MOB_ID,
		[Schema], Packages, [Procedures], Functions, [Tables], UDT, [Views], [Synonyms], 
		@StartDate, @StartDate, Metadata_TRH_ID
	FROM
		inserted
		
END
GO
