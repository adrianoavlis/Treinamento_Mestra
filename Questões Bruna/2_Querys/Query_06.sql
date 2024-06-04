
-- Atividades 19/03/2014   

-- c) Listar os participantes que possuem todas as situações, desconsiderando a situação
-- de AUTOPATROCIO PARCIAL ordenado patroc e nome do participante. Campos:
-- Código Patrocinadora, Matricula e Nome do Participante, Situação. 

SELECT 
	[IDPLA] as idParticipante,
	[IDPAT] as cdPatrocinadora,
	[NMPAR] as nmParticipante,
	[CDCAT] as categoriaSituacao,
	[CDSITPLA] as cdSituacao
FROM PAR_PARPLA ISC , PAR_PATROCINADORAS PAT, PAR_DADOS_ANT_RECAD PART
WHERE	[CDSITPLA] = 23 
	AND [STISC] = 2 
	AND PAT.[IDPAT]= ISC.CDPAT
	AND	PART.NRMAT = ISC.NRMAT 
ORDER BY DCPAT, NMPAR
GO


-- 1) Listar a quantidade de parcelas já pagas para cada contrato VG.
-- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Nro Contrato,
-- Qtd Prestacoes pagas (informação buscada em EPT_PARCELA, campo DTMESREFPCL) 



-- 2) Listar a qtd de parcelas já pagas para o participante matricula 0050018563, contrato VG
-- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Nro Contrato,
-- Qtd Prestacoes pagas (informação buscada em EPT_PARCELA, campo DTMESREFPCL)


		
-- 3) Listar as parcelas em aberto, cobradas boleto (IDFORCBA = 3) no mes/ref 07/2012 
-- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Nro Contrato,
-- Valor da Prestação



-- 4) Listar as parcelas em aberto no mes/ref 07/2012, cobradas SIAPE (IDFORCBA = 6) 
-- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Nro Contrato,
-- Valor da Prestação


-- 5) Listar as parcelas integradas para o SIAPE (TABELA CTB_ARQSIAPE) no mes/ref 07/2012 
-- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Valor da Prestação (VRINF)
-- Condições: TPARQ = 'E', CDRUBSIA = '32525', STLAN = 'I'



-- 6) Listar as parcelas pagas que foram enviadas para o SIAPE (TABELA CTB_ARQSIAPE) no mes/ref 07/2012 
-- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Valor da Prestação (VRINF), Data Pagamento, Valor Pago
-- Amarrar: TPARQ = 'E', CDRUBSIA = '32525', STLAN = 'P'



-- 7) Listar as parcelas que foram recomandas do SIAPE para Boleto (TABELA CTB_ARQSIAPE) no mes/ref 07/2012 
-- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Valor da Prestação (VRINF)
-- Amarrar: TPARQ = 'E', CDRUBSIA = '32525', STLAN = 'B'


 
 -- 8) Listar as parcelas que foram recomandas do SIAPE para Debito (TABELA CTB_ARQSIAPE) no mes/ref 07/2012 
 -- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Valor da Prestação (VRINF)
 -- Amarrar: TPARQ = 'E', CDRUBSIA = '32525', STLAN = 'D'


 -- 9) Listar as parcelas pagas que tiveram o pagamento cobrado no SIAPE (TABELA EPT_PARCELAS) no mes/ref 07/2012 – IDFORCBAEFE = 6
 -- Campos: Id requerimento, Matricula e Nome do Participante, Valor cobrado da Prestação, Valor pago e Data de pagamento, Situação da parcelas


 -- 10) Listar as parcelas pagas que tiveram o pagamento cobrado na Folha de Ativos (TABELA EPT_PARCELAS) no mes/ref 07/2012 – IDFORCBAEFE = 1
 -- Campos: Id requerimento, Matricula e Nome do Participante, Valor cobrado da Prestação, Valor pago e Data de pagamento, Situação da parcelas
 
