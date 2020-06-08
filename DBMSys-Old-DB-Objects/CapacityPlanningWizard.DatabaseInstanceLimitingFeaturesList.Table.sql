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
/****** Object:  Table [CapacityPlanningWizard].[DatabaseInstanceLimitingFeaturesList]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CapacityPlanningWizard].[DatabaseInstanceLimitingFeaturesList](
	[ILF_ID] [int] IDENTITY(1,1) NOT NULL,
	[ILF_CLV_ID] [int] NULL,
	[ILF_Name] [nvarchar](255) NULL,
	[ILF_IsEnabled] [bit] NULL,
	[ILF_Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_DatabaseInstanceLimitingFeaturesList] PRIMARY KEY CLUSTERED 
(
	[ILF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_DatabaseInstanceLimitingFeaturesList###ILF_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_DatabaseInstanceLimitingFeaturesList###ILF_Name] ON [CapacityPlanningWizard].[DatabaseInstanceLimitingFeaturesList]
(
	[ILF_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [CapacityPlanningWizard].[DatabaseInstanceLimitingFeaturesList] ADD  DEFAULT ((1)) FOR [ILF_IsEnabled]
GO
