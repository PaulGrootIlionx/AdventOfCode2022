USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_4_SCRIPT_PART_1]    Script Date: 04/12/2022 14:44:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_4_SCRIPT_PART_1] as
begin;

	set nocount on;

	declare @value nvarchar(100);
	declare @score int = 0;

	create table #temp (
		AutoID int identity
		,InputValue nvarchar(20)
		,Elf1 nvarchar(1000)
		,Elf2 nvarchar(1000)
	);

	declare @elf1 nvarchar(1000);
	declare @elf2 nvarchar(1000);

	declare cur cursor for
	select
		InputValue
	from DAY_4_INPUT;

	open cur;

	fetch next from cur into @value;

	while @@FETCH_STATUS = 0
	begin
		--print @value;

		set @elf1 = dbo.fn_D4P1_getSections(left(@value, charindex(',', @value)-1));
		set @elf2 = dbo.fn_D4P1_getSections(substring(@value, charindex(',', @value)+1, 5));

		insert into #temp (InputValue, Elf1, Elf2)
		values (@value, @elf1, @elf2);

		fetch next from cur into @value;
	end

	close cur;
	deallocate cur;

	select distinct
		@score = count(*)
	from #temp
	where
		Elf1 like concat('%',Elf2,'%')
		or
		Elf2 like concat('%',Elf1,'%');

	drop table #temp;

	print @score;
end
GO
