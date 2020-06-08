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
/****** Object:  Table [BusinessLogic].[HealthChecks]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BusinessLogic].[HealthChecks](
	[HCH_ID] [int] IDENTITY(1,1) NOT NULL,
	[HCH_SCH_ID] [int] NOT NULL,
	[HCH_Name] [nvarchar](255) NOT NULL,
	[HCH_CreateDate] [datetime2](7) NOT NULL,
	[HCH_IsEnabled] [bit] NOT NULL,
	[HCH_IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_HEALTHCHECKS] PRIMARY KEY CLUSTERED 
(
	[HCH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [CK_HealthChecks_HCH_Name] UNIQUE NONCLUSTERED 
(
	[HCH_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
