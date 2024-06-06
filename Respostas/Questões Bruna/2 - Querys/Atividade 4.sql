-- Sistema Previdenci�rio

-- b) Listar apenas os participantes ATIVOS no plano, ordenado pela patrocinadora e nome 
-- do  participante. Campos: C�digo e Descri��o da Patroc, Matricula, Inscri��o e Nome do 
-- Participante).

SELECT 
		P.IDPAR, 
		PT.DCPAT, 
		P.NRMAT,
		P.NRISC, 
		P.NMPAR
FROM 
		PAR_PARTICIPANTES P
JOIN	PAR_PATROCINADORAS PT ON P.CDPAT=PT.CDPAT
JOIN	PAR_PARPLA PL ON P.IDPAR=PL.IDPAR
WHERE	PL.IDSITPLA=1
ORDER BY PT.DCPAT, P.NMPAR
GO


-- d) Listar a quantidade de participantes no plano que possuam situa��o de ATIVO,
-- AUTOPATROCINADO/AUTO PARCIAL, ordenado pela patroc. Campos: Patroc, situa��o e 
-- quantidade.


SELECT 
    PT.DCPAT,
    PL.CDSITPLA,
    COUNT(DISTINCT P.IDPAR) AS TotalParticipantes
FROM 
    PAR_PARTICIPANTES P
JOIN    
    PAR_PARPLA PL ON PL.IDPAR = P.IDPAR
JOIN    
    PAR_PATROCINADORAS PT ON PT.CDPAT = PL.CDPAT
WHERE   
    PL.CDSITPLA IN (1, 23)
GROUP BY 
    PT.DCPAT,
    PL.CDSITPLA
ORDER BY 
    PT.DCPAT
GO

-- a) Listar as situa��es no plano (Identificador, Codigo e Descri��o) ordenado pela 
-- descri��o

SELECT 
		PL.IDSITPLA, 
		PL.CDSITPLA, 
		PL.DCSITPLA
FROM
		PAR_SITPLANOS PL
ORDER BY 
		DCSITPLA
GO
		
-- c) Listar os participantes que possuem situa��o AUTOPATROCINADO/AUTO PARCIAL
-- ordenado por situa��o, patroc e nome do participante. Campos: C�digo Patrocinadora,
-- Matricula e Nome do Participante, Situa��o.


SELECT PT.CDPAT, P.NRMAT,P.NMPAR, PL.CDSITPLA FROM PAR_PARTICIPANTES P 
INNER JOIN PAR_PARPLA PL ON PL.IDPAR=P.IDPAR 
INNER JOIN PAR_PATROCINADORAS PT ON PL.CDPAT=PT.CDPAT
ORDER BY CDSITPLA, DCPAT,NMPAR
GO

-------------------------------------------------------------------------------------------------------------------------------------------------
-- a) Listar apenas as parcelas geradas no m�s de refer�ncia 07/2012.

SELECT* FROM EPT_PARCELAS WHERE DTMESREF = 201207


-- b) Listar apenas as parcelas confirmadas no m�s de refer�ncia 06/2012. 
-- OBS: Campos para os itens a) e b): identificador do requerimento de empr�stimo, m�s
-- de refer�ncia, valor da parcela.

SELECT 
    IDREQEPT, 
    DTMESREF,
    VRPCL 
FROM 
    EPT_PARCELAS 
WHERE 
    DATEPART(YEAR, DTEFEPAGPCL) = 2012 AND DATEPART(MONTH, DTEFEPAGPCL) = 06
GO


-- c) Listar apenas as parcelas integradas (A) no m�s de refer�ncia 07/2012. Campos: 
-- identificador do requerimento de empr�stimo, m�s de refer�ncia, valor da parcela.

SELECT 
    IDREQEPT, 
    DTMESREF, 
    VRPCL
FROM 
    EPT_PARCELAS
WHERE 
     STPCLEPT= 'A' 
    AND DTMESREF = '201207'
GO


-- d) Listar os contratos que tiveram AMORTIZA��O no m�s de refer�ncia 06/2012. Campos:
-- n�mero do contrato, n�mero da parcelas, valor amortizado.


SELECT 
    R.NRCTT, 
    P.NRPCLEPT, 
    P.VRPCLPAG
FROM 
    EPT_PARCELAS P
JOIN EPT_REQUERIMENTO R ON R.IDREQEPT=P.IDREQEPT
WHERE 
    TPPCL = 'V' 
    AND DTMESREF = '201206'
GO


-- e) Listar os contratos que foram LIQUIDADOS no m�s de refer�ncia 05/2012. 
-- Campos: n�mero do contrato, data de liquida��o

SELECT 
    NRCTT, 
    DATEPART(YEAR,DTLIQ)
FROM 
    EPT_REQUERIMENTO
WHERE 
    DTLIQ IS NOT NULL 
    AND DATEPART(YEAR, DTLIQ) = 2012 AND DATEPART(MONTH, DTLIQ) = 05
GO


-- QUANTOS CONTRATOS FORAM LIQUIDADOS NO M�S DE REFERENCIA 05/2012. CAMPOS QUANTIDADE

SELECT 
    COUNT(*) AS QUANTIDADE
FROM 
    EPT_REQUERIMENTO
WHERE 
    DTLIQ IS NOT NULL 
    AND DATEPART(YEAR, DTLIQ)= 2012 AND DATEPART(MONTH, DTLIQ)=05
GO


-- f) Listar apenas as parcelas que tiveram Baixa Manual no m�s de refer�ncia 06/2012. 
-- Campos: n�mero do contrato, n�mero da parcelas, data efetiva de pagamento.

SELECT 
		R.NRCTT, 
		P.NRPCLEPT, 
		P.DTPAGPCL 
FROM 
		EPT_PARCELAS P
JOIN	
		EPT_REQUERIMENTO R ON R.IDREQEPT=P.IDREQEPT
WHERE 
		P.STPCLEPT = 'C' 
		AND DTMESREF = '201206'
GO


-- g) Listar as parcelas que tiveram Baixa Manual anteriores ao m�s de refer�ncia 
-- 11/2011. Campos: n�mero do contrato, n�mero da parcelas, data efetiva de pagamento.

SELECT 
		R.NRCTT, 
		P.NRPCLEPT, 
		P.DTPAGPCL
FROM 
		EPT_PARCELAS P
JOIN	
		EPT_REQUERIMENTO R ON R.IDREQEPT=P.IDREQEPT
WHERE 
		P.STPCLEPT = 'C' AND
		 DTMESREF < '201111' --DTMESREF > '201111' (COM ESSE QUALIFICADOR EXISTE REGISTROS)
ORDER BY 
		DTPAGPCL
GO


-- h) Listar o somat�rio total de recebimentos (qualquer pagamento) no m�s de refer�ncia 
-- 06/2012.


SELECT 
    SUM(VRPCL) AS TOTAL_RECEBIMENTOS
FROM 
    EPT_PARCELAS
WHERE 
    DTMESREF = '201206' AND DTEFEPAGPCL IS NOT NULL;
GO
