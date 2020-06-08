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
/****** Object:  Table [Consolidation].[OnPrem]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[OnPrem](
	[OPR_ID] [int] IDENTITY(1,1) NOT NULL,
	[OPR_CGR_ID] [int] NULL,
	[OPR_New_MOB_ID] [int] NULL,
	[OPR_Original_MOB_ID] [int] NULL,
	[OPR_Price] [decimal](15, 3) NULL,
	[OPR_OST_ID] [tinyint] NULL,
	[OPR_CHA_ID] [tinyint] NULL,
	[OPR_RedFlagged] [bit] NULL,
	[OPR_Edition] [varchar](100) NULL,
	[OPR_OriginalCoreCount] [int] NULL,
	[OPR_OriginalLicensingCoreCount] [decimal](10, 2) NULL,
	[OPR_NewCoreCount] [int] NULL,
	[OPR_NewLicensingCoreCount] [decimal](10, 2) NULL,
 CONSTRAINT [PK_OnPrem] PRIMARY KEY CLUSTERED 
(
	[OPR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
