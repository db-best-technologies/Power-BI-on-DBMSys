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
/****** Object:  Table [BusinessLogic].[PackageRunObjectCounts]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BusinessLogic].[PackageRunObjectCounts](
	[PRO_ID] [int] IDENTITY(1,1) NOT NULL,
	[PRO_ClientID] [int] NOT NULL,
	[PRO_PKN_ID] [int] NOT NULL,
	[PRO_OBT_ID] [tinyint] NOT NULL,
	[PRO_Count] [bigint] NOT NULL,
	[PRO_InsertDate] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_PackageRunObjectCounts] PRIMARY KEY CLUSTERED 
(
	[PRO_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_PackageRun_PackageRunObjectCounts_PRO_InsertDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_PackageRun_PackageRunObjectCounts_PRO_InsertDate] ON [BusinessLogic].[PackageRunObjectCounts]
(
	[PRO_InsertDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PackageRunObjectCounts_PRO_PKN_ID#PRO_OBT_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_PackageRunObjectCounts_PRO_PKN_ID#PRO_OBT_ID] ON [BusinessLogic].[PackageRunObjectCounts]
(
	[PRO_PKN_ID] ASC,
	[PRO_OBT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [BusinessLogic].[PackageRunObjectCounts] ADD  CONSTRAINT [DF_PackageRunObjectCounts_PRO_InsertDate]  DEFAULT (sysdatetime()) FOR [PRO_InsertDate]
GO
