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
/****** Object:  Table [Activity].[AutoFileSizeChangeEvents]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[AutoFileSizeChangeEvents](
	[AFS_ID] [int] IDENTITY(1,1) NOT NULL,
	[AFS_ClientID] [int] NOT NULL,
	[AFS_MOB_ID] [int] NOT NULL,
	[AFS_AFC_ID] [tinyint] NOT NULL,
	[AFS_IDB_ID] [int] NOT NULL,
	[AFS_DBF_ID] [int] NOT NULL,
	[AFS_ProcessStartTime] [datetime2](3) NOT NULL,
	[AFS_ProcessEndTime] [datetime2](3) NOT NULL,
	[AFS_DurationMS] [bigint] NOT NULL,
	[AFS_ChangeInSizeMB] [int] NOT NULL,
	[AFS_InsertDate] [datetime2](3) NOT NULL,
	[AFS_Timestamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_AutoFileSizeChangeEvents] PRIMARY KEY CLUSTERED 
(
	[AFS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_AutoFileSizeChangeEvents_AFS_InsertDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_AutoFileSizeChangeEvents_AFS_InsertDate] ON [Activity].[AutoFileSizeChangeEvents]
(
	[AFS_InsertDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AutoFileSizeChangeEvents_AFS_MOB_ID#AFS_DBF_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_AutoFileSizeChangeEvents_AFS_MOB_ID#AFS_DBF_ID] ON [Activity].[AutoFileSizeChangeEvents]
(
	[AFS_MOB_ID] ASC,
	[AFS_DBF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AutoFileSizeChangeEvents_AFS_ProcessEndTime]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_AutoFileSizeChangeEvents_AFS_ProcessEndTime] ON [Activity].[AutoFileSizeChangeEvents]
(
	[AFS_ProcessEndTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AutoFileSizeChangeEvents_AFS_Timestamp]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_AutoFileSizeChangeEvents_AFS_Timestamp] ON [Activity].[AutoFileSizeChangeEvents]
(
	[AFS_Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Activity].[AutoFileSizeChangeEvents] ADD  CONSTRAINT [DF_AutoFileSizeChangeEvents_AFS_InsertDate]  DEFAULT (sysdatetime()) FOR [AFS_InsertDate]
GO
