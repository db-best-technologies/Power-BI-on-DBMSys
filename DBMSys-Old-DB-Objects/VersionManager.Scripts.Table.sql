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
/****** Object:  Table [VersionManager].[Scripts]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [VersionManager].[Scripts](
	[SCR_ID] [int] IDENTITY(2201,1) NOT NULL,
	[SCR_Description] [varchar](2000) NOT NULL,
	[SCR_Script] [nvarchar](max) NOT NULL,
	[SCR_DateEntered] [datetime2](3) NOT NULL,
	[SCR_DeploymentAttempts] [int] NOT NULL,
	[SCR_LastDeploymentAttemptDate] [datetime2](3) NULL,
	[SCR_IsDeployed] [bit] NOT NULL,
	[SCR_LastDeploymentErrorMessage] [nvarchar](2000) NULL,
 CONSTRAINT [PK_Scripts] PRIMARY KEY CLUSTERED 
(
	[SCR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [VersionManager].[Scripts] ADD  CONSTRAINT [DF_Scripts_SCR_DateEntered]  DEFAULT (sysdatetime()) FOR [SCR_DateEntered]
GO
ALTER TABLE [VersionManager].[Scripts] ADD  CONSTRAINT [DF_Scripts_SCR_DeploymentAttempts]  DEFAULT ((0)) FOR [SCR_DeploymentAttempts]
GO
ALTER TABLE [VersionManager].[Scripts] ADD  CONSTRAINT [DF_Scripts_SCR_IsDeployed]  DEFAULT ((0)) FOR [SCR_IsDeployed]
GO
