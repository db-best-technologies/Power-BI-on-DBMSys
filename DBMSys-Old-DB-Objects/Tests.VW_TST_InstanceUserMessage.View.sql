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
/****** Object:  View [Tests].[VW_TST_InstanceUserMessage]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_InstanceUserMessage]
AS
	SELECT TOP 0
		CAST(null AS int) AS message_id,
		CAST(null AS smallint) AS language_id,
		CAST(null AS tinyint) AS severity,
		CAST(null AS bit) AS is_event_logged,
		CAST(null AS nvarchar(2048)) AS [text],
		CAST(null as int) Metadata_TRH_ID,
		CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_InstanceUserMessage]    Script Date: 6/8/2020 1:16:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TST_InstanceUserMessage] on [Tests].[VW_TST_InstanceUserMessage]
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


	MERGE Inventory.InstanceUserMessage AS D
	USING	(
				SELECT 
					message_id,
					language_id, 
					@MOB_ID AS MOB_ID, 
					severity, is_event_logged, [text],
					Metadata_TRH_ID, Metadata_ClientID
				FROM inserted
			) AS S
			ON IUM_MOB_ID = MOB_ID
				AND IUM_MessageID = message_id
	WHEN matched THEN 
		UPDATE 
		SET
			IUM_LanguageID = language_id, 
			IUM_Severity = severity, 
			IUM_IsEventLogged = is_event_logged, 
			IUM_Text = [text],
			IUM_LastSeenDate = @StartDate,
			IUM_Last_TRH_ID = Metadata_TRH_ID
	WHEN not matched THEN 
		INSERT (IUM_MessageID, IUM_MOB_ID, IUM_LanguageID, IUM_Severity, IUM_IsEventLogged, IUM_Text, IUM_ClientID, IUM_InsertDate, IUM_LastSeenDate, IUM_Last_TRH_ID)
		VALUES (message_id, MOB_ID, language_id, severity, is_event_logged, [text], Metadata_ClientID, @StartDate, @StartDate, Metadata_TRH_ID);

END
GO
