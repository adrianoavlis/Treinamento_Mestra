CREATE OR REPLACE PROCEDURE MEPB0129
(
      PSCDFUN    IN  CHAR,
      PSCDPAT    IN  CHAR,
      PSNRPLA    IN  CHAR,
      PSDTMESREF IN  CHAR,
      PSDCUSU    IN  VARCHAR2,
      PSDCERR    OUT VARCHAR2
)
AS

--*====================================================================
--* Sistema....:  SYSPREV WEB (FAECES)
--* Módulo.....:  PARTICIPANTES / BENEFICIOS
--* Procedure..:  MEPB0129
--* Descricao..:  Geração Mensal do Relatório de Estatística SIPC-CAP
--* Programa...:
--* Tabelas ...:  BNF_HISIPCAP_PLANO
--* Revisões...:  Criação da procedure / Conversão
--* Data.......:  21/07/2010
--* Autor Rev..:  Luana Alves
--* Revisões...: Migração Oracle
--* Data.......: 29/09/2018
--* Autor Rev..: Alessandro
--*=====================================================================


      --Declaracao de Variaveis
      SDTMESANT          CHAR(6);
      STPSEXPAR          CHAR(1);
      SNRPLA               CHAR(2);
      SCDPAT               CHAR(3);
      SCDLAN               CHAR(5);
      DDTAUX               DATE;
      DDTAUX1             DATE;
      DDTULTDIAMESREF   DATE;
      NCDLAN               SMALLINT;
      NIDORI               SMALLINT;
      NNRIDA               SMALLINT;
      NQTPAR               SMALLINT;
      NQTREG               SMALLINT;
      SDCERR               VARCHAR(255);

      --Declaracao de cusror
      CURSOR C_POPULACAO IS
      SELECT
            1,
            nvl(PSCDPAT,'999') AS CDPAT,
            nvl(PSNRPLA,'99') AS NRPLA,
            ROUND( MONTHS_BETWEEN(DDTULTDIAMESREF, P.DTNSCPAR)/12.0,0),
            P.TPSEXPAR,
            COUNT(1)
            FROM  PAR_HISITPAR H, PAR_PARTICIPANTES P, PAR_PARPLA A
            WHERE  H.CDFUN    = PSCDFUN
            AND  ( H.CDPAT    = PSCDPAT OR PSCDPAT IS NULL)
            AND    H.NRPLA    = (  SELECT NRPLA
                                   FROM   PAR_PARPLA
                                   WHERE  CDFUN = H.CDFUN
                                   AND    CDPAT = H.CDPAT
                                   AND    NRISC = H.NRISC
                                   AND DTISCPAR = (SELECT MAX(DTISCPAR)
                                                   FROM  PAR_PARPLA
                                                   WHERE CDFUN = H.CDFUN
                                                   AND CDPAT = H.CDPAT
                                                   AND NRISC = H.NRISC)
                                                   AND (NRPLA = PSNRPLA OR PSNRPLA IS NULL)
                                )
            AND    H.DTINISIT  =( SELECT MAX(DTINISIT)
                                  FROM  PAR_HISITPAR
                                  WHERE CDFUN = H.CDFUN
                                  AND CDPAT = H.CDPAT
                                  AND NRISC = H.NRISC
                                  AND NRPLA = H.NRPLA
                                  AND DTINISIT <= DDTULTDIAMESREF
                                  AND ( (DTFIMSIT IS NULL) OR
                                        ( (DTFIMSIT >= DDTULTDIAMESREF) OR
                                          (DTSISFIM >= DDTULTDIAMESREF)
                                        )
                                      )
                                  AND DTSISINI <= DDTULTDIAMESREF
                                )
            AND H.SQSIT = (SELECT MAX(SQSIT)
                           FROM  PAR_HISITPAR
                           WHERE CDFUN = H.CDFUN
                           AND CDPAT = H.CDPAT
                           AND NRISC = H.NRISC
                           AND NRPLA = H.NRPLA
                           AND DTINISIT = H.DTINISIT
                           AND DTINISIT <= DDTULTDIAMESREF
                           AND ( (DTFIMSIT IS NULL) OR
                                 ( (DTFIMSIT >= DDTULTDIAMESREF) OR
                                   (DTSISFIM >= DDTULTDIAMESREF)
                                 )
                               )
                           AND DTSISINI <= DDTULTDIAMESREF
                          )
            --AND H.STISCATU IN('0','1','2')
            AND H.CDSITPLAATU IN('01','04','21','23')
            AND H.IDPARPLA = A.IDPARPLA
            --AND P.CDFUN = H.CDFUN
            --AND P.CDPAT = H.CDPAT
            --AND P.NRISC = H.NRISC
            AND P.IDPAR = A.IDPAR
            --AND  P.IDISCCTL = 'N'
            AND  nvl(P.IDISCCTL,'N') = 'N'
            GROUP BY ROUND( MONTHS_BETWEEN(DDTULTDIAMESREF, P.DTNSCPAR)/12.0,0), P.TPSEXPAR
      UNION
            SELECT
            2, nvl(PSCDPAT,'999') AS CDPAT,
            nvl(PSNRPLA,'99') AS NRPLA,
            ROUND( MONTHS_BETWEEN(DDTULTDIAMESREF, X.DTNSCPAR)/12.0,0), X.TPSEXPAR,COUNT(1)
            FROM (
            SELECT DISTINCT P.IDPAR, P.DTNSCPAR, P.TPSEXPAR
            FROM  BNF_BNFCONCEDIDOS BC,  BNF_BENEFICIOS BF,  BNF_BENEFICIARIOS BE,
                    PAR_PARTICIPANTES P, PAR_PARPLA A
            WHERE BC.CDFUN = PSCDFUN
                  AND (BC.CDPAT = PSCDPAT OR PSCDPAT IS NULL)
                  AND TO_CHAR(BC.DTCOSBNF, 'YYYYMM') <= PSDTMESREF
                  AND (BC.NRPLA = PSNRPLA OR PSNRPLA IS NULL)
                  AND nvl(BC.PRPAGUNC,0) < 100
                  AND BF.CDBNF = BC.CDBNF
                  AND BF.TPBNF IN ('AP','BP')
                  AND NOT EXISTS (SELECT 1
                          FROM  BNF_BENOCOR BO
                          WHERE BO.CDFUN = BC.CDFUN
                          AND BO.NRPCSFUN = BC.NRPCSFUN
                          AND (BO.TPOCO = 'E'
                    OR
                    UPPER(BO.DCMOTOCO) LIKE '%FALEC%'
                    OR
                    UPPER(BO.DCMOTOCO) LIKE '%ÓBITO%'
                    OR
                    UPPER(BO.DCMOTOCO) LIKE '%OBITO%')
                          AND TO_CHAR(BO.DTSISOCO, 'YYYYMM') < PSDTMESREF
                          AND BO.DTFIMOCO IS NULL)
                                      AND NOT EXISTS (SELECT 1
                                  FROM  BNF_BENOCOR BO
                                  WHERE BO.CDFUN = BC.CDFUN
                                  AND BO.NRPCSFUN = BC.NRPCSFUN
                                  AND BO.TPOCO = 'E'
                                  AND TO_CHAR(BO.DTSISOCO, 'YYYYMM') = PSDTMESREF
                                  AND NOT EXISTS (SELECT 1
                                          FROM  BNF_HIBENEFS HB
                                          WHERE HB.CDFUN = BO.CDFUN
                                          AND HB.NRPCSFUN = BO.NRPCSFUN
                                          AND HB.DTMESREF = PSDTMESREF))
                                          AND NOT EXISTS (SELECT 1
                                                  FROM  BNF_BNFCONCEDIDOS
                                                  WHERE CDFUN = BC.CDFUN
                                                  AND NRPCSFUNANT = BC.NRPCSFUN
                                                  AND TO_CHAR(DTCOSBNF, 'YYYYMM') <= PSDTMESREF)
                                                  AND NOT EXISTS (SELECT 1
                                                          FROM  BNF_HISITBNF
                                                          WHERE CDFUN = BC.CDFUN
                                                          AND NRPCSFUN = BC.NRPCSFUN
                                                          AND STBNF IN('05','08')
                                                          AND TO_CHAR(AUDATULTALT, 'YYYYMM') < PSDTMESREF)
            AND BE.IDBNFCCD = BC.IDBNFCCD
            AND BC.IDPARPLA = A.IDPARPLA
            --AND P.CDFUN = BC.CDFUN
            --AND P.CDPAT = BC.CDPAT
            --AND P.NRISC = BC.NRISC
            AND P.IDPAR = A.IDPAR
            --AND  P.IDISCCTL = 'N'
            AND  nvl(P.IDISCCTL,'N') = 'N') X
            GROUP BY ROUND( MONTHS_BETWEEN(DDTULTDIAMESREF, X.DTNSCPAR)/12.0,0), X.TPSEXPAR
      UNION
            SELECT
            3, nvl(PSCDPAT,'999') AS CDPAT,
            nvl(PSNRPLA,'99') AS NRPLA,
            ROUND( MONTHS_BETWEEN(DDTULTDIAMESREF, X.DTNSCDPD)/12.0,0), X.TPSEXDPD, COUNT(1)
            FROM (
            SELECT DISTINCT D.IDDEP, D.DTNSCDPD, D.TPSEXDPD
            FROM  BNF_BENEFICIARIOS BE, BNF_BNFCONCEDIDOS BC, PAR_DEPENDENTES D, PAR_PARTICIPANTES P, PAR_PARPLA A
            WHERE BE.CDFUN = PSCDFUN
                  AND (BC.CDPAT = PSCDPAT OR PSCDPAT IS NULL)
                  AND (BC.NRPLA = PSNRPLA OR PSNRPLA IS NULL)
                  AND BE.SQBEN > 0
                  --AND SUBSTRING(REPLACE(STR(BE.DTSISINC),'-',''),1,6) <= PSDTMESREF
                  --AND CONVERT(CHAR(6),BE.DTSISINC,112) <= PSDTMESREF
                  AND TO_CHAR(BE.DTCOSBNF, 'YYYYMM') <= PSDTMESREF
                  AND NOT EXISTS (SELECT 1
                          FROM  BNF_BENOCOR BO
                          WHERE BO.CDFUN = BE.CDFUN
                          AND BO.NRPCSFUN = BE.NRPCSFUN
                          AND BO.SQBEN = BE.SQBEN
                          AND (BO.TPOCO = 'E'
                    OR
                    UPPER(BO.DCMOTOCO) LIKE '%FALEC%'
                    OR
                    UPPER(BO.DCMOTOCO) LIKE '%ÓBITO%'
                    OR
                    UPPER(BO.DCMOTOCO) LIKE '%OBITO%')
                          --AND SUBSTRING(REPLACE(STR(BO.DTSISOCO),'-',''),1,6) < PSDTMESREF
                          AND TO_CHAR(BO.DTSISOCO, 'YYYYMM') < PSDTMESREF
                          AND BO.DTFIMOCO IS NULL)
                                      AND NOT EXISTS (SELECT 1
                                  FROM  BNF_BENOCOR BO
                                  WHERE BO.CDFUN = BE.CDFUN
                                  AND BO.NRPCSFUN = BE.NRPCSFUN
                                  AND BO.SQBEN = BE.SQBEN
                                  AND BO.TPOCO = 'E'
                                  --AND SUBSTRING(REPLACE(STR(BO.DTSISOCO),'-',''),1,6) = PSDTMESREF
                                  AND TO_CHAR(BO.DTSISOCO,'YYYYMM') = PSDTMESREF
                                  AND NOT EXISTS (SELECT 1
                                          FROM  BNF_HIBENEFS HB
                                          WHERE HB.CDFUN = BO.CDFUN
                                          AND HB.NRPCSFUN = BO.NRPCSFUN
                                          AND HB.DTMESREF = PSDTMESREF))
                                  AND BC.CDFUN = BE.CDFUN
                                  AND BC.NRPCSFUN = BE.NRPCSFUN
                                  AND BC.IDPARPLA = A.IDPARPLA
                                  --AND P.CDFUN = BC.CDFUN
                                  --AND P.CDPAT = BC.CDPAT
                                  --AND P.NRISC = BC.NRISC
                                  AND P.IDPAR = A.IDPAR
                                  --AND  P.IDISCCTL = 'N'
                                  AND  nvl(P.IDISCCTL,'N') = 'N'
                                  AND D.CDFUN = P.CDFUN
                                  AND D.CDPAT = P.CDPAT
                                  AND D.NRMAT = P.NRMAT
                                  AND D.SQDPD = BE.SQBEN ) X
              GROUP BY ROUND(MONTHS_BETWEEN(DDTULTDIAMESREF, X.DTNSCDPD)/12.0,0), X.TPSEXDPD;

