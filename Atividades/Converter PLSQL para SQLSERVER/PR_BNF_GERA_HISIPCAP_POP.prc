CREATE OR REPLACE PROCEDURE PR_BNF_GERA_HISIPCAP_POP
(psCdUsu       varchar2,
 psCdFun       char,
 psCdPat       char,
 psNrPla       char,
 psDtMesRef    char,
 prsDcErr      out varchar2)
     
as

/*===================================================================
 * Modulo...: 
 * Procedure: 
 * Autor....: 
 * Sistema..: 
 * Data.....: 
 * Descricao: 
 
 * Revisões.: 
 * Data.....: 
 * Autor Rev: 
  ==================================================================*/

v_ErroSemRegistros      exception;

sCdLan             char(5);
sCdFun             char(3);
sCdPat             char(3);
sTpSex             char(1);
sNrPla             char(2);

dDtUltDiaMes_DT    date;

nIdOri             number;
nNrIda             number;
nQtPar             number;

dDtUltDiaMes_TS    timestamp;

sDcErr             varchar2(255);


---------------------------
cursor C_POPULACAO_PLANO is
---------------------------
SELECT 1,
       TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, X.DTNSCPAR ) / 12 ),
       X.TPSEXPAR, 
       count(1)
FROM ( SELECT D.DTNSCPAR,
              D.TPSEXPAR
       FROM   PAR_SITPLA_CATEG    A,             
              PAR_HISITPAR        B,
              PAR_PARPLA          C,
              PAR_PARTICIPANTES   D,
              PAR_PLANOS          E,
              PAR_PATROCINADORAS  F,
              PAR_FUNDOS          G
       WHERE  A.STISC             IN ('0','1','2',/*'3',*/'7','9')
       AND    B.IDSITPLACATATU    = A.IDSITPLACAT
       AND    B.DTSISINI          = ( SELECT MAX( DTSISINI )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA         = B.IDPARPLA
                                      AND    DTSISINI         <= dDtUltDiaMes_TS
                                      -- 14/07/2022 (2020/77-00282): incluída a restrição de DTINISIT
                                      AND    DTINISIT         <= dDtUltDiaMes_DT
                                    )
       AND    B.DTINISIT          = ( SELECT MAX( DTINISIT )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA         = B.IDPARPLA
                                      AND    DTSISINI         = B.DTSISINI
                                      AND    DTINISIT         <= dDtUltDiaMes_DT
                                      AND   (DTSISFIM         is NULL 
                                             OR
                                             DTSISFIM         > dDtUltDiaMes_TS 
                                             -- 14/07/2022 (2020/77-00282): incluída a restrição de DTFIMSIT
                                             OR
                                             DTFIMSIT         > dDtUltDiaMes_DT
                                            )
                                    )
       AND    B.SQSIT             = ( SELECT MAX( SQSIT )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA         = B.IDPARPLA
                                      AND    DTSISINI         = B.DTSISINI
                                      AND    DTINISIT         = B.DTINISIT
                                      AND   (DTSISFIM         is NULL 
                                             OR
                                             DTSISFIM         > dDtUltDiaMes_TS 
                                             -- 14/07/2022 (2020/77-00282): incluída a restrição de DTFIMSIT
                                             OR
                                             DTFIMSIT         > dDtUltDiaMes_DT
                                            )
                                     )                                              
       AND    C.IDPARPLA          = B.IDPARPLA
       AND    E.IDPLA             = C.IDPLA
       AND    E.NRPLA             = psNrPla
       AND    F.IDPAT             = E.IDPAT
       AND  ((F.CDPAT             IN ('001','002')         AND       psCdPat =  '001')   
              OR
             (F.CDPAT             = psCdPat                AND       psCdPat <> '001'))                       
       AND    D.IDPAR             = C.IDPAR
       AND    G.IDFUN             = F.IDFUN
       AND    NOT EXISTS(         SELECT 1
                                  FROM   BNF_HISIPCAP_EXC L
                                  WHERE  L.DTMESREF       = psDtMesRef
                                  AND    L.NRPLA          = E.NRPLA
                                  AND    L.CDPAT          = F.CDPAT
                                  AND    L.CDFUN          = G.CDFUN
                                  AND    L.CDLAN          IN ('31100','31200','31300')
                                  AND    L.TPMOV          = 0
                                  AND    L.IDPARPLA       = B.IDPARPLA
                        )                              
       UNION ALL
       SELECT D.DTNSCPAR,
              D.TPSEXPAR
       FROM   PAR_HISITPAR        B,
              PAR_PARPLA          C,
              PAR_SITPLA_PARAM    A,          
              PAR_PARTICIPANTES   D,
              PAR_PLANOS          E,
              PAR_PATROCINADORAS  F,
              PAR_FUNDOS          G
       WHERE  B.DTSISINI          = ( SELECT MAX( DTSISINI )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA         = B.IDPARPLA
                                      AND    DTSISINI         <= dDtUltDiaMes_TS
                                      -- 14/07/2022 (2020/77-00282): incluída a restrição de DTINISIT
                                      AND    DTINISIT         <= dDtUltDiaMes_DT
                                    )
       AND    B.DTINISIT          = ( SELECT MAX( DTINISIT )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA         = B.IDPARPLA
                                      AND    DTSISINI         = B.DTSISINI
                                      AND    DTINISIT         <= dDtUltDiaMes_DT
                                      AND   (DTSISFIM         is NULL 
                                             OR
                                             DTSISFIM         > dDtUltDiaMes_TS
                                             -- 14/07/2022 (2020/77-00282): incluída a restrição de DTFIMSIT
                                             OR
                                             DTFIMSIT         > dDtUltDiaMes_DT
                                            )
                                    )
       AND    B.SQSIT             = ( SELECT MAX( SQSIT )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA         = B.IDPARPLA
                                      AND    DTSISINI         = B.DTSISINI
                                      AND    DTINISIT         = B.DTINISIT
                                      AND   (DTSISFIM         is NULL 
                                             OR
                                             DTSISFIM         > dDtUltDiaMes_TS
                                             -- 14/07/2022 (2020/77-00282): incluída a restrição de DTFIMSIT
                                             OR
                                             DTFIMSIT         > dDtUltDiaMes_DT
                                            )
                                     )  
       AND    B.STISCATU          = '4'                                                                   
       AND    C.IDPARPLA          = B.IDPARPLA
       AND    A.IDPLA             = C.IDPLA
       AND    A.IDSITPLACAT       = B.IDSITPLACATATU
       AND    A.TPBNFCCD          in ('AC','AD')
       AND    D.IDPAR             = C.IDPAR
       AND    E.IDPLA             = C.IDPLA
       AND    E.NRPLA             = psNrPla
       AND    F.IDPAT             = E.IDPAT
       AND  ((F.CDPAT             IN ('001','002')         AND       psCdPat =  '001')   
              OR
             (F.CDPAT             = psCdPat                AND       psCdPat <> '001'))                       
       AND    G.IDFUN             = F.IDFUN
       AND    NOT EXISTS(         SELECT 1
                                  FROM   BNF_HISIPCAP_EXC L
                                  WHERE  L.DTMESREF       = psDtMesRef
                                  AND    L.NRPLA          = E.NRPLA
                                  AND    L.CDPAT          = F.CDPAT
                                  AND    L.CDFUN          = G.CDFUN
                                  AND    L.CDLAN          IN ('31100','31200','31300')
                                  AND    L.TPMOV          = 0
                                  AND    L.IDPARPLA       = B.IDPARPLA
                        )                              
     ) X
