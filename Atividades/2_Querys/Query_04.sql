-- Sistema Previdenciário

SELECT TABLE_NAME
FROM [sysprevnucleos_hom].INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME
GO


-- b) Listar apenas os participantes ATIVOS no plano, ordenado pela patrocinadora e nome 
-- do  participante. Campos: Código e Descrição da Patroc, Matricula, Inscrição e Nome do 
-- Participante).

SELECT 
		IDPAR, 
		DCPAT, 
		NRMAT, 
		NRISC, 
		NMPAR
FROM	
		PAR_PARPLA PPLA
JOIN
		PAR_PARTICIPANTES P
ON 
		P.IDPAR=PPLA.ID.PAR
WHERE
		PPLA

GO

SP_HELP PAR_PARPLA
	




-- d) Listar a quantidade de participantes no plano que possuam situação de ATIVO,
-- AUTOPATROCINADO/AUTO PARCIAL, ordenado pela patroc. Campos: Patroc, situação e 
-- quantidade.


-- a) Listar as situações no plano (Identificador, Codigo e Descrição) ordenado pela 
-- descrição



-- c) Listar os participantes que possuem situação AUTOPATROCINADO/AUTO PARCIAL
-- ordenado por situação, patroc e nome do participante. Campos: Código Patrocinadora,
-- Matricula e Nome do Participante, Situação.



-------------------------------------------------------------------------------------------------------------------------------------------------



-- a) Listar apenas as parcelas geradas no mês de referência 07/2012.



--IDPCL       IDREQEPT    DTMESREF NRPCLEPT    STPCLEPT DTPAGPCL                DTEFEPAGPCL             VRSDODVDANT                             VRPCL                                   VRPCLPAG                                VRSALBAS                                VRJURPCL                                VRCORMON                                VRTAXADN                                VRQQM                                   VRMRA                                   VRJURMRA                                VRDSC                                   VRIOF                                   DTDVOPCL                DTBXAMNL                VRCORMRA                                TPPCL NRAVIREC  DTLANREC                IDFORCBAEFE VRMRAPAG                                VRJURMRAPAG                             VRCORMRAPAG                             VRQQMPAG                                VRTAXADNPAG                             VRSDODVDATU                             IDGRCPCL DTMOV                   AUUSUULTALT                                                                                          AUDATULTALT             AUVRSULTATU VRTAXLQZ                                VRTAXLQZPAG                             IDLANRUBEXT IDFORCBA    DTMESREFPCL VRPCLBASE                               VRTAXLQZPCL                             VRTAXQQMPCL
------------- ----------- -------- ----------- -------- ----------------------- ----------------------- --------------------------------------- --------------------------------------- --------------------------------------- --------------------------------------- --------------------------------------- --------------------------------------- --------------------------------------- --------------------------------------- --------------------------------------- --------------------------------------- --------------------------------------- --------------------------------------- ----------------------- ----------------------- --------------------------------------- ----- --------- ----------------------- ----------- --------------------------------------- --------------------------------------- --------------------------------------- --------------------------------------- --------------------------------------- --------------------------------------- -------- ----------------------- ---------------------------------------------------------------------------------------------------- ----------------------- ----------- --------------------------------------- --------------------------------------- ----------- ----------- ----------- --------------------------------------- --------------------------------------- ---------------------------------------
--595799      75645       201207   48          G        2012-07-25 00:00:00.000 NULL                    4057.19                                 146.95                                  NULL                                    4309.51                                 20.56                                   44.81                                   10.32                                   2.47                                    NULL                                    NULL                                    NULL                                    5.09                                    NULL                    NULL                    NULL                                    P     NULL      NULL                    NULL        NULL                                    NULL                                    NULL                                    NULL                                    NULL                                    4140.44                                 S        2012-07-06 15:59:36.770 dbo                                                                                                  2012-07-06 15:59:36.770 1           0.00                                    NULL                                    NULL        NULL        NULL        NULL                                    NULL                                    NULL
--595993      75877       201207   39          G        2012-08-06 00:00:00.000 NULL                    2852.85                                 75.76                                   NULL                                    2755.00                                 14.46                                   31.51                                   7.26                                    1.74                                    NULL                                    NULL                                    NULL                                    3.58                                    NULL                    NULL                    NULL                                    P     NULL      NULL                    NULL        NULL                                    NULL                                    NULL                                    NULL                                    NULL                                    2911.40                                 S        2012-07-06 16:00:12.960 dbo                                                                                                  2012-07-06 16:00:12.960 1           0.00                                    NULL                                    NULL        NULL        NULL        NULL                                    NULL                                    NULL
--656069      75645       201207   73          G        2013-09-03 00:00:00.000 NULL                    4873.78                                 146.95                                  NULL                                    4053.00                                 24.65                                   44.44                                   12.37                                   2.97                                    NULL                                    NULL                                    NULL                                    6.10                                    NULL                    NULL                    NULL                                    P     NULL      NULL                    NULL        NULL                                    NULL                                    NULL                                    NULL                                    NULL                                    4964.31                                 S        2014-01-27 10:43:09.197 nucleos                                                                                              2014-01-27 10:43:09.197 1           0.00                                    NULL                                    NULL        NULL        NULL        138.21                                  0.00                                    2.97



-- b) Listar apenas as parcelas confirmadas no mês de referência 06/2012. 
-- OBS: Campos para os itens a) e b): identificador do requerimento de empréstimo, mês
-- de referência, valor da parcela.




-- c) Listar apenas as parcelas integradas (A) no mês de referência 07/2012. Campos: 
-- identificador do requerimento de empréstimo, mês de referência, valor da parcela.




-- d) Listar os contratos que tiveram AMORTIZAÇÃO no mês de referência 06/2012. Campos:
-- número do contrato, número da parcelas, valor amortizado.



-- e) Listar os contratos que foram LIQUIDADOS no mês de referência 05/2012. Campos:
-- número do contrato, data de liquidação



-- QUANTOS CONTRATOS FORAM LIQUIDADOS NO MÊS DE REFERENCIA 05/2012. CAMPOS QUANTIDADE



-- f) Listar apenas as parcelas que tiveram Baixa Manual no mês de referência 06/2012. 
-- Campos: número do contrato, número da parcelas, data efetiva de pagamento.



-- g) Listar as parcelas que tiveram Baixa Manual anteriores ao mês de referência 
-- 11/2011. Campos: número do contrato, número da parcelas, data efetiva de pagamento.



-- h) Listar o somatório total de recebimentos (qualquer pagamento) no mês de referência 
-- 06/2012.


