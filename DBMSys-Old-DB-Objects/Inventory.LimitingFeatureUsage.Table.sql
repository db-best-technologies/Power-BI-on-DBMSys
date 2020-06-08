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
/****** Object:  Table [Inventory].[LimitingFeatureUsage]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[LimitingFeatureUsage](
	[LFU_ID] [int] IDENTITY(1,1) NOT NULL,
	[LFU_ClientID] [int] NOT NULL,
	[LFU_MOB_ID] [int] NOT NULL,
	[LFU_IDB_ID] [int] NULL,
	[LFU_LFT_ID] [int] NOT NULL,
	[LFU_InsertDate] [datetime2](3) NOT NULL,
	[LFU_LastSeenDate] [datetime2](3) NOT NULL,
	[LFU_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_LimitingFeatureUsage] PRIMARY KEY CLUSTERED 
(
	[LFU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_LimitingFeatureUsage_LFU_MOB_ID_LFU_IDB_ID_LFU_LFT_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LimitingFeatureUsage_LFU_MOB_ID_LFU_IDB_ID_LFU_LFT_ID] ON [Inventory].[LimitingFeatureUsage]
(
	[LFU_MOB_ID] ASC,
	[LFU_IDB_ID] ASC,
	[LFU_LFT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
