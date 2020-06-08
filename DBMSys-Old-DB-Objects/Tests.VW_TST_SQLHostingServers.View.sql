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
/****** Object:  View [Tests].[VW_TST_SQLHostingServers]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_SQLHostingServers]
AS
	SELECT TOP 0 CAST(null as nvarchar(128)) MachineName,
				CAST(null as tinyint) ServerRole,
				CAST(null as bit) IsClusterNode,
				CAST(null as nvarchar(1000)) as HostOS,
				CAST(null as nvarchar(128)) Metadata_Servername,
				CAST(null as int) Metadata_TRH_ID,
				CAST(null as int) Metadata_ClientID,
				CAST(null as nvarchar(512)) AS Metadata_DomainName
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLHostingServers]    Script Date: 6/8/2020 1:16:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLHostingServers] on [Tests].[VW_TST_SQLHostingServers]
instead of insert
as
	set nocount on
	declare @MOB_ID int,
			@TRH_ID int,
			@StartDate datetime2(3),
			@DomainQualifyingName nvarchar(128) = ''
			,@SuffixName	NVARCHAR(128)
			,@MachineName	nvarchar(128)
			,@Metadata_DomainName	nvarchar(512)
			,@CTRID				INT
		

	select top 1 @MOB_ID = TRH_MOB_ID,
				@TRH_ID = TRH_ID,
				@StartDate = TRH_StartDate,
				@MachineName = MachineName,
				@Metadata_DomainName = Metadata_DomainName,
				@SuffixName = Metadata_Servername
				,@CTRID = TRH_CTR_ID
	from inserted
		inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID


			--raiserror('collector ID = %d',16,1,@CTRID)

	if charindex('.', @MachineName) > 0
	    set @DomainQualifyingName = ''
    else
	    set @DomainQualifyingName = isnull('.' + @Metadata_DomainName, '')


	SELECT i.* 
			,case when i.HostOS is null or i.HostOS like '%Win%'
			  	then 2
			  when HostOS like '%Linux%'
			  	then 4
			  when HostOS like '%AIX%'
			  	then 5
			  end AS PLTID
	into #ins
	FROM inserted i
		
	merge Inventory.MonitoredObjects d
		using (
				select 
						Metadata_ClientID
						,-1 EntityID
						,MachineName + @DomainQualifyingName MachineName,
						case when ServerRole > 0 then 1 else 0 end OOS_ID,
						case when DFO_IsWindowsAuthentication = 1
							then DFO_SLG_ID
							else null
						end SLG_ID
						,PLTID
						
				from #ins 				
					inner join Inventory.MonitoredObjects on MOB_ID = @MOB_ID
					LEFT JOIN Management.DefinedObjects ON MOB_Entity_ID = DFO_ID
				) s
			on MOB_PLT_ID = PLTID
				and MOB_Name = MachineName
		when matched and MOB_OOS_ID in (0, 1, 2) and OOS_ID = 1 then update set
						MOB_OOS_ID = OOS_ID
						,MOB_CTR_ID = IIF(MOB_CTR_ID IS NULL,@CTRID,MOB_CTR_ID)
		when not matched then insert (MOB_ClientID, MOB_PLT_ID, MOB_Entity_ID, MOB_Name, MOB_OOS_ID, MOB_SLG_ID, MOB_CTR_ID)
								values(Metadata_ClientID, PLTID, EntityID, MachineName, OOS_ID, SLG_ID, @CTRID);
	
	merge Inventory.OSServers d
		using (select Metadata_ClientID,
									PLTID as PLT_ID,
						MachineName + @DomainQualifyingName MachineName,
						case when ServerRole = 2 then 1 else 0 end IsVirtualServer,
						IsClusterNode
						,MOB_ID AS MOBID
				from #ins
				
				LEFT JOIN Inventory.MonitoredObjects ON MOB_Name = MachineName + @DomainQualifyingName AND MOB_PLT_ID = PLTID
				
			) s
					on	PLT_ID = OSS_PLT_ID
						and MachineName = OSS_Name
				when matched then update set
						--OSS_IsVirtualServer = IsVirtualServer,
						OSS_IsClusterNode = IsClusterNode
						
				when not matched then insert(OSS_ClientID, OSS_PLT_ID, OSS_Name, OSS_IsVirtualServer, OSS_IsClusterNode, OSS_MOB_ID)
										values(Metadata_ClientID, PLT_ID, MachineName, IsVirtualServer, IsClusterNode, MOBID);
	
	;with ParentChild as
			(select s.MOB_ClientID ClientID, s.MOB_ID Parent_MOB_ID, case when ServerRole > 0 then 1 else 0 end IsCurrentParent
				from #ins				
					inner join Inventory.MonitoredObjects d on d.MOB_ID = @MOB_ID
					inner join Inventory.MonitoredObjects s on s.MOB_PLT_ID = PLTID					
															and s.MOB_Name = MachineName + @DomainQualifyingName
				where d.MOB_ID = @MOB_ID)
	merge Inventory.ParentChildRelationships
		using ParentChild
			on PCR_Parent_MOB_ID = Parent_MOB_ID
				and PCR_Child_MOB_ID = @MOB_ID
		when matched then update set
						PCR_IsCurrentParent = IsCurrentParent,
						PCR_LastSeenDate = sysdatetime(),
						PCR_Last_TRH_ID = @TRH_ID
		when not matched then insert(PCR_ClientID, PCR_Parent_MOB_ID, PCR_Child_MOB_ID, PCR_IsCurrentParent, PCR_InsertDate, PCR_LastSeenDate, PCR_Last_TRH_ID)
								values(ClientID, Parent_MOB_ID, @MOB_ID, IsCurrentParent, sysdatetime(), sysdatetime(), @TRH_ID);

	update Inventory.DatabaseInstanceDetails
	set DID_OSS_ID = OSS_ID
	from Inventory.DatabaseInstanceDetails
		cross apply (select top 1 OSS_ID
						from #ins						
							inner join Inventory.OSServers on OSS_Name = MachineName + @DomainQualifyingName
															and OSS_PLT_ID = PLTID															
						where ((DID_IsClustered = 0 or DID_IsClustered is null)
									and ServerRole = 1)
								or ServerRole = 2
						order by ServerRole desc) s
		inner join Inventory.MonitoredObjects on MOB_Entity_ID = DID_DFO_ID
	where MOB_ID = @MOB_ID


	--********************************************************************************************
	DECLARE @SYS_ID INT

	SELECT @SYS_ID = SHS_SYS_ID FROm Inventory.SystemHosts WHERE SHS_MOB_ID = @MOB_ID

	INSERT INTO Inventory.SystemHosts(SHS_SYS_ID,SHS_MOB_ID,SHS_ShortName)
	SELECT 
			@SYS_ID
			,MOB_ID
			,MOB_Name
	from	#ins	
	inner join Inventory.MonitoredObjects s on s.MOB_PLT_ID = PLTID	
											and s.MOB_Name = MachineName + @DomainQualifyingName
	WHERE NOT EXISTS (SELECT * FROM Inventory.SystemHosts where SHS_MOB_ID = MOB_ID)
GO
