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
/****** Object:  Table [Inventory].[History]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[History](
	[HIS_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[HIS_Type] [char](1) NOT NULL,
	[HIS_Datetime] [datetime2](3) NOT NULL,
	[HIS_TableName] [nvarchar](128) NOT NULL,
	[HIS_MOB_ID] [int] NULL,
	[HIS_PK_1] [sql_variant] NOT NULL,
	[HIS_PK_2] [sql_variant] SPARSE  NULL,
	[HIS_PK_3] [sql_variant] SPARSE  NULL,
	[HIS_PK_4] [sql_variant] SPARSE  NULL,
	[HIS_PK_5] [sql_variant] SPARSE  NULL,
	[HIS_Changes] [xml] NOT NULL,
	[HIS_Username] [nvarchar](128) NOT NULL,
	[HIS_AppName] [nvarchar](128) NOT NULL,
	[HIS_HostName] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_History] PRIMARY KEY CLUSTERED 
(
	[HIS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_History_HIS_DateTime]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_History_HIS_DateTime] ON [Inventory].[History]
(
	[HIS_Datetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_History_PKs]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_History_PKs] ON [Inventory].[History]
(
	[HIS_TableName] ASC,
	[HIS_MOB_ID] ASC,
	[HIS_PK_1] ASC
)
INCLUDE([HIS_PK_2]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
