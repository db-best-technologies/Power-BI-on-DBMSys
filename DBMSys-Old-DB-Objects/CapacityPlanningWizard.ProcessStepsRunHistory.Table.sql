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
/****** Object:  Table [CapacityPlanningWizard].[ProcessStepsRunHistory]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CapacityPlanningWizard].[ProcessStepsRunHistory](
	[PRH_ID] [int] IDENTITY(1,1) NOT NULL,
	[PRH_PSP_ID] [int] NOT NULL,
	[PRH_StartDate] [datetime2](3) NOT NULL,
	[PRH_EndDate] [datetime2](3) NULL,
	[PRH_ErrorMessage] [nvarchar](2000) NULL,
 CONSTRAINT [PK_ProcessStepsRunHistory] PRIMARY KEY CLUSTERED 
(
	[PRH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_ProcessStepsRunHistory_PRH_PSP_ID#PRH_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ProcessStepsRunHistory_PRH_PSP_ID#PRH_ID] ON [CapacityPlanningWizard].[ProcessStepsRunHistory]
(
	[PRH_PSP_ID] ASC,
	[PRH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
