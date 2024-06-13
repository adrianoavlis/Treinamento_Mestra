CREATE OR REPLACE PROCEDURE PR_BNF_GERA_HISIPCAP_MOV
(psCdUsu       varchar2,
 psCdFun       char,
 psCdPat       char,
 psNrPla       char,
 psDtMesRef    char,
 prsDcErr      out varchar2)

as

/*===================================================================
 * Modulo......: Beneficio
 * Procedure...: PR_BNF_GERA_T_HISIPCAP
 * Autor.......: Daisy
 * Sistema.....: SYSPREV 
 * Data........: 16/12/2021
 * Descricao...: Gera a tabela BNF_HISIPCAP_MOV para geração do
 *               SICADI
 * Revisões....:   
 * Data........:   
 * Autor Rev...: 

 ==================================================================*/

sDtMesAnt             char(6);

dDtPriDiaMes_DT       date;
dDtPriDiaMesAnt_DT    date;
dDtUltDiaMes_DT       date;
dDtUltDiaMesAnt_DT    date;
dDtIniVigMaxSipCap    date;

nIdFun                integer;

dDtPriDiaMes_TS       timestamp;
dDtPriDiaMesAnt_TS    timestamp;
dDtUltDiaMes_TS       timestamp;
dDtUltDiaMesAnt_TS    timestamp;

sDcErr                varchar2(255);


Begin

  
-- monta as variáveis de datas nos formatos DATE e TIMESTAMP para dar performance nas queries

sDtMesAnt          := to_char(add_months(to_date(psDtMesRef,'rrrrmm'),-1),'rrrrmm');

dDtPriDiaMesAnt_DT := to_date(sDtMesAnt || '01', 'rrrrmmdd');
dDtUltDiaMesAnt_DT := last_day(dDtPriDiaMesAnt_DT);

dDtPriDiaMesAnt_TS := to_timestamp( dDtPriDiaMesAnt_DT ||' 00:00:01.000000000', 'dd/mm/rrrr hh24:mi:ss.ff' );
dDtUltDiaMesAnt_TS := to_timestamp( dDtUltDiaMesAnt_DT ||' 23:59:59.000000000', 'dd/mm/rrrr hh24:mi:ss.ff' );

dDtPriDiaMes_DT    := to_date(psDtMesRef || '01', 'rrrrmmdd');
dDtUltDiaMes_DT    := last_day(dDtPriDiaMes_DT);

dDtPriDiaMes_TS    := to_timestamp( dDtPriDiaMes_DT ||' 00:00:01.000000000', 'dd/mm/rrrr hh24:mi:ss.ff' );
dDtUltDiaMes_TS    := to_timestamp( dDtUltDiaMes_DT ||' 23:59:59.000000000', 'dd/mm/rrrr hh24:mi:ss.ff' );

-- recupera a maior vigència da parametrização do SIPCAP

SELECT MAX(DTINIVIG)
INTO   dDtIniVigMaxSipCap
FROM   BNF_PARSSIPCAP
WHERE  DTINIVIG <= dDtUltDiaMes_DT;

   
SELECT IDFUN
INTO   nIdFun
FROM   PAR_FUNDOS
WHERE  CDFUN    = psCdFun;


/*=============================================================
                   DADOS DE BENEFICIOS
===============================================================*/

--|-----------------------------------------
--| Aposentadorias (Códigos: 11100 e 11200)
--|-----------------------------------------

sDcErr  := 'Erro na inclusão das entradas de beneficios de Aposentadoria (CDLAN 11100 e 11200)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                      DTMESREF,
       CDLAN,                   TPMOV,                      CDPAT,
       IDPARPLA,                IDBNFCCD,                   IDBEN,
       NRCPF,                   AUUSUULTALT,                AUDATULTALT,
       AUVERREGATL,             TXCHV )
SELECT psCdFun,                 X.NRPLA,                    psDtMesRef,
       X.CDLAN,                 1,                          X.CDPAT,
       X.IDPARPLA,              X.IDBNFCCD,                 X.IDBEN,
       X.NRCPF,                 psCdUsu,                    SYSDATE,
       0,                       X.CDPAT || '/' || X.NRMAT || '/' || SUBSTR(TO_CHAR(100 + X.SQDPD),2,3)
FROM ( --| trata as concessões de aposentadorias do mês
       SELECT H.CDLAN                                       AS CDLAN,
              D.CDPAT                                       AS CDPAT,
              C.NRPLA                                       AS NRPLA,
              B.NRMAT                                       AS NRMAT,
              I.SQBEN                                       AS SQDPD,
              A.IDPARPLA                                    AS IDPARPLA,
              A.IDBNFCCD                                    AS IDBNFCCD,
              I.IDBEN                                       AS IDBEN,
              TRIM(I.NRCPFBEN)                              AS NRCPF
       FROM   BNF_BNFCONCEDIDOS  A,
              PAR_PARPLA         B,
              PAR_PLANOS         C,
              PAR_PATROCINADORAS D,
              BNF_BENFPLA        F,
              BNF_BENEFICIOS     G,      
              BNF_PARSSIPCAP     H,
              BNF_BENEFICIARIOS  I
       WHERE  A.DTCOSBNF         BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT
       AND    NVL(A.PRPAGUNC,0)  <> 100
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    C.IDPLA            = B.IDPLA
       AND    C.NRPLA            = psNrPla
       AND    D.IDPAT            = C.IDPAT
       AND  ((D.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (D.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    D.IDFUN            = nIdFun      
       AND    F.IDBNFPLA         = A.IDBNFPLA
       AND    G.IDBNF            = F.IDBNF
       AND    H.DTINIVIG         = dDtIniVigMaxSipCap
       AND    H.CDBNF            = G.CDBNF
       AND    H.CDLAN            in ('11100','11200')
       AND    I.IDBNFCCD         = A.IDBNFCCD
       UNION
       --| trata as reativações das aposentadorias que não foram encerradas posteriormente dentro do mesmo mês
       SELECT I.CDLAN                                       AS CDLAN,
              E.CDPAT                                       AS CDPAT,
              D.NRPLA                                       AS NRPLA,
              C.NRMAT                                       AS NRMAT,
              K.SQBEN                                       AS SQDPD,
              B.IDPARPLA                                    AS IDPARPLA,
              B.IDBNFCCD                                    AS IDBNFCCD,
              K.IDBEN                                       AS IDBEN,
              TRIM(K.NRCPFBEN)                              AS NRCPF
       FROM   BNF_HISITBNF       A,
              BNF_BNFCONCEDIDOS  B,
              PAR_PARPLA         C,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              BNF_BENFPLA        G,
              BNF_BENEFICIOS     H,      
              BNF_PARSSIPCAP     I,
              BNF_HISITBNF       J,
              BNF_BENEFICIARIOS  K
       WHERE  A.STBNF            = '11'
       AND    A.AUDATULTALT      BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    B.IDBNFCCD         = A.IDBNFCCD
       AND    C.IDPARPLA         = B.IDPARPLA
       AND    D.IDPLA            = C.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    G.IDBNFPLA         = B.IDBNFPLA
       AND    H.IDBNF            = G.IDBNF
       AND    I.DTINIVIG         = dDtIniVigMaxSipCap
       AND    I.CDBNF            = H.CDBNF
       AND    I.CDLAN            in ('11100','11200')
       AND    K.IDBNFCCD         = A.IDBNFCCD
       AND    J.IDBNFCCD         = A.IDBNFCCD
       AND    J.AUDATULTALT      = ( SELECT MAX( AUDATULTALT )
                                     FROM   BNF_HISITBNF
                                     WHERE  IDBNFCCD         = A.IDBNFCCD
                                     AND    AUDATULTALT      < A.AUDATULTALT )
       AND    J.STBNF            = '08'
       AND    NOT EXISTS         (   SELECT 1
                                     FROM   BNF_HISITBNF
                                     WHERE  IDBNFCCD         = A.IDBNFCCD
                                     AND    STBNF            = '08'
                                     AND    AUDATULTALT      > A.AUDATULTALT
                                     AND    TRUNC( AUDATULTALT ) <= dDtUltDiaMes_DT
                                  )
       UNION
       --| trata as reativações das aposentadorias migradas sem histórico
       SELECT I.CDLAN                                       AS CDLAN,
              E.CDPAT                                       AS CDPAT,
              D.NRPLA                                       AS NRPLA,
              C.NRMAT                                       AS NRMAT,
              K.SQBEN                                       AS SQDPD,
              B.IDPARPLA                                    AS IDPARPLA,
              B.IDBNFCCD                                    AS IDBNFCCD,
              K.IDBEN                                       AS IDBEN,
              TRIM(K.NRCPFBEN)                              AS NRCPF
       FROM   BNF_HISITBNF       A,
              BNF_BNFCONCEDIDOS  B,
              PAR_PARPLA         C,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              BNF_BENFPLA        G,
              BNF_BENEFICIOS     H,      
              BNF_PARSSIPCAP     I,
              BNF_BENEFICIARIOS  K
       WHERE  A.STBNF            = '11'
       AND    A.AUDATULTALT      BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    B.IDBNFCCD         = A.IDBNFCCD
       AND    C.IDPARPLA         = B.IDPARPLA
       AND    D.IDPLA            = C.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    G.IDBNFPLA         = B.IDBNFPLA
       AND    H.IDBNF            = G.IDBNF
       AND    I.DTINIVIG         = dDtIniVigMaxSipCap
       AND    I.CDBNF            = H.CDBNF
       AND    I.CDLAN            in ('11100','11200')
       AND    K.IDBNFCCD         = A.IDBNFCCD
       AND    NOT EXISTS(        SELECT 1
                                 FROM   BNF_HISITBNF   J
                                 WHERE  J.IDBNFCCD     = A.IDBNFCCD
                                 AND    J.AUDATULTALT  < A.AUDATULTALT )
     ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 1
                  AND    IDBNFCCD = X.IDBNFCCD
                );


sDcErr  := 'Erro na inclusão das saidas de beneficios de Aposentadoria ( CDLAN 11100 e 11200)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                 DTMESREF,
       CDLAN,                   TPMOV,                 CDPAT,
       IDPARPLA,                IDBNFCCD,              IDBEN,
       NRCPF,                   AUUSUULTALT,           AUDATULTALT,
       AUVERREGATL,             TXCHV )
SELECT psCdFun,                 X.NRPLA,               psDtMesRef,
       X.CDLAN,                 2,                     X.CDPAT,
       X.IDPARPLA,              X.IDBNFCCD,            X.IDBEN,
       X.NRCPF,                 psCdUsu,               SYSDATE,
       0,                       X.CDPAT || '/' || X.NRMAT || '/' || SUBSTR(TO_CHAR(100 + X.SQDPD),2,3)
FROM  (--| trata as saídas decorrentes de transformação de aposentadoria
       SELECT I.CDLAN                                  AS CDLAN,
              E.CDPAT                                  AS CDPAT,
              D.NRPLA                                  AS NRPLA,
              C.NRMAT                                  AS NRMAT,
              K.SQBEN                                  AS SQDPD,
              B.IDPARPLA                               AS IDPARPLA,
              B.IDBNFCCD                               AS IDBNFCCD,
              K.IDBEN                                  AS IDBEN,
              TRIM(K.NRCPFBEN)                         AS NRCPF
       FROM   BNF_BNFCONCEDIDOS  A,
              BNF_BNFCONCEDIDOS  B,
              PAR_PARPLA         C,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              BNF_BENFPLA        G,
              BNF_BENEFICIOS     H,      
              BNF_PARSSIPCAP     I,
              BNF_BENEFICIARIOS  K
       WHERE  A.DTCOSBNF         BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    A.IDBNFCCDANT      IS NOT NULL
       AND    B.IDBNFCCD         = A.IDBNFCCDANT
       AND    C.IDPARPLA         = B.IDPARPLA
       AND    D.IDPLA            = C.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    G.IDBNFPLA         = B.IDBNFPLA
       AND    H.IDBNF            = G.IDBNF
       AND    I.DTINIVIG         = dDtIniVigMaxSipCap
       AND    I.CDBNF            = H.CDBNF
       AND    I.CDLAN            in ('11100','11200')
       AND    K.IDBNFCCD         = B.IDBNFCCD
       AND    NOT EXISTS (       SELECT 1
                                 FROM   BNF_HISITBNF  J
                                 WHERE  J.IDBNFCCD    = B.IDBNFCCD
                                 AND    J.AUDATULTALT = ( SELECT MAX(AUDATULTALT)
                                                          FROM   BNF_HISITBNF
                                                          WHERE  IDBNFCCD           = J.IDBNFCCD
                                                          AND    AUDATULTALT        < A.DTCOSBNF )
                                 AND    J.STBNF       IN ('08','09','12'))
       --| trata as saídas decorrentes de encerramento sem posterior reativação no mês
       UNION
       SELECT I.CDLAN                                  AS CDLAN,
              E.CDPAT                                  AS CDPAT,
              D.NRPLA                                  AS NRPLA,
              C.NRMAT                                  AS NRMAT,
              K.SQBEN                                  AS SQDPD,
              B.IDPARPLA                               AS IDPARPLA,
              B.IDBNFCCD                               AS IDBNFCCD,
              K.IDBEN                                  AS IDBEN,
              TRIM(K.NRCPFBEN)                         AS NRCPF
       FROM   BNF_HISITBNF       A,
              BNF_BNFCONCEDIDOS  B,
              PAR_PARPLA         C,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              BNF_BENFPLA        G,
              BNF_BENEFICIOS     H,      
              BNF_PARSSIPCAP     I,
              BNF_BENEFICIARIOS  K
       WHERE  A.STBNF            IN ('08','12')
       AND    A.AUDATULTALT      BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    B.IDBNFCCD         = A.IDBNFCCD
       AND    C.IDPARPLA         = B.IDPARPLA
       AND    D.IDPLA            = C.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    G.IDBNFPLA         = B.IDBNFPLA
       AND    H.IDBNF            = G.IDBNF
       AND    I.DTINIVIG         = dDtIniVigMaxSipCap
       AND    I.CDBNF            = H.CDBNF
       AND    I.CDLAN            in ('11100','11200')
       AND    K.IDBNFCCD         = A.IDBNFCCD
       AND    NOT EXISTS (         SELECT 1
                                   FROM   BNF_HISITBNF
                                   WHERE  IDBNFCCD     = A.IDBNFCCD
                                   AND    AUDATULTALT  > A.AUDATULTALT
                                   AND    AUDATULTALT  <= dDtUltDiaMes_TS
                                   AND    STBNF        = '11')           
      ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 2
                  AND    IDBNFCCD = X.IDBNFCCD
                );
      

--|---------------------------------------------------      
--| Auxílios - Prestação Continuada ( Código: 12000 )
--|---------------------------------------------------    

sDcErr  := 'Erro na inclusão das entradas de beneficios de Auxilio - Prestação Continuada (CDLAN 12000)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                      DTMESREF,
       CDLAN,                   TPMOV,                      CDPAT,
       IDPARPLA,                IDBNFCCD,                   IDBEN,
       NRCPF,                   AUUSUULTALT,                AUDATULTALT,
       AUVERREGATL,             TXCHV )
SELECT psCdFun,                 X.NRPLA,                    psDtMesRef,
       X.CDLAN,                 1,                          X.CDPAT,
       X.IDPARPLA,              X.IDBNFCCD,                 X.IDBEN,
       X.NRCPF,                 psCdUsu,                    SYSDATE,
       0,                       X.CDPAT || '/' || X.NRMAT || '/' || SUBSTR(TO_CHAR(100 + X.SQDPD),2,3)
FROM ( --| trata as concessões de auxílios do mês
       SELECT H.CDLAN                                       AS CDLAN,
              E.CDPAT                                       AS CDPAT,
              D.NRPLA                                       AS NRPLA,
              B.NRMAT                                       AS NRMAT,
              K.SQBEN                                       AS SQDPD,
              A.IDPARPLA                                    AS IDPARPLA,
              A.IDBNFCCD                                    AS IDBNFCCD,
              K.IDBEN                                       AS IDBEN,
              TRIM(K.NRCPFBEN)                              AS NRCPF
       FROM   BNF_BNFCONCEDIDOS  A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              BNF_BENFPLA        F,
              BNF_BENEFICIOS     G,      
              BNF_PARSSIPCAP     H,
              BNF_BENEFICIARIOS  K
       WHERE  A.DTCOSBNF         BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    F.IDBNFPLA         = A.IDBNFPLA
       AND    G.IDBNF            = F.IDBNF
       AND    H.DTINIVIG         = dDtIniVigMaxSipCap
       AND    H.CDBNF            = G.CDBNF
       AND    H.CDLAN            = '12000'
       AND    K.IDBNFCCD         = A.IDBNFCCD
       UNION
       --| trata as reativações dos benefícios que não foram encerrados dentro do mesmo mês e não estavam
       --| na folha de pagamento do mês anterior
       SELECT I.CDLAN                                       AS CDLAN,
              E.CDPAT                                       AS CDPAT,
              D.NRPLA                                       AS NRPLA,
              C.NRMAT                                       AS NRMAT,
              K.SQBEN                                       AS SQDPD,
              B.IDPARPLA                                    AS IDPARPLA,
              B.IDBNFCCD                                    AS IDBNFCCD,
              K.IDBEN                                       AS IDBEN,
              TRIM(K.NRCPFBEN)                              AS NRCPF
       FROM   BNF_HISITBNF       A,
              BNF_BNFCONCEDIDOS  B,
              PAR_PARPLA         C,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              BNF_BENFPLA        G,
              BNF_BENEFICIOS     H,      
              BNF_PARSSIPCAP     I,
              BNF_BENEFICIARIOS  K
       WHERE  A.STBNF            = '11'
       AND    A.AUDATULTALT      BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    B.IDBNFCCD         = A.IDBNFCCD
       AND    C.IDPARPLA         = B.IDPARPLA
       AND    D.IDPLA            = C.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    G.IDBNFPLA         = B.IDBNFPLA
       AND    H.IDBNF            = G.IDBNF
       AND    I.DTINIVIG         = dDtIniVigMaxSipCap
       AND    I.CDBNF            = H.CDBNF
       AND    I.CDLAN            = '12000'
       AND    K.IDBNFCCD         = A.IDBNFCCD
       AND    NOT EXISTS         (   SELECT 1
                                     FROM   BNF_HISITBNF
                                     WHERE  IDBNFCCD         = A.IDBNFCCD
                                     AND    AUDATULTALT      >= dDtPriDiaMes_TS
                                     AND    AUDATULTALT      < A.AUDATULTALT
                                     AND    STBNF            IN ('08','09','12')
                                  )
       AND    NOT EXISTS         (   SELECT 1
                                     FROM   BNF_PAGAMENTOS   E
                                     WHERE  E.IDBEN          = K.IDBEN
                                     AND    E.DTMESREF       = sDtMesAnt
                                  )
     ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 1
                  AND    IDBNFCCD = X.IDBNFCCD
                );
       

sDcErr  := 'Erro na inclusão das saídas dos beneficios de Auxilio - Prestação Continuada (CDLAN 12000)';
     
INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                 DTMESREF,
       CDLAN,                   TPMOV,                 CDPAT,
       IDPARPLA,                IDBNFCCD,              IDBEN,
       NRCPF,                   AUUSUULTALT,           AUDATULTALT,
       AUVERREGATL,             TXCHV )
