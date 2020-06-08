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
/****** Object:  Table [Activity].[DatabaseMailSendRequestUser]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[DatabaseMailSendRequestUser](
	[SRU_ID] [int] IDENTITY(1,1) NOT NULL,
	[SRU_Name] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_DatabaseMailSendRequestUser] PRIMARY KEY CLUSTERED 
(
	[SRU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DatabaseMailSendRequestUser_SRU_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DatabaseMailSendRequestUser_SRU_Name] ON [Activity].[DatabaseMailSendRequestUser]
(
	[SRU_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO