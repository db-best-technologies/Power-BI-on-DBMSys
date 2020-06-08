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
/****** Object:  Table [Management].[Settings_Types]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Management].[Settings_Types](
	[STT_SET_Module] [varchar](100) NOT NULL,
	[STT_SET_Key] [varchar](100) NOT NULL,
	[STT_Min_Value] [int] NULL,
	[STT_Max_Value] [int] NULL,
	[STT_Value_Type] [varchar](32) NOT NULL,
	[STT_Is_Nullable] [bit] NOT NULL,
 CONSTRAINT [PK_Settings_Types] PRIMARY KEY CLUSTERED 
(
	[STT_SET_Module] ASC,
	[STT_SET_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