GROUP BY 1, 
         TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, X.DTNSCPAR ) / 12 ),
         X.TPSEXPAR
UNION
SELECT 2,
       TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, I.DTNSCPAR ) / 12 ),
       I.TPSEXPAR, 
       count(1)
FROM   BNF_BNFCONCEDIDOS   A,
       BNF_BENEFICIARIOS   B,
       PAR_PARPLA          C,
       PAR_PLANOS          D,
       PAR_PATROCINADORAS  E,
       PAR_FUNDOS          F,
       BNF_BENFPLA         G,
       BNF_BENEFICIOS      H,
       PAR_PARTICIPANTES   I
WHERE  A.DTCOSBNF          <= dDtUltDiaMes_TS
AND    NVL(A.PRPAGUNC,0)   < 100
AND    B.IDBNFCCD          = A.IDBNFCCD
AND    B.SQBEN             = 0
AND    C.IDPARPLA          = A.IDPARPLA
AND    D.IDPLA             = C.IDPLA
AND    D.NRPLA             = psNrPla
AND    E.IDPAT             = D.IDPAT
AND  ((E.CDPAT             IN ('001','002')         AND       psCdPat =  '001')   
      OR
      (E.CDPAT             = psCdPat                AND       psCdPat <> '001'))                       
AND    F.IDFUN             = E.IDFUN
AND    G.IDBNFPLA          = A.IDBNFPLA
AND    H.IDBNF             = G.IDBNF
AND    H.TPBNF             IN ('AP','BP')
AND    I.IDPAR             = C.IDPAR       
AND    NOT EXISTS(         SELECT 1
                           FROM   BNF_HISITBNF K
                           WHERE  K.IDBNFCCD    = A.IDBNFCCD
                           AND    K.AUDATULTALT = ( SELECT MAX( AUDATULTALT)
                                                    FROM   BNF_HISITBNF
                                                    WHERE  IDBNFCCD      = K.IDBNFCCD
                                                    AND    AUDATULTALT   <= dDtUltDiaMes_TS )
                           AND    K.DTINISIT    = ( SELECT MAX( DTINISIT )
                                                    FROM   BNF_HISITBNF
                                                    WHERE  IDBNFCCD      = K.IDBNFCCD
                                                    AND    AUDATULTALT   = K.AUDATULTALT
                                                  )
                           AND    K.SQSIT       = ( SELECT MAX( SQSIT )
                                                    FROM   BNF_HISITBNF
                                                    WHERE  IDBNFCCD      = K.IDBNFCCD
                                                    AND    DTINISIT      = K.DTINISIT
                                                    AND    AUDATULTALT   = K.AUDATULTALT
                                                  )
                           AND    K.STBNF       IN ('05','08','09','12')
                  )