SELECT PsCdFun,                 X.NRPLA,               psDtMesRef,
       X.CDLAN,                 2,                     X.CDPAT,
       X.IDPARPLA,              X.IDBNFCCD,            X.IDBEN,
       X.NRCPF,                 psCdUsu,               SYSDATE, ---alterado  psCdUsu||'[S]' para  psCdUsu -- 23/01/23 D.D.
       0,                       X.CDPAT || '/' || X.NRMAT || '/' || SUBSTR(TO_CHAR(100 + X.SQDPD),2,3)
FROM  (--| trata as saídas decorrentes de encerramento do benefício desde que não tenha sido pago
       --| na folha daquele mês
       SELECT I.CDLAN                                  AS CDLAN,
              E.CDPAT                                  AS CDPAT,
              D.NRPLA                                  AS NRPLA,
              C.NRMAT                                  AS NRMAT,
              K.SQBEN                                  AS SQDPD,
              B.IDPARPLA                               AS IDPARPLA,
              B.IDBNFCCD                               AS IDBNFCCD,
              K.IDBEN                                  AS IDBEN,
              TRIM(K.NRCPFBEN)                         AS NRCPF
       FROM   BNF_HISITBNF         A,
              BNF_BNFCONCEDIDOS    B,
              PAR_PARPLA           C,
              PAR_PLANOS           D,
              PAR_PATROCINADORAS   E,
              BNF_BENFPLA          G,
              BNF_BENEFICIOS       H,      
              BNF_PARSSIPCAP       I,
              BNF_BENEFICIARIOS    K
       WHERE  A.STBNF              IN ( '08','12')
       AND    A.AUDATULTALT        BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    B.IDBNFCCD           = A.IDBNFCCD
       AND    NVL(B.PRPAGUNC,0)    <> 100
       AND    C.IDPARPLA           = B.IDPARPLA
       AND    D.IDPLA              = C.IDPLA
       AND    D.NRPLA              = psNrPla
       AND    E.IDPAT              = D.IDPAT
       AND    E.IDFUN              = nIdFun      
       AND  ((E.CDPAT              IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT              = psCdPat           AND   psCdPat <> '001')) 
       AND    G.IDBNFPLA           = B.IDBNFPLA
       AND    H.IDBNF              = G.IDBNF
       AND    I.DTINIVIG           = dDtIniVigMaxSipCap
       AND    I.CDBNF              = H.CDBNF
       AND    I.CDLAN              = '12000'
       AND    K.IDBNFCCD           = A.IDBNFCCD
       AND    NOT EXISTS (         SELECT 1
                                   FROM   BNF_HISITBNF
                                   WHERE  IDBNFCCD     = A.IDBNFCCD
                                   AND    AUDATULTALT  > A.AUDATULTALT
                                   AND    AUDATULTALT  <= dDtUltDiaMes_TS
                                   AND    STBNF        = '11') 
       AND    NOT EXISTS         ( SELECT 1
                                   FROM   BNF_PAGAMENTOS E
                                   WHERE  E.IDBEN        = K.IDBEN
                                   AND    E.DTMESREF     = psDtMesRef
                                  )
       UNION
       --| trata os auxílios que finalizaram no mês anterior e não sairam porque houve pagamento na folha
       SELECT I.CDLAN                                  AS CDLAN,
              E.CDPAT                                  AS CDPAT,
              D.NRPLA                                  AS NRPLA,
              C.NRMAT                                  AS NRMAT,
              K.SQBEN                                  AS SQDPD,
              B.IDPARPLA                               AS IDPARPLA,
              B.IDBNFCCD                               AS IDBNFCCD,
              K.IDBEN                                  AS IDBEN,
              TRIM(K.NRCPFBEN)                         AS NRCPF
       FROM   BNF_HISITBNF         A,
              BNF_BNFCONCEDIDOS    B,
              PAR_PARPLA           C,
              PAR_PLANOS           D,
              PAR_PATROCINADORAS   E,
              BNF_BENFPLA          G,
              BNF_BENEFICIOS       H,      
              BNF_PARSSIPCAP       I,
              BNF_BENEFICIARIOS    K
       WHERE  A.STBNF              IN ( '08','12')
       AND    A.AUDATULTALT        BETWEEN dDtPriDiaMesAnt_TS AND dDtUltDiaMesAnt_TS
       AND    B.IDBNFCCD           = A.IDBNFCCD
       AND    NVL(B.PRPAGUNC,0)    <> 100
       AND    C.IDPARPLA           = B.IDPARPLA
       AND    D.IDPLA              = C.IDPLA
       AND    D.NRPLA              = psNrPla
       AND    E.IDPAT              = D.IDPAT
       AND    E.IDFUN              = nIdFun      
       AND  ((E.CDPAT              IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT              = psCdPat           AND   psCdPat <> '001')) 
       AND    G.IDBNFPLA           = B.IDBNFPLA
       AND    H.IDBNF              = G.IDBNF
       AND    I.DTINIVIG           = dDtIniVigMaxSipCap
       AND    I.CDBNF              = H.CDBNF
       AND    I.CDLAN              = '12000'
       AND    K.IDBNFCCD           = A.IDBNFCCD
       AND    EXISTS(              SELECT 1
                                   FROM   BNF_PAGAMENTOS E
                                   WHERE  E.IDBEN        = K.IDBEN
                                   AND    E.DTMESREF     = sDtMesAnt
                    )
       AND    NOT EXISTS (         SELECT 1
                                   FROM   BNF_HISITBNF
                                   WHERE  IDBNFCCD     = A.IDBNFCCD
                                   AND    AUDATULTALT  > A.AUDATULTALT
                                   AND    AUDATULTALT  <= dDtUltDiaMes_TS
                                   AND    STBNF        = '11') 
     ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 2
                  AND    IDBNFCCD = X.IDBNFCCD
                );

--|------------------------------------
--| Pensão por Morte ( Código: 14000 )
--|------------------------------------
/*
12/05/2022: a Prevdata conta os grupos familiares de cada benefício de pensão por morte
*/

sDcErr  := 'Erro na inclusão das entradas de beneficios de Pensões (CDLAN 14000)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                      DTMESREF,
       CDLAN,                   TPMOV,                      CDPAT,
       IDPARPLA,                IDBNFCCD,                   IDBEN,
       NRCPF,                   AUUSUULTALT,                AUDATULTALT,
       AUVERREGATL,             TXCHV )
SELECT psCdFun,                 X.NRPLA,                    psDtMesRef,
       X.CDLAN,                 1,                          X.CDPAT,
       X.IDPARPLA,              X.IDBNFCCD,                 X.IDBEN,
       X.NRCPF,                 psCdUsu,                    SYSDATE,
       0,                       X.CDPAT || '/' || X.NRMAT || '/' || SUBSTR(TO_CHAR(100 + X.SQDPD),2,3)
