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
/****** Object:  Table [Operational].[MaintenanceWindowLog]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Operational].[MaintenanceWindowLog](
	[MWL_ID] [int] IDENTITY(1,1) NOT NULL,
	[MWL_InsertDate] [datetime2](3) NOT NULL,
	[MWL_MTW_ID] [int] NOT NULL,
	[MWL_Start_OOS_ID] [tinyint] NOT NULL,
	[MWL_IsClosed] [bit] NOT NULL,
 CONSTRAINT [PK_MaintenanceWindowLog] PRIMARY KEY CLUSTERED 
(
	[MWL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_MaintenanceWindowLog_#MWL_MTW_ID#MWL_IsClosed]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_MaintenanceWindowLog_#MWL_MTW_ID#MWL_IsClosed] ON [Operational].[MaintenanceWindowLog]
(
	[MWL_MTW_ID] ASC,
	[MWL_IsClosed] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_MaintenanceWindowLog_MWL_IsClosed##MWL_MTW_ID#MWL_Start_OOS_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_MaintenanceWindowLog_MWL_IsClosed##MWL_MTW_ID#MWL_Start_OOS_ID] ON [Operational].[MaintenanceWindowLog]
(
	[MWL_IsClosed] ASC
)
INCLUDE([MWL_MTW_ID],[MWL_Start_OOS_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Operational].[MaintenanceWindowLog] ADD  CONSTRAINT [DF_MaintenanceWindowLog_MWL_InsertDate]  DEFAULT (sysdatetime()) FOR [MWL_InsertDate]
GO
