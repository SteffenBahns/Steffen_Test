
		(
			select
				null
			from 
				Demokunde_staging.dbo.[srcKunGutschein] kg 
			where 
				kgh.[Auftr-Nr]=kg.[Auftrags-num] 
		)

-- temp res03
select 
	o.[Kunden-Num]
	,max(o.[Auftrags-Num]) as [Auftrags-Num]
into #tmp
from 
	Demokunde_staging.dbo.[srcOrder] o
group by
	o.[Kunden-Num]
having COUNT(*) = 1

select
	t.[Auftrags-Num]
	,kg.[Gutsch-Ident]
	,''one to one'' as src
into #res03
from 
	Demokunde_staging.dbo.[srcKunGutschein] kg
	join #tmp t
		on kg.[Kunden-Num] = t.[Kunden-Num]
where
	kg.[Auftrags-Num] = 0

