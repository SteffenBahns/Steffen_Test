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
WHERE [Kostenart] = ''Return Costs Warehouse / Article''
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
	END AS [DB1_BEST_BD]
	
	-- 24.11.2011, A.G.: new measure [BRABS_MOS_BD-31] and [RABS_GES_MOS_BD-31]
	,CASE
		WHEN DATEDIFF(DAY, CONVERT(datetime, CONVERT(varchar(20), w.fkDimTime)), getdate()) >=31
		THEN w.[BRABS_MOS_BD]
		ELSE 0
	END as [BRABS_MOS_BD-31]
	,CASE
		WHEN DATEDIFF(DAY, CONVERT(datetime, CONVERT(varchar(20), w.fkDimTime)), getdate()) >=31
		THEN w.[RABS_GES_MOS_BD]
		ELSE 0
	END as [RABS_GES_MOS_BD-31]
	-- 01.12.2011, A.G.:  new measure [BRABS_MOS_BD 30]
	,CASE
		WHEN DATEDIFF(DAY, CONVERT(datetime, CONVERT(varchar(20), w.fkDimTime)), getdate()) < 31
		THEN w.[BRABS_MOS_BD]
		ELSE 0
	END as [BRABS_MOS_BD 30]
	,CASE
		WHEN DATEDIFF(DAY, CONVERT(datetime, CONVERT(varchar(20), w.fkDimTime)), getdate()) < 31
		THEN w.[RABS_GES_MOS_BD]
		ELSE 0
	END as [RABS_GES_MOS_BD 30]
	
	-- 06.01.2012, LST: BUG Abschrift
	,case when BRUMS_MOS_BD != 0 then ABS_VK_MOS_BBW else 0 end as ABS_VK_MOS_BRUMS
	,case when NUMS_MOS_BD != 0 then ABS_VK_MOS_BBW else 0 end as ABS_VK_MOS_NUMS
	,case when RUMS_GES_MOS_BD != 0 then ABS_VK_MOS_BBW else 0 end as ABS_VK_MOS_RUMS_GES
	
	-- 12.02.2012, LST: resolve NULL-issue Retouren
	
	,case when w.RET_MOS <> 0 then 0 else -1 end as RET_MOS_ZERO
	,case when w.RET_VOLL <> 0 then 0 else -1 end as RET_VOLL_ZERO
	,case when w.RET_TEIL <> 0 then 0 else -1 end as RET_TEIL_ZERO

			
