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
/****** Object:  Table [Consolidation].[ConsolidationBlocks_LoadBlocks]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[ConsolidationBlocks_LoadBlocks](
	[CBL_ID] [int] IDENTITY(1,1) NOT NULL,
	[CBL_HST_ID] [tinyint] NOT NULL,
	[CBL_CLB_ID] [int] NOT NULL,
	[CBL_LBL_ID] [int] NOT NULL,
	[CBL_BufferedCPUStrength] [int] NOT NULL,
	[CBL_BufferedMemoryMB] [bigint] NOT NULL,
	[CBL_BufferedNetworkDownloadSpeedMbit] [int] NOT NULL,
	[CBL_BufferedNetworkUploadSpeedMbit] [int] NOT NULL,
	[CBL_BufferedNetworkSpeedMbit] [int] NOT NULL,
	[CBL_BufferedDiskSizeMB] [bigint] NULL,
	[CBL_BufferedIOPS] [int] NULL,
	[CBL_BufferedMBPerSec] [int] NULL,
	[CBL_AvgMonthlyIOPS] [bigint] NULL,
	[CBL_AvgMonthlyNetworkOutboundMB] [bigint] NULL,
	[CBL_AvgMonthlyNetworkInboundMB] [bigint] NULL,
	[CBL_DLR_ID] [tinyint] NULL,
	[CBL_VirtualCoreCount] [int] NULL,
 CONSTRAINT [PK_ConsolidationBlocks_LoadBlocks] PRIMARY KEY CLUSTERED 
(
	[CBL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_ConsolidationBlocks_LoadBlocks_CBL_CLB_ID#CBL_LBL_ID##CLB_DLR_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ConsolidationBlocks_LoadBlocks_CBL_CLB_ID#CBL_LBL_ID##CLB_DLR_ID] ON [Consolidation].[ConsolidationBlocks_LoadBlocks]
(
	[CBL_CLB_ID] ASC,
	[CBL_LBL_ID] ASC
)
INCLUDE([CBL_DLR_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ConsolidationBlocks_LoadBlocks_CBL_HST_ID#CBL_DLR_ID##CBL_CLB_ID#CBL_LBL_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ConsolidationBlocks_LoadBlocks_CBL_HST_ID#CBL_DLR_ID##CBL_CLB_ID#CBL_LBL_ID] ON [Consolidation].[ConsolidationBlocks_LoadBlocks]
(
	[CBL_HST_ID] ASC,
	[CBL_DLR_ID] ASC
)
INCLUDE([CBL_CLB_ID],[CBL_LBL_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ConsolidationBlocks_LoadBlocks_CBL_HST_ID#CBL_LBL_ID##CBL_CLB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ConsolidationBlocks_LoadBlocks_CBL_HST_ID#CBL_LBL_ID##CBL_CLB_ID] ON [Consolidation].[ConsolidationBlocks_LoadBlocks]
(
	[CBL_HST_ID] ASC,
	[CBL_LBL_ID] ASC
)
INCLUDE([CBL_CLB_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
