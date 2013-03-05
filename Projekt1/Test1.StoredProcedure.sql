Kunde 2
GO Bonjour Steffen
SET QUOTED_IDENTIFIER ON
GO Hallo
IF Arbeit im SkriptS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_ODS_FACT_LAGER_WE_SONST]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ===== This Software is copyright (c) by nextel Business Intelligence Solutions GmbH =====
enRetour) as NABS
					,null as RE
				select
					 al.[Artikel-Num]
					,al.[Artikel-Bez]
					,null
						(
							al.[Jou-Reason] = 8
							and al.[2-Num] in (5,6,7,9)
						)
						or
						(
							al.[Jou-Reason] = 8
							and al.[Lager-Num] = 1
							and al.[Auftrags-Num] <> 0
						)
					)
					--and fqwe(float,replace(al.DifFrVerf,'','',''.''))) < 99999
				group by
					 al.[Artikel-Num]
					,al.[Artikel-Bez]

				--RES_STK
				union all
				select
					 al.[Artikel-Num]
					,al.[Artikel-Bez]
					If 
					,null as BRABS
					,null as NABS
					,null as RET_STK
					,SUM(conve1e2fFrVerf,'','',''.''))) as RES_STK
				from
					Demokunde_Staging.dbo.srcArtLagJournal al
				where
							al.[Jou-Reason] in (1,3)
					and al.[sdf-Num] in (1,11)
				
