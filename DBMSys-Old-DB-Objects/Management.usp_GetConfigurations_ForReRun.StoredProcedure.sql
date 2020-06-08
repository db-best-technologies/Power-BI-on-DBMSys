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
/****** Object:  StoredProcedure [Management].[usp_GetConfigurations_ForReRun]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Management].[usp_GetConfigurations_ForReRun]

as
set nocount on
select * from Management.Settings where set_key in 
(
'CPU Buffer Percentage'
,'Disk IO Buffer Percentage'
,'Disk Size Buffer Percentage'
,'Memory Buffer Percentage'
,'Network Speed Buffer Percentage'
,'Counter Percentile'
,'CPU Cap Percentage'
,'Disk IO Cap Percentage'
,'Disk Size Cap Percentage'
,'Memory Cap Percentage'
,'Network Speed Cap Percentage'
)
GO