into DWH_FACT_ORDERPOS
from
	(
	select
		r.fkDimArtikel
		,isnull(r.fkDimGutschein,4) as fkDimGutschein
		,r.fkDimKunde
		,case when kd.nmb is not null then 4 else 5 end as fkDimKundeCluster
		,3 as fkDimLager
		,4 as fkDimLieferant
		-- 24.08.2011, LiefBest
		,@iDummyLiefBestID as fk_liefbest_id
		,r.fkDimOrder
		,r.fkDimPreis
		,r.fkDimRetoure
		,r.fkDimStatus
		,r.fkDimTime
		,r.fkDimTimeFD
		,r.fkDimTimeRD
		,r.fkDimTimeSD
		,r.fkDimZahlart
		,r.fkDimSKNZ
		,r.EKPreis
		
		-- 09.03.2012, LST: EK HIST
		,(select convert(float,replace(hc.EinkPreis,'','',''.'')) from #SrcArtHistEKHistClear hc
		  where hc.[Artikel-Num] = r.[Artikel-Num] 
				and hc.[Artikel-Bez] = r.[Artikel-Bez]
				and hc.Datum = isnull(r.EKPreisHistDat,r.EKPreisHistFirst)
		 ) as EKPreisHist
		,EKPreisHistDat
		,EKPreisHistFirst
		 
		,r.Abschrift as ABS_VK_MOS_BBW
		,r.[BBM_MOS_BD] * r.[VK_ERZ_MOS] as [BBW_MOS_BD]
		,r.[BBM_MOS_BD] * r.[VK_ERZ_MOS_MWST] as [BBW_MOS_BD_MWST]
		,r.[BBM_MOS_BD]
		,(r.[BBM_MOS_BD] - r.[MenStorniert]) * r.[VK_ERZ_MOS] as [BRUMS_MOS_BD]
		,(r.[BBM_MOS_BD] - r.[MenStorniert]) * r.[VK_ERZ_MOS_MWST] as [BRUMS_MOS_BD_MWST]
		,(r.[BBM_MOS_BD] - r.[MenStorniert]) as [BRABS_MOS_BD]
	-- LABS / LUMS	
	-- 29.06.2012, A.G.:
	-- nach lange Suche haben Dennis und ich herausgefunden, dass Bedingung "LEFT([RET-CODE],1)=8"
	-- falsch ist. Da Retourengründe sich verändert haben, müsste auch diese Bedingung 
	-- angepasst werden. Dennis wird darüber mit Demokunde sprechen.
	/*
	-- 11.08.2012, A.G.: old implementation deactivated
	-- 11.07.2012 old implementation
		,case when 
			left(r.[Ret-Code],1) = 9 
			or (MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 and left(r.[Ret-Code],1) = 8) 
			then 0 else r.BBM_MOS_BD - r.MenStorniert end as [LABS_MOS_BD]
		,case when 
			left(r.[Ret-Code],1) = 9 
			or (MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 and left(r.[Ret-Code],1) = 8)
			then 0 else r.BBM_MOS_BD - r.MenStorniert end
		 * r.[VK_ERZ_MOS] as [LUMS_MOS_BD]
		,case when 
			left(r.[Ret-Code],1) = 9 
			or (MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 and left(r.[Ret-Code],1) = 8)
			then 0 else r.BBM_MOS_BD - r.MenStorniert end
		 * r.[VK_ERZ_MOS_MWST] as [LUMS_MOS_BD_MWST]
	*/
	
	-- 11.07.2012, new implementation
		,case when 
			left(r.[Ret-Code],1) = 9 
			or (MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 and r.[Ret-Code]= 8) 
			then 0 else r.BBM_MOS_BD - r.MenStorniert end as [LABS_MOS_BD]
		,case when 
			left(r.[Ret-Code],1) = 9 
			or (MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 and r.[Ret-Code] = 8)
			then 0 else r.BBM_MOS_BD - r.MenStorniert end
		 * r.[VK_ERZ_MOS] as [LUMS_MOS_BD]
		,case when 
			left(r.[Ret-Code],1) = 9 
			or (MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 and r.[Ret-Code] = 8)
			then 0 else r.BBM_MOS_BD - r.MenStorniert end
		 * r.[VK_ERZ_MOS_MWST] as [LUMS_MOS_BD_MWST]
	
	-- RABS / RUMS
	-- 8 = sonstiger Retourengrund --> Annahme: Wenn Voll-Retoure hat der Kunde das Paket nicht erhalten 
	-- 29.06.2012, A.G.:
	-- nach lange Suche haben Dennis und ich herausgefunden, dass Bedingung "LEFT([RET-CODE],1)=8"
	-- falsch ist. Da Retourengründe sich verändert haben, müsste auch diese Bedingung 
	-- angepasst werden. Dennis wird darüber mit Demokunde sprechen.
	/*
	-- 11.08.2012, A.G.: old implementation deactivated
	-- 11.07.2012, old implementation
		,case when 
			not ((left(r.[Ret-Code],1) = 9 
			or (MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 and left(r.[Ret-Code],1) = 8))) 
			and r.[Ret-Code] != -99 then r.MenRetour else 0 end as [RABS_MOS_BD]
		,case when 
			not ((left(r.[Ret-Code],1) = 9 
			or (MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 and left(r.[Ret-Code],1) = 8)))
			and r.[Ret-Code] != -99 then r.MenRetour else 0 end 
		 * r.[VK_ERZ_MOS]as [RUMS_MOS_BD]
		,case when 
			not ((left(r.[Ret-Code],1) = 9 
			or (MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 and left(r.[Ret-Code],1) = 8)))
			and r.[Ret-Code] != -99 then r.MenRetour else 0 end 
		 * r.[VK_ERZ_MOS_MWST]as [RUMS_MOS_BD_MWST]	
	*/
	
	-- 11.07.2012, new implementation
		,case when 
			not ((left(r.[Ret-Code],1) = 9 
			or (MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 and r.[Ret-Code] = 8))) 
			and r.[Ret-Code] != -99 then r.MenRetour else 0 end as [RABS_MOS_BD]
		,case when 
			not ((left(r.[Ret-Code],1) = 9 
			or (MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 and r.[Ret-Code] = 8)))
			and r.[Ret-Code] != -99 then r.MenRetour else 0 end 
		 * r.[VK_ERZ_MOS]as [RUMS_MOS_BD]
		,case when 
			not ((left(r.[Ret-Code],1) = 9 
			or (MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 and r.[Ret-Code] = 8)))
			and r.[Ret-Code] != -99 then r.MenRetour else 0 end 
		 * r.[VK_ERZ_MOS_MWST]as [RUMS_MOS_BD_MWST]
		 
	-- RABS / RUMS Gesamt
		,case when r.[Ret-Code] != -99 then r.MenRetour else 0 end as [RABS_GES_MOS_BD]
		,case when r.[Ret-Code] != -99 then r.MenRetour else 0 end 
		 * r.[VK_ERZ_MOS]as [RUMS_GES_MOS_BD]
		,case when r.[Ret-Code] != -99 then r.MenRetour else 0 end 
		 * r.[VK_ERZ_MOS_MWST]as [RUMS_GES_MOS_BD_MWST]		 
		 
		 
	-- NABS / NUMS
		,case when r.[Ret-Code] != -99 then 0 else r.BBM_MOS_BD - r.MenStorniert - r.MenRetour end as [NABS_MOS_BD]
		,case when r.[Ret-Code] != -99 then 0 else r.BBM_MOS_BD - r.MenStorniert - r.MenRetour end
		 * r.[VK_ERZ_MOS] as [NUMS_MOS_BD]		
		,case when r.[Ret-Code] != -99 then 0 else r.BBM_MOS_BD - r.MenStorniert - r.MenRetour end
		 * r.[VK_ERZ_MOS_MWST] as [NUMS_MOS_BD_MWST]
		--,case when r.[Ret-Code] != -99 then 0 else r.Abschrift end as ABS_VK_MOS_BRUMS
	
	---- BEST_MOS / VOLLRETOUREN / TEILRETOUREN
	---- 27.06.2012, correct condition here. Add checking for the stock differences.
		,convert(int,[Auftrags-Num]) as BEST_MOS
		,case when (MenRetourTotal - MengeLagerDif) > 0 then convert(int,[Auftrags-Num]) end as RET_MOS
		/* old expression
		,case when MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 
		 then convert(int,[Auftrags-Num]) else null end as RET_VOLL
		*/
		-- new expression, with differences
		,case when (MenGeliefTotal - MengeLagerDif) = (MenRetourTotal - MengeLagerDif) and 
		 (MenRetourTotal - MengeLagerDif) > 0  
		 then convert(int,[Auftrags-Num]) else null end as RET_VOLL
		/* old expression
		,case when MenGeliefTotal > MenRetourTotal and MenRetourTotal > 0 
		 then convert(int,[Auftrags-Num]) else null end as RET_TEIL
		*/
		-- new expression, with differences
		,case when (MenGeliefTotal - MengeLagerDif) > (MenRetourTotal - MengeLagerDif)  and 
		 (MenRetourTotal - MengeLagerDif) > 0 
		 then convert(int,[Auftrags-Num]) else null end as RET_TEIL
	
	-- MOS
		,r.MenStorniert
		,r.MenGelief
		,r.MenRetour
		,r.MenGeliefTotal
		,r.MenRetourTotal
		,r.[Auftrags-Num]
	
	-- 24.10.2011: dimension Webtrekk
		,ISNULL(dWT.ID, @iDummyWebtrekkID) as fk_webtrekk_id
		
		-- 25.10.2011: Mahn-sta
		,r.[Mahn-Sta] as MahnStatus
		
		-- 09.11.2011: LST added
		,r.VerkPreis
		,r.UVK_MOS
		
		-- 09.02.2012, A.G.: dimension Webtrekk_v2
		,ISNULL(dWT_v2.ID, @iDummyWebtrekk_v2_ID) as fk_webtrekk_v2_id
		
		-- testweise kann geg. gelöscht werden
		,r.[Ret-Code]
		,r.[Ret-Code-Test]
		
	from
	(
		select 
			 o.[Auftrags-Num]
			,op.[Artikel-Num]
			,op.[Artikel-Bez]
			,convert(int,replace(''20''+RIGHT(o.[Bestell-Datum],2)+SUBSTRING(o.[Bestell-Datum],4,2)+LEFT(o.[Bestell-Datum],2),''??'',''090101'')) as fkDimTime
			,convert(int,replace(''20''+RIGHT(i.[Rech-Datum],2)+SUBSTRING(i.[Rech-Datum],4,2)+LEFT(i.[Rech-Datum],2),''??'',''090101'')) as fkDimTimeFD
			,convert(int,replace(''20''+RIGHT(op.[Mod-Datum],2)+SUBSTRING(op.[Mod-Datum],4,2)+LEFT(op.[Mod-Datum],2),''??'',''010101'')) as fkDimTimeSD --Stornodatum
			--LST 110315 ,convert(int,replace(''20''+RIGHT(rj.Datum,2)+SUBSTRING(rj.Datum,4,2)+LEFT(rj.Datum,2),''??'',''090101'')) as fkDimTimeRD
			,convert(int,convert(varchar,convert(datetime,RIGHT(_xx.Datum,2)+SUBSTRING(_xx.Datum,4,2)+LEFT(_xx.datum,2)),112)) as fkDimTimeRD
			,g.ID as fkDimGutschein
			,a.ID as fkDimArtikel
			,s.ID as fkDimStatus
			,isnull(k.ID,4) as fkDimKunde
			,case when op.PayPal > 0 then (select id from DWH_DIM_ZAHLART where [Rech-Art-Typ] = ''PayPal'')
			 else z.id end as fkDimZahlart
			,isnull(dr.ID,1) as fkDimRetoure -- 3 = -99
			,od.ID as fkDimOrder
			,p.ID as fkDimPreis
			,sknz.id as fkDimSKNZ
			,CONVERT(float,op.MenBestel)/isnull(khno.nmb,1)/ ISNULL(gn.nmbOfGut,1) as [BBM_MOS_BD]
			,CONVERT(float,op.MenGelief)/isnull(khno.nmb,1)/ ISNULL(gn.nmbOfGut,1) as MenGelief--
			,CONVERT(float,op.MenRetour)/isnull(khno.nmb,1)/ ISNULL(gn.nmbOfGut,1) as MenRetour--
			,case when op.[OrdPos-Sta] = 21 or o.[Order-Sta] = 21 then CONVERT(float,op.MenBestel) /isnull(khno.nmb,1)/ ISNULL(gn.nmbOfGut,1) else 0 end as [MenStorniert]--
			,convert(float,replace(op.NettoAnteil,'','',''.'')) as [VK_ERZ_MOS]
			,convert(float,replace(op.Preis,'','',''.'')) as [VK_ERZ_MOS_MWST]			
			,(select isnull(max(convert(float,replace(l.EinkPreis,'','',''.''))),0) 
				from Demokunde_Staging.dbo.srcARTLIF l 
				where l.[HLi-Ind] = ''yes'' and l.[Artikel-Num] = op.[Artikel-Num]) as EKPreis
			
			-- 09.03.2012, LST: EK HIST
			,(select max(ek.Datum) from #SrcArtHistEKHistClear ek
			  where 
					ek.Datum
					<= convert(int,replace(''20''+RIGHT(o.[Bestell-Datum],2)+SUBSTRING(o.[Bestell-Datum],4,2)+LEFT(o.[Bestell-Datum],2),''??'',''090101''))
					and ek.[Artikel-Num] = op.[Artikel-Num] and ek.[Artikel-Bez] = op.[Artikel-Bez]
			 ) as EKPreisHistDat
			
			,(select min(ek.Datum) from #SrcArtHistEKHistClear ek
			  where ek.[Artikel-Num] = op.[Artikel-Num] and ek.[Artikel-Bez] = op.[Artikel-Bez]
			 ) as EKPreisHistFirst
			
			,CONVERT(float,op.MenGeliefTotal)/isnull(khno.nmb,1)/ ISNULL(gn.nmbOfGut,1) as MenGeliefTotal
			,CONVERT(float,op.MenRetourTotal)/isnull(khno.nmb,1)/ ISNULL(gn.nmbOfGut,1) as MenRetourTotal
			,op.Abschrift/isnull(khno.nmb,1)/ ISNULL(gn.nmbOfGut,1) as Abschrift
			
			-- 17.04.2012, LST: Retcode-Mapping New
			,_xx.[Ret-Code-Test] as [Ret-Code-Test]
			,_xx.[Ret-Code] as [Ret-Code]
	
			,o.[Kunden-Num]
			
			-- 24.10.2011: link to dim. "Webtrekk"
			,o.[eAuftrags-NumOrg]
			
			-- 25.10.2011: Man-Status aus srcInvoice
			,i.[Mahn-Sta]
			
			-- 09.11.2011: add for uvk-vk/vk
			,op.UVK_MOS
			, convert(float,replace(op.VerkPreis,'','',''.'')) as VerkPreis
			-- 27.06.2012, A.G: add stock differences
			,ISNULL(_stockDiff.MengeLagerDif,0) AS MengeLagerDif
			
		from Demokunde_Staging.dbo.[srcORDER] o
		left join Demokunde_Staging.dbo.srcInvoice i
			on i.[Firmen-Num] = o.[Firmen-Num] and i.[Auftrags-Num] = o.[Auftrags-Num] and i.[Order-Count] = o.[Order-Count]
		left join DWH_DIM_ORDER od
			on o.[Auftrags-Num] = od.[Auftrags-Num]
		left join Demokunde_Staging.dbo.ORDERPOS op 
			on o.[Firmen-Num] = op.[Firmen-Num] and o.[Auftrags-Num] = op.[Auftrags-Num] and o.[Order-Count] = op.[Order-Count]
		left join DWH_DIM_ARTIKEL a 
			on a.[Artikel-Num] = op.[Artikel-Num] and a.[Artikel-Bez] = op.[Artikel-Bez]
		left join DWH_DIM_STATUS s 
			on s.[Order-Sta] = o.[Order-Sta] and s.[OrdPos-Sta] = isnull(op.[OrdPos-Sta],''n/a'')
		left join DWH_DIM_KUNDE k 
			on k.[Kunden-Num] = o.[Kunden-Num]
		left join DWH_DIM_ZAHLART z 
			on z.[Rech-Art-Code] = o.[Rech-Art] and z.[Zahl-Art-Code] = o.[Zahl-Art]
		-- 16.01.2012, A.G.: bugfixing link to the "RetourenJournal". It''s possible
		-- that when return has more than 1 position. This must be checked.
		-- I decided to take just MAX() of all reasons
		/*
		left join Demokunde_Staging.dbo.RetourenJournal rj
			on rj.[Firmen-Num] = o.[Firmen-Num] and rj.[Auftrags-Num] = o.[Auftrags-Num] and rj.[Order-Count] = o.[Order-Count] and
				 rj.OrderPos = op.[OrderPos] and rj.nmb = op.nmb
		*/
		left join (
			SELECT 
				rj.[Firmen-Num]
				,rj.[Auftrags-Num]
				,rj.[Order-Count]
				,rj.OrderPos
				,rj.nmb
				,rj.Datum
				,isnull(MAX(rj.[Ret-Code]),-99) as [Ret-Code-Test]
				-- DH 13.07.2012: Retouren-Code Mapping hierhin verlagert, damit JOIN gegen DIM_RETOURE auf gemappte Ret-Codes zugreift
				,isnull(MAX(
					case 
						when convert(int,convert(varchar,convert(datetime,RIGHT(rj.Datum,2)+SUBSTRING(rj.Datum,4,2)+LEFT(rj.datum,2)),112)) <= 20120425
										 and LEN(rj.[Ret-Code]) = 2
										 and LEFT(rj.[Ret-Code],1) not in (5,7,9)
						then LEFT(rj.[Ret-Code],1) +
							case 
								when right(rj.[Ret-Code],1) = 0 then ''5''
								when right(rj.[Ret-Code],1) = 1 then ''3''
								when right(rj.[Ret-Code],1) = 2 then ''4''
								when right(rj.[Ret-Code],1) = 3 then ''4''
								when right(rj.[Ret-Code],1) = 4 then ''3''
								when right(rj.[Ret-Code],1) = 5 then ''2''
								when right(rj.[Ret-Code],1) = 6 then ''1''
								when right(rj.[Ret-Code],1) = 7 then ''1''
								when right(rj.[Ret-Code],1) = 8 then ''1''
								when right(rj.[Ret-Code],1) = 9 then ''6''
							end
					 else rj.[Ret-Code]
					 end
					 ),-99) as [Ret-Code]
			FROM Demokunde_Staging.dbo.RetourenJournal rj
			GROUP BY rj.[Firmen-Num]
				,rj.[Auftrags-Num]
				,rj.[Order-Count]
				,rj.OrderPos
				,rj.nmb
				,rj.Datum
		) _xx
		on _xx.[Firmen-Num] = o.[Firmen-Num] and _xx.[Auftrags-Num] = o.[Auftrags-Num] and _xx.[Order-Count] = o.[Order-Count] and
				 _xx.OrderPos = op.[OrderPos] and _xx.nmb = op.nmb
		left join DWH_DIM_RETOURE dr
			on dr.RetCode = _xx.[Ret-Code]
		left join DWH_DIM_PREIS p
			on p.PH_01 = op.PH_01 and p.PH_02 = op.PH_02
		-- LST 2011.06.24 add kungutschein
			left join Demokunde_Staging.dbo.srcKonHist kh
		on o.[Firmen-Num] = kh.[Firmen-Num] and o.[Auftrags-Num] = kh.[Auftrags-Num] and o.[Order-Count] = kh.[Order-Count] 
		and kh.[Kon-Code] in (98,109,971,972,973 , 48,159,974,975,976)
		left join #khNo khno
			on khno.[Firmen-Num] = o.[Firmen-Num] and khno.[Auftrags-Num] = o.[Auftrags-Num] and khno.[Order-Count] = o.[Order-Count]
		left join Demokunde_Staging.dbo.GutscheinCodes gi 
			on gi.[Auftrags-Num] = o.[Auftrags-Num]
		left join #GutschNmb gn
			on gn.[Auftrags-Num] = o.[Auftrags-Num]
		left join Demokunde.dbo.DWH_DIM_GUTSCHEIN g
			on g.[Gutsch-Betrag] = CONVERT(float,replace(kh.Haben,'','',''.'')) 
				and g.[Gutsch-Ident] = isnull(gi.[Gutsch-Ident],''kein Gutsch-Ident'')
				and g.[Kon-Code] = kh.[Kon-Code]
				and g.[Gutsch-Ident-Src] = isnull(gi.src,''kein Gutsch-Ident'')
		-- LST 2011.12.11 add dimension SKNZ
		left join DWH_DIM_SAISONKNZ sknz
			on	sknz.[Artikel-Num] = op.[Artikel-Num]
					and sknz.[Artikel-Bez] = op.[Artikel-Bez]
					and convert(int,replace(''20''+RIGHT(o.[Bestell-Datum],2)+SUBSTRING(o.[Bestell-Datum],4,2)+LEFT(o.[Bestell-Datum],2),''??'',''090101'')) 
						  between convert(int,convert(varchar,sknz.Fromdate,112)) and  convert(int,convert(varchar,sknz.toDate,112))
		-- 27.06.2012, checking stock differences (returns of type 8 or 9)
		LEFT JOIN (
			SELECT
				  rj.[Firmen-Num]
				, rj.[Auftrags-Num]
				--, rj.[Order-Count]
				, SUM(rj.MenRetour) AS MengeLagerDif
			FROM [Demokunde_Staging].dbo.RetourenJournal rj
			WHERE rj.[Ret-Code] IN (8,9)
			GROUP BY rj.[Firmen-Num], rj.[Auftrags-Num]--, rj.[Order-Count]
		) _stockDiff
			ON _stockDiff.[Auftrags-Num] = o.[Auftrags-Num] AND 
			   --_stockDiff.[Order-Count] = o.[Order-Count] AND
			   _stockDiff.[Firmen-Num] = o.[Firmen-Num]
		where 
			o.[Firmen-Num] = (select value from adm_parameters where code = ''Firma'')
			and convert(float,replace(op.VerkPreis,'','',''.'')) != 0
		
		
	) r
	left join #kd kd
		on kd.[Kunden-Num] = r.[Kunden-Num]
			 and kd.minDate = r.fkDimTime 
		
			*
		FROM Demokunde_Staging.dbo.src_webtrekk_data_v2 d
		WHERE d.Direkt = 1 AND d.BestelNr = r.[eAuftrags-NumOrg]
		ORDER BY LEN(d.ChannelName) ASC
	) wt_v2_direkt
	/*
	LEFT JOIN Demokunde_Staging.dbo.src_webtrekk_data_v2 wt_v2_erste
	  ON wt_v2_erste.BestelNr = r.[eAuftrags-NumOrg] AND wt_v2_erste.Erste = 1
	*/
	OUTER APPLY (
		SELECT TOP 1
			*
		FROM Demokunde_Staging.dbo.src_webtrekk_data_v2 e
		WHERE e.Erste = 1 AND e.BestelNr = r.[eAuftrags-NumOrg]
		ORDER BY LEN(e.ChannelName) ASC
	) wt_v2_erste
	/*
	LEFT JOIN Demokunde_Staging.dbo.src_webtrekk_data_v2 wt_v2_letzte
	  ON wt_v2_letzte.BestelNr = r.[eAuftrags-NumOrg]  AND wt_v2_letzte.Letzte = 1
	*/
	OUTER APPLY (
		SELECT TOP 1
			*
		FROM Demokunde_Staging.dbo.src_webtrekk_data_v2 l
		WHERE l.Letzte = 1 AND l.BestelNr = r.[eAuftrags-NumOrg]
		ORDER BY LEN(l.ChannelName) ASC
	) wt_v2_letzte
	LEFT JOIN DWH_DIM_WEBTREKKV2 dWT_v2
	  ON  wt_v2_direkt.ChannelName = dWT_v2.Direkt 
	      AND wt_v2_erste.ChannelName = dWT_v2.Erste 
	      AND wt_v2_letzte.ChannelName = dWT_v2.Letzte
) w	


