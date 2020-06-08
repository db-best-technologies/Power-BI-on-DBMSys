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
/****** Object:  UserDefinedTableType [ResponseProcessing].[TT_Event_ContactList_Properties]    Script Date: 6/8/2020 1:14:31 PM ******/
CREATE TYPE [ResponseProcessing].[TT_Event_ContactList_Properties] AS TABLE(
	[EventID] [int] NOT NULL,
	[GroupName] [nvarchar](255) NOT NULL,
	[IsActive] [bit] NULL,
	[ResponseTypeID] [int] NOT NULL,
	[SubscriptionTypeID] [tinyint] NOT NULL,
	[IncludeOpenAndShut] [bit] NOT NULL,
	[ResponseGroupingID] [tinyint] NOT NULL,
	[RespondOnceForMultipleIdenticalEvents] [bit] NOT NULL,
	[RerunEachMin] [int] NULL,
	[RerunMaxNumberOfTimes] [int] NULL,
	[ProcessingInterval] [int] NOT NULL
)
GO
