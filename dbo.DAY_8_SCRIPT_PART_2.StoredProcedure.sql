USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_8_SCRIPT_PART_2]    Script Date: 08/12/2022 11:21:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_8_SCRIPT_PART_2] as
begin

	set nocount on;

	declare @value nvarchar(100);
	declare @x int;
	declare @y int;

	create table #grid (
		AutoID int identity,
		X int,
		Y int,
		TreeHeight int
		,VisibleTop bit
		,VisibleBottom bit
		,VisibleLeft bit
		,VisibleRight bit
		,ScoreTop int
		,ScoreBottom int
		,ScoreLeft int
		,ScoreRight int
		,ScenicScore int
	);

	--Eerst grid samenstellen uit brondata
	declare cur cursor for
	select
		AutoID as y, InputValue
	from DAY_8_INPUT
	order by
		AutoID;

	open cur;

	fetch next from cur into @y, @value;

	while @@FETCH_STATUS = 0
	begin
		set @x = 1;

		while (@x <= len(@value))
		begin
			insert into #grid (X, Y, TreeHeight) values (@x, @y, substring(@value,@x, 1));
			set @x = @x + 1;
		end

		fetch next from cur into @y, @value;
	end

	close cur;
	deallocate cur;

	declare @treeID int;
	declare @height int;
	declare @visibleTop bit;
	declare @visibleBottom bit;
	declare @visibleLeft bit;
	declare @visibleRight bit;
	declare @scoreLeft int;
	declare @scoreRight int;
	declare @scoreTop int;
	declare @scoreBottom int;
	declare @step int;
	declare @maxX int;
	declare @maxY int;
	declare @totalScore int;

	select @maxX = max(X) from #grid;
	select @maxY = max(Y) from #grid;

	--Grid doorlopen
	declare grid_cur cursor for
	select
		AutoID, X, Y, TreeHeight
	from #grid;

	open grid_cur;

	fetch next from grid_cur into @treeID, @x, @y, @height;

	while @@FETCH_STATUS = 0
	begin
		--neem aan dat boom zichtbaar is, tenzij het tegendeel wordt bewezen
		set @visibleTop = 1;
		set @visibleBottom = 1;
		set @visibleLeft = 1;
		set @visibleRight = 1;

		--controleren op hogere bomen (of zelfde hoogte) om de boom heen
		if ((select count(*) from #grid where X = @x and Y < @y and TreeHeight >= @height) > 0) set @visibleTop = 0;
		if ((select count(*) from #grid where X = @x and Y > @y and TreeHeight >= @height) > 0) set @visibleBottom = 0;
		if ((select count(*) from #grid where X < @x and Y = @y and TreeHeight >= @height) > 0) set @visibleLeft = 0;
		if ((select count(*) from #grid where X > @x and Y = @y and TreeHeight >= @height) > 0) set @visibleRight = 0;

		--Scores berekenen
		--Top Score
		set @scoreTop = 0;
		if (@x > 1)
		begin
			set @step = @y - 1;
			while (@step > 0)
			begin
				set @scoreTop = @scoreTop + 1;
				if ((select count(*) from #grid where X = @x and Y = @step and TreeHeight >= @height) > 0) set @step = 0;
				else set @step = @step - 1;
			end;
		end;
		--Bottom Score
		set @scoreBottom = 0;
		if (@y < @maxY)
		begin
			set @step = @y + 1;
			while (@step <= @maxY)
			begin
				set @scoreBottom = @scoreBottom + 1;
				if ((select count(*) from #grid where X = @x and Y = @step and TreeHeight >= @height) > 0) set @step = 100;
				else set @step = @step + 1;
			end;
		end;
		--Left Score
		set @scoreLeft = 0;
		if (@x > 1)
		begin
			set @step = @x - 1;
			while (@step > 0)
			begin
				set @scoreLeft = @scoreLeft + 1;
				if ((select count(*) from #grid where X = @step and Y = @y and TreeHeight >= @height) > 0) set @step = 0;
				else set @step = @step - 1;
			end;
		end;
		--Right Score
		set @scoreRight = 0;
		if (@x < @maxX)
		begin
			set @step = @x + 1;
			while (@step <= @maxX)
			begin
				set @scoreRight = @scoreRight + 1;
				if ((select count(*) from #grid where X = @step and Y = @y and TreeHeight >= @height) > 0) set @step = 100;
				else set @step = @step + 1;
			end;
		end;

		set @totalScore = 0;

		set @totalScore = @scoreTop * @scoreLeft * @scoreBottom * @scoreRight;

		update #grid
		set VisibleTop = @visibleTop,
		    VisibleBottom = @visibleBottom, 
			VisibleLeft = @visibleLeft, 
			VisibleRight = @visibleRight ,
			ScoreTop = @scoreTop,
			ScoreBottom = @scoreBottom,
			ScoreLeft = @scoreLeft,
			ScoreRight = @scoreRight,
			ScenicScore = @totalScore
		where
			AutoID = @treeID;

		fetch next from grid_cur into @treeID, @x, @y, @height;
	end

	close grid_cur;
	deallocate grid_cur;

	declare @output int;

	select @output = max(ScenicScore) from #grid;

	print @output;

	drop table #grid;
	

end
GO
