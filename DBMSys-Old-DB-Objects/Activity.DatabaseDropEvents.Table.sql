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
/****** Object:  Table [Activity].[DatabaseDropEvents]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[DatabaseDropEvents](
	[DDE_ID] [int] IDENTITY(1,1) NOT NULL,
	[DDE_ClientID] [int] NOT NULL,
	[DDE_MOB_ID] [int] NOT NULL,
	[DDE_DatabaseName] [nvarchar](128) NOT NULL,
	[DDE_HSN_ID] [int] NOT NULL,
	[DDE_PGN_ID] [int] NULL,
	[DDE_INL_ID] [int] NOT NULL,
	[DDE_DropDate] [datetime2](3) NOT NULL,
	[DDE_InsertDate] [datetime2](3) NOT NULL,
	[DDE_TimeStamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_DatabaseDropEvents] PRIMARY KEY CLUSTERED 
(
	[DDE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DatabaseDropEvents_DDE_DropDate#DDE_DatabaseName]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_DatabaseDropEvents_DDE_DropDate#DDE_DatabaseName] ON [Activity].[DatabaseDropEvents]
(
	[DDE_InsertDate] ASC,
	[DDE_DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DatabaseDropEvents_DDE_MOB_ID#DDE_DropDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_DatabaseDropEvents_DDE_MOB_ID#DDE_DropDate] ON [Activity].[DatabaseDropEvents]
(
	[DDE_MOB_ID] ASC,
	[DDE_DropDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DatabaseDropEvents_DDE_TimeStamp]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_DatabaseDropEvents_DDE_TimeStamp] ON [Activity].[DatabaseDropEvents]
(
	[DDE_TimeStamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Activity].[DatabaseDropEvents] ADD  CONSTRAINT [DF_DatabaseDropEvents_DDE_InsertDate]  DEFAULT (sysdatetime()) FOR [DDE_InsertDate]
GO
