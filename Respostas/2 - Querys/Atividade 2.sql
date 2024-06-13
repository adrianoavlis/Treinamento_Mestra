-- a) Listar os participantes que possuam empréstimo VIGENTE (VG). Campos: Código da
-- patrocinadora, matricula e nome do participante, id do requerimento de empréstimo,
-- número do contrato de empréstimo, ********prazo contrato.

SELECT CDPAT, NRMAT, IDREQEPT, NRCTT, QTPRZ FROM EPT_REQUERIMENTO  R
JOIN PAR_PARTICIPANTES P ON P.IDPAR= R.IDPAR
WHERE IDSITEPT = 'VG' 
GO

-- d) Listar as formas de cobrança dos participantes que tenha empréstimo VIGENTE. 
-- Campo: Matricula e Nome dos participantes, número do contrato de Empréstimo, Forma 
-- de Cobrança (Código e *********Descrição).

SELECT 
    p.NRMAT AS Matricula,
    p.NMPAR AS Nome,
    r.NRCTT AS Numero_Contrato,
    t.CDEPTCBA AS Codigo_Cobranca,
    t.DCEPTCBA AS Descricao_Cobranca
FROM 
    PAR_PARTICIPANTES p
JOIN 
    EPT_REQUERIMENTO r ON p.IDPAR = r.IDPAR
JOIN 
    EPT_TIPOCOBRANCA t ON r.IDTIPEPT = t.IDEPTCBA
WHERE 
    r.DTVCTFIM IS NULL
GO
 

-- c) Listar os participantes que tenham liquidado empréstimo por reforma (LR) no mês de 
-- referência 04/2012. Campos: Código da patrocinadora, matricula e nome do participante,
-- id do requerimento de empréstimo, número do contrato de empréstimo, data de 
-- liquidação.

SELECT 
    p.CDPAT AS Codigo_Patrocinadora,
    p.NRMAT AS Matricula,
    p.NMPAR AS Nome,
    r.IDREQEPT AS ID_Requerimento,
    r.NRCTT AS Numero_Contrato,
    r.DTLIQ AS Data_Liquidacao, 
	R.IDSITEPT AS ID_SIT
FROM 
    PAR_PARTICIPANTES p
JOIN 
    EPT_REQUERIMENTO r ON p.IDPAR = r.IDPAR
WHERE 
    r.IDSITEPT = 'LR' AND
    r.DTLIQ BETWEEN '2012-04-01' AND '2012-04-30';
GO


-------------------------------------------------------------------------------------------------------------------------------------------------

-- b) Listar os participantes que tenham data de crédito de empréstimo Vigente no mês de
-- referência 05/2012. Campos: Código da patrocinadora, matricula e nome do participante,
-- id do requerimento de empréstimo, número do contrato de empréstimo, data de crédito.

SELECT 
    p.CDPAT AS Codigo_Patrocinadora,
    p.NRMAT AS Matricula,
    p.NMPAR AS Nome,
    r.IDREQEPT AS ID_Requerimento,
    r.NRCTT AS Numero_Contrato,
    r.DTCRE AS Data_Credito
FROM 
    PAR_PARTICIPANTES p
JOIN 
    EPT_REQUERIMENTO r ON p.IDPAR = r.IDPAR
WHERE 
    r.DTCRE BETWEEN '2012-05-01' AND '2012-05-31'
    AND (r.DTVCTFIM IS NULL OR r.DTVCTFIM > '2012-05-31');
GO

