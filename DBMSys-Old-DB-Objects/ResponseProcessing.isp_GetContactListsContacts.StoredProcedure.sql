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
/****** Object:  StoredProcedure [ResponseProcessing].[isp_GetContactListsContacts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ResponseProcessing].[isp_GetContactListsContacts]
AS
	SELECT   CON_ID
			,CON_Name
			,CON_EmaillAddress
			,CON_PhoneNumber
			,CON_IsActive
	FROM ResponseProcessing.Contacts
	ORDER BY CON_Name ASC

	SELECT	 CLS_ID
			,CLS_Name
	FROM ResponseProcessing.ContactLists
	ORDER BY CLS_Name ASC

	SELECT	 --CLC_ID
			--,
			CLC_CON_ID
			,CLC_CLS_ID
	FROM ResponseProcessing.ContactLists_Contacts
	ORDER BY CLC_CLS_ID ASC
GO
