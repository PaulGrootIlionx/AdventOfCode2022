USE [AOC2022]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_D13_P1_getIndent]    Script Date: 13/12/2022 23:33:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_D13_P1_getIndent] (@level int) returns nvarchar(255) as
begin

	declare @indent nvarchar(255);
	declare @i int = 1;

	while (@i < @level)
	begin
		set @indent = concat(@indent,'  ');
		set @i = @i + 1;
	end;

	return @indent;

end
GO
