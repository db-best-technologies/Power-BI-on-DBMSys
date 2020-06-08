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
/****** Object:  View [Tests].[VW_TST_OperatingSystem]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_OperatingSystem]
as
select top 0 CAST(null as nvarchar(128)) Caption,
			CAST(null as int) CodeSet,
			CAST(null as smallint) CountryCode,
			CAST(null as nvarchar(128)) CSDVersion,
			CAST(null as smallint) CurrentTimeZone,
			CAST(null as datetime) InstallDate,
			CAST(null as datetime) LastBootUpTime,
			CAST(null as varchar(10)) Locale,
			CAST(null as bigint) MaxProcessMemorySize,
			CAST(null as nvarchar(128)) OSArchitecture,
			CAST(null as smallint) OSLanguage,
			CAST(null as bit) PAEEnabled,
			CAST(null as tinyint) ProductType,
			CAST(null as bigint) TotalVisibleMemorySize,
			CAST(null as varchar(100)) [Version],
			CAST(null as nvarchar(255)) CSName,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_OperatingSystem]    Script Date: 6/8/2020 1:16:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_OperatingSystem] on [Tests].[VW_TST_OperatingSystem]
	instead of insert
as
set nocount on
declare @Entity_ID int,
		@MOB_ID int
		,@TSTID int

select top 1 @MOB_ID = TRH_MOB_ID	
			,@TSTID = TRH_TST_ID
from inserted
	inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
	inner join Inventory.MonitoredObjects on TRH_MOB_ID = MOB_ID

IF @TSTID = 18
BEGIN
	merge Inventory.ProductLevels d
		using (select distinct CSDVersion
				from inserted
				where CSDVersion is not null) s
			on PRL_PLT_ID = 2
				and CSDVersion = PRL_Name
		when not matched then insert(PRL_PLT_ID, PRL_Name)
								values(2, CSDVersion);

	merge Inventory.Versions d
		using (select distinct [Version], [Version] VersionName, cast(replace([Version], '.', '') as decimal(18, 4)) VersionNumber
				from inserted) s
					on VER_PLT_ID = 2
					and [Version] = VER_Name
		when not matched then insert (VER_PLT_ID, VER_Full, VER_Name, VER_Number)
								values(2, [Version], VersionName, VersionNumber);

	merge Inventory.Editions d
		using (select Caption
				from inserted) s
					on EDT_PLT_ID = 2
					and Caption = EDT_Name
		when not matched then insert (EDT_PLT_ID, EDT_Name)
								values(2, Caption);

	;with NewRows as
			(select VER_ID, EDT_ID
				from inserted
					inner join Inventory.Versions on VER_PLT_ID = 2
													and VER_Number = cast(replace([Version], '.', '') as decimal(18, 4))
					inner join Inventory.Editions on EDT_PLT_ID = 2
													and EDT_Name = Caption)
	update Inventory.MonitoredObjects
	set MOB_VER_ID = VER_ID,
		MOB_Engine_EDT_ID = EDT_ID
	from NewRows
	where MOB_ID = @MOB_ID
		and (MOB_VER_ID <> VER_ID or MOB_VER_ID is null)
		and (MOB_Engine_EDT_ID <> EDT_ID or MOB_Engine_EDT_ID is null)

	DECLARE 
			@OldParentMOBID	INT = 0

	SELECT
			@OldParentMOBID = o.MOB_ID
	FROM	Inventory.OSServers
	JOIN	Inventory.MonitoredObjects n ON OSS_MOB_ID = n.MOB_ID
	JOIN	Inventory.MonitoredObjects o ON OSS_CSName = o.MOB_Name AND n.MOB_PLT_ID = o.MOB_PLT_ID
	JOIN	Management.ObjectOperationalStatuses ON o.MOB_OOS_ID = OOS_ID AND OOS_IsOperational = 1
	WHERE	OSS_MOB_ID = @MOB_ID
			AND EXISTS (SELECT * FROM Inventory.ParentChildRelationships WHERE PCR_Parent_MOB_ID = o.MOB_ID)

	IF ISNULL(@OldParentMOBID,0) <> 0
	BEGIN
		with pcr as 
		(
			SELECT 
					PCR_Child_MOB_ID AS CMOB
			FROM	Inventory.ParentChildRelationships 
			WHERE	PCR_Parent_MOB_ID = @MOB_ID
		)
		UPDATE	Inventory.ParentChildRelationships 
		SET		PCR_Parent_MOB_ID = @MOB_ID 
		WHERE	PCR_Parent_MOB_ID = @OldParentMOBID
				AND NOT EXISTS (SELECT * FROM pcr WHERE PCR_Child_MOB_ID = CMOB)
	
	END

	;with NewRows as
			(select CodeSet, CountryCode, PRL_ID, CurrentTimeZone,
					InstallDate, LastBootUpTime, Locale,
					OSLanguage, 
					TotalVisibleMemorySize/1024 TotalVisibleMemorySizeMB, MaxProcessMemorySize/1024 MaxProcessMemorySize, 
					CSName
				from inserted
					left join Inventory.ProductLevels on PRL_PLT_ID = 2
															and PRL_Name = CSDVersion
			)

	update Inventory.OSServers
	set OSS_CodeSet = CodeSet,
		OSS_CountryCode = CountryCode,
		OSS_PRL_ID = PRL_ID,
		OSS_CurrentTimeZone = CurrentTimeZone,
		OSS_InstallDate = InstallDate,
		OSS_LastBootUpTime = LastBootUpTime,
		OSS_Locale = Locale,
		OSS_Language = OSLanguage,
		OSS_TotalPhysicalMemoryMB = TotalVisibleMemorySizeMB,
		OSS_MaxProcessMemorySizeMB = MaxProcessMemorySize,
		OSS_CSName = CSName
	from NewRows
	WHERE OSS_MOB_ID = @MOB_ID
END
ELSE
	IF @TSTID = 133
	BEGIN
		
		;with NewRows as
				(select case when OSArchitecture like '%64%' then 64
								when OSArchitecture is not null then 32
							end Architecture, ProductType, PAEEnabled
					from inserted
				)

		update Inventory.OSServers
		set OSS_Architecture = isnull(Architecture, OSS_Architecture),
			OSS_OPT_ID = ProductType,
			OSS_IsPAEEnabled = PAEEnabled
		from NewRows
		WHERE OSS_MOB_ID = @MOB_ID
	END
GO