AND    NOT EXISTS(         SELECT 1
                           FROM   BNF_BNFCONCEDIDOS
                           WHERE  CDFUN           = A.CDFUN
                           AND    NRPCSFUNANT     = A.NRPCSFUN
                           AND    DTCOSBNF        <= dDtUltDiaMes_TS
                  )
AND    NOT EXISTS(         SELECT 1
                           FROM   BNF_BENOCOR J
                           WHERE  J.IDBEN    = B.IDBEN
                           AND    J.DTSISOCO = ( SELECT MAX( DTSISOCO)
                                                 FROM   BNF_BENOCOR
                                                 WHERE  IDBEN       = J.IDBEN
                                                 AND    DTSISOCO    <= dDtUltDiaMes_TS )
                           AND    J.DTINIOCO = ( SELECT MAX( DTINIOCO)
                                                 FROM   BNF_BENOCOR
                                                 WHERE  IDBEN       = J.IDBEN
                                                 AND    DTSISOCO    = J.DTSISOCO )
                           AND    J.TPOCO    = 'E'
                  )
AND    NOT EXISTS(         SELECT  1
                           FROM    BNF_BENOCOR                 J1,
                                   PARPVDAT.PAR_HISITPAT       J2,
                                   PARPVDAT.PAR_PADSITPAR      J3
                           WHERE   J1.IDBEN                    = B.IDBEN
                           AND     J1.DTSISOCO                 = ( SELECT MAX( DTSISOCO)
                                                                   FROM   BNF_BENOCOR
                                                                   WHERE  IDBEN        = J1.IDBEN
                                                                   AND    DTSISOCO    <= dDtUltDiaMes_TS )
                           AND     J1.TPOCO                    = 'S'
                           AND     J2.IDPAR                    = C.IDPAR
                           AND     J2.AUDATULTALT              = ( SELECT MAX( AUDATULTALT)
                                                                   FROM   PARPVDAT.PAR_HISITPAT
                                                                   WHERE  IDPAR        = J2.IDPAR
                                                                   AND    AUDATULTALT <= dDtUltDiaMes_TS )
                           AND     J2.DTINISIT                 = ( SELECT MAX( DTINISIT)
                                                                   FROM   PARPVDAT.PAR_HISITPAT
                                                                   WHERE  IDPAR        = J2.IDPAR
                                                                   AND    AUDATULTALT  = J2.AUDATULTALT
                                                                   AND    DTINISIT    <= dDtUltDiaMes_DT )
                           AND     J3.IDPADSITPAR              = J2.IDPADSITPAR
                           AND     J3.CDSITEQV                 = 'AT'                                                                        
                  )                  
AND    NOT EXISTS(         SELECT 1
                           FROM   BNF_HISIPCAP_EXC L
                           WHERE  L.DTMESREF       = psDtMesRef
                           AND    L.NRPLA          = D.NRPLA
                           AND    L.CDPAT          = E.CDPAT
                           AND    L.CDFUN          = F.CDFUN
                           AND    L.CDLAN          = '32000'
                           AND    L.TPMOV          = 0
                           AND    L.IDBEN          = B.IDBEN
                 )                              
GROUP BY 2, 
         TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, I.DTNSCPAR ) / 12 ),
         I.TPSEXPAR
UNION
SELECT 3,
       TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, I.DTNSCDPD ) / 12 ),
       I.TPSEXDPD, 
       count(1)
FROM   BNF_BNFCONCEDIDOS   A,
       BNF_BENEFICIARIOS   B,
       PAR_PARPLA          C,
       PAR_PLANOS          D,
       PAR_PATROCINADORAS  E,
       PAR_FUNDOS          F,
       BNF_BENFPLA         G,
       BNF_BENEFICIOS      H,
       PAR_DEPENDENTES     I
WHERE  A.DTCOSBNF          <= dDtUltDiaMes_TS
AND    NVL(A.PRPAGUNC,0)   < 100
AND    B.IDBNFCCD          = A.IDBNFCCD
AND    B.SQBEN             > 0
AND    C.IDPARPLA          = A.IDPARPLA
AND    D.IDPLA             = C.IDPLA
AND    D.NRPLA             = psNrPla
AND    E.IDPAT             = D.IDPAT
AND  ((E.CDPAT             IN ('001','002')         AND       psCdPat =  '001')   
      OR
      (E.CDPAT             = psCdPat                AND       psCdPat <> '001'))                       
