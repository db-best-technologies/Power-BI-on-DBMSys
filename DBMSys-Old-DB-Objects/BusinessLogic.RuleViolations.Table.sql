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
/****** Object:  Table [BusinessLogic].[RuleViolations]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BusinessLogic].[RuleViolations](
	[RLV_ID] [int] IDENTITY(1,1) NOT NULL,
	[RLV_ClientID] [int] NOT NULL,
	[RLV_PRR_ID] [int] NOT NULL,
	[RLV_MOB_ID] [int] NULL,
	[RLV_InsertDate] [datetime2](3) NOT NULL,
	[RLV_Info1] [sql_variant] SPARSE  NULL,
	[RLV_Info2] [sql_variant] SPARSE  NULL,
	[RLV_Info3] [sql_variant] SPARSE  NULL,
	[RLV_Info4] [sql_variant] SPARSE  NULL,
	[RLV_Info5] [sql_variant] SPARSE  NULL,
	[RLV_Info6] [sql_variant] SPARSE  NULL,
	[RLV_Info7] [sql_variant] SPARSE  NULL,
	[RLV_Info8] [sql_variant] SPARSE  NULL,
	[RLV_Info9] [sql_variant] SPARSE  NULL,
	[RLV_Info10] [sql_variant] SPARSE  NULL,
	[RLV_Info11] [sql_variant] SPARSE  NULL,
	[RLV_Info12] [sql_variant] SPARSE  NULL,
	[RLV_Info13] [sql_variant] SPARSE  NULL,
	[RLV_Info14] [sql_variant] SPARSE  NULL,
	[RLV_Info15] [sql_variant] SPARSE  NULL,
	[RLV_Info16] [sql_variant] SPARSE  NULL,
	[RLV_Info17] [sql_variant] SPARSE  NULL,
	[RLV_Info18] [sql_variant] SPARSE  NULL,
	[RLV_Info19] [sql_variant] SPARSE  NULL,
	[RLV_Info20] [sql_variant] SPARSE  NULL,
 CONSTRAINT [PK_RuleViolations] PRIMARY KEY CLUSTERED 
(
	[RLV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_RuleViolations_RLV_InsertDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_RuleViolations_RLV_InsertDate] ON [BusinessLogic].[RuleViolations]
(
	[RLV_InsertDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RuleViolations_RLV_PRR_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_RuleViolations_RLV_PRR_ID] ON [BusinessLogic].[RuleViolations]
(
	[RLV_PRR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [BusinessLogic].[RuleViolations] ADD  CONSTRAINT [DF_RuleViolations_RLV_InsertDate]  DEFAULT (sysdatetime()) FOR [RLV_InsertDate]
GO
