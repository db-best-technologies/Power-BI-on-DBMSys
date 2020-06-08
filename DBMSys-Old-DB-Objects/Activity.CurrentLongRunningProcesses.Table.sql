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
/****** Object:  Table [Activity].[CurrentLongRunningProcesses]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[CurrentLongRunningProcesses](
	[CRP_ID] [int] IDENTITY(1,1) NOT NULL,
	[CRP_ClientID] [int] NOT NULL,
	[CRP_MOB_ID] [int] NOT NULL,
	[CRP_StartDate] [datetime] NOT NULL,
	[CRP_SessionID] [int] NOT NULL,
	[CRP_SQS_ID] [int] NOT NULL,
	[CRP_LGN_ID] [int] NULL,
	[CRP_PGN_ID] [int] NULL,
	[CRP_OBN_ID] [int] NULL,
	[CRP_IDB_ID] [int] NOT NULL,
	[CRP_HSN_ID] [int] NULL,
	[CRP_IsFinished] [bit] NOT NULL,
	[CPR_Timestamp] [timestamp] NOT NULL,
	[CPR_InsertDate] [datetime2](3) NOT NULL,
	[CRP_Last_TRH_ID] [int] NOT NULL,
	[CRP_Last_SeenDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CurrentLongRunningProcesses] PRIMARY KEY CLUSTERED 
(
	[CRP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Activity].[CurrentLongRunningProcesses] ADD  DEFAULT (getutcdate()) FOR [CPR_InsertDate]
GO