AND    F.IDFUN             = E.IDFUN
AND    G.IDBNFPLA          = A.IDBNFPLA
AND    H.IDBNF             = G.IDBNF
AND    H.TPBNF             = 'PS'
AND    I.IDPAR             = C.IDPAR   
AND    I.SQDPD             = B.SQBEN    
AND    NOT EXISTS(         SELECT 1
                           FROM   BNF_BENOCOR J
                           WHERE  J.IDBEN    = B.IDBEN
                           AND    J.DTSISOCO = ( SELECT MAX( DTSISOCO)
                                                 FROM   BNF_BENOCOR
                                                 WHERE  IDBEN       = J.IDBEN
                                                 AND    DTSISOCO    <= dDtUltDiaMes_TS )
                           AND    J.DTINIOCO = ( SELECT MAX( DTINIOCO)
                                                 FROM   BNF_BENOCOR
                                                 WHERE  IDBEN       = J.IDBEN
                                                 AND    DTSISOCO    = J.DTSISOCO )
                           AND    J.TPOCO    = 'E'
                 )   
AND    NOT EXISTS(         SELECT 1
                           FROM   BNF_HISITBNF K
                           WHERE  K.IDBNFCCD    = A.IDBNFCCD
                           AND    K.AUDATULTALT = ( SELECT MAX( AUDATULTALT)
                                                    FROM   BNF_HISITBNF
                                                    WHERE  IDBNFCCD      = K.IDBNFCCD
                                                    AND    AUDATULTALT   <= dDtUltDiaMes_TS )
                           AND    K.DTINISIT    = ( SELECT MAX( DTINISIT )
                                                    FROM   BNF_HISITBNF
                                                    WHERE  IDBNFCCD      = K.IDBNFCCD
                                                    AND    AUDATULTALT   = K.AUDATULTALT
                                                  )
                           AND    K.SQSIT       = ( SELECT MAX( SQSIT )
                                                    FROM   BNF_HISITBNF
                                                    WHERE  IDBNFCCD      = K.IDBNFCCD
                                                    AND    DTINISIT      = K.DTINISIT
                                                    AND    AUDATULTALT   = K.AUDATULTALT
                                                  )
                           AND    K.STBNF       IN ('05','08','09','12')
                  )
-- 26/04/2022: incluido o EXISTS em BNF_PAGAMENTOS devido a problemas de migração                 
AND    EXISTS(             SELECT 1
                           FROM   BNF_PAGAMENTOS K
                           WHERE  K.IDBEN        = B.IDBEN
                         --AND    K.DTMESREF     = psDtMesRef
             )                              
AND    NOT EXISTS(         SELECT 1
                           FROM   BNF_HISIPCAP_EXC L
                           WHERE  L.DTMESREF       = psDtMesRef
                           AND    L.NRPLA          = D.NRPLA
                           AND    L.CDPAT          = E.CDPAT
                           AND    L.CDFUN          = F.CDFUN
                           AND    L.CDLAN          = '33000'
                           AND    L.TPMOV          = 0
                           AND    L.IDBEN          = B.IDBEN
                 )                              
GROUP BY 3, 
         TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, I.DTNSCDPD ) / 12 ),
         I.TPSEXDPD;


--------------------------
cursor C_POPULACAO_CONS is
--------------------------
SELECT 1,
       TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, X.DTNSC ) / 12 ),
       X.TPSEX, 
       count(1)