-- 27.10.2011
-- Berechnung von "DB1"-Komponenten, die pro Auftrag (und nicht pro Position) angerechnet werden müssen
--
-- Shipping Cost
UPDATE [DWH_FACT_ORDERPOS]
SET [Shipping Cost] = @fShippingCost / _x.Anz_Zeilen
FROM [DWH_FACT_ORDERPOS] F
INNER JOIN (
	SELECT [BEST_MOS], COUNT(1) As Anz_Zeilen
	FROM [DWH_FACT_ORDERPOS] F1
	WHERE F1.BEST_MOS_LUMS > 0
	GROUP BY [BEST_MOS]
) _x
ON F.BEST_MOS = _x.BEST_MOS
WHERE BEST_MOS_LUMS > 0

-- Return Shipping
UPDATE [DWH_FACT_ORDERPOS]
SET [Return Shipping] = @fReturnShipping / _x.Anz_Zeilen
FROM [DWH_FACT_ORDERPOS] F
INNER JOIN (
	SELECT [BEST_MOS], COUNT(1) As Anz_Zeilen
	FROM [DWH_FACT_ORDERPOS] F1
	WHERE F1.BEST_MOS_RUMS > 0
	GROUP BY [BEST_MOS]
) _x
ON F.BEST_MOS = _x.BEST_MOS
WHERE F.BEST_MOS_RUMS >0

-- DW License Cost
-- hier wird Kostensatz durch 100 geteilt, da es Prozentwert ist
UPDATE [DWH_FACT_ORDERPOS]
SET [DW License Charge] = ((@fDWLicCharge * F.BBW_MOS_BD)/100) 
FROM [DWH_FACT_ORDERPOS] F

-- MOS License Cost
-- Prozentwert => durch 100 teilen
UPDATE [DWH_FACT_ORDERPOS]
SET [MOS License Charge] = ((@fMOSLicCharge * F.NUMS_MOS_BD)/100)
FROM [DWH_FACT_ORDERPOS] F
