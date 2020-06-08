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
/****** Object:  StoredProcedure [GUI].[usp_Get_Executive_Summary_Exists]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_Get_Executive_Summary_Exists]
	@Is_Exists	bit OUTPUT
AS
BEGIN
	IF object_id('tempdb..#Result') is not null
		DROP TABLE #Result

	CREATE TABLE #Result
	(
		MOB_ID					int, 
		SYS_Name				nvarchar(512),
		ComputerName			nvarchar(512), 
		SQLServerProductName	nvarchar(512), 
		SQLServerVersion		nvarchar(512), 
		SQLServerServicePack	nvarchar(512), 
		SQLServerEdition		nvarchar(512), 
		OperatingSystem			nvarchar(512), 
		OperatingSystemServicePack   nvarchar(512), 
		OSArchitectureType		nvarchar(512), 
		NumberOfProcessors		int, 
		NumberOfTotalCores		int, 
		NumberOfLogicalProcessors   int, 
		LicensedCores			int, 
		SystemMemoryMB			nvarchar(512), 
		MachineType				nvarchar(512), 
		MachineManufacturer		nvarchar(512), 
		MachineModel			nvarchar(512), 
		DB_COUNT				int, 
		PLT_ID					tinyint,
		Edition					nvarchar(512),
		PCR_Child_MOB_ID		int, 
		Device_Type				nvarchar(512), 
		SQL_InstanceName		nvarchar(512), 
		DB_PLT_ID				tinyint, 
		PLT_Name				nvarchar(512) ,
		DB_PLT_Name				nvarchar(512), 
	)

	INSERT INTO #Result
	EXEC usp_Get_Executive '1'

	IF EXISTS (SELECT 1 FROM #Result)
	BEGIN
		SET @Is_Exists = 1
	END ELSE
	BEGIN
		SET @Is_Exists = 0
	END
END
GO
