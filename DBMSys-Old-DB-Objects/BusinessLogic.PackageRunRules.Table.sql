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
/****** Object:  Table [BusinessLogic].[PackageRunRules]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BusinessLogic].[PackageRunRules](
	[PRR_ID] [int] IDENTITY(1,1) NOT NULL,
	[PRR_ClientID] [int] NOT NULL,
	[PRR_PKN_ID] [int] NOT NULL,
	[PRR_RUL_ID] [int] NOT NULL,
	[PRR_RTH_ID] [int] NULL,
	[PRR_StartDate] [datetime2](3) NOT NULL,
	[PRR_EndDate] [datetime2](3) NULL,
	[PRR_RowsReturned] [bigint] NULL,
	[PRR_ErrorMessage] [nvarchar](2000) NULL,
 CONSTRAINT [PK_PackageRunRules] PRIMARY KEY CLUSTERED 
(
	[PRR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_PackageRunRules_PRR_StartDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_PackageRunRules_PRR_StartDate] ON [BusinessLogic].[PackageRunRules]
(
	[PRR_StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
