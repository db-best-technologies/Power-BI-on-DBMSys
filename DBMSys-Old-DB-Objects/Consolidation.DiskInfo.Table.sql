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
/****** Object:  Table [Consolidation].[DiskInfo]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[DiskInfo](
	[DSI_ID] [int] IDENTITY(1,1) NOT NULL,
	[DSI_MOB_ID] [int] NOT NULL,
	[DSI_IDB_ID] [int] NULL,
	[DSI_UsedSpace] [bigint] NULL,
	[DSI_DataFilesMB] [bigint] NULL,
	[DSI_DataFilesMBIn3Years] [bigint] NULL,
	[DSI_LogFilesMB] [bigint] NULL,
	[DSI_TempdbMB] [bigint] NULL,
	[DSI_YearlyGrowthMB] [bigint] NULL,
	[DSI_DataFreeSpaceMB] [bigint] NULL,
	[DSI_DataFreeSpaceMBIn3Years] [bigint] NULL,
	[DSI_LogFreeSpaceMB] [bigint] NULL,
	[DSI_TotalFreeSpaceMB] [bigint] NULL,
	[DSI_FileTypeSeparation] [bit] NULL,
 CONSTRAINT [PK_DiskInfo] PRIMARY KEY CLUSTERED 
(
	[DSI_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
