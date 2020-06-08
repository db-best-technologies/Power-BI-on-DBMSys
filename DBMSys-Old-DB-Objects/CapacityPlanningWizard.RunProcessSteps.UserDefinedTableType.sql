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
/****** Object:  UserDefinedTableType [CapacityPlanningWizard].[RunProcessSteps]    Script Date: 6/8/2020 1:14:31 PM ******/
CREATE TYPE [CapacityPlanningWizard].[RunProcessSteps] AS TABLE(
	[StepID] [int] NULL
)
GO
