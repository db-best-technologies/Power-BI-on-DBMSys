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
/****** Object:  Table [PresentationManagement].[InputParameters]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PresentationManagement].[InputParameters](
	[IPR_ID] [int] IDENTITY(1,1) NOT NULL,
	[IPR_PRN_ID] [int] NOT NULL,
	[IPR_CategoryName] [varchar](100) NOT NULL,
	[IPR_Name] [varchar](100) NOT NULL,
	[IPR_Code] [varchar](100) NOT NULL,
	[IPR_Description] [varchar](1000) NOT NULL,
	[IPR_IPD_ID] [tinyint] NOT NULL,
	[IPR_Value] [sql_variant] NULL,
	[IPR_BinaryValue] [varbinary](max) NULL,
	[IPR_TableDescription] [xml] NULL,
 CONSTRAINT [PK_InputParameters] PRIMARY KEY CLUSTERED 
(
	[IPR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_InputParameters_IPR_PRN_ID#IPR_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_InputParameters_IPR_PRN_ID#IPR_Name] ON [PresentationManagement].[InputParameters]
(
	[IPR_PRN_ID] ASC,
	[IPR_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
