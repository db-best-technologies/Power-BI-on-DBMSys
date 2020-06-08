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
/****** Object:  Table [Activity].[OperatingSystemEventLogEvents]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[OperatingSystemEventLogEvents](
	[EVL_ID] [int] IDENTITY(1,1) NOT NULL,
	[EVL_ClientID] [int] NOT NULL,
	[EVL_MOB_ID] [int] NOT NULL,
	[EVL_ELC_ID] [int] NULL,
	[EVL_ELF_ID] [int] NOT NULL,
	[EVL_EventCode] [int] NOT NULL,
	[EVL_EventIdentifier] [bigint] NOT NULL,
	[EVL_Message] [nvarchar](max) NOT NULL,
	[EVL_ESN_ID] [int] NOT NULL,
	[EVL_TimeGenerated] [datetime2](3) NOT NULL,
	[EVL_TimeWritten] [datetime2](3) NOT NULL,
	[EVL_EET_ID] [tinyint] NOT NULL,
	[EVL_EUN_ID] [int] NULL,
	[EVL_Timestamp] [timestamp] NOT NULL,
	[EVL_InsertDate] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_OperatingSystemEventLogEvents] PRIMARY KEY CLUSTERED 
(
	[EVL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_OperatingSystemEventLogEvents_EVL_InsertDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_OperatingSystemEventLogEvents_EVL_InsertDate] ON [Activity].[OperatingSystemEventLogEvents]
(
	[EVL_InsertDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OperatingSystemEventLogEvents_EVL_MOB_ID#EVL_ELF_ID#EVL_EventCode#EVL_EventIdentifier#EVL_TimeWritten]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_OperatingSystemEventLogEvents_EVL_MOB_ID#EVL_ELF_ID#EVL_EventCode#EVL_EventIdentifier#EVL_TimeWritten] ON [Activity].[OperatingSystemEventLogEvents]
(
	[EVL_MOB_ID] ASC,
	[EVL_ELF_ID] ASC,
	[EVL_EventCode] ASC,
	[EVL_EventIdentifier] ASC,
	[EVL_TimeWritten] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OperatingSystemEventLogEvents_EVL_TimeWritten]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_OperatingSystemEventLogEvents_EVL_TimeWritten] ON [Activity].[OperatingSystemEventLogEvents]
(
	[EVL_TimeWritten] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Activity].[OperatingSystemEventLogEvents] ADD  CONSTRAINT [DF_OperatingSystemEventLogEvents_EVL_InsertDate]  DEFAULT (sysdatetime()) FOR [EVL_InsertDate]
GO
