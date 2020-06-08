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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_ReceiveCloudPricingData]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [CapacityPlanningWizard].[usp_ReceiveCloudPricingData]
AS
BEGIN
	SET NOCOUNT ON

	declare 
		@handle uniqueidentifier,
		@body xml,
		@messageType nvarchar(128),
		@XML_CloudPricing xml;

	;receive top (1)
		@handle = conversation_handle,
		@body = cast(message_body as xml),
		@messageType = message_type_name
	from qRunPricesImportReceive

	IF @handle is not null
	BEGIN
		if @messageType <> 'msgRunPricesImport' return
	
		SET @XML_CloudPricing = @body

		end conversation @handle with cleanup	

		IF @XML_CloudPricing is not null
		BEGIN
			DECLARE @ErrMsg NVARCHAR(MAX) = ''
			BEGIN TRY
				EXEC [Consolidation].[usp_UpdateAWSEC2Pricing]
					@XML_EC2Pricing = @XML_CloudPricing
			END TRY
			BEGIN CATCH
				SET @ErrMsg += ERROR_MESSAGE() + CHAR(10) + CHAR(13)
			END CATCH

			BEGIN TRY
				EXEC [Consolidation].[usp_UpdateAWSRDSPricing]
					@XML_RDSPricing = @XML_CloudPricing
			END TRY
			BEGIN CATCH
				SET @ErrMsg += ERROR_MESSAGE() + CHAR(10) + CHAR(13)
			END CATCH

			BEGIN TRY
				EXEC [Consolidation].[usp_UpdateAzureVMPricing]
					@XML_AzurePricing = @XML_CloudPricing
			END TRY
			BEGIN CATCH
				SET @ErrMsg += ERROR_MESSAGE() + CHAR(10) + CHAR(13)
			END CATCH

			IF @ErrMsg <> ''
			BEGIN
				update CapacityPlanningWizard.CloudPricingUploadingState
				set CPS_State = 1, CPS_Description = 'Error during importing XML: ' + @ErrMsg;--+ ERROR_MESSAGE();

				Raiserror(@ErrMsg,16,1)
				
			END
			ELSE
				UPDATE CapacityPlanningWizard.CloudPricingUploadingState
				SET CPS_State = 2,
					CPS_Description = 'XML Prices were successfully imported',
					CPS_FinishDate = SYSDATETIME()
		END
	END
END
GO
