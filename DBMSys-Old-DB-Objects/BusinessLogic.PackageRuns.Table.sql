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
/****** Object:  Table [BusinessLogic].[PackageRuns]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BusinessLogic].[PackageRuns](
	[PKN_ID] [int] IDENTITY(1,1) NOT NULL,
	[PKN_ClientID] [int] NOT NULL,
	[PKN_PKG_ID] [int] NOT NULL,
	[PKN_PeriodStartDate] [date] NOT NULL,
	[PKN_PeriodEndDate] [date] NOT NULL,
	[PKN_IsExplicitPeriod] [bit] NOT NULL,
	[PKN_VAT_ID] [tinyint] NOT NULL,
	[PKN_PercentileIfNeeded] [tinyint] NULL,
	[PKN_StartDate] [datetime2](3) NOT NULL,
	[PKN_EndDate] [datetime2](3) NULL,
	[PKN_TotalRulesQty] [int] NULL,
 CONSTRAINT [PK_PackageRuns] PRIMARY KEY CLUSTERED 
(
	[PKN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_PackageRuns_PKN_PKG_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_PackageRuns_PKN_PKG_ID] ON [BusinessLogic].[PackageRuns]
(
	[PKN_PKG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PackageRuns_PKN_StartDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_PackageRuns_PKN_StartDate] ON [BusinessLogic].[PackageRuns]
(
	[PKN_StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
