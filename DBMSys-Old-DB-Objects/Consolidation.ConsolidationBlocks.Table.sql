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
/****** Object:  Table [Consolidation].[ConsolidationBlocks]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[ConsolidationBlocks](
	[CLB_ID] [int] IDENTITY(1,1) NOT NULL,
	[CLB_HST_ID] [tinyint] NOT NULL,
	[CLB_PSH_ID] [int] NOT NULL,
	[CLB_OST_ID] [tinyint] NULL,
	[CLB_CHA_ID] [tinyint] NULL,
	[CLB_CappedCPUStrength] [int] NOT NULL,
	[CLB_CappedMemoryMB] [bigint] NOT NULL,
	[CLB_CappedNetworkSpeedMbit] [int] NOT NULL,
	[CLB_CappedDiskSizeMB] [bigint] NULL,
	[CLB_DiskBlockSize] [int] NOT NULL,
	[CLB_CappedIOPS] [int] NULL,
	[CLB_CappedMBPerSec] [int] NULL,
	[CLB_CGR_ID] [int] NOT NULL,
	[CLB_CHE_ID] [tinyint] NULL,
	[CLB_DLR_ID] [tinyint] NULL,
	[CLB_BasePricePerMonthUSD] [decimal](15, 3) NULL,
	[CLB_BasePriceWithSQLLicensePerMonthUSD] [decimal](15, 3) NULL,
	[CLB_TempID] [int] NULL,
	[CLB_CMP_ID] [int] NULL,
	[CLB_PricePerDisk] [decimal](17, 10) NULL,
 CONSTRAINT [PK_ConsolidationBlocks] PRIMARY KEY CLUSTERED 
(
	[CLB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_ConsolidationBlocks_CLB_HST_ID#CLB_PSH_ID#CLB_DLR_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ConsolidationBlocks_CLB_HST_ID#CLB_PSH_ID#CLB_DLR_ID] ON [Consolidation].[ConsolidationBlocks]
(
	[CLB_HST_ID] ASC,
	[CLB_PSH_ID] ASC,
	[CLB_DLR_ID] ASC
)
INCLUDE([CLB_CHE_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ConsolidationBlocks_CLB_ID_CLB_BasePricePerMonthUSD]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ConsolidationBlocks_CLB_ID_CLB_BasePricePerMonthUSD] ON [Consolidation].[ConsolidationBlocks]
(
	[CLB_ID] ASC,
	[CLB_BasePricePerMonthUSD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ConsolidationBlocks_CLB_PSH_ID#CLB_OST_ID#CLB_DLR_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ConsolidationBlocks_CLB_PSH_ID#CLB_OST_ID#CLB_DLR_ID] ON [Consolidation].[ConsolidationBlocks]
(
	[CLB_PSH_ID] ASC,
	[CLB_OST_ID] ASC,
	[CLB_DLR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