FROM ( SELECT DISTINCT
              D.NRMAT             AS NRMAT,
              D.DTNSCPAR          AS DTNSC,
              D.TPSEXPAR          AS TPSEX
       FROM   PAR_SITPLA_CATEG    A,             
              PAR_HISITPAR        B,
              PAR_PARPLA          C,
              PAR_PARTICIPANTES   D,
              PAR_PLANOS          E,
              PAR_PATROCINADORAS  F,
              PAR_FUNDOS          G
       WHERE  A.STISC             IN ('0','1','2',/*'3',*/'7','9')
       AND    B.IDSITPLACATATU    = A.IDSITPLACAT
       AND    B.DTSISINI          = ( SELECT MAX( DTSISINI )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA         = B.IDPARPLA
                                      AND    DTSISINI         <= dDtUltDiaMes_TS
                                      -- 14/07/2022 (2020/77-00282): incluída a restrição de DTINISIT
                                      AND    DTINISIT         <= dDtUltDiaMes_DT
                                    )
       AND    B.DTINISIT          = ( SELECT MAX( DTINISIT )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA         = B.IDPARPLA
                                      AND    DTSISINI         = B.DTSISINI
                                      AND    DTINISIT         <= dDtUltDiaMes_DT
                                      AND   (DTSISFIM         is NULL 
                                             OR
                                             DTSISFIM         > dDtUltDiaMes_TS 
                                             -- 14/07/2022 (2020/77-00282): incluída a restrição de DTFIMSIT
                                             OR
                                             DTFIMSIT         > dDtUltDiaMes_DT
                                            )
                                    )
       AND    B.SQSIT             = ( SELECT MAX( SQSIT )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA         = B.IDPARPLA
                                      AND    DTSISINI         = B.DTSISINI
                                      AND    DTINISIT         = B.DTINISIT
                                      AND   (DTSISFIM         is NULL 
                                             OR
                                             DTSISFIM         > dDtUltDiaMes_TS 
                                             -- 14/07/2022 (2020/77-00282): incluída a restrição de DTFIMSIT
                                             OR
                                             DTFIMSIT         > dDtUltDiaMes_DT
                                            )
                                     )                                              
       AND    C.IDPARPLA          = B.IDPARPLA
       AND    D.IDPAR             = C.IDPAR
       AND    E.IDPLA             = C.IDPLA
       AND    F.IDPAT             = E.IDPAT
       AND    G.IDFUN             = F.IDFUN
       AND    G.CDFUN             = psCdFun
       AND    NOT EXISTS(         SELECT 1
                                  FROM   BNF_HISIPCAP_EXC L
                                  WHERE  L.DTMESREF       = psDtMesRef
                                  AND    L.NRPLA          = E.NRPLA
                                  AND    L.CDPAT          = F.CDPAT
                                  AND    L.CDFUN          = G.CDFUN
                                  AND    L.CDLAN          IN ('31100','31200','31300')
                                  AND    L.TPMOV          = 0
                                  AND    L.IDPARPLA       = B.IDPARPLA
                        )                              
       UNION ALL
       SELECT DISTINCT
              D.NRMAT             AS NRMAT,
              D.DTNSCPAR          AS DTNSC,
              D.TPSEXPAR          AS TPSEX
       FROM   PAR_HISITPAR        B,
              PAR_PARPLA          C,
              PAR_SITPLA_PARAM    A,          
              PAR_PARTICIPANTES   D,
              PAR_PLANOS          E,
              PAR_PATROCINADORAS  F,
              PAR_FUNDOS          G
       WHERE  B.DTSISINI          = ( SELECT MAX( DTSISINI )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA         = B.IDPARPLA
                                      AND    DTSISINI         <= dDtUltDiaMes_TS
                                      -- 14/07/2022 (2020/77-00282): incluída a restrição de DTINISIT
                                      AND    DTINISIT         <= dDtUltDiaMes_DT
                                    )
       AND    B.DTINISIT          = ( SELECT MAX( DTINISIT )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA         = B.IDPARPLA
                                      AND    DTSISINI         = B.DTSISINI
                                      AND    DTINISIT         <= dDtUltDiaMes_DT
                                      AND   (DTSISFIM         is NULL 
                                             OR
                                             DTSISFIM         > dDtUltDiaMes_TS
                                             -- 14/07/2022 (2020/77-00282): incluída a restrição de DTFIMSIT
                                             OR
                                             DTFIMSIT         > dDtUltDiaMes_DT
                                            )
                                    )
       AND    B.SQSIT             = ( SELECT MAX( SQSIT )
                                      FROM   PAR_HISITPAR
                                      WHERE  IDPARPLA         = B.IDPARPLA
                                      AND    DTSISINI         = B.DTSISINI
                                      AND    DTINISIT         = B.DTINISIT
                                      AND   (DTSISFIM         is NULL 
                                             OR
                                             DTSISFIM         > dDtUltDiaMes_TS
                                             -- 14/07/2022 (2020/77-00282): incluída a restrição de DTFIMSIT
                                             OR
                                             DTFIMSIT         > dDtUltDiaMes_DT
                                            )
                                     )  
       AND    B.STISCATU          = '4'                                                                   
       AND    C.IDPARPLA          = B.IDPARPLA
       AND    A.IDPLA             = C.IDPLA
       AND    A.IDSITPLACAT       = B.IDSITPLACATATU
       AND    A.TPBNFCCD          in ('AC','AD')
       AND    D.IDPAR             = C.IDPAR
       AND    E.IDPLA             = C.IDPLA
       AND    F.IDPAT             = E.IDPAT
       AND    G.IDFUN             = F.IDFUN
       AND    G.CDFUN             = psCdFun
       AND    NOT EXISTS(         SELECT 1
                                  FROM   BNF_HISIPCAP_EXC L
                                  WHERE  L.DTMESREF       = psDtMesRef
                                  AND    L.NRPLA          = E.NRPLA
                                  AND    L.CDPAT          = F.CDPAT
                                  AND    L.CDFUN          = G.CDFUN
                                  AND    L.CDLAN          IN ('31100','31200','31300')
                                  AND    L.TPMOV          = 0
                                  AND    L.IDPARPLA       = B.IDPARPLA
                        )                              
     ) X
GROUP BY 1, 
         TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, X.DTNSC ) / 12 ),
         X.TPSEX
UNION
SELECT 2,
       TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, X.DTNSC ) / 12 ),
       X.TPSEX, 
       count(1)
