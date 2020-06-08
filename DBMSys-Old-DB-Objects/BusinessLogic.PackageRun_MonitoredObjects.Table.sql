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
/****** Object:  Table [BusinessLogic].[PackageRun_MonitoredObjects]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BusinessLogic].[PackageRun_MonitoredObjects](
	[PRM_ID] [int] IDENTITY(1,1) NOT NULL,
	[PRM_ClientID] [int] NOT NULL,
	[PRM_PKN_ID] [int] NOT NULL,
	[PRM_MOB_ID] [int] NOT NULL,
	[PRM_InsertDate] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_PackageRun_MonitoredObjects] PRIMARY KEY CLUSTERED 
(
	[PRM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_PackageRun_MonitoredObjects_PRM_InsertDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_PackageRun_MonitoredObjects_PRM_InsertDate] ON [BusinessLogic].[PackageRun_MonitoredObjects]
(
	[PRM_InsertDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PackageRun_MonitoredObjectsPRM_PKN_ID#PRM_MOB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_PackageRun_MonitoredObjectsPRM_PKN_ID#PRM_MOB_ID] ON [BusinessLogic].[PackageRun_MonitoredObjects]
(
	[PRM_PKN_ID] ASC,
	[PRM_MOB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [BusinessLogic].[PackageRun_MonitoredObjects] ADD  CONSTRAINT [DF_PackageRun_MonitoredObjects_PRM_InsertDate]  DEFAULT (sysdatetime()) FOR [PRM_InsertDate]
GO
