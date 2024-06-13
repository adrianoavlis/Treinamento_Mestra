
-- Data Inicio: 18/03/2014

-- A) Listar os participantes que possuam empréstimo VIGENTE (VG). Campos: Código da 
-- patrocinadora, matricula e nome do participante, id do requerimento de empréstimo, 
-- número do contrato de empréstimo, prazo contrato. (SISTEMA DE EMPRÉSTIMO)

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


-- B) Listar a quantidade de participantes no plano que possuam situação de ATIVO, 
-- AUTOPATROCINADO/AUTO PARCIAL, ordenado pela patroc. Campos: Patroc, situação e 
-- quantidade. (SISTEMA PREVIDENCIÁRIO)

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


-- C) Listar os participantes que tenham data de crédito de empréstimo Vigente no mês de
-- referência 05/2012. Campos: Código da patrocinadora, matricula e nome do participante,
-- id do requerimento de empréstimo, número do contrato de empréstimo,
-- data de crédito. (SISTEMA DE EMPRÉSTIMO)

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


-- D) Listar as situações no plano (Identificador, Codigo e Descrição) ordenado pela 
-- descrição. (SISTEMA PREVIDENCIÁRIO)

SELECT 
		IDSITPLA AS Identificador,
		CDSITPLA AS Codigo,
		DCSITPLA AS Descricao
FROM 
		PAR_SITPLANOS
ORDER BY 
		DCSITPLA
GO


-- E) Listar os participantes que tenham liquidado empréstimo por reforma (LR) no mês de
-- referência 04/2012. Campos: Código da patrocinadora, matricula e nome do participante, 
-- id do requerimento de empréstimo, número do contrato de empréstimo,
-- data de liquidação. (SISTEMA DE EMPRÉSTIMO)

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
-- do participante. Campos: Código e Descrição da Patroc, Matricula, Inscrição e Nome do 
-- Participante). (SISTEMA PREVIDENCIÁRIO)

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

-- G) Listar as formas de cobrança dos participantes que tenha empréstimo VIGENTE. Campo: 
-- Matricula e Nome dos participantes, número do contrato de Empréstimo, Forma de Cobrança
-- (Código e Descrição). (SISTEMA DE EMPRÉSTIMO)

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


-- H) Listar os participantes que possuem situação AUTOPATROCINADO/AUTO PARCIAL ordenado 
-- por situação, patroc e nome do participante. Campos: Código Patrocinadora, Matricula e
-- Nome do Participante, Situação. (SISTEMA PREVIDENCIÁRIO)

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


-- I) Listar o somatório total de recebimentos (qualquer pagamento) no mês de referência 
-- 06/2012. (SISTEMA DE EMPRÉSTIMO)
SELECT 
    SUM(PCL.VRPCLPAG) AS TotalRecebimentos
FROM 
    EPT_PARCELAS PCL
WHERE 
    PCL.DTMESREF = '201206' 
GO 

-- J) Listar os contratos que foram LIQUIDADOS no mês de referência 05/2012.
-- Campos: número do contrato, data de liquidação. (SISTEMA DE EMPRÉSTIMO)

SELECT 
    REQ.NRCTT AS NumeroContrato,
    REQ.DTLIQ AS DataLiquidacao
FROM 
    EPT_REQUERIMENTO REQ
WHERE 
    YEAR(REQ.DTLIQ) = 2012
    AND MONTH(REQ.DTLIQ) = 5;


-- K) Listar apenas as parcelas geradas no mês de referência 07/2012. Campos: identificador
-- do requerimento de empréstimo, mês de referência, valor da parcela. (SISTEMA DE EMPRÉSTIMO)
 
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

 
-- L) Listar as parcelas que tiveram Baixa Manual anteriores ao mês de referência 11/2011.
-- Campos: número do contrato, número da parcelas, data efetiva de pagamento. (SISTEMA DE EMPRÉSTIMO)

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

-- M) Listar apenas as parcelas confirmadas no mês de referência 06/2012. 
-- OBS: Campos: identificador do requerimento de empréstimo, mês de referência, 
-- valor da parcela. (SISTEMA DE EMPRÉSTIMO)

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
	

-- N) Listar apenas as parcelas que tiveram Baixa Manual no mês de referência 06/2012.
-- Campos: número do contrato, número da parcelas, data efetiva de pagamento. (SISTEMA DE EMPRÉSTIMO)

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

-- O) Listar apenas as parcelas integradas (A) no mês de referência 07/2012. 
-- Campos: identificador do requerimento de empréstimo, mês de referência, 
-- valor da parcela. (SISTEMA DE EMPRÉSTIMO)

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


-- P) Listar os contratos que tiveram AMORTIZAÇÃO no mês de referência 06/2012. 
-- Campos: número do contrato, número da parcelas, valor amortizado. (SISTEMA DE EMPRÉSTIMO)

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


-- Q) Listar os contratos que foram LIQUIDADOS no mês de referência 05/2012.
-- Campos: número do contrato, data de liquidação. (SISTEMA DE EMPRÉSTIMO)

SELECT 
    REQ.NRCTT AS NumeroContrato,
    REQ.DTLIQ AS DataLiquidacao
FROM 
    EPT_REQUERIMENTO REQ
WHERE 
    YEAR(REQ.DTLIQ) = 2012
    AND MONTH(REQ.DTLIQ) = 5
GO


-- R) Altere o nome do participante que tem a inscrição nº 000068601 (De: Eduardo C Vieira
-- para : Eduardo Carvalho Vieira ).

BEGIN TRANSACTION 
	
	UPDATE PAR_PARTICIPANTES
	SET NMPAR = 'Eduardo Carvalho Vieira'
	WHERE NRISC = '000068601'

COMMIT 
GO