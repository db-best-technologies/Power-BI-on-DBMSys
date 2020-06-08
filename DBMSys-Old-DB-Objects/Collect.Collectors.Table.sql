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
/****** Object:  Table [Collect].[Collectors]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Collect].[Collectors](
	[CTR_ID] [int] IDENTITY(1,1) NOT NULL,
	[CTR_Name] [nvarchar](255) NOT NULL,
	[CTR_Description] [nvarchar](4000) NULL,
	[CTR_CreateDate] [datetime] NOT NULL,
	[CTR_LastConfigGetDate] [datetime] NULL,
	[CTR_LastResponceDate] [datetime] NULL,
	[CTR_IsDeleted] [bit] NULL,
	[CTR_IsDefault] [bit] NULL,
 CONSTRAINT [PK_Collectors] PRIMARY KEY CLUSTERED 
(
	[CTR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
