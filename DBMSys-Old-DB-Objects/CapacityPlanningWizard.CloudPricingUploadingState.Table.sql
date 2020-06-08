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
/****** Object:  Table [CapacityPlanningWizard].[CloudPricingUploadingState]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CapacityPlanningWizard].[CloudPricingUploadingState](
	[CPS_ID] [int] IDENTITY(1,1) NOT NULL,
	[CPS_State] [int] NULL,
	[CPS_Description] [varchar](1000) NULL,
	[CPS_LaunchDate] [datetime2](3) NULL,
	[CPS_FinishDate] [datetime2](3) NULL,
 CONSTRAINT [PK_CloudPricingUploadingState] PRIMARY KEY CLUSTERED 
(
	[CPS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
