USE [AOC2022]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_D4P1_getSections]    Script Date: 04/12/2022 14:44:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_D4P1_getSections] (@input nvarchar(20)) returns nvarchar(1000) as
begin

	declare @output nvarchar(1000);
	set @output = '';

	declare @start int;
	declare @end int;

	declare @startBit bit = 0;
	declare @endBit bit = 0;

	set @start = left(@input,charindex('-',@input)-1);
	set @end = substring(@input,charindex('-',@input)+1,3);

	declare @i int = 0;

	while (@i <= 99)
	begin
		if (@i = @start) set @startBit = 1;
		if (@i = @end) set @startBit = 0;

		if (@startBit = 1)
		begin
			set @output = concat(@output,right(concat('00',@i),2),',');
		end
		if (@i = @end)
		begin
			set @output = concat(@output,right(concat('00',@i),2));
		end
		
		set @i = @i + 1;
	end

	return @output;

end
GO
