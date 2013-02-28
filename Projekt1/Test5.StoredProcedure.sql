t

-- 26.10.2011: für die Berechnung von DB1 müssen
-- Kostensätze von MDM ermittelt werden
-- Filterung erfolgt über Name und ID
-- Shipping Cost
DECLARE @fShippingCost float
SELECT @fShippingCost = [Kostensatz]
FROM MDM.dbo._DB1_KOSTEN
WHERE [Kostenart] = ''Shipping Cost'' 
AND ID=7293
-- Material costs
DECLARE @fPickMatCost floatasd
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
AND idasd
DECLARE @fMOSLicCharge float
SELECT @fMOSLicCharge = [Kostensatz]
FROM MDM.dbo._DB1_KOSTEN
WHERE [Kostenart] = ''MOS License Charge''
AND id = 7298
-- Mahnasd
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
AND id =asd
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
	,convertasging.dbo.SrcArtEKHist a
where exists
			(
				select
					null
				from
					#SrcArtEKHistMax b
				where
					a.[Arasd
	a.[Kunden-Num]
	,min(a.fkDimTime) as minDate
	,MIN([Auftrags-Num]) as minAuftrNr
	,COUNT(*) as nmb
into #kd
from
	(
		select 
			o.[Kunden-Num]
			,conasd
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

-- temp nmb asd
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
	,w.RABS_GES_MOSasd_BD != 0 then BEST_MOS else -1 end as BEST_MOS_LUMS
	,CASE WHEN LUMS_MOS_BD <> 0 THEN 0 ELSE -1 END AS BEST_MOS_LUMS_ZERO
	
	-- 03.11.2011, Aasd
	
	-- 26.10.2011: Berechnung von "DB 1"
	,CONVERT(float, 0.0) as [Shipping Cost] -- später ausrechnen, da es pro Auftrag (und nicht pro Position) berechnet werden soll
	,CONVERT(float, (w.BRABS_MOS_BD * @fPickMatCost))  as [Pick Material Cost]
	,CONVERT(float,asdnach Validierung gelöscht werden 20120413
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
		ELSE 0ad
			
into DWH_FACT_ORDERPOS
from
	(
	select
		r.fkDimArtikel
		,isnull(r.fkDimGutschein,4) as fkDimGutschein
		,r.fkDimKunde
		,case when kd.nmb is not null then 4 else 5 end as fkDimKundeCluster
		,3 as fkDimLager
		,4 as fasdBez] = r.[Artikel-Bez]
				and hc.Datum = isnull(r.EKPreisHistDat,r.EKPreisHistFirst)
		 ) as EKPreisHist
		,EKPreisHistDat
		,EKPreisHistFirst
		 
		,r.Abschrift as ABS_VK_MOS_BBW
		,r.[BBM_MOS_BD] * r.[VK_ERZ_MOS] as [BBW_MOS_BD]
		,r.[BBM_MOS_BD] * r.[VK_ERZ_MOS_MWST] as [BBW_MOS_BD_MWST]
		,r.[BBM_MOS_BD]
		,(r.[BBM_MOSads
			left(r.[Ret-Code],1) = 9 
			or (MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 and left(r.[Ret-Code],1) = 8)
			then 0 else r.BBM_MOS_BD - r.MenStorniert end
		 * r.[VK_ERZ_MOS] as [LUMS_MOS_BD]
		,case when adRetourTotal and MenRetourTotal > 0 and r.[Ret-Code] = 8)
			then 0 else r.BBM_MOS_BD - r.MenStorniert end
		 * r.[VK_ERZ_MOS] as [LUMS_MOS_BD]
		,case when 
			left(r.[Ret-Code],1) = 9 
			or (MenGeliefTotal = MenRetourTotal and MenRetourTotal > 0 and r.[Ret-Code] = 8)
			then 0 else r.BBM_MOS_BD - r.MenStorniert end
		 * r.[VK_ERZ_MOS_MWST] as [LUMS_MOS_BD_MWST]
	
	-- RABS / RUMSadsde],1) = 9 
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
		--,case when r.[Ret-Codasd
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
			,convert(intasdr o.[Order-Sta] = 21 then CONVERT(float,op.MenBestel) /isnull(khno.nmb,1)/ ISNULL(gn.nmbOfGut,1) else 0 end as [MenStorniert]--
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
			,o.[eAuftasd
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
						as
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
		
		as
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
asd
	WHERE F1.asd