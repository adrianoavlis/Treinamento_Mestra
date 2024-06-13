-- a) Listar os participantes que possuam empr�stimo VIGENTE (VG). Campos: C�digo da
-- patrocinadora, matricula e nome do participante, id do requerimento de empr�stimo,
-- n�mero do contrato de empr�stimo, ********prazo contrato.

SELECT CDPAT, NRMAT, IDREQEPT, NRCTT, QTPRZ FROM EPT_REQUERIMENTO  R
JOIN PAR_PARTICIPANTES P ON P.IDPAR= R.IDPAR
WHERE IDSITEPT = 'VG' 
GO

-- d) Listar as formas de cobran�a dos participantes que tenha empr�stimo VIGENTE. 
-- Campo: Matricula e Nome dos participantes, n�mero do contrato de Empr�stimo, Forma 
-- de Cobran�a (C�digo e *********Descri��o).

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
 

-- c) Listar os participantes que tenham liquidado empr�stimo por reforma (LR) no m�s de 
-- refer�ncia 04/2012. Campos: C�digo da patrocinadora, matricula e nome do participante,
-- id do requerimento de empr�stimo, n�mero do contrato de empr�stimo, data de 
-- liquida��o.

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

-- b) Listar os participantes que tenham data de cr�dito de empr�stimo Vigente no m�s de
-- refer�ncia 05/2012. Campos: C�digo da patrocinadora, matricula e nome do participante,
-- id do requerimento de empr�stimo, n�mero do contrato de empr�stimo, data de cr�dito.

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

