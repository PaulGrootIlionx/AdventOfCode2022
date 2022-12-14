USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[sp_D13P1_comparePairs]    Script Date: 13/12/2022 23:33:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_D13P1_comparePairs] (@pairLeft nvarchar(255), @leftType nvarchar(10), @pairRight nvarchar(255), @rightType nvarchar(10), @level int) as
begin

	set nocount on;

	--print concat('sp_D13P1_comparePairs lVal: ',@pairLeft,', lType: ',@leftType,', rVal: ',@pairRight,', rType: ',@rightType,', level: ',@level)

	declare @output int = null;

	declare @indent nvarchar(255);
	declare @indentLevel int;

	declare @return_value int;

	set @indentLevel = @level;
	set @indent = dbo.fn_D13_P1_getIndent(@indentLevel);

	declare @subLevel int;
	set @subLevel = @level + 1;

	print concat(@indent,'- Compare ',@pairLeft,' vs ',@pairRight);

	--both sides are JSON
	if (@leftType = 'JSON' and @rightType = 'JSON')
	begin
		--Create tables from JSON
		create table #left (rowKey int, rowValue nvarchar(255), rowType nvarchar(10));
		create table #right (rowKey int, rowValue nvarchar(255), rowType nvarchar(10));

		--lege json afvangen
		if (@pairLeft <> '[]')
		begin
			insert into #left
			select [key] as [rowKey],
			   [value] as [rowValue],
			   case [type]
				  when 2 then 'INT'
				  when 4 then 'JSON'
			   end as [rowType]
			from openjson (@pairLeft);
		end;
		else
		begin
			insert into #left values (0, null, 'INT');
		end
	
		--Lege json afvangen
		if (@pairRight <> '[]')
		begin
			insert into #right
			select [key] as [rowKey],
				   [value] as [rowValue],
				   case [type]
					  when 2 then 'INT'
					  when 4 then 'JSON'
				   end as [rowType]
			from openjson (@pairRight);
		end;
		else
		begin
			insert into #right values (0, null, 'INT');
		end;

		declare @maxLeftKey int;
		declare @maxRightKey int;
		declare @maxKey int;

		select @maxLeftKey = max(rowKey) from #left;
		select @maxRightKey = max(rowKey) from #right;

		if (@maxLeftKey >= @maxRightKey) set @maxKey = @maxLeftKey;
		else set @maxKey = @maxRightKey;

		declare @leftKey int = 0;
		declare @rightKey int;

		declare @leftValue nvarchar(255);
		declare @rightValue nvarchar(255);
		declare @rowLeftType nvarchar(10);
		declare @rowRightType nvarchar(10);

		while (@leftKey <= @maxKey)
		begin
			if ((select count(*) from #left where rowKey = @leftKey) > 0) select @leftValue = rowValue, @rowLeftType = rowType from #left where rowKey = @leftKey;
			else
			begin
				set @leftValue = null;
				set @leftType = null;
			end;
			if ((select count(*) from #right where rowKey = @leftKey) > 0) select @rightKey = rowKey, @rightValue = rowValue, @rowRightType = rowType from #right where rowKey = @leftKey;
			else
			begin
				set @rightKey = null;
				set @rightValue = null;
				set @rightType = null;
			end;

			--Right side has run empty
			if (@rightValue is null and @leftValue is not null)
			begin
				print concat(@indent,'  - Right side ran out of items, so inputs are not in the right order');
				set @output = 2;
				set @leftKey = @maxKey + 1;
			end;
			--Left side has run empty
			if (@leftValue is null and @rightValue is not null)
			begin
				print concat(@indent,'  - Left side ran out of items, so inputs are in the right order');
				set @output = 1;
				set @leftKey = @maxKey + 1;
			end;
			--Right and left is not empty
			if (@leftValue is not null and @rightValue is not null)
			begin			
				exec @return_value = dbo.sp_D13P1_comparePairs @leftValue, @rowLeftType, @rightValue, @rowRightType, @subLevel;
				if (@return_value > 0)
				begin
					set @output = @return_value;
					set @leftKey = @maxKey + 1;
				end;
			end;
			--Left and right are both empty, so continue

			set @leftKey = @leftKey + 1;
		end;

		--left ran out of items
		if (isnull(@output,0) = 0 and @maxLeftKey < @maxRightKey)
		begin
			print concat(@indent,'  - Left side ran out of items, so inputs are in the right order')
			set @output = 1;
		end;

		drop table #left;
		drop table #right;

	end
	--both sides are INT
	if (@leftType = 'INT' and @rightType = 'INT')
	begin
		--Left is smaller than right
		if (cast(@pairLeft as int) < cast(@pairRight as int))
		begin
			print concat(@indent,'  - Left side is smaller, so inputs are in the right order')
			set @output = 1;
		end;
		--Right is smaller than left
		if (cast(@pairRight as int) < cast(@pairLeft as int))
		begin
			print concat(@indent,'  - Right side is smaller, so inputs are not in the right order')
			set @output = 2;
		end;
	end;
	--left is JSON, right is INT
	if (@leftType = 'JSON' and @rightType = 'INT')
	begin
		--Make right side also JSON
		print concat(@indent,'    - Mixed types; convert right to [',@pairRight,'] and retry comparison');
		set @rightValue = concat('[',@pairRight,']');
		set @subLevel = @subLevel + 1;
		exec @return_value = dbo.sp_D13P1_comparePairs @pairLeft, N'JSON', @rightValue, N'JSON', @subLevel;
		if (@return_value > 0)
		begin
			set @output = @return_value;
		end;
	end;
	--left is INT, right is JSON
	if (@leftType = 'INT' and @rightType = 'JSON')
	begin
		--Make right side also JSON
		print concat(@indent,'    - Mixed types; convert left to [',@pairLeft,'] and retry comparison');
		set @leftValue = concat('[',@pairLeft,']');
		set @subLevel = @subLevel + 1;
		exec @return_value = dbo.sp_D13P1_comparePairs @leftValue, N'JSON', @pairRight, N'JSON', @subLevel;
		if (@return_value > 0)
		begin
			set @output = @return_value;
		end;
	end;

	if (@output is null and @level = 1)
	begin
		print concat(@indent,'- Left side ran out of items, so inputs are in the right order');
		set @output = 1;
	end

	return isnull(@output,0);

end;
GO
