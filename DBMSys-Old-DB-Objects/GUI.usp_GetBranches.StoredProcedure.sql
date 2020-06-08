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
/****** Object:  StoredProcedure [GUI].[usp_GetBranches]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_GetBranches]
	@TreeType tinyint,
	@ParentCode varchar(50) = null
as
set transaction isolation level read uncommitted
set nocount on

select GIO_Code Code, ISNULL(TRT_AlternativeDisplayName, GIO_DisplayName) DisplayName,
	ISNULL(TRT_AlternativeIconLink, GIO_IconLink) IconLink, GIO_ProcedureName ProcedureName,
	GIO_AllowSearch AllowSearch,
	(select DisplayName, ProcedureName
		from (select ISNULL(t1.TRT_AlternativeDisplayName, i1.GIO_DisplayName) DisplayName,
					ISNULL(t1.TRT_AlternativeIconLink, i1.GIO_IconLink) IconLink,
					i1.GIO_ProcedureName ProcedureName
				from GUI.TreeStructure t1
					inner join GUI.GUIObjects i1 on t1.TRT_GIO_Code = i1.GIO_Code
				where t1.TRT_TTY_ID = @TreeType
					and t1.TRT_IsVisible = 1
					and t1.TRT_OAT_ID = 2
					and t1.TRT_Parent_GIO_Code = t.TRT_GIO_Code
				) SubTables
		order by DisplayName
		for xml auto, root('SubTables'), type) SubTables
from GUI.TreeStructure t
	inner join GUI.GUIObjects i on TRT_GIO_Code = GIO_Code
where t.TRT_TTY_ID = @TreeType
	and TRT_IsVisible = 1
	and TRT_OAT_ID = 1
	and (TRT_Parent_GIO_Code = @ParentCode
			or (TRT_Parent_GIO_Code is null
					and @ParentCode is null)
		)
order by DisplayName
GO
