USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_8_SCRIPT_PART_1]    Script Date: 08/12/2022 11:21:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_8_SCRIPT_PART_1] as
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

		update #grid set VisibleTop = @visibleTop, VisibleBottom = @visibleBottom, VisibleLeft = @visibleLeft, VisibleRight = @visibleRight where AutoID = @treeID;

		fetch next from grid_cur into @treeID, @x, @y, @height;
	end

	close grid_cur;
	deallocate grid_cur;

	declare @output int;

	select @output = count(*) from #grid where (cast(VisibleTop as int)+cast(VisibleBottom as int)+cast(VisibleLeft as int)+cast(VisibleRight as int)) > 0;

	print @output;

	drop table #grid;
	

end
GO
