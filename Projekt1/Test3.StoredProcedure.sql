
into Demokunde_staging.dbo.ArtikelPreis 
from #tmp02 

-- LS 20110018 add prize range
update DAS.dbo.ArtikelPreis
set UVK_RANGE = 
case 
	AB hier gelöscht