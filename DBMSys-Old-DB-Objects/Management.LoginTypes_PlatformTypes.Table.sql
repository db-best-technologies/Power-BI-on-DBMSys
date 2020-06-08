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
/****** Object:  Table [Management].[LoginTypes_PlatformTypes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Management].[LoginTypes_PlatformTypes](
	[LPC_ID] [int] IDENTITY(1,1) NOT NULL,
	[LPC_PLT_ID] [int] NOT NULL,
	[LPC_LGY_ID] [int] NOT NULL,
 CONSTRAINT [PK_LoginTypesPlatformConnection] PRIMARY KEY CLUSTERED 
(
	[LPC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Management].[LoginTypes_PlatformTypes]  WITH CHECK ADD  CONSTRAINT [FK_LoginTypesPlatformConnection_LoginTypesPlatformConnection] FOREIGN KEY([LPC_ID])
REFERENCES [Management].[LoginTypes_PlatformTypes] ([LPC_ID])
GO
ALTER TABLE [Management].[LoginTypes_PlatformTypes] CHECK CONSTRAINT [FK_LoginTypesPlatformConnection_LoginTypesPlatformConnection]
GO