FROM ( --| trata as concessões do mês
       SELECT H.CDLAN                                       AS CDLAN,
              E.CDPAT                                       AS CDPAT,
              D.NRPLA                                       AS NRPLA,
              B.NRMAT                                       AS NRMAT,
              I.SQBEN                                       AS SQDPD,
              A.IDPARPLA                                    AS IDPARPLA,
              A.IDBNFCCD                                    AS IDBNFCCD,
              I.IDBEN                                       AS IDBEN,
              TRIM(I.NRCPFBEN)                              AS NRCPF
       FROM   BNF_BNFCONCEDIDOS  A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              BNF_BENFPLA        F,
              BNF_BENEFICIOS     G,      
              BNF_PARSSIPCAP     H,
              BNF_BENEFICIARIOS  I
       WHERE  A.DTCOSBNF         BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT
       AND    NVL(A.PRPAGUNC,0)  <> 100
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    F.IDBNFPLA         = A.IDBNFPLA
       AND    G.IDBNF            = F.IDBNF
       AND    H.DTINIVIG         = dDtIniVigMaxSipCap
       AND    H.CDBNF            = G.CDBNF
       AND    H.CDLAN            = '14000'
       AND    I.IDBNFCCD         = A.IDBNFCCD
       AND    I.IDBENPCP         = 'S' -- só pode ter 1 beneficiário principal por grupo familiar!
       UNION
       --| trata as reativações dos benefícios que não foram encerrados dentro do mesmo mês
       SELECT I.CDLAN                                       AS CDLAN,
              E.CDPAT                                       AS CDPAT,
              D.NRPLA                                       AS NRPLA,
              C.NRMAT                                       AS NRMAT,
              J.SQBEN                                       AS SQDPD,
              B.IDPARPLA                                    AS IDPARPLA,
              B.IDBNFCCD                                    AS IDBNFCCD,
              J.IDBEN                                       AS IDBEN,
              TRIM(J.NRCPFBEN)                              AS NRCPF
       FROM   BNF_HISITBNF       A,
              BNF_BNFCONCEDIDOS  B,
              PAR_PARPLA         C,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              BNF_BENFPLA        G,
              BNF_BENEFICIOS     H,      
              BNF_PARSSIPCAP     I,
              BNF_BENEFICIARIOS  J
       WHERE  A.STBNF            = '11'
       AND    A.AUDATULTALT      BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    B.IDBNFCCD         = A.IDBNFCCD
       AND    C.IDPARPLA         = B.IDPARPLA
       AND    D.IDPLA            = C.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    G.IDBNFPLA         = B.IDBNFPLA
       AND    H.IDBNF            = G.IDBNF
       AND    I.DTINIVIG         = dDtIniVigMaxSipCap
       AND    I.CDBNF            = H.CDBNF
       AND    I.CDLAN            = '14000'
       AND    J.IDBNFCCD         = A.IDBNFCCD
       AND    J.IDBENPCP         = 'S' -- só pode ter 1 beneficiário principal por grupo familiar!
       AND    NOT EXISTS         (   SELECT 1
                                     FROM   BNF_HISITBNF K
                                     WHERE  K.IDBNFCCD       = A.IDBNFCCD
                                     AND    K.AUDATULTALT    = ( SELECT MAX(AUDATULTALT)
                                                                 FROM   BNF_HISITBNF
                                                                 WHERE  IDBNFCCD    = K.IDBNFCCD
                                                                 AND    AUDATULTALT < A.AUDATULTALT
                                                                )
                                     AND    STBNF            IN ('07')
                                  )
       AND    NOT EXISTS         (   SELECT 1
                                     FROM   BNF_HISITBNF
                                     WHERE  IDBNFCCD         = A.IDBNFCCD
                                     AND    AUDATULTALT      >= dDtPriDiaMes_TS
                                     AND    AUDATULTALT      < A.AUDATULTALT
                                     AND    STBNF            IN ('07','08')
                                  )
     ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 1
                  AND    IDBEN    = X.IDBEN
                );


sDcErr  := 'Erro na inclusão das saidas de beneficios de Pensões (CDLAN 14000)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                 DTMESREF,
       CDLAN,                   TPMOV,                 CDPAT,
       IDPARPLA,                IDBNFCCD,              IDBEN,
       NRCPF,                   AUUSUULTALT,           AUDATULTALT,
       AUVERREGATL,             TXCHV )
SELECT psCdFun,                 X.NRPLA,               psDtMesRef,
       X.CDLAN,                 2,                     X.CDPAT,
       X.IDPARPLA,              X.IDBNFCCD,            X.IDBEN,
       X.NRCPF,                 psCdUsu,               SYSDATE,
       0,                       X.CDPAT || '/' || X.NRMAT || '/' || SUBSTR(TO_CHAR(100 + X.SQDPD),2,3)
FROM  (
       --| trata as saídas decorrentes do encerramento do benefício
       SELECT I.CDLAN                                  AS CDLAN,
              E.CDPAT                                  AS CDPAT,
              D.NRPLA                                  AS NRPLA,
              C.NRMAT                                  AS NRMAT,
              J.SQBEN                                  AS SQDPD,
              B.IDPARPLA                               AS IDPARPLA,
              B.IDBNFCCD                               AS IDBNFCCD,
              J.IDBEN                                  AS IDBEN,
              TRIM(J.NRCPFBEN)                         AS NRCPF
       FROM   BNF_HISITBNF         A,
              BNF_BNFCONCEDIDOS    B,
              PAR_PARPLA           C,
              PAR_PLANOS           D,
              PAR_PATROCINADORAS   E,
              BNF_BENFPLA          G,
              BNF_BENEFICIOS       H,      
              BNF_PARSSIPCAP       I,
              BNF_BENEFICIARIOS    J
       WHERE  A.AUDATULTALT        BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       -- 17/04/2023: incluído o STBNF 12 por conta dos problemas nos encerramentos de pensão
       AND    A.STBNF              IN ( '08', '12' )
       AND    B.IDBNFCCD           = A.IDBNFCCD
       AND    NVL(B.PRPAGUNC,0)    <> 100
       AND    C.IDPARPLA           = B.IDPARPLA
       AND    D.IDPLA              = C.IDPLA
       AND    D.NRPLA              = psNrPla
       AND    E.IDPAT              = D.IDPAT
       AND    E.IDFUN              = nIdFun      
       AND  ((E.CDPAT              IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT              = psCdPat           AND   psCdPat <> '001')) 
       AND    G.IDBNFPLA           = B.IDBNFPLA
       AND    H.IDBNF              = G.IDBNF
       AND    I.DTINIVIG           = dDtIniVigMaxSipCap
       AND    I.CDBNF              = H.CDBNF
       AND    I.CDLAN              = '14000'
       AND    J.IDBNFCCD           = A.IDBNFCCD
       AND    J.IDBENPCP           = 'S' -- só pode ter 1 beneficiário principal por grupo familiar!
       -- 08/03/2023: incluído o teste de BNF_BENOCOR para desconsiderar os beneficiários
       --             migrados já encerrados  
       AND    EXISTS (             SELECT 1
                                   FROM   BNF_BENOCOR
                                   WHERE  IDBEN        = J.IDBEN
                                   AND    AUDATULTALT  BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
                                   AND    TPOCO        = 'E') 
       AND    NOT EXISTS (         SELECT 1
                                   FROM   BNF_HISITBNF
                                   WHERE  IDBNFCCD     = A.IDBNFCCD
                                   AND    AUDATULTALT  > A.AUDATULTALT
                                   AND    AUDATULTALT  <= dDtUltDiaMes_TS
                                   AND    STBNF        = '11') 
     ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 2
                  AND    IDBEN    = X.IDBEN
                );


--|------------------------------------
--| Pagamento Único ( Código: 16000 )
--|------------------------------------

sDcErr  := 'Erro na inclusão das entradas de beneficios de pagamento único (CDLAN 16000)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                      DTMESREF,
       CDLAN,                   TPMOV,                      CDPAT,
       IDPARPLA,                IDBNFCCD,                   IDBEN,
       NRCPF,                   AUUSUULTALT,                AUDATULTALT,
       AUVERREGATL,             TXCHV )
SELECT psCdFun,                 X.NRPLA,                    psDtMesRef,
       X.CDLAN,                 1,                          X.CDPAT,
       X.IDPARPLA,              X.IDBNFCCD,                 X.IDBEN,
       X.NRCPF,                 psCdUsu,                    SYSDATE,
       0,                       X.CDPAT || '/' || X.NRMAT || '/' || SUBSTR(TO_CHAR(100 + X.SQDPD),2,3)
FROM ( --| trata as concessões dos benefícios de pagamento único
       SELECT '16000'                                       AS CDLAN, 
              E.CDPAT                                       AS CDPAT,
              D.NRPLA                                       AS NRPLA,
              B.NRMAT                                       AS NRMAT,
              C.SQBEN                                       AS SQDPD,
              A.IDPARPLA                                    AS IDPARPLA,
              A.IDBNFCCD                                    AS IDBNFCCD,
              C.IDBEN                                       AS IDBEN,
              TRIM(C.NRCPFBEN)                              AS NRCPF
       FROM   BNF_BNFCONCEDIDOS  A,
              PAR_PARPLA         B,
              BNF_BENEFICIARIOS  C,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E
       WHERE  A.DTCOSBNF         BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    NVL(A.PRPAGUNC,0)  = 100
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    C.IDBNFCCD         = A.IDBNFCCD
       AND   (C.SQBEN            = 0                 OR    C.IDBENPCP = 'S')
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
     ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 1
                  AND    IDBEN    = X.IDBEN
                );
     
sDcErr  := 'Erro na inclusão das entradas de beneficios de pagamento único (CDLAN 16000)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                      DTMESREF,
       CDLAN,                   TPMOV,                      CDPAT,
       IDPARPLA,                IDBNFCCD,                   IDBEN,
       NRCPF,                   AUUSUULTALT,                AUDATULTALT,
       AUVERREGATL,             TXCHV )
SELECT psCdFun,                 X.NRPLA,                    psDtMesRef,
       X.CDLAN,                 2,                          X.CDPAT,
       X.IDPARPLA,              X.IDBNFCCD,                 X.IDBEN,
       X.NRCPF,                 psCdUsu,                    SYSDATE,
       0,                       X.CDPAT || '/' || X.NRMAT || '/' || SUBSTR(TO_CHAR(100 + X.SQDPD),2,3)
FROM ( --| trata as concessões dos benefícios de pagamento único
       SELECT'16000'                                        AS CDLAN, 
              E.CDPAT                                       AS CDPAT,
              D.NRPLA                                       AS NRPLA,
              B.NRMAT                                       AS NRMAT,
              C.SQBEN                                       AS SQDPD,
              A.IDPARPLA                                    AS IDPARPLA,
              A.IDBNFCCD                                    AS IDBNFCCD,
              C.IDBEN                                       AS IDBEN,
              TRIM(C.NRCPFBEN)                              AS NRCPF
       FROM   BNF_BNFCONCEDIDOS  A,
              PAR_PARPLA         B,
              BNF_BENEFICIARIOS  C,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E
       WHERE  A.DTCOSBNF         BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    NVL(A.PRPAGUNC,0)  = 100
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    C.IDBNFCCD         = A.IDBNFCCD
       AND   (C.SQBEN            = 0                 OR   C.IDBENPCP = 'S')
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
     ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 2
                  AND    IDBEN    = X.IDBEN
                );


/*=============================================================
                   DADOS DOS INSTITUTOS
===============================================================*/

--|------------------------------------------------
--| Benefício Proporcional Diferido (Código: 21000)
--| Autopatrocínio                  (Código: 22000)
--|------------------------------------------------
     
sDcErr  := 'Erro na inclusão das entradas de BPD e Autopatrocinio (CDLAN 21100 e 22000)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                      DTMESREF,
       CDLAN,                   TPMOV,                      CDPAT,
       IDPARPLA,                NRCPF,                      AUUSUULTALT,
       AUDATULTALT,             AUVERREGATL,                TXCHV )
SELECT psCdFun,                 X.NRPLA,                    psDtMesRef,
       X.CDLAN,                 1,                          X.CDPAT,
       X.IDPARPLA,              X.NRCPF,                    psCdUsu,
       SYSDATE,                 0,                          X.CDPAT || '/' || X.NRMAT || '/00'
FROM ( SELECT '21000'                                       AS CDLAN,
              E.CDPAT                                       AS CDPAT,
              D.NRPLA                                       AS NRPLA,
              B.NRMAT                                       AS NRMAT,
              A.IDPARPLA                                    AS IDPARPLA,
              TRIM(K.NRCPFPAR)                              AS NRCPF
       FROM   PAR_HISITPAR       A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              PAR_PARTICIPANTES  K
       WHERE  A.DTSISINI         BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    A.STISCATU         = '9'
       AND  ( A.STISCANT         <> '9'
              OR
             (A.STISCANT         = A.STISCATU    AND   A.DTINISIT = B.DTISCPAR))
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR            = B.IDPAR
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_SITPLA_PARAM
                                 WHERE  IDPLA                 = B.IDPLA
                                 AND    IDSITPLACAT           = A.IDSITPLACATANT
                                 AND    NVL(TPBNFCCD,'XX')    IN ('AD','AC')
                         )
       UNION                
       SELECT '22000'                                       AS CDLAN,
              E.CDPAT                                       AS CDPAT,
              D.NRPLA                                       AS NRPLA,
              B.NRMAT                                       AS NRMAT,
              A.IDPARPLA                                    AS IDPARPLA,
              TRIM(K.NRCPFPAR)                              AS NRCPF
       FROM   PAR_HISITPAR       A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              PAR_PARTICIPANTES  K
       WHERE  A.DTSISINI         BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       -- 30/11/2022: incluído o STISC '2'
       AND    A.STISCATU         IN ( '1', '2')
       AND  ( A.STISCANT         NOT IN ( '1', '2')
              OR
             (A.STISCANT         = A.STISCATU    AND   A.DTINISIT = B.DTISCPAR))
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR            = B.IDPAR
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_SITPLA_PARAM
                                 WHERE  IDPLA                 = B.IDPLA
                                 AND    IDSITPLACAT           = A.IDSITPLACATANT
                                 AND    NVL(TPBNFCCD,'XX')    IN ('AD','AC')
                         )
     ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 1
                  AND    IDPARPLA = X.IDPARPLA
                );


     
