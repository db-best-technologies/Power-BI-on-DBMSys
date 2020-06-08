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
/****** Object:  StoredProcedure [Consolidation].[usp_UpdateAllCloudPricing]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Consolidation].[usp_UpdateAllCloudPricing]
--declare
	@XML_CloudPricing	xml = NULL,
	@ReturnResults bit = 1
AS
BEGIN

	DECLARE @ErrMsg NVARCHAR(MAX) = ''
	BEGIN TRY
		EXEC [Consolidation].[usp_UpdateAWSEC2Pricing]
			@XML_EC2Pricing = @XML_CloudPricing,
			@ReturnResults = @ReturnResults
	END TRY
	BEGIN CATCH
		SET @ErrMsg += ERROR_MESSAGE() + CHAR(10) + CHAR(13)
	END CATCH

	BEGIN TRY
		EXEC [Consolidation].[usp_UpdateAWSRDSPricing]
			@XML_RDSPricing = @XML_CloudPricing,
			@ReturnResults = @ReturnResults
	END TRY
	BEGIN CATCH
		SET @ErrMsg += ERROR_MESSAGE() + CHAR(10) + CHAR(13)
	END CATCH

	BEGIN TRY
		EXEC [Consolidation].[usp_UpdateAzureVMPricing]
			@XML_AzurePricing = @XML_CloudPricing,
			@ReturnResults = @ReturnResults
	END TRY
	BEGIN CATCH
		SET @ErrMsg += ERROR_MESSAGE() + CHAR(10) + CHAR(13)
	END CATCH

	IF @ErrMsg <> ''
		Raiserror(@ErrMsg,16,1)
END
GO
