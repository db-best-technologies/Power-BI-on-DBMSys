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
/****** Object:  Table [PerformanceData].[CounterCombinations]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PerformanceData].[CounterCombinations](
	[CCB_ID] [int] IDENTITY(1,1) NOT NULL,
	[CCB_FromDate] [datetime2](3) NOT NULL,
	[CCB_ToDate] [datetime2](3) NOT NULL,
	[CCB_MOB_ID] [int] NOT NULL,
	[CCB_CSY_ID] [tinyint] NOT NULL,
	[CCB_CounterID] [int] NOT NULL,
	[CCB_CIN_ID] [int] NULL,
	[CCB_IDB_ID] [int] NULL,
 CONSTRAINT [PK_CounterCombinations] PRIMARY KEY NONCLUSTERED 
(
	[CCB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_CounterCombinations_CCB_ToDate#CCB_FromDate#CCB_MOB_ID#CCB_CSY_ID#CCB_CounterID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE CLUSTERED INDEX [IX_CounterCombinations_CCB_ToDate#CCB_FromDate#CCB_MOB_ID#CCB_CSY_ID#CCB_CounterID] ON [PerformanceData].[CounterCombinations]
(
	[CCB_ToDate] ASC,
	[CCB_FromDate] ASC,
	[CCB_MOB_ID] ASC,
	[CCB_CSY_ID] ASC,
	[CCB_CounterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CounterCombinations_CCB_MOB_ID#CCB_CSY_ID#CCB_CounterID##CCB_CIN_ID#CCB_IDB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_CounterCombinations_CCB_MOB_ID#CCB_CSY_ID#CCB_CounterID##CCB_CIN_ID#CCB_IDB_ID] ON [PerformanceData].[CounterCombinations]
(
	[CCB_MOB_ID] ASC,
	[CCB_CSY_ID] ASC,
	[CCB_CounterID] ASC
)
INCLUDE([CCB_CIN_ID],[CCB_IDB_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
