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
/****** Object:  UserDefinedTableType [EventProcessing].[TT_MonitoredEvents]    Script Date: 6/8/2020 1:14:31 PM ******/
CREATE TYPE [EventProcessing].[TT_MonitoredEvents] AS TABLE(
	[TT_MOV_ID] [int] NULL,
	[TT_MEG_ID] [int] NULL,
	[TT_MOV_IsActive] [bit] NULL,
	[TT_MOV_Weekdays] [varchar](7) NULL,
	[TT_MOV_FromHour] [char](5) NULL,
	[TT_MOV_ToHour] [char](5) NULL,
	[TT_ESV_ID] [tinyint] NULL,
	[TT_THL_ID] [tinyint] NULL,
	[TT_IncludeExclude] [xml] NULL
)
GO
