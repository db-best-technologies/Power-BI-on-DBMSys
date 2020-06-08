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
/****** Object:  Table [Management].[OperationConfigurations]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Management].[OperationConfigurations](
	[OCF_ID] [tinyint] NOT NULL,
	[OCF_NAME] [nvarchar](255) NOT NULL,
	[OCF_XML] [xml] NOT NULL,
	[OCF_Priority] [int] NOT NULL,
	[OCF_IsApply] [bit] NOT NULL,
 CONSTRAINT [PK_OperationConfigurations] PRIMARY KEY CLUSTERED 
(
	[OCF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Management].[OperationConfigurations] ADD  DEFAULT ((0)) FOR [OCF_IsApply]
GO
/****** Object:  Trigger [Management].[trg_OperationConfigurations_CheckID]    Script Date: 6/8/2020 1:15:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Management].[trg_OperationConfigurations_CheckID] on [Management].[OperationConfigurations]
for insert,update
as
set nocount on;
	declare @T TABLE
	(
		T_ID		TINYINT
		,T_IsTrue	BIT DEFAULT(0)
	)
	INSERT INTO @T(T_ID)
	SELECT OCF_ID from inserted

	UPDATE	@T 
	SET		T_IsTrue = 1
	WHERE	power(2,round(log(T_ID,2),0)) = T_ID

	IF EXISTS (SELECT * FROM @T WHERE T_IsTrue = 0)
	BEGIN
		RAISERROR('OCF_ID Is not power of 2',24,1) with log
		if @@TRANCOUNT >0
			rollback;
	END
GO
ALTER TABLE [Management].[OperationConfigurations] ENABLE TRIGGER [trg_OperationConfigurations_CheckID]
GO
