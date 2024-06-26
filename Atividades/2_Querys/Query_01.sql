-- OPERA��ES COM DATAS.

-- UNIDADES: DIA - DD / MES - MM / ANO - YY

-- - GETDATE() -> OBTEM A DATA ATUAL DO SISTEMA

SELECT GETDATE()


-- - DATEPART (UNIDADE, DATA) -> RETORNA UM INTEIRO


SELECT DATEPART(HH, '1992-12-08')


-- - DATEADD (UNIDADE, QUANTIDADE, DATA) -> ADICIONA UM VALOR A UNIDADE
SELECT DATEADD(month, 1, '20240830');
SELECT DATEADD(DAY, 1, '2024-08-31');

-- - DATEDIFF (UNIDADE, DATA 1, DATA 2) -> DIFEREN�A ENTRE DATAS / COMPARA��O - SEMPRE DATA 2 - DATA 1 

SELECT DATEDIFF(YY, '1992-12-08', '2024-06-05')

-------------------------------------------------------------------------------------------------------

-- (USAR O SELECT)
-- 1) LISTAR A DIFEREN�A DE DIAS ENTRE A DATA ATUAL E O DIA 01/03/2014.


SELECT DATEDIFF(DD, '01-03-2014', '2024-06-05')

-- 2) ACRESCENTAR UM DIA A MAIS NA DATA 05/03/2014.

SELECT DATEADD(DAY, 1, '2014-05-03');

-- 3) LISTAR O ANO DA DATA 30/06/2013.

SELECT DATEPART(YY,'2013-06-30')
SELECT DATEPART(YY,'06-30-2013')

-- LISTAR A DATA ATUAL nos seguites formatos:
-- A) dd/mm/aa
SELECT FORMAT(GETDATE(), 'dd/MM/yy') AS Data_Atual_dd_mm_aa;
-- B) dd/mm/aaaa
SELECT FORMAT(GETDATE(), 'dd/MM/yyyy') AS Data_Atual_dd_mm_aaaa;
-- C) aaaamm (sem barra)
SELECT CONVERT(VARCHAR(6), GETDATE(), 112) AS Data_Atual_aaaamm;	--  (12	 - 112	- ISO)		12 = aammdd / 112 = yyyymmdd

--##############################################################################################################################################

-- USO DA CL�USULA HAVING 
/*
EXEMPLO : EXIBIR O N�MERO DO CPF, O NOME DO PARTICIPANTE E A QUANTIDADE DE CPFs QUE
TERMINAM A N�MERA��O EM 99 E QUANDO A QUANTIDADE FOR MENOR OU IGUAL A 26. 
*/



