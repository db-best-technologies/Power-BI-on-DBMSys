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
/****** Object:  Table [BusinessLogic].[HealthCheck_Cron_Table]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BusinessLogic].[HealthCheck_Cron_Table](
	[HCT_ID] [int] IDENTITY(1,1) NOT NULL,
	[HCT_HCH_ID] [int] NOT NULL,
	[HCT_SCH_ID] [int] NOT NULL,
	[HCT_Day_Freq] [tinyint] NOT NULL,
	[HCT_Time_Freq] [tinyint] NOT NULL,
	[HCT_Day] [tinyint] NULL,
	[HCT_Week] [tinyint] NULL,
	[HCT_Month] [tinyint] NULL,
	[HCT_Minute] [tinyint] NULL,
	[HCT_Hour] [tinyint] NULL,
	[HCT_Description] [varchar](512) NULL,
 CONSTRAINT [PK_HEALTHCHECK_CRON_TABLE] PRIMARY KEY CLUSTERED 
(
	[HCT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