sDcErr  := 'Erro na inclusão das saídas de BPD e Autopatrocinio (CDLAN 21000 e 22000)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                      DTMESREF,
       CDLAN,                   TPMOV,                      CDPAT,
       IDPARPLA,                NRCPF,                      AUUSUULTALT,
       AUDATULTALT,             AUVERREGATL,                TXCHV )
SELECT psCdFun,                 X.NRPLA,                    psDtMesRef,
       X.CDLAN,                 2,                          X.CDPAT,
       X.IDPARPLA,              X.NRCPF,                    psCdUsu,
       SYSDATE,                 0,                          X.CDPAT || '/' || X.NRMAT || '/00'
FROM ( SELECT '21000'                                       AS CDLAN,
              E.CDPAT                                       AS CDPAT,
              D.NRPLA                                       AS NRPLA,
              B.NRMAT                                       AS NRMAT,
              A.IDPARPLA                                    AS IDPARPLA,
              TRIM(K.NRCPFPAR)                              AS NRCPF
       FROM   PAR_HISITPAR       A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              PAR_PARTICIPANTES  K
       WHERE  A.DTSISINI         BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    A.DTINISIT         <= dDtUltDiaMes_DT
       AND    A.STISCATU         <> '9'
       AND    A.STISCANT         =  '9'
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR            = B.IDPAR
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_SITPLA_PARAM
                                 WHERE  IDPLA                 = B.IDPLA
                                 AND    IDSITPLACAT           = A.IDSITPLACATATU
                                 AND    NVL(TPBNFCCD,'XX')    IN ('AD','AC')
                         )
       UNION
       SELECT '21000'                                       AS CDLAN,
              E.CDPAT                                       AS CDPAT,
              D.NRPLA                                       AS NRPLA,
              B.NRMAT                                       AS NRMAT,
              A.IDPARPLA                                    AS IDPARPLA,
              TRIM(K.NRCPFPAR)                              AS NRCPF
       FROM   PAR_HISITPAR       A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              PAR_PARTICIPANTES  K
       WHERE  A.DTSISINI         BETWEEN dDtPriDiaMesAnt_TS AND dDtUltDiaMesAnt_TS
       AND    A.DTINISIT         BETWEEN dDtPriDiaMes_DT    AND dDtUltDiaMes_DT
       AND    A.STISCATU         <> '9'
       AND    A.STISCANT         = '9'
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR            = B.IDPAR
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_SITPLA_PARAM
                                 WHERE  IDPLA                 = B.IDPLA
                                 AND    IDSITPLACAT           = A.IDSITPLACATATU
                                 AND    NVL(TPBNFCCD,'XX')    IN ('AD','AC')
                         )
       UNION                         
       SELECT '22000'                                       AS CDLAN,
              E.CDPAT                                       AS CDPAT,
              D.NRPLA                                       AS NRPLA,
              B.NRMAT                                       AS NRMAT,
              A.IDPARPLA                                    AS IDPARPLA,
              TRIM(K.NRCPFPAR)                              AS NRCPF
       FROM   PAR_HISITPAR       A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              PAR_PARTICIPANTES  K
       WHERE  A.DTSISINI         BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    A.DTINISIT         <= dDtUltDiaMes_DT
       -- 30/11/2022: incluído o STISC '2'
       AND    A.STISCATU         NOT IN ('1','2')
       AND    A.STISCANT         IN ('1','2')
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR            = B.IDPAR
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_SITPLA_PARAM
                                 WHERE  IDPLA                 = B.IDPLA
                                 AND    IDSITPLACAT           = A.IDSITPLACATATU
                                 AND    NVL(TPBNFCCD,'XX')    IN ('AD','AC')
                         )
       UNION
       SELECT '22000'                                       AS CDLAN,
              E.CDPAT                                       AS CDPAT,
              D.NRPLA                                       AS NRPLA,
              B.NRMAT                                       AS NRMAT,
              A.IDPARPLA                                    AS IDPARPLA,
              TRIM(K.NRCPFPAR)                              AS NRCPF
       FROM   PAR_HISITPAR       A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              PAR_PARTICIPANTES  K
       WHERE  A.DTSISINI         BETWEEN dDtPriDiaMesAnt_TS AND dDtUltDiaMesAnt_TS
       AND    A.DTINISIT         BETWEEN dDtPriDiaMes_DT    AND dDtUltDiaMes_DT
       -- 30/11/2022: incluído o STISC '2'
       AND    A.STISCATU         NOT IN ('1','2')
       AND    A.STISCANT         IN ('1','2')
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR            = B.IDPAR
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_SITPLA_PARAM
                                 WHERE  IDPLA                 = B.IDPLA
                                 AND    IDSITPLACAT           = A.IDSITPLACATATU
                                 AND    NVL(TPBNFCCD,'XX')    IN ('AD','AC')
                         )
            ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 2
                  AND    IDPARPLA = X.IDPARPLA
                );
     

--|--------------------------
--| Resgates (Código: 23000)
--|--------------------------

sDcErr  := 'Erro na inclusão das entradas de Resgates (CDLAN 23000)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                  DTMESREF,
       CDLAN,                   TPMOV,                  CDPAT,
       IDPARPLA,                NRCPF,                  AUUSUULTALT,
       AUDATULTALT,             AUVERREGATL,            TXCHV )
SELECT psCdFun,                 X.NRPLA,                psDtMesRef,
       X.CDLAN,                 1,                      X.CDPAT,
       X.IDPARPLA,              X.NRCPF,                psCdUsu,
       SYSDATE,                 0,                      X.CDPAT || '/' || X.NRMAT || '/00'
FROM ( SELECT '23000'                                   AS CDLAN,
              E.CDPAT                                   AS CDPAT,
              D.NRPLA                                   AS NRPLA,
              B.NRMAT                                   AS NRMAT,
              A.IDPARPLA                                AS IDPARPLA,
              TRIM(K.NRCPFPAR)                          AS NRCPF
       FROM   CTB_RESPOUP        A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
           /* PAR_HISITPAR       F,
              PAR_SITPLA_PARAM   G,*/
              PAR_PARTICIPANTES  K
       WHERE  A.DTPVTPAG         BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT
       AND    A.STRSG            IN ('A','C')
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
     /*AND    F.IDPARPLA         = A.IDPARPLA
       AND    F.DTSISINI         = (  SELECT MAX( DTSISINI )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA = F.IDPARPLA
                                      AND    DTSISINI < A.DTCNF )
       AND    F.DTINISIT         = (  SELECT MAX( DTINISIT )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA = F.IDPARPLA
                                      AND    DTSISINI = F.DTSISINI )
       AND    F.SQSIT            = (  SELECT MAX( SQSIT )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA = F.IDPARPLA
                                      AND    DTINISIT = F.DTINISIT
                                      AND    DTSISINI = F.DTSISINI )
       AND    G.IDPLA            = B.IDPLA
       AND    G.IDSITPLACAT      = F.IDSITPLACATATU
       AND    G.IDRSGRESPOU      = '3'*/
       AND    K.IDPAR            = B.IDPAR                                                       
     ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 1
                  AND    IDPARPLA = X.IDPARPLA
                );


--|-----------------------------------------------------------------------
--| Portabilidade de Saída - Plano de Benefício Originário (Código: 24100)
--|-----------------------------------------------------------------------

sDcErr  := 'Erro na inclusão das portabilidades de saída(CDLAN 24100)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                  DTMESREF,
       CDLAN,                   TPMOV,                  CDPAT,
       IDPARPLA,                NRCPF,                  AUUSUULTALT,
       AUDATULTALT,             AUVERREGATL,            TXCHV )
SELECT psCdFun,                 X.NRPLA,                psDtMesRef,
       X.CDLAN,                 1,                      X.CDPAT, ----2020/77-00282(02/12) alterado para 1 para constar como entrada 13/01/23 D.D.
       X.IDPARPLA,              X.NRCPF,                psCdUsu,
       SYSDATE,                 0,                      X.CDPAT || '/' || X.NRMAT || '/00'
