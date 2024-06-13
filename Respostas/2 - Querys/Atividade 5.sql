
-- Data Inicio: 18/03/2014

-- A) Listar os participantes que possuam empr�stimo VIGENTE (VG). Campos: C�digo da 
-- patrocinadora, matricula e nome do participante, id do requerimento de empr�stimo, 
-- n�mero do contrato de empr�stimo, prazo contrato. (SISTEMA DE EMPR�STIMO)

SELECT 
    PAT.CDPAT AS CodigoPatrocinadora,
    PART.NRMAT AS Matricula,
    PART.NMPAR AS NomeParticipante,
    REQ.IDREQEPT AS IdRequerimentoEmprestimo,
    REQ.NRCTT AS NumeroContratoEmprestimo,
    REQ.QTPRZ AS PrazoContrato
FROM 
    EPT_REQUERIMENTO REQ
JOIN 
    PAR_PARTICIPANTES PART ON PART.IDPAR = REQ.IDPAR
JOIN 
    PAR_PATROCINADORAS PAT ON PAT.IDPAT = PART.IDPAT
WHERE 
    REQ.IDSITEPT = 'VG';
GO 


-- B) Listar a quantidade de participantes no plano que possuam situa��o de ATIVO, 
-- AUTOPATROCINADO/AUTO PARCIAL, ordenado pela patroc. Campos: Patroc, situa��o e 
-- quantidade. (SISTEMA PREVIDENCI�RIO)

SELECT 
    PAT.CDPAT AS Patroc,
    ISC.CDSITPLA AS Situacao,
    COUNT(*) AS Quantidade
FROM 
    PAR_PARPLA ISC
JOIN 
    PAR_PARTICIPANTES PART ON PART.IDPAR = ISC.IDPAR
JOIN 
    PAR_PATROCINADORAS PAT ON PAT.IDPAT = PART.IDPAT
WHERE 
    ISC.CDSITPLA IN ('01', '04', '23')
GROUP BY 
    PAT.CDPAT, ISC.CDSITPLA
ORDER BY 
    PAT.CDPAT
GO


-- C) Listar os participantes que tenham data de cr�dito de empr�stimo Vigente no m�s de
-- refer�ncia 05/2012. Campos: C�digo da patrocinadora, matricula e nome do participante,
-- id do requerimento de empr�stimo, n�mero do contrato de empr�stimo,
-- data de cr�dito. (SISTEMA DE EMPR�STIMO)

SELECT 
    PAT.CDPAT AS CodigoPatrocinadora,
    PART.NRMAT AS Matricula,
    PART.NMPAR AS NomeParticipante,
    REQ.IDREQEPT AS IdRequerimentoEmprestimo,
    REQ.NRCTT AS NumeroContratoEmprestimo,
    REQ.DTCRE AS DataCredito
FROM 
    EPT_REQUERIMENTO REQ
JOIN 
    PAR_PARTICIPANTES PART ON PART.IDPAR = REQ.IDPAR
JOIN 
    PAR_PATROCINADORAS PAT ON PAT.IDPAT = PART.IDPAT
WHERE 
    REQ.IDSITEPT = 'VG'
	AND YEAR(REQ.DTCRE) = 2012
   -- AND MONTH(REQ.DTCRE) = 05
GO


-- D) Listar as situa��es no plano (Identificador, Codigo e Descri��o) ordenado pela 
-- descri��o. (SISTEMA PREVIDENCI�RIO)

SELECT 
		IDSITPLA AS Identificador,
		CDSITPLA AS Codigo,
		DCSITPLA AS Descricao
FROM 
		PAR_SITPLANOS
ORDER BY 
		DCSITPLA
GO


-- E) Listar os participantes que tenham liquidado empr�stimo por reforma (LR) no m�s de
-- refer�ncia 04/2012. Campos: C�digo da patrocinadora, matricula e nome do participante, 
-- id do requerimento de empr�stimo, n�mero do contrato de empr�stimo,
-- data de liquida��o. (SISTEMA DE EMPR�STIMO)

SELECT 
    PAT.CDPAT AS CodigoPatrocinadora,
    PART.NRMAT AS Matricula,
    PART.NMPAR AS NomeParticipante,
    REQ.IDREQEPT AS IdRequerimentoEmprestimo,
    REQ.NRCTT AS NumeroContratoEmprestimo,
    REQ.DTLIQ AS DataLiquidacao
FROM 
    EPT_REQUERIMENTO REQ
JOIN 
    PAR_PARTICIPANTES PART ON PART.IDPAR = REQ.IDPAR
JOIN 
    PAR_PATROCINADORAS PAT ON PAT.IDPAT = PART.IDPAT
