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
/****** Object:  Table [PerformanceData].[CounterResults_Daily]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PerformanceData].[CounterResults_Daily](
	[CRS_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CRS_ClientID] [int] NOT NULL,
	[CRS_MOB_ID] [int] NOT NULL,
	[CRS_SystemID] [tinyint] NOT NULL,
	[CRS_CounterID] [smallint] NOT NULL,
	[CRS_InstanceID] [int] NULL,
	[CRS_IDB_ID] [int] NULL,
	[CRS_DateTime] [date] NOT NULL,
	[CRS_ResultCount] [int] NOT NULL,
	[CRS_MinValue] [decimal](38, 6) NULL,
	[CRS_AvgValue] [decimal](38, 6) NULL,
	[CRS_MaxValue] [decimal](38, 6) NULL,
	[CRS_SumValue] [decimal](38, 6) NULL,
	[CRS_DominantStatus] [varchar](100) NULL,
	[CRS_DominantStatusPercentage] [int] NULL,
	[CRS_SecondaryStatus] [varchar](100) NULL,
	[CRS_SecondaryStatusPercentage] [int] NULL,
	[CRS_MaxSource_CRS_ID] [bigint] NULL,
 CONSTRAINT [PK_CounterResults_Daily] PRIMARY KEY NONCLUSTERED 
(
	[CRS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_CounterResults_Daily_CRS_DateTime#CRS_SystemID#CRS_CounterID#CRS_InstanceID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE CLUSTERED INDEX [IX_CounterResults_Daily_CRS_DateTime#CRS_SystemID#CRS_CounterID#CRS_InstanceID] ON [PerformanceData].[CounterResults_Daily]
(
	[CRS_DateTime] ASC,
	[CRS_SystemID] ASC,
	[CRS_CounterID] ASC,
	[CRS_InstanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CounterResults_Daily_CRS_MaxSource_CRS_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_CounterResults_Daily_CRS_MaxSource_CRS_ID] ON [PerformanceData].[CounterResults_Daily]
(
	[CRS_MaxSource_CRS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CounterResults_Daily_CRS_MOB_ID#CRS_SystemID#CRS_CounterID##CRS_ID#CRS_AvgValue]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_CounterResults_Daily_CRS_MOB_ID#CRS_SystemID#CRS_CounterID##CRS_ID#CRS_AvgValue] ON [PerformanceData].[CounterResults_Daily]
(
	[CRS_MOB_ID] ASC,
	[CRS_SystemID] ASC,
	[CRS_CounterID] ASC
)
INCLUDE([CRS_ID],[CRS_AvgValue]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
