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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_UpdateCPUDetails]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [CapacityPlanningWizard].[usp_UpdateCPUDetails]
--DECLARE
	@CPUName varchar(100)	
	,@Score int				
	,@CoreCount int			
as
set nocount on


merge ExternalData.CPUBenchmark d
	using (select @CPUName CPUName,
				@Score Score
			where @Score is not null) s
		on CPUName = CPB_Name
	when not matched then insert(CPB_Name, CPB_Mark)
						values(CPUName, Score);

merge ExternalData.CPUCoreInfo d
	using (select @CPUName CPUName,
				@CoreCount CoreCount
			where @CoreCount is not null) s
		on CPUName = CCI_CPUName
	when not matched then insert(CCI_CPUName, CCI_CoreCount)
						values(CPUName, CoreCount);

DECLARE 
			@AdmDB NVARCHAR(255)

SELECT  
		@AdmDB = CAST(SET_Value AS NVARCHAR(255))
FROM	Management.Settings 
where	SET_Key = 'Cloud Pricing Database Name'

IF OBJECT_ID('tempdb..#MissingCPUId') IS NOT NULL
	DROP TABLE #MissingCPUId

CREATE TABLE #MissingCPUId
(
	CPUID INT
)

DECLARE @CMD NVARCHAR(MAX)
SET @CMD = 'INSERT INTO #MissingCPUId
SELECT MSC_ID FROM ' + @AdmDB + '.CPUData.MissingCPUs WHERE MSC_CPUName = ''' + @CPUName + ''''
exec sp_executesql @CMD

DECLARE @MSCID INT
SELECT 
		@MSCID = CPUID 
FROM	#MissingCPUId

SELECT @MSCID = CPUID FROM #MissingCPUId


SET @CMD = 'EXEC ' + @AdmDB + '.CPUData.usp_MissingCPUs_Add @MSC_ID,@SingleCPUScore,@OriginalCoreCount'

	exec sp_executesql @CMD
	,N'	@MSC_ID				int,
		@SingleCPUScore		int,
		@OriginalCoreCount	int'
	,@MSC_ID			= @MSCID				
	,@SingleCPUScore	= @Score		
	,@OriginalCoreCount	= @CoreCount
GO
