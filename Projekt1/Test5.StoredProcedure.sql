t''

Apfel
DECLARE @fShippingCost float
SEL
-- Material costs
DECLARE @fPickMatCost float
SELECT @fPickMatCost = [Kostensatz]
FROM MDM.dbo._DB1_KOSTEN
WHERE TE = ''Pick & Materialkosten pro AK''
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
WHERE Cost = ''Return Mailing''
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
WHERE Cost = ''Mahnstufe 2''
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
-- Payment
DECLARE @fZahlMethode float
SELECT SA = [Kostensatz]
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
	,ISnrf
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
		Anpassungen