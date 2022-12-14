USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_13_SCRIPT_PART_1]    Script Date: 13/12/2022 23:33:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_13_SCRIPT_PART_1] as
begin

	set nocount on;

	--First save pairs to table
	create table #pairs (
		PairID int identity primary key
		,ValueLeft nvarchar(255)
		,ValueRight nvarchar(255)
		,RightOrder bit not null default 0
	);

	declare @valueLeft nvarchar(255);
	declare @valueRight nvarchar(255);
	declare @value nvarchar(255);
	declare @pairID int;
	declare @indent nvarchar(255);
	declare @level int;
	declare @compareLeft nvarchar(255);
	declare @compareRight nvarchar(255);

	declare input_cur cursor for
	select
		InputValue
	from DAY_13_INPUT
	order by
		AutoID;

	open input_cur;

	fetch next from input_cur into @value;

	while @@FETCH_STATUS = 0
	begin
		--if @value is empty, then save to db.
		if (@value = '')
		begin
			insert into #pairs (ValueLeft, ValueRight) values (@valueLeft, @valueRight);
			--reset values
			set @valueLeft = null;
			set @valueRight = null;
		end;
		else
		begin
			--left is empty, set left
			if (@valueLeft is null) set @valueLeft = @value;
			else set @valueRight = @value;
		end;

		fetch next from input_cur into @value;
	end;

	close input_cur;
	deallocate input_cur;

	--Check pairs
	declare pair_cur cursor for
	select PairID, ValueLeft, ValueRight from #pairs;

	open pair_cur;

	fetch next from pair_cur into @pairID, @valueLeft, @valueRight;

	while @@FETCH_STATUS = 0
	begin
		print concat('== Pair ',@pairID,' ==');

		declare @return_value int;
		exec @return_value = dbo.sp_D13P1_comparePairs @valueLeft, N'JSON', @valueRight, N'JSON', 1;

		if (@return_value = 1) update #pairs set RightOrder = 1 where PairID = @pairID;

		print '';

		fetch next from pair_cur into @pairID, @valueLeft, @valueRight;
	end;

	close pair_cur;
	deallocate pair_cur;

	select sum(PairID) from #pairs where RightOrder = 1;

	drop table #pairs;

end;
GO
