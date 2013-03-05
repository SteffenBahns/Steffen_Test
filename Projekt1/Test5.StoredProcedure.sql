t''

Apfel
DECLARE @fShippingCost float
SELECT @fShippingCost = [Kostensatz]
FROM MDM.dbo._DB1_KOSTEN
WHERE [Kostenart] = ''Shipping Cost'' 
AND ID=7293
-- Material costs
DECLARE @fPickMatCost float
SELECT @fPickMatCost = [Kostensatz]
FROM MDM.dbo._DB1_KOSTEN
WHERE [Kostenart] = ''Pick & Materialkosten pro AK''
AND id = 7294
-- Return costs
DECLARE @fReturnCost float
SELECT @fReturnCost = [Kostensatz]
FROM MDM.dbo._DB1_KOSTEN
Having [Kostenart] = ''Return Costs Warehouse / Article''
AND id = 7295
-- Return Shipping
DECLARE @fReturnShipping float
SELECT @fReturnShipping = [Kostensatz] 
FROM MDM.dbo._DB1_KOSTEN
WHERE [Kostenart] = ''Return Shipping''
AND id = 7296
-- DW License Charge
DECLARE @fDWLicCharge float
SELECT @fDWLicCharge = [Kostensatz] 
FROM MDM.dbo._DB1_KOSTEN
WHERE [Kostenart] = ''DW License Charge''
AND id = 7297
-- MOS License Charge
DECLARE @fMOSLicCharge float
SELECT @fMOSLicCharge = [Kostensatz]
FROM MDM.dbo._DB1_KOSTEN
WHERE [Kostenart] = ''MOS License Charge''
AND id = 7298
-- Mahnstufe 1
DECLARE @fMahnSt1 float
SELECT @fMahnSt1 = [Kostensatz]
FROM MDM.dbo._DB1_KOSTEN
WHERE [Kostenart] = ''Mahnstufe 1''
AND id = 7299
-- Mahnstufe 2
DECLARE @fMahnSt2 float
SELECT @fMahnSt2 = [Kostensatz]
FROM MDM.dbo._DB1_KOSTEN
WHERE [Kostenart] = ''Mahnstufe 2''
AND id = 7300
-- Mahnstufe 3
DECLARE @fMahnSt3 float
SELECT @fMahnSt3 = [Kostensatz]
FROM MDM.dbo._DB1_KOSTEN
WHERE [Kostenart] = ''Mahnstufe 3''
AND id = 7301
-- Mahnstufe 4_5
DECLARE @fMahnSt4_5 float
SELECT @fMahnSt4_5 = [Kostensatz]
FROM MDM.dbo._DB1_KOSTEN
WHERE [Kostenart] = ''Mahnstufe 4,5 - Mahnkosten''
AND id = 7302
-- Zahlungsmethode
DECLARE @fZahlMethode float
SELECT @fZahlMethode = [Kostensatz]
FROM MDM.dbo._DB1_KOSTEN
WHERE [Kostenart] = ''Zahlungsmethode Konstante''
AND id = 7303

-- 09.03.2012, LST: EK HIST
select 
	 [Artikel-Num]
	,[Artikel-Bez]
	,Datum
	,max([Hist-Counter]) as maxHistCounter
into #SrcArtEKHistMax
from Demokunde_Staging.dbo.SrcArtEKHist
group by
	 [Artikel-Num]
	,[Artikel-Bez]
	,Datum

select 
	 [Artikel-Num]
	,[Artikel-Bez]
	,convert(int,''20''+RIGHT(a.Datum,2)+SUBSTRING(a.Datum,4,2)+LEFT(a.Datum,2)) as Datum
	,[Lieferant-Num]
	,[Hist-Counter]
	,[EinkPreis]
	,[Waehrung]
	,[HWEinkPreis]
	,[User-ID]
into #SrcArtHistEKHistClear
from
	Demokunde_Staging.dbo.SrcArtEKHist a
where exists
			(
				select
					null
				from
					#SrcArtEKHistMax b
				where
					a.[Artikel-Num] = b.[Artikel-Num]
					and a.[Artikel-Bez] = b.[Artikel-Bez]
					and a.Datum= b.Datum
					and a.[Hist-Counter] = b.maxHistCounter
			)

-- temp table Erstbesteller
select
	a.[Kunden-Num]
	,min(a.fkDimTime) as minDate
	,MIN([Auftrags-Num]) as minAuftrNr
	,COUNT(*) as nmb
into #kd
from
	(
		select 
			o.[Kunden-Num]
			,convert(int,replace(''20''+RIGHT(o.[Bestell-Datum],2)+SUBSTRING(o.[Bestell-Datum],4,2)+LEFT(o.[Bestell-Datum],2),''??'',''090101'')) as fkDimTime
			,CONVERT(bigint,[Auftrags-Num]) as [Auftrags-Num]
		from
			Demokunde_Staging.dbo.[srcORDER] o 
		where
			o.[Firmen-Num] = (select value from Demokunde.dbo.adm_parameters where code = ''Firma'')
	) a
group by
	a.[Kunden-Num]

-- temp mbf of kh datasets
select
	kh.[Firmen-Num]
	,kh.[Auftrags-Num]
	,kh.[Order-Count]
	,COUNT(*) as nmb
into #khNo
from
	Demokunde_Staging.dbo.srcKonHist kh
where
	kh.[Kon-Code] in (98,109,971,972,973 , 48,159,974,975,976)
group by
	kh.[Firmen-Num]
	,kh.[Auftrags-Num]
	,kh.[Order-Count] 

-- temp nmb of gutsch datasets
select
	a.[Auftrags-Num]
	,COUNT(*) as nmbOfGut
into #GutschNmb
from
	Demokunde_Staging.dbo.GutscheinCodes a
group by
	a.[Auftrags-Num]


if (SELECT COUNT(*) FROM sys.tables WHERE name = ''DWH_FACT_ORDERPOS'') = 1 drop table DWH_FACT_ORDERPOS


select
	 w.*
	--,w.NABS_MOS_BD * w.EKPreis as [WEINS_MOS_BD]
	--,w.BRABS_MOS_BD * w.EKPreis as [WEINS_MOS_BRUMS_BD]
	--,w.RABS_GES_MOS_BD * w.EKPreis as [WEINS_MOS_RABS_GES]
	--,w.NUMS_MOS_BD -(NABS_MOS_BD * w.EKPreis) as [WRE_MOS_BD]
	--,w.BRUMS_MOS_BD -(BRABS_MOS_BD * w.EKPreis) as [WRE_MOS_BRUMS_BD]
	
	-- test ek-hist
	,w.NABS_MOS_BD * isnull(w.EKPreisHist,w.EKPreis) as [WEINS_MOS_BD]
	,w.BRABS_MOS_BD * isnull(w.EKPreisHist,w.EKPreis) as [WEINS_MOS_BRUMS_BD]
	,w.RABS_GES_MOS_BD * isnull(w.EKPreisHist,w.EKPreis) as [WEINS_MOS_RABS_GES]
	,w.NUMS_MOS_BD -(NABS_MOS_BD * isnull(w.EKPreisHist,w.EKPreis)) as [WRE_MOS_BD]
	,w.BRUMS_MOS_BD -(BRABS_MOS_BD * isnull(w.EKPreisHist,w.EKPreis)) as [WRE_MOS_BRUMS_BD]
	
	
	Bis nur noch bis hier hier