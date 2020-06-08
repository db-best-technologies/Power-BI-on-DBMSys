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
/****** Object:  Table [Consolidation].[SingleDatabaseSizes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[SingleDatabaseSizes](
	[SDZ_ID] [int] IDENTITY(1,1) NOT NULL,
	[SDZ_MOB_ID] [int] NOT NULL,
	[SDZ_IDB_ID] [int] NOT NULL,
	[SDZ_SizeMB] [int] NOT NULL,
	[SDZ_EstimatedYearlyGrowthMB] [int] NOT NULL,
 CONSTRAINT [PK_SingleDatabaseSizes] PRIMARY KEY CLUSTERED 
(
	[SDZ_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_SingleDatabaseSizes_SDZ_MOB_ID#SDZ_IDB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_SingleDatabaseSizes_SDZ_MOB_ID#SDZ_IDB_ID] ON [Consolidation].[SingleDatabaseSizes]
(
	[SDZ_MOB_ID] ASC,
	[SDZ_IDB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