BEGIN

    PR_BNF_GERA_HISIPCAP (PSCDFUN, PSCDPAT, PSNRPLA, PSDTMESREF, PSDCUSU,  PSDCERR);    
    RETURN;
  
  SDCERR := 'Erro ao calcular data';

  -- Calcular a ultima data do mes de referencia
  --22/11/2018 Danielson
  --DDTAUX1 := SUBSTR(PSDTMESREF,1,4) || '-' || SUBSTR(PSDTMESREF,5,2) || '-' || '01-00.00.00';
  DDTAUX1 := TO_DATE(PSDTMESREF||'01', 'YYYYMMDD');

  MEPG0002 (DDTAUX1);

  DDTULTDIAMESREF := DDTAUX1;

  IF PSDTMESREF >= '202001' THEN
    
    SDCERR := 'Erro ao limpar tabela SIPCAP';
    DELETE
    FROM  BNF_HISIPCAP_PLANO
    WHERE CDFUN = PSCDFUN
    AND  (CDPAT = PSCDPAT OR (CDPAT = '999' AND PSCDPAT IS NULL))
    AND  (NRPLA = PSNRPLA OR (NRPLA = '99' AND PSNRPLA IS NULL))
    AND  DTMESREF = PSDTMESREF;

    SDCERR := 'Erro ao limpar tabela temporaria SIPCAP';
