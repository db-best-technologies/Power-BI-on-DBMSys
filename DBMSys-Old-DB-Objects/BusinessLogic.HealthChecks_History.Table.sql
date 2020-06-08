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
/****** Object:  Table [BusinessLogic].[HealthChecks_History]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BusinessLogic].[HealthChecks_History](
	[HCY_PKN_ID] [int] NOT NULL,
	[HCY_HCH_ID] [int] NOT NULL,
	[HCY_StartDate] [datetime] NOT NULL,
	[Runned_Qty] [int] NOT NULL,
	[RuleViolations_Qty] [int] NOT NULL,
	[Lo_Qty] [int] NOT NULL,
	[Med_Qty] [int] NOT NULL,
	[Hi_Qty] [int] NOT NULL,
 CONSTRAINT [PK_HEALTHCHECKS_HISTORY] PRIMARY KEY CLUSTERED 
(
	[HCY_PKN_ID] ASC,
	[HCY_HCH_ID] ASC,
	[HCY_StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
