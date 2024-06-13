
-- Data Inicio: 18/03/2014

-- A) Listar os participantes que possuam empréstimo VIGENTE (VG). Campos: Código da 
-- patrocinadora, matricula e nome do participante, id do requerimento de empréstimo, 
-- número do contrato de empréstimo, prazo contrato. (SISTEMA DE EMPRÉSTIMO)



-- SELECT CDPAT + ' - ' + DCPAT AS PATROCINADORAS 
-- FROM PAR_PATROCINADORAS 



-- B) Listar a quantidade de participantes no plano que possuam situação de ATIVO, 
-- AUTOPATROCINADO/AUTO PARCIAL, ordenado pela patroc. Campos: Patroc, situação e 
-- quantidade. (SISTEMA PREVIDENCIÁRIO)



-- C) Listar os participantes que tenham data de crédito de empréstimo Vigente no mês de
-- referência 05/2012. Campos: Código da patrocinadora, matricula e nome do participante,
-- id do requerimento de empréstimo, número do contrato de empréstimo,
-- data de crédito. (SISTEMA DE EMPRÉSTIMO)



-- D) Listar as situações no plano (Identificador, Codigo e Descrição) ordenado pela 
-- descrição. (SISTEMA PREVIDENCIÁRIO)



-- E) Listar os participantes que tenham liquidado empréstimo por reforma (LR) no mês de
-- referência 04/2012. Campos: Código da patrocinadora, matricula e nome do participante, 
-- id do requerimento de empréstimo, número do contrato de empréstimo,
-- data de liquidação. (SISTEMA DE EMPRÉSTIMO)



-- F) Listar apenas os participantes ATIVOS no plano, ordenado pela patrocinadora e nome
-- do participante. Campos: Código e Descrição da Patroc, Matricula, Inscrição e Nome do 
-- Participante). (SISTEMA PREVIDENCIÁRIO)



-- G) Listar as formas de cobrança dos participantes que tenha empréstimo VIGENTE. Campo: 
-- Matricula e Nome dos participantes, número do contrato de Empréstimo, Forma de Cobrança
-- (Código e Descrição). (SISTEMA DE EMPRÉSTIMO)




-- H) Listar os participantes que possuem situação AUTOPATROCINADO/AUTO PARCIAL ordenado 
-- por situação, patroc e nome do participante. Campos: Código Patrocinadora, Matricula e
-- Nome do Participante, Situação. (SISTEMA PREVIDENCIÁRIO)



-- I) Listar o somatório total de recebimentos (qualquer pagamento) no mês de referência 
-- 06/2012. (SISTEMA DE EMPRÉSTIMO)



-- J) Listar os contratos que foram LIQUIDADOS no mês de referência 05/2012.
-- Campos: número do contrato, data de liquidação. (SISTEMA DE EMPRÉSTIMO)




-- K) Listar apenas as parcelas geradas no mês de referência 07/2012. Campos: identificador
-- do requerimento de empréstimo, mês de referência, valor da parcela. (SISTEMA DE EMPRÉSTIMO)
 

 
 
-- IDREQEPT    DTMESREF VRPCL
------------- -------- ---------------------------------------
--75645       201207   146.95
--75877       201207   75.76

--(2 linha(s) afetadas)


-- UPDATE NOME DA TABELA
-- SET CAMPO A SER ALTERADO = NOVO VALOR 
-- WHERE IDREQEPT =  
 
 
-- L) Listar as parcelas que tiveram Baixa Manual anteriores ao mês de referência 11/2011.
-- Campos: número do contrato, número da parcelas, data efetiva de pagamento. (SISTEMA DE EMPRÉSTIMO)



-- M) Listar apenas as parcelas confirmadas no mês de referência 06/2012. 
-- OBS: Campos: identificador do requerimento de empréstimo, mês de referência, 
-- valor da parcela. (SISTEMA DE EMPRÉSTIMO)



-- N) Listar apenas as parcelas que tiveram Baixa Manual no mês de referência 06/2012.
-- Campos: número do contrato, número da parcelas, data efetiva de pagamento. (SISTEMA DE EMPRÉSTIMO)




-- O) Listar apenas as parcelas integradas (A) no mês de referência 07/2012. 
-- Campos: identificador do requerimento de empréstimo, mês de referência, 
-- valor da parcela. (SISTEMA DE EMPRÉSTIMO)



-- P) Listar os contratos que tiveram AMORTIZAÇÃO no mês de referência 06/2012. 
-- Campos: número do contrato, número da parcelas, valor amortizado. (SISTEMA DE EMPRÉSTIMO)



-- Q) Listar os contratos que foram LIQUIDADOS no mês de referência 05/2012.
-- Campos: número do contrato, data de liquidação. (SISTEMA DE EMPRÉSTIMO)



-- R) Altere o nome do participante que tem a inscrição nº 000068601 (De: Eduardo C Vieira
-- para : Eduardo Carvalho Vieira ).

--UPDATE PAR_PARTICIPANTES
--SET NMPAR = 'Eduardo Carvalho Vieira'
--WHERE NRISC = 000068601 


