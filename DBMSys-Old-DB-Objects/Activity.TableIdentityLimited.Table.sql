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
/****** Object:  Table [Activity].[TableIdentityLimited]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[TableIdentityLimited](
	[TIL_ID] [int] IDENTITY(1,1) NOT NULL,
	[TIL_MOB_ID] [int] NOT NULL,
	[TIL_IsDeleted] [bit] NOT NULL,
	[TIL_DatabaseName] [nvarchar](255) NOT NULL,
	[TIL_TableName] [nvarchar](255) NOT NULL,
	[TIL_ColumnName] [nvarchar](255) NOT NULL,
	[TIL_ColumnType] [nvarchar](255) NOT NULL,
	[TIL_MaxValue] [float] NOT NULL,
	[TIL_CurrValue] [float] NOT NULL,
	[TIL_IdentityIncr] [float] NOT NULL,
	[TIL_IdentCurr] [float] NOT NULL,
	[TIL_CreatedDate] [datetime] NOT NULL,
	[TIL_Last_TRH_ID] [int] NOT NULL,
	[TIL_LastSeenDate] [datetime] NULL,
 CONSTRAINT [PK_TableIdentityLimited] PRIMARY KEY CLUSTERED 
(
	[TIL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_TableIdentityLimited#TIL_MOB_ID#TIL_DatabaseName#TIL_TableName#TIL_ColumnName#TIL_ColumnType#TIL_CreatedDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_TableIdentityLimited#TIL_MOB_ID#TIL_DatabaseName#TIL_TableName#TIL_ColumnName#TIL_ColumnType#TIL_CreatedDate] ON [Activity].[TableIdentityLimited]
(
	[TIL_MOB_ID] ASC,
	[TIL_DatabaseName] ASC,
	[TIL_TableName] ASC,
	[TIL_ColumnName] ASC,
	[TIL_ColumnType] ASC,
	[TIL_CreatedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
