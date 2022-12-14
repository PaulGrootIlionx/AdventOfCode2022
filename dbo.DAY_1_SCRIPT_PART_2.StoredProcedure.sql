USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_1_SCRIPT_PART_2]    Script Date: 04/12/2022 14:44:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_1_SCRIPT_PART_2] as
begin
	create table #Elves (
		[AutoID] int identity primary key
		,[Name] nvarchar(10)
	);

	create table #Contents (
		AutoID int identity primary key
		,[ElfID] int
		,[Calories] int
		,foreign key (ElfID) References #Elves(AutoID)
	);

	insert into #Elves ([Name]) values ('Elf #1');

	declare @calories nvarchar(10);
	declare @elfID int;

	select @elfID = max(AutoID) from #Elves;

	declare cur cursor for
	select
		InputValue
	from DAY_1_INPUT;

	open cur;

	fetch next from cur into @calories;

	while @@FETCH_STATUS = 0
	begin
		-- Lege regel, nieuwe elf
		if (@calories = '')
		begin
			insert into #Elves ([Name]) values (concat('Elf #',@elfID + 1));
			select @elfID = max(AutoID) from #Elves;
		end
		--Geen lege regel... aantal calorieën opslaan
		else
		begin
			insert into #Contents (ElfID, Calories) values (@elfID, @calories);
		end
		fetch next from cur into @calories;
	end

	close cur;
	deallocate cur;

	select
		sum(Calories_Total) Top3_Total_Calories
	from
		(select top 3
			ElfID, sum(Calories) Calories_Total
		from #Contents
		group by
			ElfID
		order by
			Calories_Total desc) qry;

	drop table #Elves;
	drop table #Contents;
end
GO
