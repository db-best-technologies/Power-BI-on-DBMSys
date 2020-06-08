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
/****** Object:  StoredProcedure [ResponseProcessing].[isp_SetEventsGroupProperties]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ResponseProcessing].[isp_SetEventsGroupProperties]

	@EventSubscriptions [ResponseProcessing].[TT_Event_ContactList_Properties] READONLY
AS
	DECLARE @clientID int 
	SELECT @clientID = CAST(SET_Value AS INT)
	FROM   Management.Settings
	WHERE  SET_Key ='Client ID'

	IF OBJECT_ID('tempdb..#INS') IS NOT NULL DROP TABLE #INS
	CREATE TABLE #INS 
	(
	[EventID] [int] NOT NULL
	,[GroupName] [nvarchar] (255) NOT NULL
	,[groupXML] XML
	,[IsActive] bit NULL
	,[ResponseTypeID] [int] NOT NULL
	,[SubscriptionTypeID] TINYINT NOT NULL
	,[IncludeOpenAndShut] BIT NOT NULL
	,[ResponseGroupingID] TINYINT NOT NULL
	,[RespondOnceForMultipleIdenticalEvents] BIT NOT NULL
	,[RerunEachMin] INT NULL
	,[RerunMaxNumberOfTimes] INT NULL
	,[ProcessingInterval] INT NOT NULL
	);

	INSERT INTO #INS
	SELECT 
			EventID
			,GroupName
			, cast((
								Select * 
										from
										(	select 'Contact Lists' AS Name, GroupName AS Value
											union all
											select 'Format Type' AS Name, 'Table' AS Value
										) as Parameter
										FOR XML AUTO,  ROOT('Parameters')
					)  as xml) as groupXML
			,IsActive
			,ResponseTypeID
			,SubscriptionTypeID
			,IncludeOpenAndShut
			,ResponseGroupingID
			,RespondOnceForMultipleIdenticalEvents
			,RerunEachMin
			,RerunMaxNumberOfTimes
			,ProcessingInterval
	from @EventSubscriptions

	--SELECT * FROM #INS


	;with subs as
	(
		SELECT	
		ESP_ClientID 
		,ESP_MOV_ID	AS EventID 
		,ESP_Parameters 
		,G.groupName AS GroupName
		,ESP_IsActive 
		,ESP_RSP_ID		
		,ESP_EST_ID -- Subscription trigger On Open/ On Close / both/ custom report		--
		,ESP_IncludeOpenAndShut	
		,ESP_RGT_ID			
		,ESP_RespondOnceForMultipleIdenticalEvents 
		,ESP_RerunEveryXSeconds --/ 60.0 AS RerunEachMin 
		,ESP_RerunMaxNumberOfTimes 
		,ESP_ProcessingInterval 
		FROM	ResponseProcessing.EventSubscriptions
			OUTER APPLY (SELECT groupName
							FROM
							(
								SELECT 					
								Name = t.n.value('@Name', 'varchar(500)')
								,groupName = t.n.value ('@Value', 'varchar(500)')
								FROM ESP_Parameters.nodes('/Parameters/Parameter') as t(n)
							) AS T
							WHERE Name = 'Contact Lists'
						) AS G
		WHERE ESP_RSP_ID IN (1, 4)
	)	


	MERGE subs
		USING #INS AS es
		ON  subs.EventID = es.EventID AND subs.GroupName = es.GroupName
		
		WHEN NOT MATCHED THEN INSERT (ESP_ClientID, EventID, ESP_RSP_ID, ESP_Parameters, ESP_EST_ID, ESP_IncludeOpenAndShut
										,ESP_ProcessingInterval, ESP_RGT_ID, ESP_RespondOnceForMultipleIdenticalEvents
										,ESP_RerunEveryXSeconds,  ESP_RerunMaxNumberOfTimes, ESP_IsActive  )
							VALUES (@clientID
									,es.EventID
									,es.ResponseTypeID
									,es.groupXML
									,es.SubscriptionTypeID
									,es.IncludeOpenAndShut
									,es.ProcessingInterval
									,es.ResponseGroupingID
									,es.RespondOnceForMultipleIdenticalEvents
									,es.RerunEachMin * 60
									,es.RerunMaxNumberOfTimes
									,es.IsActive
									)

		WHEN MATCHED THEN UPDATE SET
										ESP_RSP_ID					= ISNULL(es.ResponseTypeID, ESP_RSP_ID)
										,ESP_Parameters				= ISNULL(es.groupXML, ESP_Parameters)
										,ESP_EST_ID					= ISNULL(es.SubscriptionTypeID, ESP_EST_ID)
										,ESP_IncludeOpenAndShut		= ISNULL(es.IncludeOpenAndShut, ESP_IncludeOpenAndShut)
										,ESP_ProcessingInterval		= ISNULL(es.ProcessingInterval, ESP_ProcessingInterval)
										,ESP_RGT_ID					= ISNULL(ES.ResponseGroupingID, ESP_RGT_ID)
										,ESP_RespondOnceForMultipleIdenticalEvents = ISNULL(es.RespondOnceForMultipleIdenticalEvents, ESP_RespondOnceForMultipleIdenticalEvents)
										,ESP_RerunEveryXSeconds		= ISNULL(es.RerunEachMin * 60, ESP_RerunEveryXSeconds)
										,ESP_RerunMaxNumberOfTimes	= ISNULL(es.RerunMaxNumberOfTimes, ESP_RerunMaxNumberOfTimes)
										,ESP_IsActive				= ISNULL(es.IsActive, ESP_IsActive);
GO
