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
/****** Object:  Table [EventProcessing].[ProcessCycles]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EventProcessing].[ProcessCycles](
	[PRC_ID] [int] IDENTITY(1,1) NOT NULL,
	[PRC_ClientID] [int] NOT NULL,
	[PRC_MOV_ID] [int] NOT NULL,
	[PRC_StartDate] [datetime2](3) NOT NULL,
	[PRC_EndDate] [datetime2](3) NULL,
	[PRC_ErrorMessage] [nvarchar](max) NULL,
	[PRC_Timestamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_ProcessCycles] PRIMARY KEY CLUSTERED 
(
	[PRC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_ProcessCycles]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ProcessCycles] ON [EventProcessing].[ProcessCycles]
(
	[PRC_EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ProcessCycles_PRC_MOV_ID#PRC_StartDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ProcessCycles_PRC_MOV_ID#PRC_StartDate] ON [EventProcessing].[ProcessCycles]
(
	[PRC_MOV_ID] ASC,
	[PRC_StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ProcessCycles_PRC_Timestamp#PRC_EndDate##PRC_MOV_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ProcessCycles_PRC_Timestamp#PRC_EndDate##PRC_MOV_ID] ON [EventProcessing].[ProcessCycles]
(
	[PRC_Timestamp] ASC,
	[PRC_EndDate] ASC
)
INCLUDE([PRC_MOV_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ProcessCycles_PRC_Timestamp#PRC_MOV_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ProcessCycles_PRC_Timestamp#PRC_MOV_ID] ON [EventProcessing].[ProcessCycles]
(
	[PRC_Timestamp] ASC,
	[PRC_MOV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ProcessCycles_PRC_Timestamp#PRC_StartDate##PRC_MOV_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ProcessCycles_PRC_Timestamp#PRC_StartDate##PRC_MOV_ID] ON [EventProcessing].[ProcessCycles]
(
	[PRC_Timestamp] ASC,
	[PRC_StartDate] ASC
)
INCLUDE([PRC_MOV_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [EventProcessing].[ProcessCycles] ADD  CONSTRAINT [DF_ProcessCycles_PRC_StartDate]  DEFAULT (sysdatetime()) FOR [PRC_StartDate]
GO