FROM ( SELECT '24100'                                   AS CDLAN,
              E.CDPAT                                   AS CDPAT,
              D.NRPLA                                   AS NRPLA,
              B.NRMAT                                   AS NRMAT,
              A.IDPARPLA                                AS IDPARPLA,
              TRIM(K.NRCPFPAR)                          AS NRCPF
       FROM   CTB_PORTABILIDADE_SAI A,
              PAR_PARPLA            B,
              PAR_PLANOS            D,
              PAR_PATROCINADORAS    E,
              PAR_PARTICIPANTES     K  
       WHERE  A.DTPVTPAG            BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT
       AND    A.STPTB               = 'C'
       AND    A.IDTIPPTB            = 'T'
       AND    B.IDPARPLA            = A.IDPARPLA
       AND    D.IDPLA               = B.IDPLA
       AND    D.NRPLA               = psNrPla
       AND    E.IDPAT               = D.IDPAT
       AND    E.IDFUN               = nIdFun      
       AND  ((E.CDPAT               IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT               = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR               = B.IDPAR  
   ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 1
                  AND    IDPARPLA = X.IDPARPLA
                );



--|-----------------------------------------------------------------------
--| Portabilidade de Entrada - Plano de Benefício Receptor (Código: 24200)
--|-----------------------------------------------------------------------

sDcErr  := 'Erro na inclusão das portabilidades de entrada(CDLAN 24200)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                  DTMESREF,
       CDLAN,                   TPMOV,                  CDPAT,
       IDPARPLA,                NRCPF,                  AUUSUULTALT,
       AUDATULTALT,             AUVERREGATL,            TXCHV )               
SELECT psCdFun,                 X.NRPLA,                psDtMesRef,
       X.CDLAN,                 1,                      X.CDPAT,
       X.IDPARPLA,              X.NRCPF,                psCdUsu,
       SYSDATE,                 0,                      X.CDPAT || '/' || X.NRMAT || '/00'
FROM ( SELECT '24200'                                   AS CDLAN,
              E.CDPAT                                   AS CDPAT,
              D.NRPLA                                   AS NRPLA,
              B.NRMAT                                   AS NRMAT,
              A.IDPARPLA                                AS IDPARPLA,
              TRIM(K.NRCPFPAR)                          AS NRCPF
       FROM   CTB_PORTABILIDADE_ENT A,
              PAR_PARPLA            B,
              PAR_PLANOS            D,
              PAR_PATROCINADORAS    E,
              PAR_PARTICIPANTES     K                                
       WHERE  A.DTPTB               BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT
       AND    B.IDPARPLA            = A.IDPARPLA
       AND    D.IDPLA               = B.IDPLA
       AND    D.NRPLA               = psNrPla
       AND    E.IDPAT               = D.IDPAT
       AND    E.IDFUN               = nIdFun      
       AND  ((E.CDPAT               IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT               = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR               = B.IDPAR 
   ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 1
                  AND    IDPARPLA = X.IDPARPLA
                );


COMMIT;



/*=============================================================
                   DADOS DE POPULAÇÃO
===============================================================*/

--|-------------------------------------------------------------------------
--| Participante com Custeio Exclusivamente Patronal        (Código: 31100)
--| Participante com Custeio Patronal e do Participante     (Código: 31200)
--| Participante com Custeio Exclusivamente do Participante (Código: 31300)
--|-------------------------------------------------------------------------

sDcErr  := 'Erro na inclusão das entradas dos códigos 31100, 31200 e 31300.';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                  DTMESREF,
       CDLAN,                   TPMOV,                  CDPAT,
       IDPARPLA,                NRCPF,                  AUUSUULTALT,
       AUDATULTALT,             AUVERREGATL,            TXCHV )
SELECT psCdFun,                 X.NRPLA,                psDtMesRef,
       X.CDLAN,                 1,                      X.CDPAT,
       X.IDPARPLA,              X.NRCPF,                psCdUsu,
       SYSDATE,                 0,                      X.CDPAT || '/' || X.NRMAT || '/00'
FROM ( -- 14/07/2022 (2020/77-00282): incluída a restrição de DTINISIT
       SELECT DISTINCT
              '31200'                                   AS CDLAN,
              E.CDPAT                                   AS CDPAT,
              D.NRPLA                                   AS NRPLA,
              B.NRMAT                                   AS NRMAT,
              A.IDPARPLA                                AS IDPARPLA,
              TRIM(K.NRCPFPAR)                          AS NRCPF
       FROM   PAR_HISITPAR        A,
              PAR_PARPLA          B,
              PAR_PLANOS          D,
              PAR_PATROCINADORAS  E,
              PAR_PARTICIPANTES   K
       WHERE  TRUNC(A.DTSISINI)  BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT
       AND    A.DTINISIT         <= dDtUltDiaMes_DT       
       AND    A.STISCATU          IN ('0','2','7')
       AND   (A.STISCANT          NOT IN ('0','2','7')    OR    A.DTINISIT = B.DTISCPAR )
       AND    B.IDPARPLA          = A.IDPARPLA
       AND    D.IDPLA             = B.IDPLA
       AND    D.NRPLA             = psNrPla
       AND    E.IDPAT             = D.IDPAT
       AND    E.IDFUN             = nIdFun      
       AND  ((E.CDPAT             IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT             = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR             = B.IDPAR 
       AND    NOT EXISTS(         SELECT 1
                                  FROM   PAR_SITPLA_PARAM
                                  WHERE  IDPLA                 = B.IDPLA
                                  AND    IDSITPLACAT           = A.IDSITPLACATANT
                                  AND    NVL(TPBNFCCD,'XX')    IN ('AD','AC')
                         )
       UNION 
       -- 14/10/2022 (2020/77-00282): incluído o union abaixo              
       SELECT DISTINCT
              '31200'                                   AS CDLAN,
              E.CDPAT                                   AS CDPAT,
              D.NRPLA                                   AS NRPLA,
              B.NRMAT                                   AS NRMAT,
              A.IDPARPLA                                AS IDPARPLA,
              TRIM(K.NRCPFPAR)                          AS NRCPF
       FROM   PAR_HISITPAR        A,
              PAR_PARPLA          B,
              PAR_PLANOS          D,
              PAR_PATROCINADORAS  E,
              PAR_PARTICIPANTES   K
       WHERE  TRUNC(A.DTSISINI)   BETWEEN dDtPriDiaMesAnt_DT AND dDtUltDiaMesAnt_DT
       AND    A.DTINISIT          BETWEEN dDtPriDiaMes_DT    AND dDtUltDiaMes_DT       
       AND    A.STISCATU          IN ('0','2','7')
       AND   (A.STISCANT          NOT IN ('0','2','7')    OR    A.DTINISIT = B.DTISCPAR )
       AND    B.IDPARPLA          = A.IDPARPLA
       AND    D.IDPLA             = B.IDPLA
       AND    D.NRPLA             = psNrPla
       AND    E.IDPAT             = D.IDPAT
       AND    E.IDFUN             = nIdFun      
       AND  ((E.CDPAT             IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT             = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR             = B.IDPAR 
       AND    NOT EXISTS(         SELECT 1
                                  FROM   PAR_SITPLA_PARAM
                                  WHERE  IDPLA                 = B.IDPLA
                                  AND    IDSITPLACAT           = A.IDSITPLACATANT
                                  AND    NVL(TPBNFCCD,'XX')    IN ('AD','AC')
                         )
       UNION                          
       -- 14/07/2022 (2020/77-00282): incluída a restrição de DTINISIT
       -- 29/11/2022 (2020/77-00282): substituído o CDLAN 31300 pelo CASE    
       SELECT DISTINCT
              CASE WHEN (A.STISCATU = '9') THEN '31310' ELSE '31320' END   AS CDLAN,
              E.CDPAT                                                      AS CDPAT,
              D.NRPLA                                                      AS NRPLA,
              B.NRMAT                                                      AS NRMAT,
              A.IDPARPLA                                                   AS IDPARPLA,
              TRIM(K.NRCPFPAR)                                             AS NRCPF
       FROM   PAR_HISITPAR       A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              PAR_PARTICIPANTES  K
       WHERE  TRUNC(A.DTSISINI)  BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT
       AND    A.DTINISIT         <= dDtUltDiaMes_DT       
       AND    A.STISCATU        IN ('1', '9')
       /*
       09/03/2023 (2020/77-00282): substituída a restrição abaixo 
       AND  ( A.STISCANT        NOT IN ('1', '9')
              OR
             (A.STISCANT        = A.STISCATU    AND   A.DTINISIT = B.DTISCPAR))
       */
       AND    A.STISCANT        <> A.STISCATU
       AND    B.IDPARPLA        = A.IDPARPLA
       AND    D.IDPLA           = B.IDPLA
       AND    D.NRPLA           = psNrPla
       AND    E.IDPAT           = D.IDPAT
       AND    E.IDFUN           = nIdFun      
       AND  ((E.CDPAT           IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT           = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR           = B.IDPAR 
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_SITPLA_PARAM
                                 WHERE  IDPLA                 = B.IDPLA
                                 AND    IDSITPLACAT           = A.IDSITPLACATANT
                                 AND    NVL(TPBNFCCD,'XX')    IN ('AD','AC')
                         )
       -- 14/10/2022 (2020/77-00282): incluído o union abaixo   
       -- 29/11/2022 (2020/77-00282): substituído o CDLAN 31300 pelo CASE             
       UNION                          
       SELECT DISTINCT
              CASE WHEN (A.STISCATU = '9') THEN '31310' ELSE '31320' END   AS CDLAN,
              E.CDPAT                                                      AS CDPAT,
              D.NRPLA                                                      AS NRPLA,
              B.NRMAT                                                      AS NRMAT,
              A.IDPARPLA                                                   AS IDPARPLA,
              TRIM(K.NRCPFPAR)                                             AS NRCPF
       FROM   PAR_HISITPAR       A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              PAR_PARTICIPANTES  K
       WHERE  TRUNC(A.DTSISINI)  BETWEEN dDtPriDiaMesAnt_DT AND dDtUltDiaMesAnt_DT
       AND    A.DTINISIT         BETWEEN dDtPriDiaMes_DT    AND dDtUltDiaMes_DT       
       AND    A.STISCATU        IN     ('1', '9')
       /*
       09/03/2023 (2020/77-00282): substituída a restrição abaixo 
       AND  ( A.STISCANT        NOT IN ('1', '9')
              OR
             (A.STISCANT        = A.STISCATU    AND   A.DTINISIT = B.DTISCPAR))
       */
       AND    A.STISCANT        <> A.STISCATU
       AND    B.IDPARPLA        = A.IDPARPLA
       AND    D.IDPLA           = B.IDPLA
       AND    D.NRPLA           = psNrPla
       AND    E.IDPAT           = D.IDPAT
       AND    E.IDFUN           = nIdFun      
       AND  ((E.CDPAT           IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT           = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR           = B.IDPAR 
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_SITPLA_PARAM
                                 WHERE  IDPLA                 = B.IDPLA
                                 AND    IDSITPLACAT           = A.IDSITPLACATANT
                                 AND    NVL(TPBNFCCD,'XX')    IN ('AD','AC')
                         )
                         
     ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 1
                  AND    IDPARPLA = X.IDPARPLA
                );
 


sDcErr  := 'Erro na inclusão das saídas dos códigos 31100, 31200 e 31300.';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                  DTMESREF,
       CDLAN,                   TPMOV,                  CDPAT,
       IDPARPLA,                NRCPF,                  AUUSUULTALT,
       AUDATULTALT,             AUVERREGATL,            TXCHV )
SELECT psCdFun,                 X.NRPLA,                psDtMesRef,
       X.CDLAN,                 2,                      X.CDPAT,
       X.IDPARPLA,              X.NRCPF,                psCdUsu,
       SYSDATE,                 0,                      X.CDPAT || '/' || X.NRMAT || '/00'
FROM ( -- 14/07/2022 (2020/77-00282): incluída a restrição de DTINISIT
       SELECT DISTINCT
              '31200'                                   AS CDLAN,
              E.CDPAT                                   AS CDPAT,
              D.NRPLA                                   AS NRPLA,
              B.NRMAT                                   AS NRMAT,
              A.IDPARPLA                                AS IDPARPLA,
              TRIM(K.NRCPFPAR)                          AS NRCPF
       FROM   PAR_HISITPAR       A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              PAR_PARTICIPANTES  K 
       WHERE  TRUNC(A.DTSISINI)  BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT
       AND    A.DTINISIT         <= dDtUltDiaMes_DT       
       AND    A.STISCATU         NOT IN ( '0','2','7' )
       AND    A.STISCANT         IN ( '0','2','7' )
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR            = B.IDPAR
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_SITPLA_PARAM
                                 WHERE  IDPLA                 = B.IDPLA
                                 AND    IDSITPLACAT           = A.IDSITPLACATATU
                                 AND    NVL(TPBNFCCD,'XX')    IN ('AD','AC')
                         )
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_HISITPAR
                                 WHERE  IDPARPLA              = A.IDPARPLA
                                 AND   ((DTSISINI             > A.DTSISINI)                                         
                                         OR
                                        (DTSISINI             = A.DTSISINI   AND    SQSIT > A.SQSIT)) 
                                 AND    TRUNC(DTSISINI)       <= dDtUltDiaMes_DT
                                 AND    STISCATU              IN ( '0','2','7' ) )
       -- 14/10/2022 (2020/77-00282): incluído o union abaixo              
       UNION                          
       SELECT DISTINCT
              '31200'                                   AS CDLAN,
              E.CDPAT                                   AS CDPAT,
              D.NRPLA                                   AS NRPLA,
              B.NRMAT                                   AS NRMAT,
              A.IDPARPLA                                AS IDPARPLA,
              TRIM(K.NRCPFPAR)                          AS NRCPF
       FROM   PAR_HISITPAR       A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              PAR_PARTICIPANTES  K 
       WHERE  TRUNC(A.DTSISINI)  BETWEEN dDtPriDiaMesAnt_DT AND dDtUltDiaMesAnt_DT
       AND    A.DTINISIT         BETWEEN dDtPriDiaMes_DT    AND dDtUltDiaMes_DT       
       AND    A.STISCATU         NOT IN ( '0','2','7' )
       AND    A.STISCANT         IN ( '0','2','7' )
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR            = B.IDPAR
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_SITPLA_PARAM
                                 WHERE  IDPLA                 = B.IDPLA
                                 AND    IDSITPLACAT           = A.IDSITPLACATATU
                                 AND    NVL(TPBNFCCD,'XX')    IN ('AD','AC')
                         )
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_HISITPAR
                                 WHERE  IDPARPLA              = A.IDPARPLA
                                 AND   ((DTSISINI             > A.DTSISINI)                                         
                                         OR
                                        (DTSISINI             = A.DTSISINI   AND    SQSIT > A.SQSIT)) 
                                 AND    TRUNC(DTSISINI)       <= dDtUltDiaMes_DT
                                 AND    STISCATU              IN ( '0','2','7' ) )
       UNION       
       -- 14/07/2022 (2020/77-00282): incluída a restrição de DTINISIT
       -- 29/11/2022 (2020/77-00282): substituído o CDLAN 31300 pelo CASE             
       SELECT DISTINCT
              CASE WHEN (A.STISCANT = '9') THEN '31310' ELSE '31320' END   AS CDLAN,
              E.CDPAT                                                      AS CDPAT,
              D.NRPLA                                                      AS NRPLA,
              B.NRMAT                                                      AS NRMAT,
              A.IDPARPLA                                                   AS IDPARPLA,
              TRIM(K.NRCPFPAR)                                             AS NRCPF
       FROM   PAR_HISITPAR       A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              PAR_PARTICIPANTES  K 
       WHERE  A.DTSISINI         BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    A.DTINISIT         <= dDtUltDiaMes_DT  
       AND    A.STISCANT         IN ('1', '9')
       /*     
       09/03/2023 (2020/77-00282): substituída a restrição abaixo 
       AND    A.STISCATU         NOT IN ('1', '9')
       */
       AND    A.STISCATU         <> A.STISCANT
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR            = B.IDPAR
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_SITPLA_PARAM
                                 WHERE  IDPLA                 = B.IDPLA
                                 AND    IDSITPLACAT           = A.IDSITPLACATATU
                                 AND    NVL(TPBNFCCD,'XX')    IN ('AD','AC')
                         )
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_HISITPAR
                                 WHERE  IDPARPLA              = A.IDPARPLA
                                 AND   ((DTSISINI             > A.DTSISINI)                                         
                                         OR
                                        (DTSISINI             = A.DTSISINI   AND    SQSIT > A.SQSIT)) 
                                 AND    STISCATU              IN ('1', /*'3',*/ '9') )
       -- 14/10/2022 (2020/77-00282): incluído o union abaixo              
       -- 29/11/2022 (2020/77-00282): substituído o CDLAN 31300 pelo CASE             
       UNION                          
       SELECT DISTINCT
              CASE WHEN (A.STISCANT = '9') THEN '31310' ELSE '31320' END   AS CDLAN,
              E.CDPAT                                                      AS CDPAT,
              D.NRPLA                                                      AS NRPLA,
              B.NRMAT                                                      AS NRMAT,
              A.IDPARPLA                                                   AS IDPARPLA,
              TRIM(K.NRCPFPAR)                                             AS NRCPF
       FROM   PAR_HISITPAR       A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              PAR_PARTICIPANTES  K 
       WHERE  TRUNC(A.DTSISINI)  BETWEEN dDtPriDiaMesAnt_DT AND dDtUltDiaMesAnt_DT
       AND    A.DTINISIT         BETWEEN dDtPriDiaMes_DT    AND dDtUltDiaMes_DT       
       AND    A.STISCATU         NOT IN ('1', /*'3',*/ '9')
       AND    A.STISCANT         IN     ('1', /*'3',*/ '9')
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR            = B.IDPAR
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_SITPLA_PARAM
                                 WHERE  IDPLA                 = B.IDPLA
                                 AND    IDSITPLACAT           = A.IDSITPLACATATU
                                 AND    NVL(TPBNFCCD,'XX')    IN ('AD','AC')
                         )
       AND    NOT EXISTS(        SELECT 1
                                 FROM   PAR_HISITPAR
                                 WHERE  IDPARPLA              = A.IDPARPLA
                                 AND   ((DTSISINI             > A.DTSISINI)                                         
                                         OR
                                        (DTSISINI             = A.DTSISINI   AND    SQSIT > A.SQSIT)) 
                                 AND    STISCATU              IN ('1', /*'3',*/ '9') )
    ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 2
                  AND    IDPARPLA = X.IDPARPLA
                );

