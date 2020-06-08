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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_RunCloudPricingImport]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [CapacityPlanningWizard].[usp_RunCloudPricingImport]
	@XML_CloudPricing xml = NULL,
	@Timeout	int = 15
AS
BEGIN
	set nocount on

	declare 
		@SQL				nvarchar(max),
		@handle				uniqueidentifier,
		@state_id			int


	EXEC CapacityPlanningWizard.usp_ClearPricingUploadingState
		@Timeout = @Timeout

	--If any processes with status 0 (Started) than raise error
	IF EXISTS (select * from CapacityPlanningWizard.CloudPricingUploadingState where CPS_State = 0)
		RAISERROR('Cloud Prices uploading is already started', 16, 1)
	ELSE BEGIN
		IF NOT EXISTS (select * from CapacityPlanningWizard.CloudPricingUploadingState where CPS_LaunchDate > dateadd(minute, -10, sysdatetime()))
		BEGIN
			SET @SQL = concat('ALTER DATABASE ', quotename(db_name()), ' SET TRUSTWORTHY ON', char(13), char(10),
								'ALTER AUTHORIZATION ON DATABASE::', quotename(db_name()), ' TO sa', char(13), char(10),
								'ALTER DATABASE ', quotename(db_name()), ' SET NEW_BROKER WITH ROLLBACK IMMEDIATE')
			EXEC(@SQL)
		END

		begin dialog conversation @handle
		from service srvRunPricesImportSend
		to service 'srvRunPricesImportReceive'
		on contract conRunPricesImport
		with encryption = off
			
		begin try
			begin tran

				delete from CapacityPlanningWizard.CloudPricingUploadingState

				insert into CapacityPlanningWizard.CloudPricingUploadingState(CPS_State, CPS_Description, CPS_LaunchDate)
				values(0, 'XML sent to Queue', SYSDATETIME())

				set @state_id = scope_identity();
		
				;send on conversation @handle
				message type msgRunPricesImport(@XML_CloudPricing);

			commit tran
		end try
		begin catch
			if @@TRANCOUNT > 0
				rollback;

			begin tran
				update CapacityPlanningWizard.CloudPricingUploadingState
				set CPS_State = 1, CPS_Description = 'Error during sending XML to the Queue: ' + ERROR_MESSAGE()
				where CPS_ID = @state_id
			commit tran

			throw;
		end catch
	
		end conversation @handle
	END
END
GO
