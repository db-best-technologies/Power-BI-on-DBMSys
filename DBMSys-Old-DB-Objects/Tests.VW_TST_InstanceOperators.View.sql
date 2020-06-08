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
/****** Object:  View [Tests].[VW_TST_InstanceOperators]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_InstanceOperators]
AS
	SELECT TOP 0
		CAST(null as nvarchar(128)) AS name, 
		CAST(null as tinyint) AS [enabled], 
		CAST(null as nvarchar(100)) AS email_address, 
		CAST(null as int) AS last_email_date, 
		CAST(null as int) AS last_email_time, 
		CAST(null as nvarchar(100)) AS pager_address, 
		CAST(null as int) AS last_pager_date, 
		CAST(null as int) AS last_pager_time, 
		CAST(null as int) AS weekday_pager_start_time, 
		CAST(null as int) AS weekday_pager_end_time, 
		CAST(null as int) AS saturday_pager_start_time, 
		CAST(null as int) AS saturday_pager_end_time, 
		CAST(null as int) AS sunday_pager_start_time, 
		CAST(null as int) AS sunday_pager_end_time, 
		CAST(null as tinyint) AS pager_days, 
		CAST(null as nvarchar(100)) AS netsend_address, 
		CAST(null as int) AS last_netsend_date, 
		CAST(null as int) AS last_netsend_time, 
		CAST(null as int) AS category_id,
		CAST(null as int) AS Metadata_TRH_ID,
		CAST(null as int) AS Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_InstanceOperators]    Script Date: 6/8/2020 1:16:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TST_InstanceOperators] on [Tests].[VW_TST_InstanceOperators]
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


	MERGE Inventory.InstanceOperators AS D
	USING	(
				SELECT 
					name, [enabled], email_address, last_email_date, last_email_time, pager_address, last_pager_date, 
					last_pager_time, weekday_pager_start_time, weekday_pager_end_time, saturday_pager_start_time, 
					saturday_pager_end_time, sunday_pager_start_time, sunday_pager_end_time, pager_days, netsend_address, 
					last_netsend_date, last_netsend_time, category_id, @Mob_ID AS Mob_ID, Metadata_TRH_ID, Metadata_ClientID
				FROM inserted
			) AS S
			ON IOP_MOB_ID = MOB_ID
				AND IOP_Name = name
	WHEN matched THEN 
		UPDATE 
		SET
			IOP_Enabled = [enabled], 
			IOP_email_address = email_address, 
			IOP_last_email_date = last_email_date, 
			IOP_last_email_time = last_email_time, 
			IOP_pager_address = pager_address, 
			IOP_last_pager_date = last_pager_date, 
			IOP_last_pager_time = last_pager_time, 
			IOP_weekday_pager_start_time = weekday_pager_start_time, 
			IOP_weekday_pager_end_time = weekday_pager_end_time, 
			IOP_saturday_pager_start_time = saturday_pager_start_time, 
			IOP_saturday_pager_end_time = saturday_pager_end_time, 
			IOP_sunday_pager_start_time = sunday_pager_start_time, 
			IOP_sunday_pager_end_time = sunday_pager_end_time, 
			IOP_pager_days = pager_days, 
			IOP_netsend_address = netsend_address, 
			IOP_last_netsend_date = last_netsend_date, 
			IOP_last_netsend_time = last_netsend_time, 
			IOP_category_id = category_id,
			IOP_LastSeenDate = @StartDate,
			IOP_Last_TRH_ID = Metadata_TRH_ID
	WHEN not matched THEN 
		INSERT (
			IOP_MOB_ID, IOP_Name, IOP_Enabled, IOP_email_address, IOP_last_email_date, IOP_last_email_time, IOP_pager_address, IOP_last_pager_date, 
			IOP_last_pager_time, IOP_weekday_pager_start_time, IOP_weekday_pager_end_time, IOP_saturday_pager_start_time, IOP_saturday_pager_end_time, 
			IOP_sunday_pager_start_time, IOP_sunday_pager_end_time, IOP_pager_days, IOP_netsend_address, IOP_last_netsend_date, IOP_last_netsend_time, 
			IOP_category_id, IOP_InsertDate, IOP_LastSeenDate, IOP_Last_TRH_ID, IOP_ClientID)
		VALUES (
			MOB_ID, name, [enabled], email_address, last_email_date, last_email_time, pager_address, last_pager_date, 
			last_pager_time, weekday_pager_start_time, weekday_pager_end_time, saturday_pager_start_time, saturday_pager_end_time, 
			sunday_pager_start_time, sunday_pager_end_time, pager_days, netsend_address, last_netsend_date, last_netsend_time, 
			category_id, @StartDate, @StartDate, Metadata_TRH_ID, Metadata_ClientID);

END
GO
