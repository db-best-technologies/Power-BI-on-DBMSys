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
/****** Object:  Table [Consolidation].[RedFlags]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[RedFlags](
	[RFL_ID] [int] IDENTITY(1,1) NOT NULL,
	[RFL_PCG_ID] [tinyint] NOT NULL,
	[RFL_SystemID] [tinyint] NOT NULL,
	[RFL_CounterID] [int] NOT NULL,
	[RFL_DiffSign] [varchar](5) NOT NULL,
	[RFL_Value] [decimal](38, 5) NULL,
	[RFL_IsIncremental] [bit] NULL,
	[RFL_Expression] [nvarchar](max) NULL,
	[RFL_IsActive] [bit] NOT NULL,
	[RFL_DivideBy] [varchar](100) NULL,
 CONSTRAINT [PK_RedFlags] PRIMARY KEY CLUSTERED 
(
	[RFL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_RedFlags_RFL_SystemID#RFL_CounterID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_RedFlags_RFL_SystemID#RFL_CounterID] ON [Consolidation].[RedFlags]
(
	[RFL_SystemID] ASC,
	[RFL_CounterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
