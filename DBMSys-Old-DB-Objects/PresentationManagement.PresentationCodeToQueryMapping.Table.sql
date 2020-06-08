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
/****** Object:  Table [PresentationManagement].[PresentationCodeToQueryMapping]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PresentationManagement].[PresentationCodeToQueryMapping](
	[PCQ_ID] [int] IDENTITY(1,1) NOT NULL,
	[PCQ_PRN_ID] [int] NOT NULL,
	[PCQ_Code] [varchar](100) NOT NULL,
	[PCQ_QOT_ID] [tinyint] NOT NULL,
	[PCQ_Query] [nvarchar](max) NOT NULL,
	[PCQ_Header] [varchar](250) NULL,
 CONSTRAINT [PK_PresentationCodeToQueryMapping] PRIMARY KEY CLUSTERED 
(
	[PCQ_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_PresentationCodeToQueryMapping_PCQ_PRN_ID#PCQ_Code]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_PresentationCodeToQueryMapping_PCQ_PRN_ID#PCQ_Code] ON [PresentationManagement].[PresentationCodeToQueryMapping]
(
	[PCQ_PRN_ID] ASC,
	[PCQ_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