/*    DELETE
    FROM  BNF_T_HISIPCAP_PLANO
    WHERE CDFUN = PSCDFUN
    AND  (CDPAT = PSCDPAT OR (CDPAT = '999' AND PSCDPAT IS NULL))
    AND  (NRPLA = PSNRPLA OR (NRPLA = '99' AND PSNRPLA IS NULL))
    AND  DTMESREF = PSDTMESREF;
*/
    --Executa procedimento que identifica as entradas e saídas do mes
    SDCERR := 'Erro ao calcular mês anterior';
    DDTAUX := ADD_MONTHS(DDTAUX1, -1);

    /* 13/08/2010: Alterado a forma como estava recuperando o mês anterior pois
    não estava gerando corretamente e os dados não estavam sendo gerados */
    --SET SDTMESANT = SUBSTRING(REPLACE(CONVERT(CHAR(20),DDTAUX),'-',''),1,6)

    IF SUBSTR(PSDTMESREF,5,2) = '01' THEN
       SDTMESANT := PSDTMESREF - 89;
    ELSE
       SDTMESANT := PSDTMESREF - 1;
    END IF;

    SDCERR := 'Erro ao executar procedure MEPB0131';
    --MEPB0131 (PSCDFUN,PSCDPAT,PSNRPLA,PSDTMESREF,SDTMESANT, PSDCUSU, SDCERR);    

    IF SDCERR <> 'OK' THEN
       PSDCERR := SDCERR;
          GOTO SAIDA;
    END IF;

    SDCERR := 'Erro ao executar procedure MEPB0132';
    --MEPB0132 (PSCDFUN,PSCDPAT,PSNRPLA,PSDTMESREF,SDTMESANT, PSDCUSU, SDCERR);

    IF SDCERR <> 'OK' THEN
       PSDCERR := SDCERR;
          GOTO SAIDA;
    END IF;

            /*--------------------------------
      Insere os totais do mês anterior
      ---------------------------------*/

      -- Se for o mes for 07/2008 que e o primeiro mes apos mudança da legislacao,
      -- faz um insert diferenciado no mes anterior baseado nos codigos antigos

            --INSERT INTO BNF_HISIPCAP_PLANO ( CDFUN , NRPLA , DTMESREF ,
            --CDLAN , QTCOSMES , QTCANMES ,
            --QTMESANT , CDPAT , AUUSUULTALT , AUDATULTALT , AUVERREGATL )
            --SELECT PSCDFUN , CASE nvl ( PSNRPLA , '' ) WHEN '' THEN '99' ELSE PSNRPLA END , PSDTMESREF , CDLAN ,
            --0 , 0 , ABS ( QTMESANT + QTCANMES ) ,
            --    CASE nvl ( PSCDPAT , '' ) WHEN '' THEN '999' ELSE PSCDPAT END ,
            --    USER , CURRENT_TIMESTAMP , 1
            --FROM BNF_HISIPCAP_PLANO
            --WHERE CDFUN = PSCDFUN
            --AND ( CDPAT = PSCDPAT OR PSCDPAT IS NULL )
            --AND ( NRPLA = PSNRPLA OR PSNRPLA IS NULL )
            --AND DTMESREF = SDTMESANT
            --AND CDLAN = '24100' ;

            IF PSDTMESREF = '200807' THEN
               SDCERR := 'Erro ao executar procedure MEPB0134';
                  MEPB0134 (PSCDFUN,PSCDPAT,PSNRPLA,PSDTMESREF,SDCERR);
            END IF;

            IF SDCERR <> 'OK' THEN
               PSDCERR := SDCERR;
                  GOTO SAIDA;
            ELSE
               SDCERR := 'Erro na inclusão dos totais do mês anterior';
                  /* 13/08/2010: Ajustada a query que recupera os dados do mês anterior
                  para quando o patrocinador e plano não forem informados */
                  /*
                  INSERT INTO BNF_HISIPCAP_PLANO
                  (CDFUN,      NRPLA,
                    DTMESREF,    CDLAN,      QTCOSMES,    QTCANMES,
                    QTMESANT,
                    CDPAT,
                    AUUSUULTALT,  AUDATULTALT,   AUVERREGATL)
                  SELECT
                  PSCDFUN,    CASE nvl(PSNRPLA,'') WHEN '' THEN '99' ELSE PSNRPLA END,
                  PSDTMESREF,  CDLAN,      0,        0,
                  CASE WHEN CDLAN = '24100' THEN ABS(QTMESANT+QTCANMES) ELSE ABS(QTMESANT+QTCOSMES -QTCANMES) END,
                  CASE nvl(PSCDPAT,'') WHEN '' THEN '999' ELSE PSCDPAT END,
                  SYSTEM_USER,  GetDate(),    1
                  FROM  BNF_HISIPCAP_PLANO
                  WHERE CDFUN = PSCDFUN
                  AND  (CDPAT = PSCDPAT OR PSCDPAT IS NULL)
                  AND  (NRPLA = PSNRPLA OR PSNRPLA IS NULL)
                  AND  DTMESREF = SDTMESANT
                  */

                  INSERT INTO BNF_HISIPCAP_PLANO
                          ( idhissipcappla,
                            CDFUN,       NRPLA,    DTMESREF,     CDLAN,         QTCOSMES,    QTCANMES,
                            QTMESANT,    CDPAT,    AUUSUULTALT,  AUDATULTALT,   AUVERREGATL
                            )
                  SELECT  sq_pvdat_bnf_hisipcap_plano.nextval,
                      PSCDFUN,
                      nvl(PSNRPLA,'99'),
                      PSDTMESREF,
                      CDLAN,
                      0,
                      0,
                      CASE WHEN CDLAN = '24100' THEN ABS(QTMESANT+QTCANMES) ELSE ABS(QTMESANT+QTCOSMES -QTCANMES) END,
                      nvl(PSCDPAT,'999'),
                      PSDCUSU,
                      SYSDATE,
                      1
                  FROM  BNF_HISIPCAP_PLANO
                  WHERE CDFUN = PSCDFUN
                              AND ((CDPAT = '999' AND PSCDPAT IS NULL)
                                        OR
                                      (CDPAT = PSCDPAT))
                              AND ((NRPLA = '99' AND PSNRPLA IS NULL)
                                        OR
                                      (NRPLA = PSNRPLA))
                              AND DTMESREF = SDTMESANT;
            END IF;

            --Incluido para tratamento da 1ª vez do codigo
            /*INSERT INTO BNF_HISIPCAP_PLANO
                ( idhissipcappla,
                  CDFUN,      NRPLA,   DTMESREF,       CDLAN,          QTCOSMES,     QTCANMES,
                  QTMESANT,   CDPAT,   AUUSUULTALT,    AUDATULTALT,    AUVERREGATL
                  )
            select sq_pvdat_bnf_hisipcap_plano.nextval, x.*
            from
            (
            SELECT DISTINCT
                  PSCDFUN cdfun,
                  nvl(PSNRPLA,'99') nrpla,
                  PSDTMESREF dtmesref,
                  B.CDLAN cdlan,
                  0 QTCOSMES,
                  0 QTCANMES,
                  0 QTMESANT,
                  nvl(PSCDPAT,'999') cdpat,
                  PSDCUSU cdusu,
                  SYSDATE dtalt,
                  1 qtalt
            FROM(SELECT A.CDLAN
                FROM  BNF_T_HISIPCAP_PLANO A
                WHERE A.CDFUN    = PSCDFUN
                AND   A.DTMESREF = PSDTMESREF
                      AND    ((A.CDPAT  = '999' AND PSCDPAT IS NULL)
                  OR
                  (A.CDPAT = PSCDPAT))
                      AND ((A.NRPLA = '99' AND PSNRPLA IS NULL)
                  OR
                  (A.NRPLA = PSNRPLA))
                      AND  NOT EXISTS(SELECT 1 AS SWA_ColAl
                              FROM  BNF_HISIPCAP_PLANO
                              WHERE CDFUN = A.CDFUN
                              AND   NRPLA = A.NRPLA
                              AND   DTMESREF = A.DTMESREF
                              AND   CDLAN = A.CDLAN)) B
            ) X;*/

            /*-----------------------------------------------------------------
      Zera os totais do mes anterior em caso de inicio de ano (MES = 01)
      ------------------------------------------------------------------*/
      /* 19/08/2010 - Zerar a quantidade anterior quando o mês for Janeiro para os códigos específicos */
      IF SUBSTR(PSDTMESREF,5,2) = '01' THEN
               UPDATE BNF_HISIPCAP_PLANO
                  SET    QTMESANT = 0
                  WHERE CDFUN = PSCDFUN
                  AND  ((CDPAT = '999' AND PSCDPAT IS NULL)
                            OR
                            (CDPAT = PSCDPAT))
                  AND  ((NRPLA = '99' AND PSNRPLA IS NULL)
                            OR
                            (NRPLA = PSNRPLA))
                  AND  DTMESREF = PSDTMESREF
                  AND  CDLAN IN ('16000','13000','15000','23000','24100','24200');
            END IF;

            --Atualiza os totais do mes
            SDCERR := 'Erro na atualização dos totais de entradas do mês';

            IF PSCDPAT IS NULL THEN
               /*UPDATE BNF_HISIPCAP_PLANO H
                  SET (QTCOSMES) = (SELECT COUNT(DISTINCT NRISC+TO_CHAR(SQDPD))
                                                   FROM  BNF_T_HISIPCAP_PLANO
                                                   WHERE CDFUN = H.CDFUN
                                                   AND CDPAT = H.CDPAT
                                                   AND NRPLA = H.NRPLA
                                                   AND DTMESREF = H.DTMESREF
                                                   AND CDLAN = H.CDLAN
                                                   AND TPMOV = 1)
                  WHERE H.CDFUN = PSCDFUN
                  --AND H.CDPAT = '999'
                  --AND H.NRPLA = '99'
                  AND  ((H.CDPAT = '999' AND PSCDPAT IS NULL)
                            OR
                            (H.CDPAT = PSCDPAT))
                  AND  ((H.NRPLA = '99' AND PSNRPLA IS NULL)
                            OR
                            (H.NRPLA = PSNRPLA))
                  AND  H.DTMESREF = PSDTMESREF
                  AND  EXISTS( SELECT 1
                                FROM  BNF_T_HISIPCAP_PLANO
                                WHERE CDFUN = H.CDFUN
                                AND CDPAT = H.CDPAT
                                AND NRPLA = H.NRPLA
                                AND DTMESREF = H.DTMESREF
                                AND CDLAN = H.CDLAN
                                AND TPMOV = 1);*/

               SDCERR := 'Erro na atualização dos totais de saídas do mês(1)';
                 /* UPDATE BNF_HISIPCAP_PLANO H
                  SET QTCANMES =( SELECT COUNT(DISTINCT NRISC+TO_CHAR(SQDPD))
                                                  FROM  BNF_T_HISIPCAP_PLANO
                                                  WHERE CDFUN = H.CDFUN
                                                  AND CDPAT = H.CDPAT
                                                  AND NRPLA = H.NRPLA
                                                  AND DTMESREF = H.DTMESREF
                                                  AND CDLAN = H.CDLAN
                                                  AND TPMOV = 2)
                  WHERE H.CDFUN = PSCDFUN
                  \*AND H.CDPAT = '999'
                  AND H.NRPLA = '99'*\
                  AND   ((H.CDPAT = '999' AND PSCDPAT IS NULL)
                              or
                              (H.CDPAT = PSCDPAT))
                  AND   ((H.NRPLA = '99' AND PSNRPLA IS NULL)
                              or
                              (H.NRPLA = PSNRPLA))
                  AND H.DTMESREF = PSDTMESREF
                  AND EXISTS( SELECT 1
                              FROM  BNF_T_HISIPCAP_PLANO
                              WHERE CDFUN = H.CDFUN
                              AND CDPAT = H.CDPAT
                             AND NRPLA = H.NRPLA
                              AND DTMESREF = H.DTMESREF
                              AND CDLAN = H.CDLAN
                              AND TPMOV = 2);*/
                              
            ELSE
              
               /*UPDATE  BNF_HISIPCAP_PLANO H
                  SET QTCOSMES = (SELECT COUNT(DISTINCT NRISC+TO_CHAR(SQDPD))
                          FROM  BNF_T_HISIPCAP_PLANO
                          WHERE CDFUN = H.CDFUN
                          AND CDPAT = PSCDPAT
                          AND NRPLA = H.NRPLA
                          AND DTMESREF = H.DTMESREF
                          AND CDLAN = H.CDLAN
                          AND TPMOV = 1)
                  WHERE H.CDFUN = PSCDFUN
                  \*AND H.CDPAT = PSCDPAT
                  AND H.NRPLA = PSNRPLA*\
                  AND   ((H.CDPAT = '999' AND PSCDPAT IS NULL)
                              or
                              (H.CDPAT = PSCDPAT))
                  AND   ((H.NRPLA = '99' AND PSNRPLA IS NULL)
                              or
                            (H.NRPLA = PSNRPLA))
                  AND H.DTMESREF = PSDTMESREF
                  AND EXISTS( SELECT 1
                        FROM  BNF_T_HISIPCAP_PLANO
                        WHERE CDFUN = H.CDFUN
                        AND CDPAT = PSCDPAT
                        AND NRPLA = H.NRPLA
                        AND DTMESREF = H.DTMESREF
                        AND CDLAN = H.CDLAN
                        AND TPMOV = 1);*/


               SDCERR := 'Erro na atualização dos totais de saídas do mês(2)';
                /*  UPDATE  BNF_HISIPCAP_PLANO H
                  SET QTCANMES =( SELECT COUNT(DISTINCT NRISC+TO_CHAR(SQDPD))
                          FROM  BNF_T_HISIPCAP_PLANO
                          WHERE CDFUN = H.CDFUN
                          AND CDPAT = PSCDPAT
                          AND NRPLA = H.NRPLA
                          AND DTMESREF = H.DTMESREF
                          AND CDLAN = H.CDLAN
                          AND TPMOV = 2)
                  WHERE H.CDFUN = PSCDFUN
                  \*AND (H.CDPAT = PSCDPAT OR PSCDPAT IS NULL)
                  AND H.NRPLA = PSNRPLA*\
                  AND   ((H.CDPAT = '999' AND PSCDPAT IS NULL)
                              or
                              (H.CDPAT = PSCDPAT))
                  AND   ((H.NRPLA = '99' AND PSNRPLA IS NULL)
                              or
                              (H.NRPLA = PSNRPLA))
                  AND H.DTMESREF = PSDTMESREF
                  AND EXISTS(  SELECT 1
                          FROM  BNF_T_HISIPCAP_PLANO
                          WHERE CDFUN = H.CDFUN
                          AND CDPAT = PSCDPAT
                          AND NRPLA = H.NRPLA
                          AND DTMESREF = H.DTMESREF
                          AND CDLAN = H.CDLAN
                          AND TPMOV = 2);*/
            END IF;

            --Insere os totais de população
            SDCERR := 'Erro ao abrir cursor C_POPULACAO';
            OPEN C_POPULACAO;

            SDCERR := 'Erro primeiro fetch cursor C_POPULACAO';
            FETCH C_POPULACAO
            INTO NIDORI,SCDPAT,SNRPLA,NNRIDA,STPSEXPAR,NQTPAR;

            WHILE C_POPULACAO%FOUND LOOP
               SDCERR := 'Erro ao recuperar o código';
                  -- Calcular código
                  IF NIDORI = 1 THEN
                     NCDLAN := 41000;
                  ELSE
                     IF NIDORI = 2 THEN
                           NCDLAN := 42000;
                        ELSE
                           NCDLAN := 43000;
                        END IF;
                  END IF;

                  IF NNRIDA <= 24 THEN
                     SCDLAN := TO_CHAR(NCDLAN+100);
                  ELSE
                     IF NNRIDA <= 34 THEN
                           SCDLAN := TO_CHAR(NCDLAN+200);
                        ELSE
                           IF NNRIDA <= 54 THEN
                                 SCDLAN := TO_CHAR(NCDLAN+300);
                              ELSE
                                 IF NNRIDA <= 64 THEN
                                       SCDLAN := TO_CHAR(NCDLAN+400);
                                    ELSE
                                       IF NNRIDA <= 74 THEN
                                             SCDLAN := TO_CHAR(NCDLAN+500);
                                          ELSE
                                             IF NNRIDA <= 84 THEN
                                                   SCDLAN := TO_CHAR(NCDLAN+600);
                                                ELSE
                                                   SCDLAN := TO_CHAR(NCDLAN+700);
                                                END IF;
                                          END IF;
                                    END IF;
                              END IF;
                        END IF;
                  END IF;

                  SDCERR := 'Erro ao recuperar BNF_HISIPCAP_PLANO';
                  SELECT COUNT(1)
                  INTO   NQTREG
         FROM  BNF_HISIPCAP_PLANO
         WHERE CDFUN = PSCDFUN
         /*AND   CDPAT = SCDPAT
         AND   NRPLA = SNRPLA*/
         AND  ((CDPAT = '999' AND SCDPAT IS NULL)
              OR
              (CDPAT = SCDPAT))
         AND  ((NRPLA = '99' AND SNRPLA IS NULL)
              OR
              (NRPLA = SNRPLA))
         AND  DTMESREF = PSDTMESREF
         AND  CDLAN = SCDLAN;

                  IF NQTREG = 0 THEN
                     SDCERR := 'Erro ao inserir BNF_HISIPCAP_PLANO';
                        INSERT INTO BNF_HISIPCAP_PLANO
                             (idhissipcappla,
                              CDFUN,         NRPLA,      DTMESREF,      CDLAN,
                              QTSEXMAS,      QTSEXFEM,   CDPAT,         AUUSUULTALT,
                              AUDATULTALT,   AUVERREGATL)
                        VALUES
                            (sq_pvdat_bnf_hisipcap_plano.nextval,
                            PSCDFUN,       SNRPLA,     PSDTMESREF,    SCDLAN,
                            CASE STPSEXPAR WHEN 'M' THEN NQTPAR ELSE 0 END,
                            CASE STPSEXPAR WHEN 'F' THEN NQTPAR ELSE 0 END,
                            SCDPAT,         PSDCUSU,    SYSDATE,       1);
                  ELSE
                     SDCERR := 'Erro ao atualizar BNF_HISIPCAP_PLANO';
                        IF STPSEXPAR = 'M' THEN
               UPDATE  BNF_HISIPCAP_PLANO
               SET QTSEXMAS = nvl(QTSEXMAS,0)+ NQTPAR,
                   QTSEXFEM = nvl(QTSEXFEM,0)
               WHERE CDFUN = PSCDFUN
               AND   CDPAT = SCDPAT
               AND   NRPLA = SNRPLA
               AND   DTMESREF = PSDTMESREF
               AND   CDLAN = SCDLAN;
            ELSE
               UPDATE BNF_HISIPCAP_PLANO
                              SET QTSEXFEM = nvl(QTSEXFEM,0)+ NQTPAR,
                                    QTSEXMAS = nvl(QTSEXMAS,0)
                              WHERE CDFUN = PSCDFUN
                              AND   CDPAT = SCDPAT
                              AND   NRPLA = SNRPLA
                              AND   DTMESREF = PSDTMESREF
                              AND   CDLAN = SCDLAN;
                        END IF;
                  END IF;

                  SDCERR := 'Erro fetch dentro do loop cursor C_POPULACAO';
               FETCH C_POPULACAO
               INTO NIDORI,SCDPAT,SNRPLA,NNRIDA,STPSEXPAR,NQTPAR;
            END LOOP;
            SDCERR := 'Erro ao fechar cursor C_POPULACAO';
            CLOSE C_POPULACAO;
  
  ELSE  
    
    PSDCERR := 'Processamento permitido apenas a partir do mês 01/2020.';
    RETURN;
    
  END IF;
      
      
      

 SDCERR := 'OK';

   <<SAIDA>>
   PSDCERR := SDCERR;

EXCEPTION
   WHEN others THEN
      PSDCERR := SDCERR;


END MEPB0129;
