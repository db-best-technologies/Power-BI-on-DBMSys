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
/****** Object:  View [Tests].[VW_TST_InstanceAlerts]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_InstanceAlerts]
AS
	SELECT TOP 0
		CAST(null AS nvarchar(128)) AS name, 
		CAST(null AS nvarchar(100)) AS event_source, 
		CAST(null AS int) AS event_category_id, 
		CAST(null AS int) AS event_id, 
		CAST(null AS int) AS message_id, 
		CAST(null AS int) AS language_id, 
		CAST(null AS bit) AS is_event_logged,
		CAST(null AS nvarchar(2048)) AS Message_Description,
		CAST(null AS tinyint) AS Severity,
		CAST(null AS tinyint) AS [enabled], 
		CAST(null AS int) AS delay_between_responses, 
		CAST(null AS int) AS last_occurrence_date, 
		CAST(null AS int) AS last_occurrence_time, 
		CAST(null AS int) AS last_response_date, 
		CAST(null AS int) AS last_response_time, 
		CAST(null AS nvarchar(512)) AS notification_message, 
		CAST(null AS tinyint) AS include_event_description, 
		CAST(null AS nvarchar(512)) AS [database_name], 
		CAST(null AS nvarchar(100)) AS event_description_keyword, 
		CAST(null AS int) AS occurrence_count, 
		CAST(null AS int) AS count_reset_date, 
		CAST(null AS int) AS count_reset_time, 
		CAST(null AS nvarchar(128)) AS job_name, 
		CAST(null AS int) AS has_notification, 
		CAST(null AS int) AS flags, 
		CAST(null AS nvarchar(512)) AS performance_condition, 
		CAST(null AS int) AS category_id,
		CAST(null as int) AS Metadata_TRH_ID,
		CAST(null as int) AS Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_InstanceAlerts]    Script Date: 6/8/2020 1:16:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TST_InstanceAlerts] on [Tests].[VW_TST_InstanceAlerts]
	INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE 
		@MOB_ID		int,
		@StartDate	datetime2(3),
		@LanguageID smallint /*lcid in sys.syslanguages*/

	SELECT TOP 1
		@MOB_ID = H.TRH_MOB_ID,
		@StartDate = H.TRH_StartDate
	FROM 
		inserted AS I
		INNER JOIN Collect.TestRunHistory AS H 
			ON I.Metadata_TRH_ID = H.TRH_ID

	/* database_name */
	MERGE Inventory.InstanceDatabases AS S
	USING	(
				SELECT [database_name], Metadata_TRH_ID, Metadata_ClientID
				FROM inserted
				WHERE [database_name] is not null
			) AS D
			ON IDB_MOB_ID = @MOB_ID
				AND IDB_Name = [database_name]
	WHEN not matched THEN 
		INSERT (IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
		VALUES (Metadata_ClientID, @MOB_ID, [database_name], @StartDate, @StartDate, Metadata_TRH_ID);

	/* Jobs */
	MERGE Inventory.InstanceJobs AS D
	USING	(
				SELECT DISTINCT job_name, Metadata_TRH_ID, Metadata_ClientID
				FROM inserted
				WHERE job_name is not null
			) AS S
			ON IJB_MOB_ID = @MOB_ID
			AND IJB_Name = S.job_name
	WHEN not matched THEN 
			INSERT (IJB_ClientID, IJB_MOB_ID, IJB_Name, IJB_InsertDate, IJB_LastSeenDate, IJB_Last_TRH_ID)
			VALUES (Metadata_ClientID, @MOB_ID, job_name, @StartDate, @StartDate, Metadata_TRH_ID);

	/* Messages */
	MERGE Inventory.InstanceUserMessage AS D
	USING	(
				SELECT DISTINCT Message_Description, Severity, Message_ID, Language_ID, is_event_logged, Metadata_TRH_ID, Metadata_ClientID
				FROM inserted
				WHERE Message_ID is not null
						and Language_ID is not null
			) AS S
			ON IUM_MOB_ID = @MOB_ID
			AND IUM_MessageID = S.Message_ID
			AND ISNULL(IUM_LanguageID,0) = ISNULL(S.Language_ID,0)
	WHEN not matched THEN 
			INSERT (IUM_MessageID, IUM_MOB_ID, IUM_LanguageID, IUM_Severity, IUM_IsEventLogged, IUM_Text, IUM_InsertDate, IUM_LastSeenDate, IUM_Last_TRH_ID, IUM_ClientID)
			VALUES (Message_ID, @MOB_ID, Language_id, Severity, is_event_logged, Message_Description, @StartDate, @StartDate, Metadata_TRH_ID, Metadata_ClientID);	
		
	
				
	SET @LanguageID = CAST(1033 as smallint) /* English */
	MERGE Inventory.InstanceAlerts AS D
	USING	(
				SELECT DISTINCT 
					name, event_source, event_category_id, event_id, 
					M.IUM_ID, [enabled], delay_between_responses, last_occurrence_date, 
					last_occurrence_time, last_response_date, last_response_time, notification_message, 
					include_event_description,  D.IDB_ID, event_description_keyword, occurrence_count, 
					count_reset_date, count_reset_time, J.IJB_ID, has_notification, flags, 
					performance_condition, category_id, Metadata_TRH_ID, Metadata_ClientID,
					@MOB_ID AS MOB_ID
				FROM 
					inserted AS I
					OUTER APPLY (SELECT 
										TOP 1 
										m2.IUM_ID 
								from	Inventory.InstanceUserMessage AS M2
								JOIN	(SELECT distinct IUM_languageID AS lngID,IIF(IUM_languageID = @LanguageID,0,1) as ord from Inventory.InstanceUserMessage)lm on M2.IUM_LanguageID = lngID
								WHERE	I.Message_ID = M2.IUM_MessageID
										AND M2.IUM_MOB_ID = @Mob_ID 
								ORDER BY ord
						)m
					LEFT JOIN Inventory.InstanceJobs AS J
					ON I.job_name = J.IJB_Name
						AND J.IJB_MOB_ID = @Mob_ID
					LEFT JOIN Inventory.InstanceDatabases AS D
					ON I.[database_name] = D.IDB_Name
						AND D.IDB_MOB_ID = @Mob_ID
					WHERE Message_ID is not null
						and Language_ID is not null
			) AS S
			ON D.ISA_MOB_ID = S.MOB_ID
				AND D.ISA_Name = S.name
	WHEN matched THEN 
		UPDATE 
		SET
			ISA_MOB_ID = S.Mob_ID,  
			ISA_Event_Source = event_source, 
			ISA_Event_CategoryID = event_category_id, 
			ISA_EventID = event_id, 
			ISA_IUM_ID = IUM_ID, 
			ISA_Enabled = [enabled], 
			ISA_Delay_Between_Responses = delay_between_responses, 
			ISA_Last_Occurrence_Date = last_occurrence_date, 
			ISA_Last_Occurrence_Time = last_occurrence_time, 
			ISA_Last_Response_Date = last_response_date, 
			ISA_Last_Response_Time = last_response_time, 
			ISA_Notification_Message = notification_message, 
			ISA_Include_Event_Description = include_event_description, 
			ISA_IDB_ID = IDB_ID, 
			ISA_Event_Description_Keyword = event_description_keyword, 
			ISA_Occurrence_Count = occurrence_count, 
			ISA_Count_Reset_Date = count_reset_date, 
			ISA_Count_Reset_Time = count_reset_time, 
			ISA_IJB_ID = IJB_ID, 
			ISA_Has_Notification = has_notification, 
			ISA_Flags = flags, 
			ISA_Performance_Condition = performance_condition, 
			ISA_CategoryID = category_id, 
			ISA_LastSeenDate = @StartDate,
			ISA_Last_TRH_ID = Metadata_TRH_ID
	WHEN not matched THEN 
		INSERT (
			ISA_MOB_ID, ISA_Name, ISA_Event_Source, ISA_Event_CategoryID, ISA_EventID, ISA_IUM_ID, ISA_Enabled, 
			ISA_Delay_Between_Responses, ISA_Last_Occurrence_Date, ISA_Last_Occurrence_Time, ISA_Last_Response_Date, ISA_Last_Response_Time, 
			ISA_Notification_Message, ISA_Include_Event_Description, ISA_IDB_ID, ISA_Event_Description_Keyword, ISA_Occurrence_Count, 
			ISA_Count_Reset_Date, ISA_Count_Reset_Time, ISA_IJB_ID, ISA_Has_Notification, ISA_Flags, ISA_Performance_Condition, 
			ISA_CategoryID, ISA_InsertDate, ISA_LastSeenDate, ISA_Last_TRH_ID, ISA_ClientID)
		VALUES (
			Mob_ID, name, event_source, event_category_id, event_id, IUM_ID, [enabled],
			delay_between_responses, last_occurrence_date, last_occurrence_time, last_response_date, last_response_time,
			notification_message, include_event_description, IDB_ID, event_description_keyword, occurrence_count,
			count_reset_date, count_reset_time, IJB_ID, has_notification, flags, performance_condition,
			category_id, @StartDate, @StartDate, Metadata_TRH_ID, Metadata_ClientID);
	
	select * from Inventory.InstanceUserMessage where IUM_MOB_ID = @MOB_ID and IUM_MessageID = 0

END
GO
