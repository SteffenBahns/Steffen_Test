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
	
	-- 03.11.2011, A.G.: resolve NULL-problem
	,case when BRUMS_MOS_BD != 0 then BEST_MOS else -1 end as BEST_MOS_BRUMS
	,CASE WHEN BRUMS_MOS_BD !=0 THEN 0 ELSE -1 END AS BEST_MOS_BRUMS_ZERO
	
	-- 01.11.2011, A.G.: resolve NULL-issue
	,case when LUMS_MOS_BD != 0 then BEST_MOS else -1 end as BEST_MOS_LUMS
	,CASE WHEN LUMS_MOS_BD <> 0 THEN 0 ELSE -1 END AS BEST_MOS_LUMS_ZERO
	
	-- 03.11.2011, A.G.: NULL-problem
	,case when NUMS_MOS_BD != 0 then BEST_MOS else -1 end as BEST_MOS_NUMS
	,CASE WHEN NUMS_MOS_BD !=0 THEN 0 ELSE -1 END AS BEST_MOS_NUMS_ZERO
	
	-- 01.11.2011, A.G.: resolve NULL-issue
	,case when RUMS_MOS_BD != 0 then BEST_MOS else -1 end as BEST_MOS_RUMS
	,CASE WHEN RUMS_MOS_BD <> 0 THEN  0 ELSE -1 END AS BEST_MOS_RUMS_ZERO
	
	-- 03.11.2011, A.G.: NULL-problem
	,case when RUMS_GES_MOS_BD != 0 then BEST_MOS ELSE -1 end as BEST_MOS_RUMS_GES
	,CASE WHEN RUMS_GES_MOS_BD <> 0 THEN 0 ELSE -1 END AS BEST_MOS_RUMS_GES_ZERO
	
	,convert(float,0)as BBM_P
	,CONVERT(float,0) as BRUMS_P
	,convert(int,convert(smalldatetime,convert(varchar,fkDimTime))) BD_AS_TIME
	,convert(int,getdate()-convert(smalldatetime,convert(varchar,fkDimTime))) BOT_AS_TIME
	-- 25.10.2011: FORDERAUSWAHL
	,CASE 
		WHEN (w.MahnStatus = 4) OR (w.MahnStatus = 5) THEN w.NUMS_MOS_BD ELSE 0 
	END AS FORDAUSFALL_MOS_BD
	
	-- 26.10.2011: Berechnung von "DB 1"
	,CONVERT(float, 0.0) as [Shipping Cost] -- später ausrechnen, da es pro Auftrag (und nicht pro Position) berechnet werden soll
	,CONVERT(float, (w.BRABS_MOS_BD * @fPickMatCost))  as [Pick Material Cost]
	,CONVERT(float, (RABS_MOS_BD * @fReturnCost)) as [Return Costs Warehouse]
	,CONVERT(float, 0.0) as [Return Shipping]
	,CONVERT(float, 0.0) as [DW License Charge]
	,CONVERT(float, 0.0) as [MOS License Charge]
	-- Mahnstufen
	,CONVERT(float, 0.0) AS [Mahnstufe 1]
	,CONVERT(float, 0.0) AS [Mahnstufe 2]
	,CONVERT(float, 0.0) as [Mahnstufe 3]
	,CONVERT(float, 0.0) as [Mahnstufe 4_5 Mahnkosten]
	-- Zahlungsmethode
	,CONVERT(float, 0.0) as [Zahlungsmethode]
	
	-- 01.11.2011, A.G.: DB1 berechnen
	,CASE
		WHEN (w.MahnStatus = 4) OR (w.MahnStatus = 5) THEN -w.NUMS_MOS_BD 
				
		-- ÄNDERUNG Berechnung DB1_BEST_BD 
		ELSE w.NUMS_MOS_BD -(w.NABS_MOS_BD * isnull(w.EKPreisHist,w.EKPreis))
		-- ##########################
		-- unterer Statement kann nach Validierung gelöscht werden 20120413
		-- ELSE w.NUMS_MOS_BD -(NABS_MOS_BD * w.EKPreis)
		-- ##########################
	Bis hier