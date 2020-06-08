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
/****** Object:  Table [Consolidation].[PossibleHosts]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[PossibleHosts](
	[PSH_ID] [int] IDENTITY(1,1) NOT NULL,
	[PSH_HST_ID] [tinyint] NOT NULL,
	[PSH_MOB_ID] [int] NULL,
	[PSH_CMT_ID] [int] NULL,
	[PSH_VES_ID] [int] NULL,
	[PSH_OST_ID] [tinyint] NULL,
	[PSH_CoreCount] [decimal](10, 2) NULL,
	[PSH_CPUStrength] [int] NULL,
	[PSH_MemoryMB] [bigint] NULL,
	[PSH_Storage_BUL_ID] [tinyint] NULL,
	[PSH_MaxDiskCount] [int] NULL,
	[PSH_MaxDataFilesDiskSizeMB] [bigint] NULL,
	[PSH_MaxLogFilesDiskSizeMB] [bigint] NULL,
	[PSH_MaxDiskSizeMB] [bigint] NULL,
	[PSH_MaxIOPS8KB] [int] NULL,
	[PSH_MaxMBPerSec8KB] [int] NULL,
	[PSH_MaxIOPS64KB] [int] NULL,
	[PSH_MaxMBPerSec64KB] [int] NULL,
	[PSH_DataFilesMaxIOPS] [int] NULL,
	[PSH_LogFilesMaxIOPS] [int] NULL,
	[PSH_TotalMaxIOPS] [int] NULL,
	[PSH_DataFilesMaxMBPerSec] [int] NULL,
	[PSH_LogFilesMaxMBPerSec] [int] NULL,
	[PSH_TotalMaxMBPerSec] [int] NULL,
	[PSH_NetworkSpeedMbit] [int] NULL,
	[PSH_NetDownloadSpeedRatio] [decimal](10, 6) NULL,
	[PSH_NetUploadSpeedRatio] [decimal](10, 6) NULL,
	[PSH_PricePerMonthUSD] [decimal](15, 3) NULL,
	[PSH_SupportsAutoScale] [bit] NULL,
	[PSH_SupportLoadBalancing] [bit] NULL,
	[PSH_FileTypeSeparation] [bit] NOT NULL,
	[PSH_CMP_ID] [int] NULL,
	[PSH_CHE_ID] [tinyint] NULL,
	[PSH_CRG_ID] [smallint] NULL,
	[PSH_IsVM] [bit] NULL,
	[PSH_PricePerDisk] [decimal](17, 10) NULL,
	[PSH_CHA_ID] [tinyint] NULL,
 CONSTRAINT [PK_PossibleHosts] PRIMARY KEY CLUSTERED 
(
	[PSH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_PossibleHosts_PSH_CMT_ID#PSH_HST_ID#PSH_CRG_ID#PSH_OST_ID#PSH_CHE_ID#PSH_Storage_BUL_ID#PSH_CMP_ID###PSH_CMT_ID_IS_NOT_NULL]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_PossibleHosts_PSH_CMT_ID#PSH_HST_ID#PSH_CRG_ID#PSH_OST_ID#PSH_CHE_ID#PSH_Storage_BUL_ID#PSH_CMP_ID###PSH_CMT_ID_IS_NOT_NULL] ON [Consolidation].[PossibleHosts]
(
	[PSH_CMT_ID] ASC,
	[PSH_HST_ID] ASC,
	[PSH_CRG_ID] ASC,
	[PSH_OST_ID] ASC,
	[PSH_CHE_ID] ASC,
	[PSH_Storage_BUL_ID] ASC,
	[PSH_CMP_ID] ASC
)
WHERE ([PSH_CMT_ID] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PossibleHosts_PSH_HST_ID#PSH_OST_ID#PSH_CRG_ID#PSH_CHE_ID##PSH_CMT_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_PossibleHosts_PSH_HST_ID#PSH_OST_ID#PSH_CRG_ID#PSH_CHE_ID##PSH_CMT_ID] ON [Consolidation].[PossibleHosts]
(
	[PSH_HST_ID] ASC,
	[PSH_OST_ID] ASC,
	[PSH_CRG_ID] ASC,
	[PSH_CHE_ID] ASC
)
INCLUDE([PSH_CMT_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PossibleHosts_PSH_MOB_ID#PSH_HST_ID###PSH_MOB_ID_IS_NOT_NULL]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_PossibleHosts_PSH_MOB_ID#PSH_HST_ID###PSH_MOB_ID_IS_NOT_NULL] ON [Consolidation].[PossibleHosts]
(
	[PSH_MOB_ID] ASC,
	[PSH_HST_ID] ASC
)
WHERE ([PSH_MOB_ID] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PossibleHosts_PSH_VES_ID###PSH_VES_ID_IS_NOT_NULL]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_PossibleHosts_PSH_VES_ID###PSH_VES_ID_IS_NOT_NULL] ON [Consolidation].[PossibleHosts]
(
	[PSH_VES_ID] ASC
)
WHERE ([PSH_VES_ID] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
