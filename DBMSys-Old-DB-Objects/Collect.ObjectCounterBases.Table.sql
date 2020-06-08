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
/****** Object:  Table [Collect].[ObjectCounterBases]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Collect].[ObjectCounterBases](
	[OCB_ID] [int] IDENTITY(1,1) NOT NULL,
	[OCB_TST_ID] [int] NOT NULL,
	[OCB_MOB_ID] [int] NOT NULL,
	[OCB_CSY_ID] [tinyint] NOT NULL,
	[OCB_CounterID] [int] NOT NULL,
	[OCB_CIN_ID] [int] NULL,
	[OCB_IDB_ID] [int] NULL,
	[OCB_CollectionDate] [datetime2](3) NOT NULL,
	[OCB_Value] [bigint] NULL,
	[OCB_LastRestartDate] [datetime2](3) NULL,
 CONSTRAINT [PK_ObjectCounterBases] PRIMARY KEY CLUSTERED 
(
	[OCB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_ObjectCounterBases_OCB_TST_ID#OCB_MOB_ID#OCB_CSY_ID#OCB_CounterID#OCB_CIN_ID#OCB_IDB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ObjectCounterBases_OCB_TST_ID#OCB_MOB_ID#OCB_CSY_ID#OCB_CounterID#OCB_CIN_ID#OCB_IDB_ID] ON [Collect].[ObjectCounterBases]
(
	[OCB_TST_ID] ASC,
	[OCB_MOB_ID] ASC,
	[OCB_CSY_ID] ASC,
	[OCB_CounterID] ASC,
	[OCB_CIN_ID] ASC,
	[OCB_IDB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
