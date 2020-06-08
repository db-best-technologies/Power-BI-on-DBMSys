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
/****** Object:  StoredProcedure [GUI].[usp_Add_System]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_Add_System] 
 @SYS_ID	int output,
 @SYS_NAME	nvarchar(255),
 @SYS_Descr	nvarchar(255) = null
 as
 
SET NOCOUNT, XACT_ABORT ON;

declare 


 @msg NVARCHAR(2048)
 declare @t table 
 (
	id int
 )
  
MERGE Inventory.Systems WITH (HOLDLOCK) AS s
USING (SELECT @SYS_NAME AS SYS_NAME, @SYS_Descr as SYSDescription) AS i_s
      ON i_s.SYS_NAME = s.SYS_NAME

WHEN NOT MATCHED THEN
    INSERT
      (
           SYS_NAME
		   ,SYS_Description
      )
	  
    VALUES
      (
            i_s.SYS_NAME
			,i_s.SYSDescription
      )
	  output inserted.SYS_ID into @t(id)
	  ;

select @SYS_ID = id from @t

if isnull(@sys_id,0) = 0
begin
	SET @msg = FORMATMESSAGE(51007,  @SYS_NAME); 
  THROW 51007, @msg, 1; 
  select @SYS_ID = SYS_ID from Inventory.Systems where SYS_NAME = @SYS_NAME
end
GO
