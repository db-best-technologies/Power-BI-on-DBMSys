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
/****** Object:  Table [Management].[VirtualMachineManufacturers]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Management].[VirtualMachineManufacturers](
	[VMM_ID] [smallint] IDENTITY(1,1) NOT NULL,
	[VMM_ManufacturerName] [nvarchar](255) NULL,
	[VMM_ModelName] [nvarchar](255) NULL,
 CONSTRAINT [PK_VirtualMachineManufacturers] PRIMARY KEY CLUSTERED 
(
	[VMM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [Management].[trg_VirtualMachineManufacturers_Insert]    Script Date: 6/8/2020 1:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Management].[trg_VirtualMachineManufacturers_Insert] ON [Management].[VirtualMachineManufacturers]
	FOR INSERT
	AS
	SET NOCOUNT ON;
		
		;WITH ins AS
		(
			SELECT 
					OSS_ID AS OSSID
			FROM	Inventory.OSServers
			JOIN	Inventory.MachineManufacturers ON MMN_ID = OSS_MMN_ID
			JOIN	Inventory.MachineManufacturerModels ON MMD_ID = OSS_MMD_ID
			JOIN	inserted i ON i.VMM_ManufacturerName = MMN_Name AND i.VMM_ModelName = MMD_Name
							
		)

		UPDATE	Inventory.OSServers
		SET		OSS_IsVirtualServer = 1
		FROM	ins
		WHERE	OSS_ID = OSSID
				AND OSS_IsVirtualServer = 0
GO
ALTER TABLE [Management].[VirtualMachineManufacturers] ENABLE TRIGGER [trg_VirtualMachineManufacturers_Insert]
GO