WHERE 
    REQ.IDSITEPT = 'LR'
    AND YEAR(REQ.DTLIQ) = 2012
    AND MONTH(REQ.DTLIQ) = 4
GO

-- F) Listar apenas os participantes ATIVOS no plano, ordenado pela patrocinadora e nome
-- do participante. Campos: C�digo e Descri��o da Patroc, Matricula, Inscri��o e Nome do 
-- Participante). (SISTEMA PREVIDENCI�RIO)

SELECT 
    PAT.CDPAT AS CodigoPatrocinadora,
    PAT.DCPAT AS DescricaoPatrocinadora,
    PART.NRMAT AS Matricula,
    PART.NRISC AS Inscricao,
    PART.NMPAR AS NomeParticipante
FROM 
    PAR_PARTICIPANTES PART
JOIN 
    PAR_PATROCINADORAS PAT ON PAT.IDPAT = PART.IDPAT
JOIN
	PAR_PARPLA PL ON PL.IDPAR= PART.IDPAR
WHERE 
    PL.IDSITPLA = '1'
ORDER BY 
    PAT.CDPAT, PART.NMPAR
GO

-- G) Listar as formas de cobran�a dos participantes que tenha empr�stimo VIGENTE. Campo: 
-- Matricula e Nome dos participantes, n�mero do contrato de Empr�stimo, Forma de Cobran�a
-- (C�digo e Descri��o). (SISTEMA DE EMPR�STIMO)

SELECT 
    PART.NRMAT AS Matricula,
    PART.NMPAR AS NomeParticipante,
    REQ.NRCTT AS NumeroContratoEmprestimo,
    COBR.IDFORCBA AS CodigoFormaCobranca,
    TPCOB.DCEPTCBA AS DescricaoFormaCobranca
FROM 
    EPT_REQUERIMENTO REQ
JOIN 
    PAR_PARTICIPANTES PART ON PART.IDPAR = REQ.IDPAR
JOIN 
    EPT_PARCELAS COBR ON COBR.IDREQEPT = REQ.IDREQEPT
JOIN
	EPT_TIPOCOBRANCA TPCOB ON TPCOB.CDEPTCBA=COBR.IDFORCBA
WHERE 
    REQ.IDSITEPT = 'VG'
GO


-- H) Listar os participantes que possuem situa��o AUTOPATROCINADO/AUTO PARCIAL ordenado 
-- por situa��o, patroc e nome do participante. Campos: C�digo Patrocinadora, Matricula e
-- Nome do Participante, Situa��o. (SISTEMA PREVIDENCI�RIO)

SELECT 
    PAT.CDPAT AS CodigoPatrocinadora,
    PART.NRMAT AS Matricula,
    PART.NMPAR AS NomeParticipante,
    ISC.CDSITPLA AS Situacao
FROM 
    PAR_PARPLA ISC
JOIN 
    PAR_PARTICIPANTES PART ON PART.IDPAR = ISC.IDPAR
JOIN 
    PAR_PATROCINADORAS PAT ON PAT.IDPAT = PART.IDPAT
WHERE 
    ISC.CDSITPLA IN ('04','23')
ORDER BY 
    ISC.CDSITPLA, PAT.CDPAT, PART.NMPAR
GO


-- I) Listar o somat�rio total de recebimentos (qualquer pagamento) no m�s de refer�ncia 
-- 06/2012. (SISTEMA DE EMPR�STIMO)
SELECT 
    SUM(PCL.VRPCLPAG) AS TotalRecebimentos
FROM 
    EPT_PARCELAS PCL
WHERE 
    PCL.DTMESREF = '201206' 
GO 

-- J) Listar os contratos que foram LIQUIDADOS no m�s de refer�ncia 05/2012.
-- Campos: n�mero do contrato, data de liquida��o. (SISTEMA DE EMPR�STIMO)

SELECT 
    REQ.NRCTT AS NumeroContrato,
    REQ.DTLIQ AS DataLiquidacao
FROM 
    EPT_REQUERIMENTO REQ
WHERE 
    YEAR(REQ.DTLIQ) = 2012
    AND MONTH(REQ.DTLIQ) = 5;


-- K) Listar apenas as parcelas geradas no m�s de refer�ncia 07/2012. Campos: identificador
-- do requerimento de empr�stimo, m�s de refer�ncia, valor da parcela. (SISTEMA DE EMPR�STIMO)
 
 SELECT 
    PCL.IDREQEPT AS IDREQEmprestimo,
    PCL.DTMESREF AS MesReferencia,
    PCL.VRPCL AS ValorParcela
FROM 
    EPT_PARCELAS PCL
WHERE 
    PCL.DTMESREF = '201207'
	AND PCL.VRPCL <> 0.00
