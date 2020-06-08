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
/****** Object:  UserDefinedFunction [ResponseProcessing].[fn_ConvertBlackboxesToHTML]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [ResponseProcessing].[fn_ConvertBlackboxesToHTML](@Blackboxes xml) returns nvarchar(max)
as
begin
	return (replace(replace(replace(replace(
					(select '<FONT color=Blue size=3>'
								+ isnull(i.value('Header[1]', 'varchar(1000)') + '. ', '')
								+ isnull('Snapshot Date: ' + convert(char(19), i.value('SnapshotDate[1]', 'datetime'), 121), '')
								+ '</FONT>'
								+ isnull('<TABLE BORDER=1>'
											+ (select '<FONT color=Blue>' + c.value('@Name', 'varchar(1000)') + '</FONT>' td
												from i.nodes('Table/ColumnNames/Column') t1(c)
												order by c.value('@Ordinal', 'int')
												for xml path(''), root('tr'))
											+ (select (select isnull(c.value('@Value', 'varchar(1000)'), '') td
														from r.nodes('Column') t2(c)
														order by c.value('@Ordinal', 'int')
														for xml path(''))
												from i.nodes('Table/Rows/Row') t1(r)
												for xml path('tr'))						
											+ '</TABLE>'
										, '') + '<BR>'
						from @Blackboxes.nodes('Blackboxes/Blackbox/Info') t(i)
						for xml path(''))
					, '&amp;', '&'), '&gt;', '>'), '&lt;', '<'), '&#x0D;', char(13)))
end
GO
