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
/****** Object:  Table [ExternalData].[ProductLifeCycles]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ExternalData].[ProductLifeCycles](
	[PLY_ID] [int] IDENTITY(1,1) NOT NULL,
	[PLY_PLT_ID] [tinyint] NOT NULL,
	[PLY_Name] [varchar](250) NOT NULL,
	[PLY_ReleaseDate] [date] NOT NULL,
	[PLY_MainstreamSupportEndDate] [date] NULL,
	[PLY_ExtendedSupportEndDate] [date] NULL,
	[PLY_MinVersionNumber] [decimal](15, 2) NOT NULL,
 CONSTRAINT [PK_ProductLifeCycles] PRIMARY KEY CLUSTERED 
(
	[PLY_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ProductLifeCycles_PLY_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProductLifeCycles_PLY_Name] ON [ExternalData].[ProductLifeCycles]
(
	[PLY_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
