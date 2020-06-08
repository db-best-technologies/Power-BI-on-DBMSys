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
/****** Object:  Table [Activity].[RunningSQLProcesses]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[RunningSQLProcesses](
	[RQP_ID] [int] IDENTITY(1,1) NOT NULL,
	[RQP_ClientID] [int] NOT NULL,
	[RQP_MOB_ID] [int] NOT NULL,
	[RQP_DateTime] [datetime2](3) NOT NULL,
	[RQP_SessionID] [int] NOT NULL,
	[RQP_NumberOfThreads] [smallint] NOT NULL,
	[RQP_StartTime] [datetime2](3) NOT NULL,
	[RQP_WaitType_GNC_ID] [int] NULL,
	[RQP_WaitTime] [int] NULL,
	[RQP_IDB_ID] [int] NOT NULL,
	[RQP_BlockedBySessionID] [int] NULL,
	[RQP_SQS_ID] [int] NULL,
	[RQP_OBN_ID] [int] NULL,
	[RQP_CPUTime] [int] NOT NULL,
	[RQP_LogicalReads] [bigint] NULL,
	[RQP_HSN_ID] [int] NULL,
	[RQP_LGN_ID] [int] NOT NULL,
	[RQP_PGN_ID] [int] NULL,
 CONSTRAINT [PK_RunningSQLProcesses] PRIMARY KEY CLUSTERED 
(
	[RQP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_RunningSQLProcesses_RQP_DateTime]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_RunningSQLProcesses_RQP_DateTime] ON [Activity].[RunningSQLProcesses]
(
	[RQP_DateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
