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
/****** Object:  Table [Collect].[TestRunHistory]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Collect].[TestRunHistory](
	[TRH_ID] [int] IDENTITY(1,1) NOT NULL,
	[TRH_ClientID] [int] NOT NULL,
	[TRH_TST_ID] [int] NOT NULL,
	[TRH_MOB_ID] [int] NOT NULL,
	[TRH_RNR_ID] [tinyint] NOT NULL,
	[TRH_SCT_ID] [int] NOT NULL,
	[TRH_TRS_ID] [tinyint] NOT NULL,
	[TRH_InsertDate] [datetime2](3) NULL,
	[TRH_StartDate] [datetime2](3) NULL,
	[TRH_EndDate] [datetime2](3) NULL,
	[TRH_RUN_ID] [int] NULL,
	[TRH_ErrorMessage] [nvarchar](2000) NULL,
	[TRH_Timestamp] [timestamp] NOT NULL,
	[TRH_CTR_ID] [int] NULL,
	[TRH_SourceHash] [bigint] NULL,
 CONSTRAINT [PK_TestRunHistory] PRIMARY KEY CLUSTERED 
(
	[TRH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_TestRunHistory_TRH_EndDate##TRH_TST_ID#TRH_MOB_ID#TRH_TRS_ID#TRH_StartDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TestRunHistory_TRH_EndDate##TRH_TST_ID#TRH_MOB_ID#TRH_TRS_ID#TRH_StartDate] ON [Collect].[TestRunHistory]
(
	[TRH_EndDate] ASC
)
INCLUDE([TRH_TST_ID],[TRH_MOB_ID],[TRH_TRS_ID],[TRH_StartDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TestRunHistory_TRH_EndDate#TRH_TST_ID##TRH_MOB_ID#TRH_TRS_ID###TRH_TRS_ID_GT_2]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TestRunHistory_TRH_EndDate#TRH_TST_ID##TRH_MOB_ID#TRH_TRS_ID###TRH_TRS_ID_GT_2] ON [Collect].[TestRunHistory]
(
	[TRH_EndDate] ASC,
	[TRH_TST_ID] ASC
)
INCLUDE([TRH_MOB_ID],[TRH_TRS_ID]) 
WHERE ([TRH_TRS_ID]>(2))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TestRunHistory_TRH_SCT_ID##TRH_EndDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TestRunHistory_TRH_SCT_ID##TRH_EndDate] ON [Collect].[TestRunHistory]
(
	[TRH_SCT_ID] ASC
)
WHERE ([TRH_EndDate] IS NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TestRunHistory_TRH_Timestamp#TRH_TRS_ID#TRH_EndDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TestRunHistory_TRH_Timestamp#TRH_TRS_ID#TRH_EndDate] ON [Collect].[TestRunHistory]
(
	[TRH_Timestamp] ASC,
	[TRH_TRS_ID] ASC,
	[TRH_EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TestRunHistory_TRH_Timestamp#TRH_TRS_ID#TRH_StartDate##TRH_EndDate#TRH_TST_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TestRunHistory_TRH_Timestamp#TRH_TRS_ID#TRH_StartDate##TRH_EndDate#TRH_TST_ID] ON [Collect].[TestRunHistory]
(
	[TRH_Timestamp] ASC,
	[TRH_TRS_ID] ASC,
	[TRH_StartDate] ASC
)
INCLUDE([TRH_EndDate],[TRH_TST_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TestRunHistory_TRH_TST_ID#TRH_MOB_ID###TRH_TRS_ID_IN_1_2]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TestRunHistory_TRH_TST_ID#TRH_MOB_ID###TRH_TRS_ID_IN_1_2] ON [Collect].[TestRunHistory]
(
	[TRH_TST_ID] ASC,
	[TRH_MOB_ID] ASC
)
WHERE ([TRH_TRS_ID] IN ((1), (2)))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TestRunHistory_TRH_TST_ID#TRH_MOB_ID#TRH_EndDate##TRH_TRS_ID#TRH_RNR_ID###TRH_TRS_ID_IN_3_4]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TestRunHistory_TRH_TST_ID#TRH_MOB_ID#TRH_EndDate##TRH_TRS_ID#TRH_RNR_ID###TRH_TRS_ID_IN_3_4] ON [Collect].[TestRunHistory]
(
	[TRH_TST_ID] ASC,
	[TRH_MOB_ID] ASC,
	[TRH_EndDate] ASC
)
INCLUDE([TRH_TRS_ID],[TRH_RNR_ID]) 
WHERE ([TRH_TRS_ID] IN ((3), (4)))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TestRunHistory_TRH_TST_ID#TRH_MOB_ID#TRH_TRS_ID#TRH_RNR_ID#TRH_ID##TRH_StartDate#TRH_EndDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TestRunHistory_TRH_TST_ID#TRH_MOB_ID#TRH_TRS_ID#TRH_RNR_ID#TRH_ID##TRH_StartDate#TRH_EndDate] ON [Collect].[TestRunHistory]
(
	[TRH_TST_ID] ASC,
	[TRH_MOB_ID] ASC,
	[TRH_TRS_ID] ASC,
	[TRH_RNR_ID] ASC,
	[TRH_ID] ASC
)
INCLUDE([TRH_StartDate],[TRH_EndDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TestRunHistory_TRH_TST_ID#TRH_Timestamp##TRH_MOB_ID#TRH_StartDate#TRH_EndDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TestRunHistory_TRH_TST_ID#TRH_Timestamp##TRH_MOB_ID#TRH_StartDate#TRH_EndDate] ON [Collect].[TestRunHistory]
(
	[TRH_TST_ID] ASC,
	[TRH_Timestamp] ASC
)
INCLUDE([TRH_MOB_ID],[TRH_StartDate],[TRH_EndDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Collect].[TestRunHistory] ADD  CONSTRAINT [DF_TestRunHistory_TRH_InsertDate]  DEFAULT (sysdatetime()) FOR [TRH_InsertDate]
GO
