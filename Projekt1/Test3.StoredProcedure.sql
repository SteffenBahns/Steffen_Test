
into Demokunde_staging.dbo.ArtikelPreis 
from #tmp02 

-- LS 20110018 add prize range
update Demokunde_Staging.dbo.ArtikelPreis
set UVK_RANGE = 
case 
	--when UVK_MOS ''Preislage 0000'' as PH_02, 1 as orderID union
	when UVK_MOS <   30 								  then ''Preislage 0003: bis 29,99 UVK'' 
	when UVK_MOS >=  30 and UVK_MOS <  40 then ''Preislage 0304: ab 30,00 UVK''
	when UVK_MOS >=  40 and UVK_MOS <  50 then ''Preislage 0405: ab 40,00 UVK''
	when UVK_MOS >=  50 and UVK_MOS <  60 then ''Preislage 0506: ab 50,00 UVK''
	when UVK_MOS >=  60 and UVK_MOS <  70 then ''Preislage 0607: ab 60,00 UVK''
	when UVK_MOS >=  70 and UVK_MOS <  80 then ''Preislage 0708: ab 70,00 UVK''
	when UVK_MOS >=  80 and UVK_MOS <  90 then ''Preislage 0809: ab 80,00 UVK''
	when UVK_MOS >=  90 and UVK_MOS < 100 then ''Preislage 0910: ab 90,00 UVK''
	when UVK_MOS >= 100 and UVK_MOS < 120 then ''Preislage 1012: ab 100,00 UVK''
	when UVK_MOS >= 120 and UVK_MOS < 140 then ''Preislage 1214: ab 120,00 UVK''
	when UVK_MOS >= 140 and UVK_MOS < 170 then ''Preislage 1417: ab 140,00 UVK''
	when UVK_MOS >= 170 and UVK_MOS < 200 then ''Preislage 1720: ab 170,00 UVK''
	when UVK_MOS >= 200 and UVK_MOS < 300 then ''Preislage 2030: ab 200,00 UVK''
	when UVK_MOS >= 300										then ''Preislage 30XX: ab 300 UVK''
 else ''undefiniert''	end

-- L.S. 20111220: add price-cluster for purchase price
select 
	 a.[Artikel-Num]
	,max(a.[Waren-Grp]) as WarenGrp
	,max(a.[Waren-UGrp]) as WarenUGrp
into #tmp
from
	Demokunde_Staging.dbo.srcArtikel a
group by
	 a.[Artikel-Num]

select 
	 ap.[Artikel-Num] as ArtN