FROM ( SELECT DISTINCT
              I.NRMAT             AS NRMAT,
              I.DTNSCPAR          AS DTNSC,
              I.TPSEXPAR          AS TPSEX
       FROM   BNF_BNFCONCEDIDOS   A,
              BNF_BENEFICIARIOS   B,
              PAR_PARPLA          C,
              PAR_PLANOS          D,
              PAR_PATROCINADORAS  E,
              PAR_FUNDOS          F,
              BNF_BENFPLA         G,
              BNF_BENEFICIOS      H,
              PAR_PARTICIPANTES   I
       WHERE  A.DTCOSBNF          <= dDtUltDiaMes_TS
       AND    NVL(A.PRPAGUNC,0)   < 100
       AND    B.IDBNFCCD          = A.IDBNFCCD
       AND    B.SQBEN             = 0
       AND    C.IDPARPLA          = A.IDPARPLA
       AND    D.IDPLA             = C.IDPLA
       AND    E.IDPAT             = D.IDPAT
       AND    F.IDFUN             = E.IDFUN
       AND    F.CDFUN             = psCdFun
       AND    G.IDBNFPLA          = A.IDBNFPLA
       AND    H.IDBNF             = G.IDBNF
       AND    H.TPBNF             IN ('AP','BP')
       AND    I.IDPAR             = C.IDPAR       
       AND    NOT EXISTS(         SELECT 1
                                  FROM   BNF_HISITBNF K
                                  WHERE  K.IDBNFCCD    = A.IDBNFCCD
                                  AND    K.AUDATULTALT = ( SELECT MAX( AUDATULTALT)
                                                           FROM   BNF_HISITBNF
                                                           WHERE  IDBNFCCD      = K.IDBNFCCD
                                                           AND    AUDATULTALT   <= dDtUltDiaMes_TS )
                                  AND    K.DTINISIT    = ( SELECT MAX( DTINISIT )
                                                           FROM   BNF_HISITBNF
                                                           WHERE  IDBNFCCD      = K.IDBNFCCD
                                                           AND    AUDATULTALT   = K.AUDATULTALT
                                                         )
                                  AND    K.SQSIT       = ( SELECT MAX( SQSIT )
                                                           FROM   BNF_HISITBNF
                                                           WHERE  IDBNFCCD      = K.IDBNFCCD
                                                           AND    DTINISIT      = K.DTINISIT
                                                           AND    AUDATULTALT   = K.AUDATULTALT
                                                         )
                                  AND    K.STBNF       IN ('05','08','09','12')
                         )
       AND    NOT EXISTS(         SELECT 1
                                  FROM   BNF_BNFCONCEDIDOS
                                  WHERE  CDFUN           = A.CDFUN
                                  AND    NRPCSFUNANT     = A.NRPCSFUN
                                  AND    DTCOSBNF        <= dDtUltDiaMes_TS
                         )
       AND    NOT EXISTS(         SELECT 1
                                  FROM   BNF_BENOCOR J
                                  WHERE  J.IDBEN    = B.IDBEN
                                  AND    J.DTSISOCO = ( SELECT MAX( DTSISOCO)
                                                        FROM   BNF_BENOCOR
                                                        WHERE  IDBEN       = J.IDBEN
                                                        AND    DTSISOCO    <= dDtUltDiaMes_TS )
                                  AND    J.DTINIOCO = ( SELECT MAX( DTINIOCO)
                                                        FROM   BNF_BENOCOR
                                                        WHERE  IDBEN       = J.IDBEN
                                                        AND    DTSISOCO    = J.DTSISOCO )
                                  AND    J.TPOCO    = 'E'
                         )
       AND    NOT EXISTS(         SELECT  1
                                  FROM    BNF_BENOCOR                 J1,
                                          PARPVDAT.PAR_HISITPAT       J2,
                                          PARPVDAT.PAR_PADSITPAR      J3
                                  WHERE   J1.IDBEN                    = B.IDBEN
                                  AND     J1.DTSISOCO                 = ( SELECT MAX( DTSISOCO)
                                                                          FROM   BNF_BENOCOR
                                                                          WHERE  IDBEN        = J1.IDBEN
                                                                          AND    DTSISOCO    <= dDtUltDiaMes_TS )
                                  AND     J1.TPOCO                    = 'S'
                                  AND     J2.IDPAR                    = C.IDPAR
                                  AND     J2.AUDATULTALT              = ( SELECT MAX( AUDATULTALT)
                                                                          FROM   PARPVDAT.PAR_HISITPAT
                                                                          WHERE  IDPAR        = J2.IDPAR
                                                                          AND    AUDATULTALT <= dDtUltDiaMes_TS )
                                  AND     J2.DTINISIT                 = ( SELECT MAX( DTINISIT)
                                                                          FROM   PARPVDAT.PAR_HISITPAT
                                                                          WHERE  IDPAR        = J2.IDPAR
                                                                          AND    AUDATULTALT  = J2.AUDATULTALT
                                                                          AND    DTINISIT    <= dDtUltDiaMes_DT )
                                  AND     J3.IDPADSITPAR              = J2.IDPADSITPAR
                                  AND     J3.CDSITEQV                 = 'AT'                                                                        
                         )                  
       AND    NOT EXISTS(         SELECT 1
                                  FROM   BNF_HISIPCAP_EXC L
                                  WHERE  L.DTMESREF       = psDtMesRef
                                  AND    L.NRPLA          = D.NRPLA
                                  AND    L.CDPAT          = E.CDPAT
                                  AND    L.CDFUN          = F.CDFUN
                                  AND    L.CDLAN          = '32000'
                                  AND    L.TPMOV          = 0
                                  AND    L.IDBEN          = B.IDBEN
                        )  
     ) X                            
