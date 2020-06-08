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
/****** Object:  Table [Inventory].[AvailabilityGroupHealth]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[AvailabilityGroupHealth](
	[AGH_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[AGH_ClientID] [int] NOT NULL,
	[AGH_MOB_ID] [int] NOT NULL,
	[AGH_LastHardenedLSN] [datetime] NULL,
	[AGH_GroupID] [uniqueidentifier] NULL,
	[AGH_ReplicaID] [uniqueidentifier] NULL,
	[AGH_GroupDBID] [uniqueidentifier] NULL,
	[AGH_ReplicaName] [nvarchar](255) NULL,
	[AGH_DatabaseName] [nvarchar](255) NULL,
	[AGH_ReplicaRole] [tinyint] NULL,
	[AGH_ReplicaRoleDesc] [nvarchar](255) NULL,
	[AGH_IsDeleted] [bit] NOT NULL,
	[AGH_SyncStateDesc] [nvarchar](4000) NULL,
	[AGH_IsLocal] [bit] NULL,
	[AGH_SyncState] [tinyint] NULL,
	[AGH_SyncHealthDesc] [nvarchar](4000) NULL,
	[AGH_LastHardenedTime] [datetime] NULL,
	[AGH_LastRedoneTime] [datetime] NULL,
	[AGH_LogSendQueueSize] [bigint] NULL,
	[AGH_LogSendRate] [bigint] NULL,
	[AGH_RedoQueueSize] [bigint] NULL,
	[AGH_RedoRate] [bigint] NULL,
	[AGH_FilestreamSendRate] [bigint] NULL,
	[AGH_LastSeenDate] [datetime] NOT NULL,
	[AGH_Last_TRH_ID] [int] NOT NULL,
	[AGH_LastLSN] [numeric](25, 0) NULL,
 CONSTRAINT [PK_AvailabilityGroupHealth] PRIMARY KEY CLUSTERED 
(
	[AGH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Inventory].[AvailabilityGroupHealth] ADD  DEFAULT ((0)) FOR [AGH_IsDeleted]
GO
