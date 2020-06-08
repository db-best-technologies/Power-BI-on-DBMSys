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
/****** Object:  StoredProcedure [ManagementInterface].[usp_Logins_Display]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ManagementInterface].[usp_Logins_Display]
	@Description varchar(1000) = null,
	@Login nvarchar(255) = null
as
select SLG_ID ID, SLG_Description [Description], SLG_Login [Login], SLG_IsDefault IsDefault
from SYL.SqlLogins
where (SLG_Description like '%' + @Description + '%'
		or @Description is null)
	and SLG_Login like '%' + isnull(@Login, '%') + '%'
order by [Description], [Login]
GO
