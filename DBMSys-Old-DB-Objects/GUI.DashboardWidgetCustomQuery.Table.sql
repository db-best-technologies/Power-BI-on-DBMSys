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
/****** Object:  Table [GUI].[DashboardWidgetCustomQuery]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [GUI].[DashboardWidgetCustomQuery](
	[DCC_ID] [int] IDENTITY(1,1) NOT NULL,
	[DCC_Name] [nvarchar](255) NOT NULL,
	[DCC_ProcedureName] [nvarchar](255) NULL,
	[DCC_Parameters] [xml] NULL,
	[DCC_WidgetPermission] [nvarchar](100) NULL,
 CONSTRAINT [PK_DashboardWidgetCustomQuery] PRIMARY KEY CLUSTERED 
(
	[DCC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
