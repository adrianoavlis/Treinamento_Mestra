
-- Data Inicio: 18/03/2014

-- A) Listar os participantes que possuam empr�stimo VIGENTE (VG). Campos: C�digo da 
-- patrocinadora, matricula e nome do participante, id do requerimento de empr�stimo, 
-- n�mero do contrato de empr�stimo, prazo contrato. (SISTEMA DE EMPR�STIMO)



-- SELECT CDPAT + ' - ' + DCPAT AS PATROCINADORAS 
-- FROM PAR_PATROCINADORAS 



-- B) Listar a quantidade de participantes no plano que possuam situa��o de ATIVO, 
-- AUTOPATROCINADO/AUTO PARCIAL, ordenado pela patroc. Campos: Patroc, situa��o e 
-- quantidade. (SISTEMA PREVIDENCI�RIO)



-- C) Listar os participantes que tenham data de cr�dito de empr�stimo Vigente no m�s de
-- refer�ncia 05/2012. Campos: C�digo da patrocinadora, matricula e nome do participante,
-- id do requerimento de empr�stimo, n�mero do contrato de empr�stimo,
-- data de cr�dito. (SISTEMA DE EMPR�STIMO)



-- D) Listar as situa��es no plano (Identificador, Codigo e Descri��o) ordenado pela 
-- descri��o. (SISTEMA PREVIDENCI�RIO)



-- E) Listar os participantes que tenham liquidado empr�stimo por reforma (LR) no m�s de
-- refer�ncia 04/2012. Campos: C�digo da patrocinadora, matricula e nome do participante, 
-- id do requerimento de empr�stimo, n�mero do contrato de empr�stimo,
-- data de liquida��o. (SISTEMA DE EMPR�STIMO)



-- F) Listar apenas os participantes ATIVOS no plano, ordenado pela patrocinadora e nome
-- do participante. Campos: C�digo e Descri��o da Patroc, Matricula, Inscri��o e Nome do 
-- Participante). (SISTEMA PREVIDENCI�RIO)



-- G) Listar as formas de cobran�a dos participantes que tenha empr�stimo VIGENTE. Campo: 
-- Matricula e Nome dos participantes, n�mero do contrato de Empr�stimo, Forma de Cobran�a
-- (C�digo e Descri��o). (SISTEMA DE EMPR�STIMO)




-- H) Listar os participantes que possuem situa��o AUTOPATROCINADO/AUTO PARCIAL ordenado 
-- por situa��o, patroc e nome do participante. Campos: C�digo Patrocinadora, Matricula e
-- Nome do Participante, Situa��o. (SISTEMA PREVIDENCI�RIO)



-- I) Listar o somat�rio total de recebimentos (qualquer pagamento) no m�s de refer�ncia 
-- 06/2012. (SISTEMA DE EMPR�STIMO)



-- J) Listar os contratos que foram LIQUIDADOS no m�s de refer�ncia 05/2012.
-- Campos: n�mero do contrato, data de liquida��o. (SISTEMA DE EMPR�STIMO)




-- K) Listar apenas as parcelas geradas no m�s de refer�ncia 07/2012. Campos: identificador
-- do requerimento de empr�stimo, m�s de refer�ncia, valor da parcela. (SISTEMA DE EMPR�STIMO)
 

 
 
-- IDREQEPT    DTMESREF VRPCL
------------- -------- ---------------------------------------
--75645       201207   146.95
--75877       201207   75.76

--(2 linha(s) afetadas)


-- UPDATE NOME DA TABELA
-- SET CAMPO A SER ALTERADO = NOVO VALOR 
-- WHERE IDREQEPT =  
 
 
-- L) Listar as parcelas que tiveram Baixa Manual anteriores ao m�s de refer�ncia 11/2011.
-- Campos: n�mero do contrato, n�mero da parcelas, data efetiva de pagamento. (SISTEMA DE EMPR�STIMO)



-- M) Listar apenas as parcelas confirmadas no m�s de refer�ncia 06/2012. 
-- OBS: Campos: identificador do requerimento de empr�stimo, m�s de refer�ncia, 
-- valor da parcela. (SISTEMA DE EMPR�STIMO)



-- N) Listar apenas as parcelas que tiveram Baixa Manual no m�s de refer�ncia 06/2012.
-- Campos: n�mero do contrato, n�mero da parcelas, data efetiva de pagamento. (SISTEMA DE EMPR�STIMO)




-- O) Listar apenas as parcelas integradas (A) no m�s de refer�ncia 07/2012. 
-- Campos: identificador do requerimento de empr�stimo, m�s de refer�ncia, 
-- valor da parcela. (SISTEMA DE EMPR�STIMO)



-- P) Listar os contratos que tiveram AMORTIZA��O no m�s de refer�ncia 06/2012. 
-- Campos: n�mero do contrato, n�mero da parcelas, valor amortizado. (SISTEMA DE EMPR�STIMO)



-- Q) Listar os contratos que foram LIQUIDADOS no m�s de refer�ncia 05/2012.
-- Campos: n�mero do contrato, data de liquida��o. (SISTEMA DE EMPR�STIMO)



-- R) Altere o nome do participante que tem a inscri��o n� 000068601 (De: Eduardo C Vieira
-- para : Eduardo Carvalho Vieira ).

--UPDATE PAR_PARTICIPANTES
--SET NMPAR = 'Eduardo Carvalho Vieira'
--WHERE NRISC = 000068601 


