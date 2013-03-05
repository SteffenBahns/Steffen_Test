Kunde 2
into Demokunde_staging.dbo.ArtikelPreis 
from #tmp02 

-- LS 20110018 add prize range
update DAS.dbo.ArtikelPreis
set ads = 
case 
	AB hier gelöscht