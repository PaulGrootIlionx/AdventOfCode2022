USE [AOC2022]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetRPSDescription]    Script Date: 04/12/2022 14:44:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_GetRPSDescription] (@inputValue nvarchar(1)) returns nvarchar(10) as
begin
	declare @output nvarchar(10);
	set @output = case @inputValue
					when 'A' then 'Rock'
					when 'B' then 'Paper'
					when 'C' then 'Scissors'
					when 'X' then 'Rock'
					when 'Y' then 'Paper'
					when 'Z' then 'Scissors'
				end
	return @output;
end
GO
