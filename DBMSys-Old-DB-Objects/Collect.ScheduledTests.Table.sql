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
/****** Object:  Table [Collect].[ScheduledTests]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Collect].[ScheduledTests](
	[SCT_ID] [int] IDENTITY(1,1) NOT NULL,
	[SCT_ClientID] [int] NOT NULL,
	[SCT_TST_ID] [int] NOT NULL,
	[SCT_TSV_ID] [int] NOT NULL,
	[SCT_MOB_ID] [int] NOT NULL,
	[SCT_DateToRun] [datetime2](3) NOT NULL,
	[SCT_RNR_ID] [tinyint] NOT NULL,
	[SCT_InsertDate] [datetime2](3) NOT NULL,
	[SCT_STS_ID] [tinyint] NOT NULL,
	[SCT_LaunchDate] [datetime2](3) NULL,
	[SCT_ProcessStartDate] [datetime2](3) NULL,
	[SCT_ProcessEndDate] [datetime2](3) NULL,
	[SCT_RescheduledAtDate] [datetime2](3) NULL,
	[SCT_RescheduledCount] [int] NULL,
 CONSTRAINT [PK_ScheduledTests] PRIMARY KEY CLUSTERED 
(
	[SCT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_ScheduledTests_ScheduledTests_SCT_DateToRun##SCT_TST_ID#SCT_MOB_ID#SCT_RNR_ID###SCT_STS_ID_EQ_1]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ScheduledTests_ScheduledTests_SCT_DateToRun##SCT_TST_ID#SCT_MOB_ID#SCT_RNR_ID###SCT_STS_ID_EQ_1] ON [Collect].[ScheduledTests]
(
	[SCT_DateToRun] ASC
)
INCLUDE([SCT_TST_ID],[SCT_MOB_ID],[SCT_RNR_ID]) 
WHERE ([SCT_STS_ID]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ScheduledTests_SCT_STS_ID#SCT_DateToRun##SCT_MOB_ID#SCT_TST_ID#SCT_RNR_ID#SCT_RescheduledCount]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ScheduledTests_SCT_STS_ID#SCT_DateToRun##SCT_MOB_ID#SCT_TST_ID#SCT_RNR_ID#SCT_RescheduledCount] ON [Collect].[ScheduledTests]
(
	[SCT_STS_ID] ASC,
	[SCT_DateToRun] ASC
)
INCLUDE([SCT_MOB_ID],[SCT_TST_ID],[SCT_RNR_ID],[SCT_RescheduledCount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ScheduledTests_SCT_STS_ID#SCT_LaunchDate##SCT_TSV_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ScheduledTests_SCT_STS_ID#SCT_LaunchDate##SCT_TSV_ID] ON [Collect].[ScheduledTests]
(
	[SCT_STS_ID] ASC,
	[SCT_LaunchDate] ASC
)
INCLUDE([SCT_TSV_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ScheduledTests_SCT_STS_ID#SCT_RNR_ID#SCT_DateToRun##SCT_MOB_ID#SCT_TST_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ScheduledTests_SCT_STS_ID#SCT_RNR_ID#SCT_DateToRun##SCT_MOB_ID#SCT_TST_ID] ON [Collect].[ScheduledTests]
(
	[SCT_STS_ID] ASC,
	[SCT_RNR_ID] DESC,
	[SCT_DateToRun] ASC
)
INCLUDE([SCT_MOB_ID],[SCT_TST_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ScheduledTests_SCT_TST_ID#SCT_MOB_ID###SCT_ID_LT_4]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ScheduledTests_SCT_TST_ID#SCT_MOB_ID###SCT_ID_LT_4] ON [Collect].[ScheduledTests]
(
	[SCT_TST_ID] ASC,
	[SCT_MOB_ID] ASC
)
WHERE ([SCT_STS_ID]<(4))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Collect].[ScheduledTests] ADD  CONSTRAINT [DF_SCT_InsertDate]  DEFAULT (sysdatetime()) FOR [SCT_InsertDate]
GO
ALTER TABLE [Collect].[ScheduledTests] ADD  CONSTRAINT [DF_ScheduledTests_SCT_STS_ID]  DEFAULT ((1)) FOR [SCT_STS_ID]
GO
