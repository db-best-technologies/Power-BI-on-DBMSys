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
/****** Object:  Table [Inventory].[SystemHosts]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[SystemHosts](
	[SHS_ID] [int] IDENTITY(1,1) NOT NULL,
	[SHS_SYS_ID] [int] NULL,
	[SHS_MOB_ID] [int] NULL,
	[SHS_ShortName] [nvarchar](100) NULL,
 CONSTRAINT [PK_SystemHosts] PRIMARY KEY CLUSTERED 
(
	[SHS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Inventory].[SystemHosts]  WITH CHECK ADD  CONSTRAINT [FK_SystemHosts_Systems] FOREIGN KEY([SHS_SYS_ID])
REFERENCES [Inventory].[Systems] ([SYS_ID])
GO
ALTER TABLE [Inventory].[SystemHosts] CHECK CONSTRAINT [FK_SystemHosts_Systems]
GO