--|----------------------------------------
--| Assistidos Aposentados (Código: 32000)
--|----------------------------------------

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                 DTMESREF,
       CDLAN,                   TPMOV,                 CDPAT,
       IDPARPLA,                IDBNFCCD,              IDBEN,
       NRCPF,                   AUUSUULTALT,           AUDATULTALT,
       AUVERREGATL,             TXCHV 
      )
SELECT A.CDFUN,                 A.NRPLA,               A.DTMESREF,
       '32000',                 A.TPMOV,               A.CDPAT,
       A.IDPARPLA,              A.IDBNFCCD,            A.IDBEN,
       A.NRCPF,                 psCdUsu,               SYSDATE,
       0,                       A.TXCHV
FROM   BNF_HISIPCAP_MOV       A
WHERE  A.CDFUN                = psCdFun
AND  ((A.CDPAT                IN ('001','002')    AND   psCdPat = '001')
       OR
      (A.CDPAT                = psCdPat           AND   psCdPat <> '001')) 
AND    A.NRPLA                = psNrPla
AND    A.DTMESREF             = psDtMesRef
AND    A.CDLAN                IN ('11100','11200')
AND    A.AUUSUULTALT          = psCdUsu;


--|----------------------------------------------------
--| Assistidos Beneficiários de Pensão (Código: 33000)
--|----------------------------------------------------

sDcErr  := 'Erro na inclusão das entradas de Assistidos - Beneficiarios de Pensão (CDLAN 3300)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                   DTMESREF,
       CDLAN,                   TPMOV,                   CDPAT,
       IDPARPLA,                IDBNFCCD,                IDBEN,
       NRCPF,                   AUUSUULTALT,             AUDATULTALT,
       AUVERREGATL,             txchv 
      )
SELECT psCdFun,                 X.NRPLA,                 psDtMesRef,
       X.CDLAN,                 1,                       X.CDPAT,
       X.IDPARPLA,              X.IDBNFCCD,              X.IDBEN,  
       X.NRCPF,                 psCdUsu,                 SYSDATE,
       0,                       X.CDPAT || '/' || X.NRMAT || '/' || SUBSTR(TO_CHAR(100 + X.SQDPD),2,3)
FROM ( SELECT DISTINCT
              '33000'                                    AS CDLAN,
              E.CDPAT                                    AS CDPAT,
              D.NRPLA                                    AS NRPLA,
              B.NRMAT                                    AS NRMAT,
              F.SQBEN                                    AS SQDPD,
              A.IDPARPLA                                 AS IDPARPLA,
              A.IDBNFCCD                                 AS IDBNFCCD,
              F.IDBEN                                    AS IDBEN,
              TRIM(F.NRCPFBEN)                           AS NRCPF
       FROM   BNF_BENEFICIARIOS  F,                                      
              BNF_BNFCONCEDIDOS  A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              BNF_BENFPLA        G,
              BNF_BENEFICIOS     H 
       WHERE  TRUNC(F.DTSISINC)  BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT
       AND    F.SQBEN            > 0
       AND    A.IDBNFCCD         = F.IDBNFCCD
       AND    NVL(A.PRPAGUNC,0)  < 100
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    G.IDBNFPLA         = A.IDBNFPLA
       AND    H.IDBNF            = G.IDBNF
       AND    H.TPBNF            = 'PS'
       UNION
       SELECT DISTINCT
              '33000'                                    AS CDLAN,
              E.CDPAT                                    AS CDPAT,
              D.NRPLA                                    AS NRPLA,
              B.NRMAT                                    AS NRMAT,
              G.SQBEN                                    AS SQDPD,
              A.IDPARPLA                                 AS IDPARPLA,
              A.IDBNFCCD                                 AS IDBNFCCD,
              F.IDBEN                                    AS IDBEN,
              TRIM(K.NRCPFPAR)                           AS NRCPF
       FROM   BNF_BENOCOR        F,                                                                                     
              BNF_BENEFICIARIOS  G,                                      
              BNF_BNFCONCEDIDOS  A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              BNF_BENFPLA        H,
              BNF_BENEFICIOS     I,
              PAR_PARTICIPANTES  K 
       WHERE  F.DTSISOCO         BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    F.TPOCO            = 'L'
       AND    G.IDBEN            = F.IDBEN
       AND    G.SQBEN            > 0
       AND  ( G.DTSISINC         IS NULL          OR   G.DTSISINC < dDtPriDiaMes_TS )
       AND    A.IDBNFCCD         = G.IDBNFCCD
       AND    NVL(A.PRPAGUNC,0)  < 100
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    H.IDBNFPLA         = A.IDBNFPLA
       AND    I.IDBNF            = H.IDBNF
       AND    I.TPBNF            = 'PS'
       AND    K.IDPAR            = B.IDPAR
       AND    NOT EXISTS (       SELECT 1
                                 FROM   BNF_BENOCOR H
                                 WHERE  H.IDBEN     = F.IDBEN
                                 AND    H.DTSISOCO  = ( SELECT MAX( DTSISOCO )
                                                        FROM   BNF_BENOCOR
                                                        WHERE  IDBEN         = H.IDBEN
                                                        AND    DTSISOCO      < F.DTSISOCO
                                                        AND    TPOCO         <> 'L' )
                                 AND    h.TPOCO     = 'S')
     ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 1
                  AND    IDBEN    = X.IDBEN
                );


sDcErr  := 'Erro na inclusão das saidas de Assistidos - Beneficiarios de Pensão (CDLAN 33000)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                  DTMESREF,
       CDLAN,                   TPMOV,                  CDPAT,
       IDPARPLA,                IDBNFCCD,               IDBEN,
       NRCPF,                   AUUSUULTALT,            AUDATULTALT,
       AUVERREGATL,             TXCHV 
      )
SELECT psCdFun,                 X.NRPLA,                psDtMesRef,
       X.CDLAN,                 2,                      X.CDPAT,
       X.IDPARPLA,              X.IDBNFCCD,             X.IDBEN,
       X.NRCPF,                 psCdUsu,                SYSDATE,
       0,                       X.CDPAT || '/' || X.NRMAT || '/' || SUBSTR(TO_CHAR(100 + X.SQDPD),2,3)
FROM ( SELECT DISTINCT
              '33000'                                   AS CDLAN,
              E.CDPAT                                   AS CDPAT,
              D.NRPLA                                   AS NRPLA,
              B.NRMAT                                   AS NRMAT,
              G.SQBEN                                   AS SQDPD,
              A.IDPARPLA                                AS IDPARPLA,
              A.IDBNFCCD                                AS IDBNFCCD,
              F.IDBEN                                   AS IDBEN,
              TRIM(K.NRCPFPAR)                          AS NRCPF
       FROM   BNF_BENOCOR        F,                                                                                     
              BNF_BENEFICIARIOS  G,                                      
              BNF_BNFCONCEDIDOS  A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              PAR_PARTICIPANTES  K 
       WHERE  F.DTSISOCO         BETWEEN dDtPriDiaMes_TS AND dDtUltDiaMes_TS
       AND    F.TPOCO            = 'E'
       AND    G.IDBEN            = F.IDBEN
       AND    G.SQBEN            > 0
       AND    A.IDBNFCCD         = G.IDBNFCCD
       AND    NVL(A.PRPAGUNC,0)  < 100
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    K.IDPAR            = B.IDPAR
     ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 2
                  AND    IDBEN    = X.IDBEN
                );


--|-----------------------------------------
--| Designados Participantes (Código: 34100)
--|-----------------------------------------

sDcErr  := 'Erro na inclusão das entradas de Designados Participantes (CDLAN 34100)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                  DTMESREF,
       CDLAN,                   TPMOV,                  CDPAT,
       IDPARPLA,                IDDEP,                  NRCPF,
       AUUSUULTALT,             AUDATULTALT,            AUVERREGATL,
       TXCHV
     )
SELECT psCdFun,                 X.NRPLA,                psDtMesRef,
       X.CDLAN,                 1,                      X.CDPAT,
       X.IDPARPLA,              X.IDDEP,                X.NRCPF,
       psCdUsu,                 SYSDATE,                0,
       X.CDPAT || '/' || X.NRMAT || '/' || SUBSTR(TO_CHAR(100 + X.SQDPD),2,3)
