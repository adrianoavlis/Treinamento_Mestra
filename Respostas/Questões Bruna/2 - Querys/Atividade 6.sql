

-- Atividades 19/03/2014   

-- c) Listar os participantes que possuem todas as situa��es, desconsiderando a situa��o
-- de AUTOPATROCIO PARCIAL ordenado patroc e nome do participante. Campos:
-- C�digo Patrocinadora, Matricula e Nome do Participante, Situa��o. 

SELECT 
		PAT.CDPAT as CodigoPatrocinadora,
		PART.NRMAT as Matricula,
		PART.NMPAR as NomeParticipante,
		ISC.CDSITPLA as Situacao
FROM	
		PAR_PARPLA ISC
JOIN	
		PAR_PATROCINADORAS PAT ON PAT.IDPAT = ISC.CDPAT
JOIN	
		PAR_PARTICIPANTES PART ON PART.NRMAT = ISC.NRMAT
WHERE 
		ISC.CDSITPLA <> 'AUTOPATROCIO PARCIAL'
ORDER BY 
		PAT.CDPAT, PART.NMPAR;
GO



-- 1) Listar a quantidade de parcelas j� pagas para cada contrato VG.
-- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Nro Contrato,
-- Qtd Prestacoes pagas (informa��o buscada em EPT_PARCELA, campo DTMESREFPCL) 

SELECT 
    PAT.CDPAT as CodigoPatrocinadora,
    PART.NRMAT as Matricula,
    PART.NMPAR as NomeParticipante,
    REQ.NRCTT as NroContrato,
    COUNT(PCL.DTMESREFPCL) as QtdPrestacoesPagas
FROM 
    EPT_PARCELAS PCL
JOIN 
    EPT_REQUERIMENTO REQ ON REQ.IDREQEPT = PCL.IDREQEPT
JOIN 
    PAR_PARTICIPANTES PART ON PART.IDPAR = REQ.IDPAR
JOIN 
    PAR_PATROCINADORAS PAT ON PAT.IDPAT = PART.IDPAT
WHERE 
    REQ.IDSITEPT ='VG'
GROUP BY 
    PAT.CDPAT, PART.NRMAT, PART.NMPAR, REQ.NRCTT;
GO

-- 2) Listar a qtd de parcelas j� pagas para o participante matricula 0001001311, contrato VG
-- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Nro Contrato,
-- Qtd Prestacoes pagas (informa��o buscada em EPT_PARCELA, campo DTMESREFPCL)

SELECT 
    PAT.CDPAT as CodigoPatrocinadora,
    PART.NRMAT as Matricula,
    PART.NMPAR as NomeParticipante,
    REQ.NRCTT as NroContrato,
    COUNT(PCL.DTMESREFPCL) as QtdPrestacoesPagas
FROM 
    EPT_PARCELAS PCL
JOIN 
    EPT_REQUERIMENTO REQ ON REQ.IDREQEPT = PCL.IDREQEPT
JOIN 
    PAR_PARTICIPANTES PART ON PART.IDPAR = REQ.IDPAR
JOIN 
    PAR_PATROCINADORAS PAT ON PAT.IDPAT = PART.IDPAT
WHERE 
    REQ.IDSITEPT = 'VG'
    AND PART.NRMAT = '0001001311'
GROUP BY 
    PAT.CDPAT, PART.NRMAT, PART.NMPAR, REQ.NRCTT;
GO

		
-- 3) Listar as parcelas em aberto, cobradas boleto (IDFORCBA = 3) no mes/ref 07/2012 
-- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Nro Contrato,
-- Valor da Presta��o

SELECT 
    PAT.CDPAT as CodigoPatrocinadora,
    PART.NRMAT as Matricula,
    PART.NMPAR as NomeParticipante,
    REQ.NRCTT as NroContrato,
    PCL.VRPCL as ValorPrestacao
FROM 
    EPT_PARCELAS PCL
JOIN 
    EPT_REQUERIMENTO REQ ON REQ.IDREQEPT = PCL.IDREQEPT
JOIN 
    PAR_PARTICIPANTES PART ON PART.IDPAR = REQ.IDPAR
JOIN 
    PAR_PATROCINADORAS PAT ON PAT.IDPAT = PART.IDPAT
WHERE 
	PCL.IDFORCBA = 3
    AND PCL.DTMESREFPCL = '201403'
    AND PCL.STPCLEPT = 'A' 
ORDER BY 
	PCL.DTMESREFPCL
GO

SELECT IDFORCBA FROM EPT_PARCELAS

SELECT COLUMN_NAME, TABLE_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%IDFORCBA%'
ORDER BY TABLE_NAME
GO


-- 4) Listar as parcelas em aberto no mes/ref 07/2012, cobradas SIAPE (IDFORCBA = 6) 
-- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Nro Contrato,
-- Valor da Presta��o


-- 5) Listar as parcelas integradas para o SIAPE (TABELA CTB_ARQ	SIAPE) no mes/ref 07/2012 
-- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Valor da Presta��o (VRINF)
-- Condi��es: TPARQ = 'E', CDRUBSIA = '32525', STLAN = 'I'



-- 6) Listar as parcelas pagas que foram enviadas para o SIAPE (TABELA CTB_ARQSIAPE) no mes/ref 07/2012 
-- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Valor da Presta��o (VRINF), Data Pagamento, Valor Pago
-- Amarrar: TPARQ = 'E', CDRUBSIA = '32525', STLAN = 'P'



-- 7) Listar as parcelas que foram recomandas do SIAPE para Boleto (TABELA CTB_ARQSIAPE) no mes/ref 07/2012 
-- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Valor da Presta��o (VRINF)
-- Amarrar: TPARQ = 'E', CDRUBSIA = '32525', STLAN = 'B'


 
 -- 8) Listar as parcelas que foram recomandas do SIAPE para Debito (TABELA CTB_ARQSIAPE) no mes/ref 07/2012 
 -- Campos: Codigo Patrocinadora, Matricula e Nome do Participante, Valor da Presta��o (VRINF)
 -- Amarrar: TPARQ = 'E', CDRUBSIA = '32525', STLAN = 'D'


 -- 9) Listar as parcelas pagas que tiveram o pagamento cobrado no SIAPE (TABELA EPT_PARCELAS) no mes/ref 07/2012 � IDFORCBAEFE = 6
 -- Campos: Id requerimento, Matricula e Nome do Participante, Valor cobrado da Presta��o, Valor pago e Data de pagamento, Situa��o da parcelas


 -- 10) Listar as parcelas pagas que tiveram o pagamento cobrado na Folha de Ativos (TABELA EPT_PARCELAS) no mes/ref 07/2012 � IDFORCBAEFE = 1
 -- Campos: Id requerimento, Matricula e Nome do Participante, Valor cobrado da Presta��o, Valor pago e Data de pagamento, Situa��o da parcelas
 
