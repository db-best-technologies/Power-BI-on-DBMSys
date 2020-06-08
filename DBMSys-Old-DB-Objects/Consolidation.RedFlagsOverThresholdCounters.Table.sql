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
/****** Object:  Table [Consolidation].[RedFlagsOverThresholdCounters]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[RedFlagsOverThresholdCounters](
	[RFC_ID] [int] IDENTITY(1,1) NOT NULL,
	[RFC_PCG_ID] [tinyint] NOT NULL,
	[RFC_CSY_ID] [tinyint] NOT NULL,
	[RFC_CounterID] [int] NOT NULL,
	[RFC_MOB_ID] [int] NOT NULL,
	[RFC_CounterInstanceID] [int] NULL,
	[RFC_DiffSign] [varchar](5) NOT NULL,
	[RFC_Value] [decimal](38, 5) NULL,
	[RFC_MinValue] [decimal](38, 5) NULL,
	[RFC_AvgValue] [decimal](38, 5) NULL,
	[RFC_MaxValue] [decimal](38, 5) NULL,
	[RFC_SamplesCollected] [int] NULL,
	[RFC_DaysSampled] [int] NULL,
	[RFC_PercentOverThreshold] [decimal](10, 2) NULL,
	[RFC_HoursWithMoreThanThan30PercentRecurrence] [varchar](100) NULL,
 CONSTRAINT [PK_RedFlagsOverThresholdCounters] PRIMARY KEY CLUSTERED 
(
	[RFC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