GROUP BY 2, 
         TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, X.DTNSC ) / 12 ),
         X.TPSEX
UNION
SELECT 3,
       TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, X.DTNSC ) / 12 ),
       X.TPSEX, 
       count(1)
FROM ( SELECT DISTINCT
              C.NRMAT             AS NRMAT,
              I.DTNSCDPD          AS DTNSC,
              I.TPSEXDPD          AS TPSEX
       FROM   BNF_BNFCONCEDIDOS   A,
              BNF_BENEFICIARIOS   B,
              PAR_PARPLA          C,
              PAR_PLANOS          D,
              PAR_PATROCINADORAS  E,
              PAR_FUNDOS          F,
              BNF_BENFPLA         G,
              BNF_BENEFICIOS      H,
              PAR_DEPENDENTES     I
       WHERE  A.DTCOSBNF          <= dDtUltDiaMes_TS
       AND    NVL(A.PRPAGUNC,0)   < 100
       AND    B.IDBNFCCD          = A.IDBNFCCD
       AND    B.SQBEN             > 0
       AND    C.IDPARPLA          = A.IDPARPLA
       AND    D.IDPLA             = C.IDPLA
       AND    E.IDPAT             = D.IDPAT
       AND    F.IDFUN             = E.IDFUN
       AND    F.CDFUN             = psCdFun
       AND    G.IDBNFPLA          = A.IDBNFPLA
       AND    H.IDBNF             = G.IDBNF
       AND    H.TPBNF             = 'PS'
       AND    I.IDPAR             = C.IDPAR   
       AND    I.SQDPD             = B.SQBEN    
       AND    NOT EXISTS(         SELECT 1
                                  FROM   BNF_BENOCOR J
                                  WHERE  J.IDBEN    = B.IDBEN
                                  AND    J.DTSISOCO = ( SELECT MAX( DTSISOCO)
                                                        FROM   BNF_BENOCOR
                                                        WHERE  IDBEN       = J.IDBEN
                                                        AND    DTSISOCO    <= dDtUltDiaMes_TS )
                                  AND    J.DTINIOCO = ( SELECT MAX( DTINIOCO)
                                                        FROM   BNF_BENOCOR
                                                        WHERE  IDBEN       = J.IDBEN
                                                        AND    DTSISOCO    = J.DTSISOCO )
                                  AND    J.TPOCO    = 'E'
                        )   
       AND    NOT EXISTS(         SELECT 1
                                  FROM   BNF_HISITBNF K
                                  WHERE  K.IDBNFCCD    = A.IDBNFCCD
                                  AND    K.AUDATULTALT = ( SELECT MAX( AUDATULTALT)
                                                           FROM   BNF_HISITBNF
                                                           WHERE  IDBNFCCD      = K.IDBNFCCD
                                                           AND    AUDATULTALT   <= dDtUltDiaMes_TS )
                                  AND    K.DTINISIT    = ( SELECT MAX( DTINISIT )
                                                           FROM   BNF_HISITBNF
                                                           WHERE  IDBNFCCD      = K.IDBNFCCD
                                                           AND    AUDATULTALT   = K.AUDATULTALT
                                                         )
                                  AND    K.SQSIT       = ( SELECT MAX( SQSIT )
                                                           FROM   BNF_HISITBNF
                                                           WHERE  IDBNFCCD      = K.IDBNFCCD
                                                           AND    DTINISIT      = K.DTINISIT
                                                           AND    AUDATULTALT   = K.AUDATULTALT
                                                         )
                                  AND    K.STBNF       IN ('05','08','09','12')
                         )
       -- 26/04/2022: incluido o EXISTS em BNF_PAGAMENTOS devido a problemas de migração                 
       AND    EXISTS(             SELECT 1
                                  FROM   BNF_PAGAMENTOS K
                                  WHERE  K.IDBEN        = B.IDBEN
                                --AND    K.DTMESREF     = psDtMesRef
                    )                              
       AND    NOT EXISTS(         SELECT 1
                                  FROM   BNF_HISIPCAP_EXC L
                                  WHERE  L.DTMESREF       = psDtMesRef
                                  AND    L.NRPLA          = D.NRPLA
                                  AND    L.CDPAT          = E.CDPAT
                                  AND    L.CDFUN          = F.CDFUN
                                  AND    L.CDLAN          = '33000'
                                  AND    L.TPMOV          = 0
                                  AND    L.IDBEN          = B.IDBEN
                        )
     ) X                              
