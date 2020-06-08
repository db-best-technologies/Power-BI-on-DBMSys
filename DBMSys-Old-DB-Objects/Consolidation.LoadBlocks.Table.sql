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
/****** Object:  Table [Consolidation].[LoadBlocks]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[LoadBlocks](
	[LBL_ID] [int] IDENTITY(1,1) NOT NULL,
	[LBL_CGR_ID] [int] NOT NULL,
	[LBL_MOB_ID] [int] NOT NULL,
	[LBL_IDB_ID] [int] NULL,
	[LBL_OST_ID] [tinyint] NOT NULL,
	[LBL_CHA_ID] [tinyint] NULL,
	[LBL_CHE_ID] [tinyint] NULL,
	[LBL_CPUStrength] [decimal](10, 0) NULL,
	[LBL_MemoryMB] [decimal](19, 0) NULL,
	[LBL_DataFilesDiskSize] [bigint] NULL,
	[LBL_LogFilesDiskSize] [bigint] NULL,
	[LBL_DiskSize] [decimal](19, 0) NULL,
	[LBL_BlockSize] [decimal](10, 0) NULL,
	[LBL_ReadsSec] [decimal](19, 0) NULL,
	[LBL_WritesSec] [decimal](19, 0) NULL,
	[LBL_ReadsMBSec] [decimal](19, 0) NULL,
	[LBL_WritesMBSec] [decimal](19, 0) NULL,
	[LBL_DataFilesIOps] [bigint] NULL,
	[LBL_LogFilesIOps] [bigint] NULL,
	[LBL_DataFilesMBPerSec] [bigint] NULL,
	[LBL_LogFilesMBPerSec] [bigint] NULL,
	[LBL_NetworkUsageDownloadMbit] [decimal](10, 0) NULL,
	[LBL_NetworkUsageUploadMbit] [decimal](10, 0) NULL,
	[LBL_MonthlyDiskIOPS] [decimal](19, 0) NULL,
	[LBL_MonthlyNetworkOutboundMB] [decimal](19, 0) NULL,
	[LBL_MonthlyNetworkInboundMB] [decimal](19, 0) NULL,
	[LBL_SQLInstanceCount] [tinyint] NULL,
	[LBL_HasSoftwareAssurance] [bit] NULL,
	[LBL_VBC_ID] [tinyint] NULL,
	[LBL_IsVM] [bit] NOT NULL,
 CONSTRAINT [PK_LoadBlocks] PRIMARY KEY CLUSTERED 
(
	[LBL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
