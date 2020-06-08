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
/****** Object:  Table [Inventory].[DBMILimitingFeatures]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[DBMILimitingFeatures](
	[DLF_ID] [int] IDENTITY(1,1) NOT NULL,
	[DLF_MOB_ID] [int] NOT NULL,
	[DLF_EntityId] [nvarchar](255) NULL,
	[DLF_Entityname] [nvarchar](255) NULL,
	[DLF_EntityChildID] [nvarchar](255) NULL,
	[DLF_EntityChildName] [nvarchar](255) NULL,
	[DLF_LimitedF] [nvarchar](255) NOT NULL,
	[DLF_EntityValue] [nvarchar](255) NULL,
	[DLF_IsDeleted] [bit] NOT NULL,
	[DLF_Last_TRH_ID] [int] NOT NULL,
	[DLF_LastSeenDate] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_DBMILimitingFeatures] PRIMARY KEY CLUSTERED 
(
	[DLF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DBMILimitingFeatures###DLF_MOB_ID#DLF_EntityId#DLF_Entityname#DLF_EntityChildID#DLF_EntityChildName#DLF_LimitedF]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DBMILimitingFeatures###DLF_MOB_ID#DLF_EntityId#DLF_Entityname#DLF_EntityChildID#DLF_EntityChildName#DLF_LimitedF] ON [Inventory].[DBMILimitingFeatures]
(
	[DLF_MOB_ID] ASC,
	[DLF_EntityId] ASC,
	[DLF_Entityname] ASC,
	[DLF_EntityChildID] ASC,
	[DLF_EntityChildName] ASC,
	[DLF_LimitedF] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Inventory].[DBMILimitingFeatures] ADD  DEFAULT ((0)) FOR [DLF_IsDeleted]
GO
