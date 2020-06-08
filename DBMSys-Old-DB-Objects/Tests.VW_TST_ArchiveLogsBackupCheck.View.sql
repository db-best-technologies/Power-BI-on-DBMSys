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
/****** Object:  View [Tests].[VW_TST_ArchiveLogsBackupCheck]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_ArchiveLogsBackupCheck]
AS
	SELECT TOP 0
		CAST(null as varchar(255)) AS MSG,
		CAST(null as varchar(255)) AS [Status],
		CAST(null as int) AS Metadata_TRH_ID,
		CAST(null as int) AS Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_ArchiveLogsBackupCheck]    Script Date: 6/8/2020 1:15:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TST_ArchiveLogsBackupCheck] on [Tests].[VW_TST_ArchiveLogsBackupCheck]
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


	INSERT INTO [Inventory].[ArchiveLogsBackupCheck] (
		ALC_Client_ID, ALC_MOB_ID, ALC_Message, ALC.ALC_OCS_ID, ALC_InsertDate, ALC_LastSeenDate, ALC_Last_TRH_ID)
	SELECT
		Metadata_ClientID, @MOB_ID, i.MSG, S.OCS_ID, @StartDate, @StartDate, Metadata_TRH_ID
	FROM
		inserted AS i
		INNER JOIN Inventory.Oracle_Checks_Statuses AS S
			ON i.[Status] = S.OCS_Name
		
END
GO
