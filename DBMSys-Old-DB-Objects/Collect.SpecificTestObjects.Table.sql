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
/****** Object:  Table [Collect].[SpecificTestObjects]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Collect].[SpecificTestObjects](
	[STO_ID] [int] IDENTITY(1,1) NOT NULL,
	[STO_ClientID] [int] NOT NULL,
	[STO_TST_ID] [int] NOT NULL,
	[STO_MOB_ID] [int] NOT NULL,
	[STO_IsExcluded] [bit] NOT NULL,
	[STO_IntervalType] [char](1) NULL,
	[STO_IntervalPeriod] [int] NULL,
	[STO_Comments] [varchar](1000) NULL,
	[STO_IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_SpecificTestObjects] PRIMARY KEY CLUSTERED 
(
	[STO_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_SpecificTestObjects_ETO_TST_ID#ETO_MOB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_SpecificTestObjects_ETO_TST_ID#ETO_MOB_ID] ON [Collect].[SpecificTestObjects]
(
	[STO_TST_ID] ASC,
	[STO_MOB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Collect].[SpecificTestObjects] ADD  DEFAULT ((0)) FOR [STO_IsActive]
GO
