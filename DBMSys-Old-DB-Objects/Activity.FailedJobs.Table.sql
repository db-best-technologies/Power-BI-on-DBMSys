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
/****** Object:  Table [Activity].[FailedJobs]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[FailedJobs](
	[FLJ_ID] [int] IDENTITY(1,1) NOT NULL,
	[FLJ_ClientID] [int] NOT NULL,
	[FLJ_MOB_ID] [int] NOT NULL,
	[FLJ_JobName] [nvarchar](128) NOT NULL,
	[FLJ_StepName] [nvarchar](128) NOT NULL,
	[FLJ_FirstFailureDate] [datetime2](0) NOT NULL,
	[FLJ_LastFailureDate] [datetime2](0) NOT NULL,
	[FLJ_FailureCount] [int] NOT NULL,
	[FLJ_LastErrorMessage] [nvarchar](max) NULL,
	[FLJ_JobDeleted] [bit] NOT NULL,
	[FLJ_IsClosed] [bit] NOT NULL,
	[FLJ_FirstSuccessDate] [datetime2](3) NULL,
	[FLJ_LastSuccessDate] [datetime2](3) NULL,
	[FLJ_SuccessCount] [int] NULL,
	[FLJ_Timestamp] [timestamp] NOT NULL,
	[FLJ_InsertDate] [datetime2](3) NOT NULL,
	[FLJ_LastSeenDate] [datetime2](3) NOT NULL,
	[FLJ_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_FailedJobs] PRIMARY KEY CLUSTERED 
(
	[FLJ_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_FailedJobs_FLJ_LastSuccessDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_FailedJobs_FLJ_LastSuccessDate] ON [Activity].[FailedJobs]
(
	[FLJ_LastSuccessDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_FailedJobs_FLJ_MOB_ID#FLJ_IsClosed#FLJ_Last_TRH_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_FailedJobs_FLJ_MOB_ID#FLJ_IsClosed#FLJ_Last_TRH_ID] ON [Activity].[FailedJobs]
(
	[FLJ_MOB_ID] ASC,
	[FLJ_IsClosed] ASC,
	[FLJ_Last_TRH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_FailedJobs_FLJ_MOB_ID#FLJ_JobName#FLJ_StepName#FLJ_IsClosed#FLJ_FirstFailureDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_FailedJobs_FLJ_MOB_ID#FLJ_JobName#FLJ_StepName#FLJ_IsClosed#FLJ_FirstFailureDate] ON [Activity].[FailedJobs]
(
	[FLJ_MOB_ID] ASC,
	[FLJ_JobName] ASC,
	[FLJ_StepName] ASC,
	[FLJ_IsClosed] ASC,
	[FLJ_FirstFailureDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_FailedJobs_FLJ_Timestamp]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_FailedJobs_FLJ_Timestamp] ON [Activity].[FailedJobs]
(
	[FLJ_Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Activity].[trg_FailedJobs]    Script Date: 6/8/2020 1:14:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Activity].[trg_FailedJobs] on [Activity].[FailedJobs]
	instead of delete
as
set nocount on

merge Activity.FailedJobs d
using deleted s
	on d.FLJ_ID = s.FLJ_ID
	when matched and d.FLJ_IsClosed = 0 then update set
											FLJ_IsClosed = 1,
											FLJ_JobDeleted = 1
	when matched and d.FLJ_IsClosed = 1 then delete;
GO
ALTER TABLE [Activity].[FailedJobs] ENABLE TRIGGER [trg_FailedJobs]
GO
