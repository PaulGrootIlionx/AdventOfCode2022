USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_2_SCRIPT_PART_2]    Script Date: 04/12/2022 14:44:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_2_SCRIPT_PART_2] as
begin;
	create table #rounds (
		RoundNumber int identity primary key
		,OpponentPlaysCode nvarchar(1)
		,OpponentPlaysDescription nvarchar(10)
		,PlayerPlaysCode nvarchar(1)
		,PlayerPlaysDescription nvarchar(10)
		,ScoreShape int
		,ScoreOutcome int
		,TotalScore int
	)

	declare @value nvarchar(10);
	declare @opponent nvarchar(1);
	declare @opponentDescription nvarchar(10);
	declare @player nvarchar(1);
	declare @outcome nvarchar(1);
	declare @playerDescription nvarchar(10);
	declare @scoreShape int;
	declare @scoreOutcome int;

	declare cur cursor for
	select
		InputValue
	from DAY_2_INPUT;

	open cur;

	fetch next from cur into @value;

	while @@FETCH_STATUS = 0
	begin
		set @opponent = left(@value,1);
		set @outcome = right(@value,1);

		--Get descriptions
		set @opponentDescription = dbo.fn_GetRPSDescription(@opponent);

		--Lose round
		if @outcome = 'X'
		begin
			set @scoreOutcome = 0;
			if (@opponent = 'A') begin set @player = 'C'; end;
			if (@opponent = 'B') begin set @player = 'A'; end;
			if (@opponent = 'C') begin set @player = 'B'; end;
		end;
		--Draw
		if @outcome = 'Y'
		begin
			set @scoreOutcome = 3;
			set @player = @opponent;
		end;
		--Win round
		if @outcome = 'Z'
		begin
			set @scoreOutcome = 6;
			if (@opponent = 'A') begin set @player = 'B'; end;
			if (@opponent = 'B') begin set @player = 'C'; end;
			if (@opponent = 'C') begin set @player = 'A'; end;
		end;

		-- Set player description
		set @playerDescription = dbo.fn_GetRPSDescription(@player);

		-- Set shape score
		--Score rock = 1
		if @player = 'A' begin set @scoreShape = 1; end;
		--Score paper = 2
		if @player = 'B' begin set @scoreShape = 2; end;
		--Score scissors = 3
		if @player = 'C' begin set @scoreShape = 3; end;

		insert into #rounds (OpponentPlaysCode, OpponentPlaysDescription, PlayerPlaysCode, PlayerPlaysDescription, ScoreShape, ScoreOutcome, TotalScore)
		values (@opponent, @opponentDescription, @player, @playerDescription, @scoreShape, @scoreOutcome, @scoreShape + @scoreOutcome);

		fetch next from cur into @value;
	end

	close cur;
	deallocate cur;

	select
		sum(TotalScore)
		--distinct OpponentPlaysCode, OpponentPlaysDescription, PlayerPlaysCode, PlayerPlaysDescription, ScoreShape, ScoreOutcome, TotalScore
	from #rounds;

	drop table #rounds;
end
GO
