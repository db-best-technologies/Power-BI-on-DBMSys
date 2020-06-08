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
/****** Object:  Table [Consolidation].[PerDatabaseRatios]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[PerDatabaseRatios](
	[PDR_ID] [int] IDENTITY(1,1) NOT NULL,
	[PDR_MOB_ID] [int] NOT NULL,
	[PDR_IDB_ID] [int] NOT NULL,
	[PDR_CPURatio] [decimal](38, 20) NOT NULL,
	[PDR_MemoryRatio] [decimal](38, 20) NOT NULL,
	[PDR_IOphRatio] [decimal](38, 20) NOT NULL,
	[PDR_MBphRatio] [decimal](38, 20) NOT NULL,
 CONSTRAINT [PK_PerDatabaseRatios] PRIMARY KEY CLUSTERED 
(
	[PDR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_PerDatabaseRatios_PDR_MOB_ID#PDR_IDB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_PerDatabaseRatios_PDR_MOB_ID#PDR_IDB_ID] ON [Consolidation].[PerDatabaseRatios]
(
	[PDR_MOB_ID] ASC,
	[PDR_IDB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
