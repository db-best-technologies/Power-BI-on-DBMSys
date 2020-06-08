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
/****** Object:  Table [Consolidation].[RedFlagsByResourceType]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[RedFlagsByResourceType](
	[RFR_ID] [int] IDENTITY(1,1) NOT NULL,
	[RFR_MOB_ID] [int] NOT NULL,
	[RFR_PCG_ID] [tinyint] NOT NULL,
	[RFR_DaysSampled] [int] NULL,
	[RFR_PercentOverThreshold] [decimal](10, 2) NOT NULL,
	[RFR_HoursWithMoreThanThan30PercentRecurrence] [nvarchar](1000) NULL,
 CONSTRAINT [PK_RedFlagsByResourceType] PRIMARY KEY CLUSTERED 
(
	[RFR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