GROUP BY 3, 
         TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, X.DTNSC ) / 12 ),
         X.TPSEX;



FUNCTION FN_RECUPERA_CODIGO
   ( pnIdOri       in  smallint,
     pnNrIda       in  smallint )

   RETURN     CHAR

IS

   nCdLan        INTEGER;
   sCdLan        CHAR(05);

BEGIN
     IF pnIdOri = 1 THEN
        nCdLan := 41000;
     ELSIF pnIdOri = 2 THEN
        nCdLan := 42000;
     ELSE
        nCdLan := 43000;
     END IF;

     IF pnNrIda <= 24 THEN
        sCdLan := to_char( nCdLan + 100 );
     ELSIF pnNrIda <= 34 THEN
        sCdLan := to_char( nCdLan + 200 );
     ELSIF pnNrIda <= 54 THEN
        sCdLan := to_char( nCdLan + 300 );
     ELSIF pnNrIda <= 64 THEN
        sCdLan := to_char( nCdLan + 400 );
     ELSIF pnNrIda <= 74 THEN
        sCdLan := to_char( nCdLan + 500 );
     ELSIF pnNrIda <= 84 THEN
        sCdLan := to_char( nCdLan + 600 );
     ELSE
        sCdLan := to_char( nCdLan + 700 );
     END IF;

  RETURN sCdLan;

END FN_RECUPERA_CODIGO;



-----
Begin
-----
  
  dDtUltDiaMes_DT := last_day( to_date( psDtMesRef, 'RRRRMM' ));
  dDtUltDiaMes_TS := to_timestamp( dDtUltDiaMes_DT ||' 23:59:59.000000000', 'dd/mm/rrrr hh24:mi:ss.ff' );


  if psNrPla <> '99' then
       
    sNrPla := psNrPla;
    sCdPat := psCdPat;
    sCdFun := psCdFun; 
    
  else
    
    sNrPla := '99';
    sCdPat := '999';
    sCdFun := '001'; 
      
  end if;  
  

      
  if sNrPla <> '99' then 
    sDcErr := 'Erro ao abrir cursor C_POPULACAO_PLANO.';
    open C_POPULACAO_PLANO;
  else  
    sDcErr := 'Erro ao abrir cursor C_POPULACAO_CONS.';
    open C_POPULACAO_CONS;
  end if;
  
  loop
    
    if sNrPla <> '99' then
      sDcErr := 'Erro ao ler cursor C_POPULACAO_PLANO.';
    
      fetch C_POPULACAO_PLANO
      into  nIdOri, nNrIda, sTpSex, nQtPar;

      exit when C_POPULACAO_PLANO%notFound;
    else
      sDcErr := 'Erro ao ler cursor C_POPULACAO_CONS.';
      
      fetch C_POPULACAO_CONS
      into  nIdOri, nNrIda, sTpSex, nQtPar;

      exit when C_POPULACAO_CONS%notFound;
    end if;
            
    sCdLan := FN_RECUPERA_CODIGO( nIdOri, nNrIda );

    if sTpSex = 'M' then

      update BNF_HISIPCAP_PLANO
      set    QTSEXMAS     = nvl( QTSEXMAS, 0) + nQtPar
      where  DTMESREF     = psDtMesRef
      and    NRPLA        = sNrPla
      and    CDPAT        = sCdPat
      and    CDFUN        = sCdFun
      and    CDLAN        = sCdLan
      and    AUUSUULTALT  = psCdUsu;

    else

      update BNF_HISIPCAP_PLANO
      set    QTSEXFEM     = nvl( QTSEXFEM, 0) + nQtPar
      where  DTMESREF     = psDtMesRef
      and    NRPLA        = sNrPla
      and    CDPAT        = sCdPat
      and    CDFUN        = sCdFun
      and    CDLAN        = sCdLan
      and    AUUSUULTALT  = psCdUsu;

    end if;

  end loop;
  
  if sNrPla <> '99' then        
    sDcErr := 'Erro ao fechar cursor C_POPULACAO_PLANO.';
    close C_POPULACAO_PLANO;
  else  
    sDcErr := 'Erro ao fechar cursor C_POPULACAO_CONS.';
    close C_POPULACAO_CONS;
  end if;
  
  prsDcErr := null;

/*------------------- Tratamento de erros  */

exception

    when v_ErroSemRegistros then
      prsDcErr := sDcErr || ' [PR_BNF_GERA_HISIPCAP_V2] "' || SQLCODE || '"';
      rollback;
      return;

    when others then
      prsDcErr := sDcErr || ' - Erro ' || SQLCODE;
      rollback;
      return;


End PR_BNF_GERA_HISIPCAP_POP;
/