FROM ( SELECT DISTINCT
              '34100'                                   AS CDLAN,
              F.CDPAT                                   AS CDPAT,
              E.NRPLA                                   AS NRPLA,
              D.NRMAT                                   AS NRMAT,
              C.SQDPD                                   AS SQDPD,
              D.IDPARPLA                                AS IDPARPLA,
              B.IDDEP                                   AS IDDEP,
              TRIM(C.NRCPFDPD)                          AS NRCPF
       FROM   PAR_DEPFIN         A,                                                                                     
              PAR_DEPPLA         B,  
              PAR_PLANOS         E,
              PAR_PATROCINADORAS F,                                    
              PAR_DEPENDENTES    C,
              PAR_PARPLA         D,
              PAR_HISITPAR       H,
              PAR_SITPLA_PARAM   I
       WHERE  TRUNC(A.DTSISINI)  BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT
       AND    A.IDFINDPD         = '01'
       AND    B.IDDEPPLA         = A.IDDEPPLA
       AND    E.IDPLA            = B.IDPLA
       AND    E.NRPLA            = psNrPla
       AND    F.IDPAT            = E.IDPAT
       AND    F.IDFUN            = nIdFun      
       AND  ((F.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (F.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    C.IDDEP            = B.IDDEP
       AND    D.IDPAR            = C.IDPAR
       AND    D.IDPLA            = B.IDPLA
       AND    H.IDPARPLA         = D.IDPARPLA
       AND    H.DTSISINI         = ( SELECT MAX( DTSISINI )
                                     FROM   PAR_HISITPAR
                                     WHERE  IDPARPLA      =  H.IDPARPLA
                                     AND    DTSISINI      <= dDtUltDiaMes_TS )
       AND    I.IDPLA            = B.IDPLA
       AND    I.IDSITPLACAT      = H.IDSITPLACATATU                                                   
       AND  ((H.STISCATU         IN ('0','1','2',/*'3',*/'7','9')) 
              OR 
             (H.STISCATU         = '4'           and NVL(I.TPBNFCCD,'XX') = 'AD')) 
       UNION
       SELECT DISTINCT
              '34100'                                   AS CDLAN,
              F.CDPAT                                   AS CDPAT,
              E.NRPLA                                   AS NRPLA,
              D.NRMAT                                   AS NRMAT,
              C.SQDPD                                   AS SQDPD,
              D.IDPARPLA                                AS IDPARPLA,
              B.IDDEP                                   AS IDDEP,
              TRIM(C.NRCPFDPD)                          AS NRCPF
       FROM   PAR_DEPFIN         A,                                                                                     
              PAR_DEPPLA         B,  
              PAR_PLANOS         E,
              PAR_PATROCINADORAS F,                                        
              PAR_DEPENDENTES    C,
              PAR_PARPLA         D,
              PAR_HISITPAR       H,
              PAR_SITPLA_PARAM   I
       WHERE  A.DTSISINI         IS NULL
       AND    A.DTINIVIG         BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT  
       AND    A.IDFINDPD         = '01'
       AND    B.IDDEPPLA         = A.IDDEPPLA
       AND    E.IDPLA            = B.IDPLA
       AND    E.NRPLA            = psNrPla
       AND    F.IDPAT            = E.IDPAT
       AND    F.IDFUN            = nIdFun      
       AND  ((F.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (F.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    C.IDDEP            = B.IDDEP
       AND    D.IDPAR            = C.IDPAR
       AND    D.IDPLA            = B.IDPLA
       AND    H.IDPARPLA         = D.IDPARPLA
       AND    H.DTSISINI         = ( SELECT MAX( DTSISINI )
                                     FROM   PAR_HISITPAR
                                     WHERE  IDPARPLA      =  H.IDPARPLA
                                     AND    DTSISINI      <= dDtUltDiaMes_TS )
       AND    I.IDPLA            = B.IDPLA
       AND    I.IDSITPLACAT      = H.IDSITPLACATATU                                                   
       AND  ((H.STISCATU         IN ('0','1','2',/*'3',*/'7','9')) 
              OR 
             (H.STISCATU         = '4'           and NVL(I.TPBNFCCD,'XX') = 'AD'))  
    ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 1
                  AND    IDDEP    = X.IDDEP
                );     
           
          
sDcErr  := 'Erro na inclusão das saidas de Designados Participantes (CDLAN 34100)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                  DTMESREF,
       CDLAN,                   TPMOV,                  CDPAT,
       IDPARPLA,                IDDEP,                  NRCPF,
       AUUSUULTALT,             AUDATULTALT,            AUVERREGATL,
       TXCHV 
     )
SELECT DISTINCT
       psCdFun,                 X.NRPLA,                psDtMesRef,
       X.CDLAN,                 2,                      X.CDPAT,
       X.IDPARPLA,              X.IDDEP,                X.NRCPF,
       psCdUsu,                 SYSDATE,                0,
       X.CDPAT || '/' || X.NRMAT || '/' || SUBSTR(TO_CHAR(100 + X.SQDPD),2,3)
FROM ( -- trata as saídas registradas no cadastro de dependentes
       SELECT '34100'                                   AS CDLAN,
              F.CDPAT                                   AS CDPAT,
              E.NRPLA                                   AS NRPLA,
              D.NRMAT                                   AS NRMAT,
              C.SQDPD                                   AS SQDPD,
              D.IDPARPLA                                AS IDPARPLA,
              B.IDDEP                                   AS IDDEP,
              TRIM(C.NRCPFDPD)                          AS NRCPF
       FROM   PAR_DEPFIN         A,                                                                                     
              PAR_DEPPLA         B,   
              PAR_PLANOS         E,
              PAR_PATROCINADORAS F,                                   
              PAR_DEPENDENTES    C,
              PAR_PARPLA         D,
              PAR_HISITPAR       H,
              PAR_SITPLA_PARAM   I
       WHERE  TRUNC(A.DTSISFIM)  BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT
       AND    A.IDFINDPD         = '01'
       AND    B.IDDEPPLA         = A.IDDEPPLA
       AND    E.IDPLA            = B.IDPLA
       AND    E.NRPLA            = psNrPla
       AND    F.IDPAT            = E.IDPAT
       AND    F.IDFUN            = nIdFun      
       AND  ((F.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (F.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    C.IDDEP            = B.IDDEP
       AND    D.IDPAR            = C.IDPAR
       AND    D.IDPLA            = B.IDPLA
       AND    H.IDPARPLA         = D.IDPARPLA
       AND    H.DTSISINI         = ( SELECT MAX( DTSISINI )
                                     FROM   PAR_HISITPAR
                                     WHERE  IDPARPLA      =  H.IDPARPLA
                                     AND    DTSISINI      <= dDtUltDiaMes_TS )
       AND    I.IDPLA            = B.IDPLA
       AND    I.IDSITPLACAT      = H.IDSITPLACATATU                                                   
       AND  ((H.STISCATU         IN ('0','1','2',/*'3',*/'7','9')) 
              OR 
             (H.STISCATU         = '4'           and NVL(I.TPBNFCCD,'XX') = 'AD'))                                                                                                      
       UNION
       SELECT '34100'                                   AS CDLAN,
              F.CDPAT                                   AS CDPAT,
              E.NRPLA                                   AS NRPLA,
              D.NRMAT                                   AS NRMAT,
              C.SQDPD                                   AS SQDPD,
              D.IDPARPLA                                AS IDPARPLA,
              B.IDDEP                                   AS IDDEP,
              TRIM(C.NRCPFDPD)                          AS NRCPF
       FROM   PAR_DEPFIN         A,                                                                                     
              PAR_DEPPLA         B,    
              PAR_PLANOS         E,
              PAR_PATROCINADORAS F,                                  
              PAR_DEPENDENTES    C,
              PAR_PARPLA         D,
              PAR_HISITPAR       H,
              PAR_SITPLA_PARAM   I
       WHERE  A.DTSISFIM         IS NULL
       AND    A.DTFIMVIG         BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT   
       AND    A.IDFINDPD         = '01'
       AND    B.IDDEPPLA         = A.IDDEPPLA
       AND    E.IDPLA            = B.IDPLA
       AND    E.NRPLA            = psNrPla
       AND    F.IDPAT            = E.IDPAT
       AND    F.IDFUN            = nIdFun      
       AND  ((F.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (F.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    C.IDDEP            = B.IDDEP
       AND    D.IDPAR            = C.IDPAR
       AND    D.IDPLA            = B.IDPLA
       AND    H.IDPARPLA         = D.IDPARPLA
       AND    H.DTSISINI         = ( SELECT MAX( DTSISINI )
                                     FROM   PAR_HISITPAR
                                     WHERE  IDPARPLA      =  H.IDPARPLA
                                     AND    DTSISINI      <= dDtUltDiaMes_TS )
       AND    I.IDPLA            = B.IDPLA
       AND    I.IDSITPLACAT      = H.IDSITPLACATATU                                                   
       AND  ((H.STISCATU         IN ('0','1','2',/*'3',*/'7','9')) 
              OR 
             (H.STISCATU         = '4'           and NVL(I.TPBNFCCD,'XX') = 'AD'))                        
       UNION
       -- trata as saídas decorrentes de resgate e portabilidade de saída
       -- 08/03/2023: incluído o teste de STISCANT
       SELECT '34100'                                   AS CDLAN,
              A.CDPAT                                   AS CDPAT,
              A.NRPLA                                   AS NRPLA,
              B.NRMAT                                   AS NRMAT,
              C.SQDPD                                   AS SQDPD,
              A.IDPARPLA                                AS IDPARPLA,
              C.IDDEP                                   AS IDDEP,
              TRIM(C.NRCPFDPD)                          AS NRCPF
       FROM   BNF_HISIPCAP_MOV   A,
              PAR_PARPLA         B,
              PAR_DEPENDENTES    C,
              PAR_DEPPLA         D,
              PAR_DEPFIN         E,
              PAR_HISITPAR       F
       WHERE  A.DTMESREF         = psDtMesRef
       AND    A.NRPLA            = psNrPla
       AND  ((A.CDPAT            IN ('001','002')       AND     psCdPat =  '001')  
              OR
             (A.CDPAT            = psCdPat              AND     psCdPat <> '001'))          
       AND    A.CDLAN            IN ('23000','24100','32000')
       AND    A.TPMOV            = 1
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    C.IDPAR            = B.IDPAR  
       AND    D.IDDEP            = C.IDDEP
       AND    D.IDPLA            = B.IDPLA
       AND  ((D.DTEXCDPD         IS NULL) 
              OR
             (D.DTEXCDPD         >= dDtPriDiaMes_DT))
       AND  ((D.DTSISFIM         IS NULL) 
              OR
             (TRUNC(D.DTSISFIM)  >= dDtPriDiaMes_DT))     
       AND    E.IDDEPPLA         = D.IDDEPPLA
       AND    E.IDFINDPD         = '01'
       AND    TRUNC(E.DTSISINI)  < dDtPriDiaMes_DT
       AND  ( E.DTSISFIM         IS NULL        
              OR   
             (TRUNC(E.DTSISFIM)  BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT ))  
       AND  ((E.DTFIMVIG         IS NULL) 
              OR
             (E.DTFIMVIG         >= dDtPriDiaMes_DT))
       AND    F.IDPARPLA         = A.IDPARPLA
       AND    F.DTSISINI         = ( SELECT MAX( DTSISINI )
                                     FROM   PAR_HISITPAR
                                     WHERE  IDPARPLA      =  F.IDPARPLA
                                     AND    DTSISINI      <= dDtUltDiaMes_TS )
       AND    F.STISCANT         <> '5' 
       UNION
       -- trata as saídas decorrentes de aposentadoria
       SELECT '34100'                                   AS CDLAN,
              A.CDPAT                                   AS CDPAT,
              A.NRPLA                                   AS NRPLA,
              B.NRMAT                                   AS NRMAT,
              C.SQDPD                                   AS SQDPD,
              A.IDPARPLA                                AS IDPARPLA,
              C.IDDEP                                   AS IDDEP,
              TRIM(C.NRCPFDPD)                          AS NRCPF
       FROM   BNF_HISIPCAP_MOV   A,
              PAR_PARPLA         B,
              PAR_DEPENDENTES    C,
              PAR_DEPPLA         D,
              PAR_DEPFIN         E
       WHERE  A.DTMESREF         = psDtMesRef
       AND    A.NRPLA            = psNrPla
       AND  ((A.CDPAT            IN ('001','002')       AND     psCdPat =  '001')  
              OR
             (A.CDPAT            = psCdPat              AND     psCdPat <> '001'))          
       AND    A.CDLAN            IN ('32000')
       AND    A.TPMOV            = 1
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    C.IDPAR            = B.IDPAR  
       AND    D.IDDEP            = C.IDDEP
       AND    D.IDPLA            = B.IDPLA
       AND  ((D.DTEXCDPD         IS NULL) 
              OR
             (D.DTEXCDPD         >= dDtPriDiaMes_DT))
       AND  ((D.DTSISFIM         IS NULL) 
              OR
             (TRUNC(D.DTSISFIM)  >= dDtPriDiaMes_DT))     
       AND    E.IDDEPPLA         = D.IDDEPPLA
       AND    E.IDFINDPD         = '01'
       AND    TRUNC(E.DTSISINI)  < dDtPriDiaMes_DT
       AND  ( E.DTSISFIM         IS NULL        
              OR   
             (TRUNC(E.DTSISFIM)  BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT ))  
       AND  ((E.DTFIMVIG         IS NULL) 
              OR
             (E.DTFIMVIG         >= dDtPriDiaMes_DT))
       UNION
       -- trata as saídas decorrentes de concessão de pensão por morte de ativo
       -- (só considerar as saídas dos que já se encontravam cadastrados antes da concessão da pensão)
       SELECT '34100'                                   AS CDLAN,
              E.CDPAT                                   AS CDPAT,
              D.NRPLA                                   AS NRPLA,
              B.NRMAT                                   AS NRMAT,
              H.SQDPD                                   AS SQDPD,
              A.IDPARPLA                                AS IDPARPLA,
              H.IDDEP                                   AS IDDEP,
              TRIM(H.NRCPFDPD)                          AS NRCPF
       FROM   BNF_BNFCONCEDIDOS  A,
              PAR_PARPLA         B,
              PAR_PLANOS         D,
              PAR_PATROCINADORAS E,
              BNF_BENFPLA        F,
              BNF_BENEFICIOS     G,
              PAR_DEPENDENTES    H,
              PAR_DEPPLA         I,
              PAR_DEPFIN         J
       WHERE  A.DTCOSBNF         BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT
       AND    A.NRPCSFUNANT      IS NULL
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    D.IDPLA            = B.IDPLA
       AND    D.NRPLA            = psNrPla
       AND    E.IDPAT            = D.IDPAT
       AND    E.IDFUN            = nIdFun      
       AND  ((E.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (E.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    F.IDBNFPLA         = A.IDBNFPLA
       AND    G.IDBNF            = F.IDBNF
       AND    G.TPBNF            = 'PS'
       AND    H.IDPAR            = B.IDPAR
       AND    H.DTFALDPD         IS NULL
       AND    I.IDPLA            = B.IDPLA
       AND    I.IDDEP            = H.IDDEP
       AND  ((I.DTEXCDPD         IS NULL) 
              OR
             (I.DTEXCDPD         >= dDtPriDiaMes_DT))
       AND  ((I.DTSISFIM         IS NULL) 
              OR
             (TRUNC(I.DTSISFIM)  >= dDtPriDiaMes_DT))     
       AND    J.IDDEPPLA         = I.IDDEPPLA
       AND    J.IDFINDPD         = '01'
       AND    TRUNC(J.DTSISINI)  < dDtPriDiaMes_DT 
       AND  ( J.DTSISFIM         IS NULL        
              OR   
             (TRUNC(J.DTSISFIM) BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT ))  
       AND  ((J.DTFIMVIG         IS NULL) 
              OR
             (J.DTFIMVIG         >= dDtPriDiaMes_DT))
       AND    NOT EXISTS(        SELECT 1
                                 FROM   BNF_HISIPCAP_MOV
                                 WHERE  DTMESREF = psDtMesRef
                                 AND    NRPLA    = D.NRPLA
                                 AND    CDPAT    = E.CDPAT
                                 AND    CDFUN    = psCdFun
                                 AND    CDLAN    IN ('11100','11200')
                                 AND    TPMOV    = 2
                                 AND    IDPARPLA = A.IDPARPLA
                        )
       AND    NOT EXISTS(        SELECT 1
                                 FROM   BNF_HISIPCAP_MOV
                                 WHERE  DTMESREF < psDtMesRef
                                 AND    NRPLA    = D.NRPLA
                                 AND    CDPAT    = E.CDPAT
                                 AND    CDFUN    = psCdFun
                                 AND    CDLAN    = '34100'
                                 AND    TPMOV    = 2
                                 AND    IDDEP    = H.IDDEP
                        )
     ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 2
                  AND    IDDEP    = X.IDDEP
                );            
       

--|-----------------------------------------
--| Designados Assistidos (Código: 34200)
--|-----------------------------------------

sDcErr  := 'Erro na inclusão das entradas de Designados Assistidos (CDLAN 34200)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                  DTMESREF,
       CDLAN,                   TPMOV,                  CDPAT,
       IDPARPLA,                IDDEP,                  NRCPF,
       AUUSUULTALT,             AUDATULTALT,            AUVERREGATL,
       TXCHV 
     )
SELECT psCdFun,                 X.NRPLA,                psDtMesRef,
       X.CDLAN,                 1,                      X.CDPAT,
       X.IDPARPLA,              X.IDDEP,                X.NRCPF,
       psCdUsu,                 SYSDATE,                0,
       X.CDPAT || '/' || X.NRMAT || '/' || SUBSTR(TO_CHAR(100 + X.SQDPD),2,3)
FROM ( SELECT DISTINCT
              '34200'                                   AS CDLAN,
              F.CDPAT                                   AS CDPAT,
              E.NRPLA                                   AS NRPLA,
              D.NRMAT                                   AS NRMAT,
              C.SQDPD                                   AS SQDPD,
              D.IDPARPLA                                AS IDPARPLA,
              B.IDDEP                                   AS IDDEP,
              TRIM(C.NRCPFDPD)                          AS NRCPF
       FROM   PAR_DEPFIN         A,                                                                                     
              PAR_DEPPLA         B,     
              PAR_PLANOS         E,
              PAR_PATROCINADORAS F,                                     
              PAR_DEPENDENTES    C,
              PAR_PARPLA         D,
              PAR_HISITPAR       H,
              PAR_SITPLA_PARAM   I
       WHERE  TRUNC(A.DTSISINI)  BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT  
       AND    A.IDFINDPD         = '01'
       AND    B.IDDEPPLA         = A.IDDEPPLA
       AND    E.IDPLA            = B.IDPLA
       AND    E.NRPLA            = psNrPla
       AND    F.IDPAT            = E.IDPAT
       AND    F.IDFUN            = nIdFun      
       AND  ((F.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (F.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    C.IDDEP            = B.IDDEP
       AND    D.IDPAR            = C.IDPAR
       AND    D.IDPLA            = B.IDPLA
       AND    H.IDPARPLA         = D.IDPARPLA
       AND    H.DTSISINI         = ( SELECT MAX( DTSISINI )
                                     FROM   PAR_HISITPAR
                                     WHERE  IDPARPLA      =  H.IDPARPLA
                                     AND    DTSISINI      <= dDtUltDiaMes_TS )
       AND    H.STISCATU         = '4'
       AND    I.IDPLA            = B.IDPLA
       AND    I.IDSITPLACAT      = H.IDSITPLACATATU 
       AND    NVL(I.TPBNFCCD,'XX') IN ('AP','BP')                                                                                                      
       UNION
       SELECT DISTINCT
              '34200'                                   AS CDLAN,
              F.CDPAT                                   AS CDPAT,
              E.NRPLA                                   AS NRPLA,
              D.NRMAT                                   AS NRMAT,
              C.SQDPD                                   AS SQDPD,
              D.IDPARPLA                                AS IDPARPLA,
              B.IDDEP                                   AS IDDEP,
              TRIM(C.NRCPFDPD)                          AS NRCPF
       FROM   PAR_DEPFIN         A,                                                                                     
              PAR_DEPPLA         B,      
              PAR_PLANOS         E,
              PAR_PATROCINADORAS F,                                    
              PAR_DEPENDENTES    C,
              PAR_PARPLA         D,
              PAR_HISITPAR       H,
              PAR_SITPLA_PARAM   I
       WHERE  A.DTSISINI         IS NULL
       AND    A.DTINIVIG         BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT  
       AND    A.IDFINDPD         = '01'
       AND    B.IDDEPPLA         = A.IDDEPPLA
       AND    E.IDPLA            = B.IDPLA
       AND    E.NRPLA            = psNrPla
       AND    F.IDPAT            = E.IDPAT
       AND    F.IDFUN            = nIdFun      
       AND  ((F.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (F.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    C.IDDEP            = B.IDDEP
       AND    D.IDPAR            = C.IDPAR
       AND    D.IDPLA            = B.IDPLA
       AND    H.IDPARPLA         = D.IDPARPLA
       AND    H.DTSISINI         = ( SELECT MAX( DTSISINI )
                                     FROM   PAR_HISITPAR
                                     WHERE  IDPARPLA      =  H.IDPARPLA
                                     AND    DTSISINI      <= dDtUltDiaMes_TS )
       AND    H.STISCATU         = '4'
       AND    I.IDPLA            = B.IDPLA
       AND    I.IDSITPLACAT      = H.IDSITPLACATATU 
       AND    NVL(I.TPBNFCCD,'XX') IN ('AP','BP')                                                                                                      
       -- trata as entradas decorrentes de concessão de aposentadoria
       UNION
       SELECT '34200'                                   AS CDLAN,
              A.CDPAT                                   AS CDPAT,
              A.NRPLA                                   AS NRPLA,
              B.NRMAT                                   AS NRMAT,
              C.SQDPD                                   AS SQDPD,
              A.IDPARPLA                                AS IDPARPLA,
              C.IDDEP                                   AS IDDEP,
              TRIM(C.NRCPFDPD)                          AS NRCPF
       FROM   BNF_HISIPCAP_MOV   A,
              PAR_PARPLA         B,
              PAR_DEPENDENTES    C,
              PAR_DEPPLA         D,
              PAR_DEPFIN         E
       WHERE  A.DTMESREF         = psDtMesRef
       AND    A.NRPLA            = psNrPla
       AND  ((A.CDPAT            IN ('001','002')       AND     psCdPat =  '001')  
              OR
             (A.CDPAT            = psCdPat              AND     psCdPat <> '001'))          
       AND    A.CDLAN            = '32000'
       AND    A.TPMOV            = 1
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    C.IDPAR            = B.IDPAR  
       AND    D.IDDEP            = C.IDDEP
       AND    D.IDPLA            = B.IDPLA
       AND  ((D.DTEXCDPD         IS NULL) 
              OR
             (D.DTEXCDPD         >= dDtPriDiaMes_DT))
       AND  ((D.DTSISFIM         IS NULL) 
              OR
             (TRUNC(D.DTSISFIM)  >= dDtPriDiaMes_DT))     
       AND    E.IDDEPPLA         = D.IDDEPPLA
       AND    E.IDFINDPD         = '01'
       AND    TRUNC(E.DTSISINI)  < dDtPriDiaMes_DT
       AND  ( E.DTSISFIM         IS NULL        
              OR   
             (TRUNC(E.DTSISFIM) BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT ))  
       AND  ((E.DTFIMVIG         IS NULL) 
              OR
             (E.DTFIMVIG         >= dDtPriDiaMes_DT))
    ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 1
                  AND    IDDEP    = X.IDDEP
                );     
                
                
     
sDcErr  := 'Erro na inclusão das saidas de Designados Assistidos (CDLAN 34200)';

INSERT INTO BNF_HISIPCAP_MOV
     ( CDFUN,                   NRPLA,                  DTMESREF,
       CDLAN,                   TPMOV,                  CDPAT,
       IDPARPLA,                IDDEP,                  NRCPF,
       AUUSUULTALT,             AUDATULTALT,            AUVERREGATL,
       TXCHV 
     )
SELECT DISTINCT
       psCdFun,                 X.NRPLA,                psDtMesRef,
       X.CDLAN,                 2,                      X.CDPAT,
       X.IDPARPLA,              X.IDDEP,                X.NRCPF,
       psCdUsu,                 SYSDATE,                0,
       X.CDPAT || '/' || X.NRMAT || '/' || SUBSTR(TO_CHAR(100 + X.SQDPD),2,3)
FROM ( -- trata as saídas registradas no cadastro de dependentes
       SELECT '34200'                                   AS CDLAN,
              F.CDPAT                                   AS CDPAT,
              E.NRPLA                                   AS NRPLA,
              D.NRMAT                                   AS NRMAT,
              C.SQDPD                                   AS SQDPD,
              D.IDPARPLA                                AS IDPARPLA,
              B.IDDEP                                   AS IDDEP,
              TRIM(C.NRCPFDPD)                          AS NRCPF
       FROM   PAR_DEPFIN         A,                                                                                     
              PAR_DEPPLA         B,  
              PAR_PLANOS         E,
              PAR_PATROCINADORAS F,                                      
              PAR_DEPENDENTES    C,
              PAR_PARPLA         D,  
              PAR_HISITPAR       H,
              PAR_SITPLA_PARAM   I
       WHERE  TRUNC(A.DTSISFIM)  BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT  
       AND    A.IDFINDPD         = '01'
       AND    B.IDDEPPLA         = A.IDDEPPLA
       AND    E.IDPLA            = B.IDPLA
       AND    E.NRPLA            = psNrPla
       AND    F.IDPAT            = E.IDPAT
       AND    F.IDFUN            = nIdFun      
       AND  ((F.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (F.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    C.IDDEP            = B.IDDEP
       AND    D.IDPAR            = C.IDPAR
       AND    D.IDPLA            = B.IDPLA
       AND    H.IDPARPLA         = D.IDPARPLA
       AND    H.DTSISINI         = ( SELECT MAX( DTSISINI )
                                     FROM   PAR_HISITPAR
                                     WHERE  IDPARPLA      =  H.IDPARPLA
                                     AND    DTSISINI      <= dDtUltDiaMes_TS )                                                  
       AND    H.STISCATU         = '4'
       AND    I.IDPLA            = B.IDPLA
       AND    I.IDSITPLACAT      = H.IDSITPLACATATU 
       AND    NVL(I.TPBNFCCD,'XX') IN ('AP','BP')                                                                                                      
       UNION
       SELECT '34200'                                   AS CDLAN,
              F.CDPAT                                   AS CDPAT,
              E.NRPLA                                   AS NRPLA,
              D.NRMAT                                   AS NRMAT,
              C.SQDPD                                   AS SQDPD,
              D.IDPARPLA                                AS IDPARPLA,
              B.IDDEP                                   AS IDDEP,
              TRIM(C.NRCPFDPD)                          AS NRCPF
       FROM   PAR_DEPFIN         A,                                                                                     
              PAR_DEPPLA         B,      
              PAR_PLANOS         E,
              PAR_PATROCINADORAS F,                                  
              PAR_DEPENDENTES    C,
              PAR_PARPLA         D,
              PAR_HISITPAR       H,
              PAR_SITPLA_PARAM   I
       WHERE  A.DTSISFIM         IS NULL
       AND    A.DTFIMVIG         BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT   
       AND    A.IDFINDPD         = '01'
       AND    B.IDDEPPLA         = A.IDDEPPLA
       AND    E.IDPLA            = B.IDPLA
       AND    E.NRPLA            = psNrPla
       AND    F.IDPAT            = E.IDPAT
       AND    F.IDFUN            = nIdFun      
       AND  ((F.CDPAT            IN ('001','002')    AND   psCdPat = '001')
              OR
             (F.CDPAT            = psCdPat           AND   psCdPat <> '001')) 
       AND    C.IDDEP            = B.IDDEP
       AND    D.IDPAR            = C.IDPAR
       AND    D.IDPLA            = B.IDPLA
       AND    H.IDPARPLA         = D.IDPARPLA
       AND    H.DTSISINI         = ( SELECT MAX( DTSISINI )
                                     FROM   PAR_HISITPAR
                                     WHERE  IDPARPLA      =  H.IDPARPLA
                                     AND    DTSISINI      <= dDtUltDiaMes_TS )
       AND    H.STISCATU         = '4'
       AND    I.IDPLA            = B.IDPLA
       AND    I.IDSITPLACAT      = H.IDSITPLACATATU 
       AND    NVL(I.TPBNFCCD,'XX') IN ('AP','BP')                                                                                                      
       UNION
       -- trata as saídas decorrentes de término de aposentadoria
       SELECT '34200'                                   AS CDLAN,
              A.CDPAT                                   AS CDPAT,
              A.NRPLA                                   AS NRPLA,
              B.NRMAT                                   AS NRMAT,
              C.SQDPD                                   AS SQDPD,
              A.IDPARPLA                                AS IDPARPLA,
              C.IDDEP                                   AS IDDEP,
              TRIM(C.NRCPFDPD)                          AS NRCPF
       FROM   BNF_HISIPCAP_MOV   A,
              PAR_PARPLA         B,
              PAR_DEPENDENTES    C,
              PAR_DEPPLA         D,
              PAR_DEPFIN         E
       WHERE  A.DTMESREF         = psDtMesRef
       AND    A.NRPLA            = psNrPla
       AND  ((A.CDPAT            IN ('001','002')       AND     psCdPat =  '001')  
              OR
             (A.CDPAT            = psCdPat              AND     psCdPat <> '001'))          
       AND    A.CDLAN            = '32000'
       AND    A.TPMOV            = 2
       AND    B.IDPARPLA         = A.IDPARPLA
       AND    C.IDPAR            = B.IDPAR  
       AND    D.IDDEP            = C.IDDEP
       AND    D.IDPLA            = B.IDPLA
     --AND    D.STDPD            = 'A'
       AND  ((D.DTEXCDPD         IS NULL) 
              OR
             (D.DTEXCDPD         >= dDtPriDiaMes_DT))
       AND  ((D.DTSISFIM         IS NULL) 
              OR
             (TRUNC(D.DTSISFIM)  BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT))
       AND    E.IDDEPPLA         = D.IDDEPPLA
       AND    E.IDFINDPD         = '01'
       AND    TRUNC(E.DTSISINI)  < dDtPriDiaMes_DT
       AND  ( E.DTSISFIM         IS NULL        
              OR   
             (TRUNC(E.DTSISFIM) BETWEEN dDtPriDiaMes_DT AND dDtUltDiaMes_DT ))  
       AND  ((E.DTFIMVIG         IS NULL) 
              OR
             (E.DTFIMVIG         >= dDtPriDiaMes_DT))
     ) X
WHERE NOT EXISTS( SELECT 1
                  FROM   BNF_HISIPCAP_EXC
                  WHERE  DTMESREF = psDtMesRef
                  AND    NRPLA    = X.NRPLA
                  AND    CDPAT    = X.CDPAT
                  AND    CDFUN    = psCdFun
                  AND    CDLAN    = X.CDLAN
                  AND    TPMOV    = 2
                  AND    IDDEP    = X.IDDEP
                );            

                
COMMIT;


/*------------------- Tratamento de erros  */

exception
     when others then
          prsDcErr := sDcErr ;
          dbms_output.put_line(sDcErr);
          raise_application_error(-20005, sDcErr);
          rollback;
          return;


End PR_BNF_GERA_HISIPCAP_MOV;
/
