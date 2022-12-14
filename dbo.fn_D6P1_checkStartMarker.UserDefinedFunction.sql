USE [AOC2022]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_D6P1_checkStartMarker]    Script Date: 06/12/2022 11:06:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_D6P1_checkStartMarker] (@input nvarchar(4)) returns bit as
begin

	declare @output bit;
	set @output = 0;

	declare @char_1 int = ascii(substring(@input,1,1));
	declare @char_2 int = ascii(substring(@input,2,1));
	declare @char_3 int = ascii(substring(@input,3,1));
	declare @char_4 int = ascii(substring(@input,4,1));

	if (@char_1 not in (@char_2, @char_3, @char_4)
		and @char_2 not in (@char_1, @char_3, @char_4)
		and @char_3 not in (@char_2, @char_1, @char_4)
		and @char_4 not in (@char_2, @char_3, @char_1))
	begin
		set @output = 1;
	end

	return @output;

end
GO
