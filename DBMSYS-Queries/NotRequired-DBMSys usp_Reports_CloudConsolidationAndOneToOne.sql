USE [DBMSYS_InternationalPaper_International_Paper]
GO

DECLARE	@return_value int

EXEC	@return_value = [Consolidation].[usp_Reports_CloudConsolidationAndOneToOne]
		@CLV_ID = 1

SELECT	'Return Value' = @return_value

GO
