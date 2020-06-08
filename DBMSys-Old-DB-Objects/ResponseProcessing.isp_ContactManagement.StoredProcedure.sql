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
/****** Object:  StoredProcedure [ResponseProcessing].[isp_ContactManagement]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ResponseProcessing].[isp_ContactManagement]
@ContactID INT OUTPUT
,@Name VARCHAR(255)
,@Email VARCHAR(255)
,@Phone VARCHAR(255)
,@isActive bit = 0 
,@isDelete bit = 0
AS
	DECLARE @clientID int 
	SELECT @clientID=CAST(SET_Value AS INT)
	FROM   Management.Settings
	WHERE  SET_Key ='Client ID'
	
	 	IF EXISTS (select top 1 1 from ResponseProcessing.Contacts where CON_Name = @Name AND CON_ID <> @ContactID)
		BEGIN
			RAISERROR ('Contact with name %s already exists', 16,3, @Name)
			RETURN
		END

	IF EXISTS (select top 1 1 from ResponseProcessing.Contacts where CON_EmaillAddress = @Email AND CON_ID <> @ContactID)
		BEGIN
			RAISERROR ('Contact with email %s already exists', 16,4, @Email)
			RETURN
		END
	
	IF @isActive IS NULL
		SET @isActive = 0

		 DECLARE  @ids TABLE
		(ID INT NULL)

	IF(@ContactID IS NULL)
		BEGIN
			IF(@Name IS NULL OR @Email IS NULL)
				BEGIN
					RAISERROR ('Name and Email Adress could not be empty', 16,3)
					RETURN
				END


			INSERT INTO ResponseProcessing.Contacts (CON_ClientID, CON_Name, CON_EmaillAddress, CON_PhoneNumber, CON_IsActive)
						output inserted.CON_ID into @ids(ID)
			VALUES ( @clientID
					,@Name
					,@Email
					,@Phone
					,@isActive );
			SELECT TOP 1 @ContactID = ID FROM @ids
		END
		
	ELSE IF(@isDelete = 1)
		BEGIN
			DELETE FROM ResponseProcessing.ContactLists_Contacts
			WHERE CLC_CON_ID = @ContactID

			DELETE FROM ResponseProcessing.Contacts
			WHERE CON_ID = @ContactID

		END

	ELSE 
		BEGIN			
			UPDATE ResponseProcessing.Contacts
			SET 
				 CON_Name =			 ISNULL(@Name,CON_Name)
				,CON_EmaillAddress = ISNULL(@Email, CON_EmaillAddress)
				,CON_PhoneNumber =	 ISNULL(@Phone, CON_PhoneNumber)
				,CON_IsActive =      ISNULL(@isActive, 0)
			WHERE CON_ID = @ContactID
		END
GO
