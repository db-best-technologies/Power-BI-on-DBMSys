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
/****** Object:  StoredProcedure [GUI].[usp_Host_Performance_save]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_Host_Performance_save]
--declare 
		@t Collect.TT_SpecificTestObjects readonly
	
as
set nocount on;

declare @tt Collect.TT_SpecificTestObjects

insert into @tt
select 
		distinct t.* 
from	@t t
join	Inventory.MonitoredObjects on MOB_ID = STO_MOB_ID
join	Collect.Tests on TST_ID = STO_TST_ID
join	Collect.TestVersions on TST_ID = TSV_TST_ID and MOB_PLT_ID = TSV_PLT_ID


insert into @tt(STO_ClientID, STO_TST_ID, STO_MOB_ID)
select 
		distinct
		tt.STO_ClientID 
		,TST_DontRunIfErrorIn_TST_ID
		,STO_MOB_ID
from	@tt tt
join	collect.Tests on TST_ID = STO_TST_ID
where	TST_DontRunIfErrorIn_TST_ID is not null
		and not exists (select * from @tt tt2 where TST_DontRunIfErrorIn_TST_ID = tt2.STO_TST_ID and tt.STO_MOB_ID = tt2.STO_MOB_ID)

DELETE FROM Collect.SpecificTestObjects WHERE STO_MOB_ID IN (SELECT STO_MOB_ID FROM @t t WHERE t.STO_TST_ID = -1)

SELECT 
		ROW_NUMBER() OVER ( ORDER BY MOB_NAME,TST_NAME) as MissingId
		,MOB_NAME
		,TST_NAME
FROM	@tt tt
LEFT JOIN	@t t on tt.STO_TST_ID = t.STO_TST_ID AND tt.STO_MOB_ID = t.STO_MOB_ID
JOIN	Inventory.MonitoredObjects ON tt.STO_MOB_ID = MOB_ID
JOIN	Collect.Tests ON tt.STO_TST_ID = TST_ID
WHERE	t.STO_TST_ID IS NULL
		AND NOT EXISTS (SELECT * FROM Collect.SpecificTestObjects STO WHERE STO.STO_MOB_ID = t.STO_MOB_ID AND STO.STO_TST_ID = t.STO_TST_ID)
ORDER BY MOB_NAME
		,TST_NAME

SELECT 
		ROW_NUMBER() OVER ( ORDER BY MOB_NAME,TST_NAME) as SuperfluousId
		,MOB_NAME
		,TST_NAME
FROM	@t tt
LEFT JOIN	@tt t on tt.STO_TST_ID = t.STO_TST_ID AND tt.STO_MOB_ID = t.STO_MOB_ID
JOIN	Inventory.MonitoredObjects ON tt.STO_MOB_ID = MOB_ID
JOIN	Collect.Tests ON tt.STO_TST_ID = TST_ID
WHERE	t.STO_TST_ID IS NULL
		AND NOT EXISTS (SELECT * FROM Collect.SpecificTestObjects STO WHERE STO.STO_MOB_ID = t.STO_MOB_ID AND STO.STO_TST_ID = t.STO_TST_ID)
ORDER BY MOB_NAME
		,TST_NAME



update STO set STO_IsActive = 0 from Collect.SpecificTestObjects STO join @tt ins on STO.STO_MOB_ID = ins.STO_MOB_ID;

MERGE	Collect.SpecificTestObjects WITH (HOLDLOCK) AS STO
USING	(select STO_ClientID, STO_TST_ID, STO_MOB_ID, STO_IntervalType, STO_IntervalPeriod, STO_Comments from @tt t join Collect.Tests tst on t.STO_TST_ID = tst.TST_ID) as ins
ON		STO.STO_MOB_ID = ins.STO_MOB_ID and STO.STO_TST_ID = ins.STO_TST_ID
WHEN MATCHED THEN
	update set STO_IsActive = 1-- - STO_IsExcluded
WHEN NOT MATCHED THEN

	INSERT(STO_ClientID, STO_TST_ID, STO_MOB_ID, STO_IsExcluded, STO_IntervalType, STO_IntervalPeriod, STO_Comments,STO_IsActive)
	VALUES (ins.STO_ClientID, ins.STO_TST_ID, ins.STO_MOB_ID, 0, ins.STO_IntervalType, ins.STO_IntervalPeriod, ins.STO_Comments,1);
GO
