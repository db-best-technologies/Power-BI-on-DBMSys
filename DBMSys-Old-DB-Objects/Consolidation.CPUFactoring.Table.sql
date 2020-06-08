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
/****** Object:  Table [Consolidation].[CPUFactoring]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[CPUFactoring](
	[CPF_ID] [int] IDENTITY(1,1) NOT NULL,
	[CPF_MOB_ID] [int] NULL,
	[CPF_VES_ID] [int] NULL,
	[CPF_CPUFactor] [decimal](10, 4) NOT NULL,
	[CPF_CPUName] [varchar](100) NOT NULL,
	[CPF_SingleCPUScore] [int] NOT NULL,
	[CPF_CPUCount] [int] NOT NULL,
	[CPF_IsVM] [bit] NOT NULL,
	[CPF_IsUsableCoreCountApplied] [bit] NULL,
 CONSTRAINT [PK_CPUFacting] PRIMARY KEY CLUSTERED 
(
	[CPF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
