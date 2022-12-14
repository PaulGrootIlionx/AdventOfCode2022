USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_2_SCRIPT_PART_1]    Script Date: 04/12/2022 14:44:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_2_SCRIPT_PART_1] as
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
		set @player = right(@value,1);

		--Get descriptions
		set @opponentDescription = dbo.fn_GetRPSDescription(@opponent);
		set @playerDescription = dbo.fn_GetRPSDescription(@player);

		--Score rock = 1
		if @player = 'X' begin set @scoreShape = 1; end;
		--Score paper = 2
		if @player = 'Y' begin set @scoreShape = 2; end;
		--Score scissors = 3
		if @player = 'Z' begin set @scoreShape = 3; end;

		--Score = draw = 3
		if (@opponentDescription = @playerDescription)
		begin
			set @scoreOutcome = 3;
		end;
		else
		begin
			-- Win: paper beats rock = 6
			if (@player = 'Y' and @opponent = 'A') begin set @scoreOutcome = 6; end;
			-- Win: scissors beats paper = 6
			if (@player = 'Z' and @opponent = 'B') begin set @scoreOutcome = 6; end;
			-- Win: rock beats scissors = 6
			if (@player = 'X' and @opponent = 'C') begin set @scoreOutcome = 6; end;
			-- Loss: paper beats rock = 0
			if (@player = 'X' and @opponent = 'B') begin set @scoreOutcome = 0; end;
			-- Loss: scissors beats paper = 0
			if (@player = 'Y' and @opponent = 'C') begin set @scoreOutcome = 0; end;
			-- Loss: rock beats scissors = 0
			if (@player = 'Z' and @opponent = 'A') begin set @scoreOutcome = 0; end;
		end

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
