USE [AOC2022]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_D6P2_checkStartMessage]    Script Date: 06/12/2022 11:06:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_D6P2_checkStartMessage] (@input nvarchar(14)) returns bit as
begin

	declare @output bit;
	set @output = 0;

	declare @char_1 int = ascii(substring(@input,1,1));
	declare @char_2 int = ascii(substring(@input,2,1));
	declare @char_3 int = ascii(substring(@input,3,1));
	declare @char_4 int = ascii(substring(@input,4,1));
	declare @char_5 int = ascii(substring(@input,5,1));
	declare @char_6 int = ascii(substring(@input,6,1));
	declare @char_7 int = ascii(substring(@input,7,1));
	declare @char_8 int = ascii(substring(@input,8,1));
	declare @char_9 int = ascii(substring(@input,9,1));
	declare @char_10 int = ascii(substring(@input,10,1));
	declare @char_11 int = ascii(substring(@input,11,1));
	declare @char_12 int = ascii(substring(@input,12,1));
	declare @char_13 int = ascii(substring(@input,13,1));
	declare @char_14 int = ascii(substring(@input,14,1));

	if (@char_1 not in (@char_2, @char_3, @char_4, @char_5, @char_6, @char_7, @char_8, @char_9, @char_10, @char_11, @char_12, @char_13, @char_14)
		and @char_2 not in (@char_1, @char_3, @char_4, @char_5, @char_6, @char_7, @char_8, @char_9, @char_10, @char_11, @char_12, @char_13, @char_14)
		and @char_3 not in (@char_2, @char_1, @char_4, @char_5, @char_6, @char_7, @char_8, @char_9, @char_10, @char_11, @char_12, @char_13, @char_14)
		and @char_4 not in (@char_2, @char_3, @char_1, @char_5, @char_6, @char_7, @char_8, @char_9, @char_10, @char_11, @char_12, @char_13, @char_14)
		and @char_5 not in (@char_2, @char_3, @char_4, @char_1, @char_6, @char_7, @char_8, @char_9, @char_10, @char_11, @char_12, @char_13, @char_14)
		and @char_6 not in (@char_2, @char_3, @char_4, @char_5, @char_1, @char_7, @char_8, @char_9, @char_10, @char_11, @char_12, @char_13, @char_14)
		and @char_7 not in (@char_2, @char_3, @char_4, @char_5, @char_6, @char_1, @char_8, @char_9, @char_10, @char_11, @char_12, @char_13, @char_14)
		and @char_8 not in (@char_2, @char_3, @char_4, @char_5, @char_6, @char_7, @char_1, @char_9, @char_10, @char_11, @char_12, @char_13, @char_14)
		and @char_9 not in (@char_2, @char_3, @char_4, @char_5, @char_6, @char_7, @char_8, @char_1, @char_10, @char_11, @char_12, @char_13, @char_14)
		and @char_10 not in (@char_2, @char_3, @char_4, @char_5, @char_6, @char_7, @char_8, @char_9, @char_1, @char_11, @char_12, @char_13, @char_14)
		and @char_11 not in (@char_2, @char_3, @char_4, @char_5, @char_6, @char_7, @char_8, @char_9, @char_10, @char_1, @char_12, @char_13, @char_14)
		and @char_12 not in (@char_2, @char_3, @char_4, @char_5, @char_6, @char_7, @char_8, @char_9, @char_10, @char_11, @char_1, @char_13, @char_14)
		and @char_13 not in (@char_2, @char_3, @char_4, @char_5, @char_6, @char_7, @char_8, @char_9, @char_10, @char_11, @char_12, @char_1, @char_14)
		and @char_14 not in (@char_2, @char_3, @char_4, @char_5, @char_6, @char_7, @char_8, @char_9, @char_10, @char_11, @char_12, @char_13, @char_1))
	begin
		set @output = 1;
	end

	return @output;

end
GO
