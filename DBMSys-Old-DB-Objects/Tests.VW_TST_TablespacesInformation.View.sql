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
/****** Object:  View [Tests].[VW_TST_TablespacesInformation]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_TablespacesInformation]
AS
	SELECT TOP 0
		CAST(NULL AS nvarchar(255)) AS TablespaceName,
		CAST(NULL AS nvarchar(16)) AS [Status],
		CAST(NULL AS nvarchar(16)) AS Contents,
		CAST(NULL AS int) AS SizeMB,
		CAST(NULL AS int) AS FreeSpaceMB,
		CAST(NULL AS int) AS UsedSpaceMB,
		CAST(NULL AS int) AS PercentFreeMB,
		CAST(NULL AS int) AS PercentUsed,
		CAST(NULL AS int) AS MaxSizeMB,
		CAST(NULL AS int) AS UsedMaxSize,
		CAST(NULL AS int) AS Metadata_TRH_ID,
		CAST(NULL AS int) AS Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_TablespacesInformation]    Script Date: 6/8/2020 1:16:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TST_TablespacesInformation] on [Tests].[VW_TST_TablespacesInformation]
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

	-- Tablespace Name
	MERGE Inventory.Tablespaces AS S
	USING	(
				SELECT [TablespaceName], Metadata_TRH_ID, Metadata_ClientID
				FROM inserted
				WHERE [TablespaceName] is not null
			) AS D
			ON TSP_TableSpaceName = [TableSpaceName]
	WHEN not matched THEN 
		INSERT (TSP_TableSpaceName)
		VALUES (TableSpaceName);

	-- Status
	MERGE Inventory.Oracle_Checks_Statuses AS S
	USING	(
				SELECT [Status], Metadata_TRH_ID, Metadata_ClientID
				FROM inserted
				WHERE [status] is not null
			) AS D
			ON OCS_Name = [Status]
	WHEN not matched THEN 
		INSERT (OCS_Name)
		VALUES ([Status]);

	-- Contents
	MERGE Inventory.Contents AS S
	USING	(
				SELECT [Contents], Metadata_TRH_ID, Metadata_ClientID
				FROM inserted
				WHERE [Contents] is not null
			) AS D
			ON 
				CNT_ContentName = Contents
	WHEN not matched THEN 
		INSERT (CNT_ContentName)
		VALUES (Contents);


	INSERT INTO [Inventory].[TablespacesInformation] (
		TSI_Client_ID, TSI_MOB_ID, TSI_TSP_ID, TSI_OCS_ID, TSI_CNT_ID, TSI_SizeMB, TSI_FreeSpaceMB,
		TSI_UsedSpaceMB, TSI_PercentFreeMB, TSI_PercentUsed, TSI_MaxSizeMB, TSI_UsedMaxSize,
		TSI_InsertDate, TSI_LastSeenDate, TSI_Last_TRH_ID)
	SELECT
		Metadata_ClientID, @MOB_ID, TS.TSP_ID, S.OCS_ID, C.CNT_ID, i.SizeMB, i.FreeSpaceMB,
		i.UsedSpaceMB, i.PercentFreeMB, i.PercentUsed, i.MaxSizeMB, i.UsedMaxSize,
		@StartDate, @StartDate, Metadata_TRH_ID
	FROM
		inserted AS i
		INNER JOIN Inventory.Tablespaces AS TS
			ON i.TablespaceName = TS.TSP_TableSpaceName
		INNER JOIN Inventory.Oracle_Checks_Statuses AS S
			ON i.[Status] = S.OCS_Name
		INNER JOIN Inventory.Contents AS C
			ON i.Contents = C.CNT_ContentName

END
GO