GO

 
-- L) Listar as parcelas que tiveram Baixa Manual anteriores ao m�s de refer�ncia 11/2011.
-- Campos: n�mero do contrato, n�mero da parcelas, data efetiva de pagamento. (SISTEMA DE EMPR�STIMO)

SELECT 
    REQ.NRCTT AS NumeroContrato,
    PCL.NRPCLEPT AS NumeroParcela,
    PCL.DTEFEPAGPCL AS DataEfetivaPagamento
FROM 
    EPT_PARCELAS PCL
JOIN 
    EPT_REQUERIMENTO REQ ON REQ.IDREQEPT = PCL.IDREQEPT
WHERE 
    YEAR(PCL.DTEFEPAGPCL) < 2011
    AND MONTH(PCL.DTEFEPAGPCL) < 11
	--AND PCL.STPCLEPT IN ('M', 'B')
ORDER BY 
	PCL.DTEFEPAGPCL

-- M) Listar apenas as parcelas confirmadas no m�s de refer�ncia 06/2012. 
-- OBS: Campos: identificador do requerimento de empr�stimo, m�s de refer�ncia, 
-- valor da parcela. (SISTEMA DE EMPR�STIMO)

SELECT 
    PCL.IDREQEPT AS IdentificadorRequerimentoEmprestimo,
    PCL.DTMESREF AS MesReferencia,
    PCL.VRPCL AS ValorParcela
FROM 
    EPT_PARCELAS PCL
WHERE 
    PCL.DTMESREF = 201206
    AND PCL.STPCLEPT = 'C'
GO
	

-- N) Listar apenas as parcelas que tiveram Baixa Manual no m�s de refer�ncia 06/2012.
-- Campos: n�mero do contrato, n�mero da parcelas, data efetiva de pagamento. (SISTEMA DE EMPR�STIMO)

SELECT 
    REQ.NRCTT AS NumeroContrato,
    PCL.NRPCLEPT AS NumeroParcela,
    PCL.DTEFEPAGPCL AS DataEfetivaPagamento
FROM 
    EPT_PARCELAS PCL
JOIN 
    EPT_REQUERIMENTO REQ ON REQ.IDREQEPT = PCL.IDREQEPT
WHERE 
    YEAR(PCL.DTEFEPAGPCL) = 2012
    AND MONTH(PCL.DTEFEPAGPCL) = 6
    AND PCL.STPCLEPT = 'M'
ORDER BY NRCTT
GO

-- O) Listar apenas as parcelas integradas (A) no m�s de refer�ncia 07/2012. 
-- Campos: identificador do requerimento de empr�stimo, m�s de refer�ncia, 
-- valor da parcela. (SISTEMA DE EMPR�STIMO)

SELECT 
    PCL.IDREQEPT AS IdentificadorRequerimentoEmprestimo,
    PCL.DTMESREF AS MesReferencia,
    PCL.VRPCL AS ValorParcela,
	STPCLEPT
FROM 
    EPT_PARCELAS PCL
WHERE 
    PCL.DTMESREF = 201207
    AND PCL.STPCLEPT = 'A'
GO 


-- P) Listar os contratos que tiveram AMORTIZA��O no m�s de refer�ncia 06/2012. 
-- Campos: n�mero do contrato, n�mero da parcelas, valor amortizado. (SISTEMA DE EMPR�STIMO)

SELECT 
    REQ.NRCTT AS NumeroContrato,
    PCL.NRPCLEPT AS NumeroParcela,
    PCL.VRPCLPAG AS ValorAmortizado,
	DTMESREF
	
FROM 
    EPT_PARCELAS PCL
JOIN 
    EPT_REQUERIMENTO REQ ON REQ.IDREQEPT = PCL.IDREQEPT
WHERE 
    --DTMESREF = '201207'
     PCL.DTMESREFPCL > PCL.DTMESREF 
GO


-- Q) Listar os contratos que foram LIQUIDADOS no m�s de refer�ncia 05/2012.
-- Campos: n�mero do contrato, data de liquida��o. (SISTEMA DE EMPR�STIMO)

SELECT 
    REQ.NRCTT AS NumeroContrato,
    REQ.DTLIQ AS DataLiquidacao
FROM 
    EPT_REQUERIMENTO REQ
WHERE 
    YEAR(REQ.DTLIQ) = 2012
    AND MONTH(REQ.DTLIQ) = 5
GO


-- R) Altere o nome do participante que tem a inscri��o n� 000068601 (De: Eduardo C Vieira
-- para : Eduardo Carvalho Vieira ).

BEGIN TRANSACTION 
	
	UPDATE PAR_PARTICIPANTES
	SET NMPAR = 'Eduardo Carvalho Vieira'
	WHERE NRISC = '000068601'

COMMIT 
GO