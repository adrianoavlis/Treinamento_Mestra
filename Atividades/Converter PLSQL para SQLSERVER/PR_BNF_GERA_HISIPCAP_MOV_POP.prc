CREATE OR REPLACE PROCEDURE PR_BNF_GERA_HISIPCAP_MOV_POP
(psCdUsu          varchar2,
 psCdFun          char,
 psCdPat          char,
 psNrPla          char,
 psDtMesRef       char,
 psDtMesRefAnt    char,
 prsDcErr         out varchar2)

as

/*===================================================================
 * Modulo... :
 * Procedure :
 * Autor.... :
 * Sistema.. :
 * Data..... :
 * Descricao :

 * Revisões. :
 * Data......:
 * Autor Rev.:

 ==================================================================*/

--|------------------------------------
--| Declaração de Variáveis e Cursores
--|------------------------------------

v_ErroSemRegistros      exception;

sDcErr                 varchar2(255);

dDtNsc                 date;
dDtPriDiaMes_DT        date;
dDtUltDiaMesAnt        date;
dDtUltDiaMes_DT        date;

sCdLan                 char(5);
sCdPat                 char(3);
sCdLanAnt              char(5);
sNrCpf                 char(11);
sNrMat                 char(10);
sNrIsc                 char(9);
sTpSex                 char(1);

nIdBen                 integer;
nIdBnfCcd              integer;
nIdParPla              integer;
nIdOri                 integer;
nNrIda                 integer;
nNrIdaAnt              integer;
nTpMov                 integer;

nSqDpd                 number(10);

dDtPriDiaMes_TS        timestamp;
dDtUltDiaMes_TS        timestamp;


cursor C_MOV_ENT_SAI is
select 1,         
       A.TPMOV, 
       D.CDPAT,     
       B.NRMAT,
       0,             
       A.IDPARPLA, 
       NULL,  
       NULL,  
       C.DTNSCPAR,   
       C.TPSEXPAR,
       TRIM(C.NRCPFPAR)
from   BNF_HISIPCAP_MOV     A,
       PAR_PARPLA           B,
       PAR_PARTICIPANTES    C,
       PAR_PATROCINADORAS   D
where  A.DTMESREF           = psDtMesRef
and    A.NRPLA              = psNrPla
and  ((A.CDPAT              in ('001','002')  and   psCdPat  = '001')
       or
      (A.CDPAT              = psCdPat         and   psCdPat <> '001'))                   
and    A.CDFUN              = psCdFun
and    A.CDLAN              in ('31100','31200','31300')
and    A.AUUSUULTALT        = psCdUsu
and    B.IDPARPLA           = A.IDPARPLA
and    C.IDPAR              = B.IDPAR
and    D.IDPAT              = C.IDPAT
union
select 2,         
       A.TPMOV, 
       E.CDPAT,
       C.NRMAT,
       0,    
       A.IDPARPLA, 
       A.IDBNFCCD,  
       A.IDBEN,  
       D.DTNSCPAR,   
       D.TPSEXPAR,
       TRIM(B.NRCPFBEN)
from   BNF_HISIPCAP_MOV     A,
       BNF_BENEFICIARIOS    B,
       PAR_PARPLA           C,
       PAR_PARTICIPANTES    D,
       PAR_PATROCINADORAS   E
where  A.DTMESREF           = psDtMesRef
and    A.NRPLA              = psNrPla
and  ((A.CDPAT              in ('001','002')  and   psCdPat  = '001')
       or
      (A.CDPAT              = psCdPat         and   psCdPat <> '001'))                   
and    A.CDFUN              = psCdFun
and    A.CDLAN              = '32000'
and    A.AUUSUULTALT        = psCdUsu
and    B.IDBEN              = A.IDBEN
and    C.IDPARPLA           = A.IDPARPLA
and    D.IDPAR              = C.IDPAR
and    E.IDPAT              = D.IDPAT
union
select 3,
       A.TPMOV,
       G.CDPAT,
       D.NRMAT,
       B.SQBEN,      
       A.IDPARPLA,
       A.IDBNFCCD,
       A.IDBEN,   
       E.DTNSCDPD,   
       E.TPSEXDPD,
       TRIM(B.NRCPFBEN)
from   BNF_HISIPCAP_MOV     A,
       BNF_BENEFICIARIOS    B,
       BNF_BNFCONCEDIDOS    C,
       PAR_PARPLA           D,
       PAR_DEPENDENTES      E,
       PAR_PARTICIPANTES    F,
       PAR_PATROCINADORAS   G
where  A.DTMESREF           = psDtMesRef
and    A.NRPLA              = psNrPla
and  ((A.CDPAT              in ('001','002')  and   psCdPat  = '001')
       or
      (A.CDPAT              = psCdPat         and   psCdPat <> '001'))                   
and    A.CDFUN              = psCdFun
and    A.CDLAN              = '33000'
and    A.AUUSUULTALT        = psCdUsu
AND    B.IDBEN              = A.IDBEN
AND    C.IDBNFCCD           = B.IDBNFCCD
AND    D.IDPARPLA           = C.IDPARPLA
and    E.IDPAR              = D.IDPAR
AND    E.SQDPD              = B.SQBEN
and    F.IDPAR              = D.IDPAR
and    G.IDPAT              = F.IDPAT
order by 1, 2;


cursor C_DIF_IDADE is
SELECT 1,
       E.CDPAT,
       C.NRMAT,
       0,          
       B.IDPARPLA,
       NULL,              
       NULL,              
       F.DTNSCPAR,
       F.TPSEXPAR,
       TRIM(F.NRCPFPAR)
FROM   PAR_SITPLA_CATEG   A,
       PAR_HISITPAR       B,
       PAR_PARPLA         C,
       PAR_PLANOS         D,
       PAR_PATROCINADORAS E,
       PAR_PARTICIPANTES  F
WHERE  A.STISC                IN ('0','1','2',/*'3',*/'7','9')
AND    B.IDSITPLACATATU       = A.IDSITPLACAT
AND    B.DTSISINI             = ( SELECT MAX( DTSISINI )
                                  FROM   PAR_HISITPAR
                                  WHERE  IDPARPLA         = B.IDPARPLA
                                  AND    DTSISINI         <= dDtUltDiaMes_TS )
AND    B.DTINISIT             = ( SELECT MAX( DTINISIT )
                                  FROM   PAR_HISITPAR
                                  WHERE  IDPARPLA         = B.IDPARPLA
                                  AND    DTSISINI         = B.DTSISINI
                                  AND    DTINISIT         <= dDtUltDiaMes_DT
                                  AND  ( DTSISFIM         is NULL  OR    DTSISFIM  > dDtUltDiaMes_TS )
                                )
AND    B.SQSIT                = ( SELECT MAX( SQSIT )
                                  FROM   PAR_HISITPAR
                                  WHERE  IDPARPLA         = B.IDPARPLA
                                  AND    DTSISINI         = B.DTSISINI
                                  AND    DTINISIT         = B.DTINISIT
                                  AND  ( DTSISFIM         is NULL  OR    DTSISFIM  > dDtUltDiaMes_TS )
                             )                                              
AND    C.IDPARPLA             = B.IDPARPLA
AND    D.IDPLA                = C.IDPLA
AND    D.NRPLA                = psNrPla
AND    E.IDPAT                = D.IDPAT
AND  ((E.CDPAT                IN ('001','002')      AND     psCdpat  = '001')
       OR
      (E.CDPAT                = psCdpat             AND     psCdpat <> '001'))
AND    F.IDPAR                = C.IDPAR
AND  ( TRUNC( MONTHS_BETWEEN( dDtUltDiaMesAnt, F.DTNSCPAR ) / 12 ) <>
       TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, F.DTNSCPAR ) / 12 ))
UNION
SELECT 1,
       E.CDPAT,         
       C.NRMAT,
       0, 
       B.IDPARPLA,
       NULL,              
       NULL,              
       G.DTNSCPAR,
       G.TPSEXPAR,
       TRIM(G.NRCPFPAR)
FROM   PAR_SITPLA_CATEG   A,
       PAR_HISITPAR       B,
       PAR_PARPLA         C,
       PAR_PLANOS         D,
       PAR_PATROCINADORAS E,
       PAR_SITPLA_PARAM   F,
       PAR_PARTICIPANTES  G
WHERE  A.STISC                = '4'
AND    B.IDSITPLACATATU       = A.IDSITPLACAT
AND    B.DTSISINI             = ( SELECT MAX( DTSISINI )
                                  FROM   PAR_HISITPAR
                                  WHERE  IDPARPLA         = B.IDPARPLA
                                  AND    DTSISINI         <= dDtUltDiaMes_TS )
AND    B.DTINISIT             = ( SELECT MAX( DTINISIT )
                                  FROM   PAR_HISITPAR
                                  WHERE  IDPARPLA         = B.IDPARPLA
                                  AND    DTSISINI         = B.DTSISINI
                                  AND    DTINISIT         <= dDtUltDiaMes_DT
                                  AND  ( DTSISFIM         is NULL  OR    DTSISFIM  > dDtUltDiaMes_TS )
                                )
AND    B.SQSIT                = ( SELECT MAX( SQSIT )
                                  FROM   PAR_HISITPAR
                                  WHERE  IDPARPLA         = B.IDPARPLA
                                  AND    DTSISINI         = B.DTSISINI
                                  AND    DTINISIT         = B.DTINISIT
                                  AND  ( DTSISFIM         is NULL  OR    DTSISFIM  > dDtUltDiaMes_TS )
                             )                                              
AND    C.IDPARPLA             = B.IDPARPLA
AND    D.IDPLA                = C.IDPLA
AND    D.NRPLA                = psNrPla
AND    E.IDPAT                = D.IDPAT
AND  ((E.CDPAT                IN ('001','002')      AND     psCdpat  = '001')
       OR
      (E.CDPAT                = psCdpat             AND     psCdpat <> '001'))
AND    F.IDPLA                = C.IDPLA
AND    F.IDSITPLACAT          = B.IDSITPLACATATU
AND    F.TPBNFCCD             IN ('AD','AC')
AND    G.IDPAR                = C.IDPAR
AND  ( TRUNC( MONTHS_BETWEEN( dDtUltDiaMesAnt, G.DTNSCPAR ) / 12 ) <>
       TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, G.DTNSCPAR ) / 12 ))
UNION
SELECT 2,
       E.CDPAT,  
       H.NRMAT,
       I.SQBEN,        
       A.IDPARPLA,
       A.IDBNFCCD,              
       I.IDBEN,              
       H.DTNSCPAR,
       H.TPSEXPAR,
       TRIM(I.NRCPFBEN)
FROM   BNF_BNFCONCEDIDOS  A,
       PAR_PARPLA         B,
       PAR_PLANOS         D,
       PAR_PATROCINADORAS E,
       BNF_BENFPLA        F,
       BNF_BENEFICIOS     G,
       PAR_PARTICIPANTES  H,
       BNF_BENEFICIARIOS  I
WHERE  A.DTCOSBNF         < dDtPriDiaMes_DT
AND    NVL(A.PRPAGUNC,0)  < 100
AND    B.IDPARPLA         = A.IDPARPLA
AND    D.IDPLA            = B.IDPLA
AND    D.NRPLA            = psNrPla
AND    E.IDPAT            = D.IDPAT
AND  ((E.CDPAT            IN ('001','002')      AND     psCdpat  = '001')
       OR
      (E.CDPAT            = psCdpat             AND     psCdpat <> '001'))
AND    F.IDBNFPLA         = A.IDBNFPLA
AND    G.IDBNF            = F.IDBNF
AND    G.TPBNF           IN ( 'AP', 'BP' )
AND    H.IDPAR            = B.IDPAR 
AND  ( TRUNC( MONTHS_BETWEEN( dDtUltDiaMesAnt, H.DTNSCPAR ) / 12 ) <>
       TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, H.DTNSCPAR ) / 12 ))
AND    I.IDBNFCCD         = A.IDBNFCCD
AND    NOT EXISTS(        SELECT 1
                          FROM   BNF_HISITBNF
                          WHERE  IDBNFCCD          = A.IDBNFCCD
                          AND    STBNF             IN ('05','08','09')
                          AND    AUDATULTALT       = ( SELECT MAX(AUDATULTALT)
                                                       FROM   BNF_HISITBNF
                                                       WHERE  IDBNFCCD           = A.IDBNFCCD
                                                       AND    AUDATULTALT        < dDtPriDiaMes_TS )
                 )  
AND    NOT EXISTS(        SELECT 1
                          FROM   BNF_BENOCOR       J
                          WHERE  J.IDBEN           = I.IDBEN
                          AND    J.TPOCO           = 'E'
                          AND    J.DTSISOCO        = ( SELECT MAX(DTSISOCO)
                                                       FROM   BNF_BENOCOR
                                                       WHERE  IDBEN              = J.IDBEN
                                                       AND    DTSISOCO           < dDtPriDiaMes_TS )
                  )
AND    NOT EXISTS(        SELECT 1
                          FROM   BNF_BNFCONCEDIDOS
                          WHERE  CDFUN             = A.CDFUN
                          AND    NRPCSFUNANT       = A.NRPCSFUN
                          AND    DTCOSBNF          < dDtPriDiaMes_DT 
                  )
UNION
SELECT 3,
       E.CDPAT,          
       B.NRMAT,
       F.SQBEN,
       A.IDPARPLA,
       F.IDBNFCCD,
       F.IDBEN,
       I.DTNSCDPD,
       I.TPSEXDPD,
       TRIM(F.NRCPFBEN)
FROM   BNF_BENEFICIARIOS  F,                                      
       BNF_BNFCONCEDIDOS  A,
       PAR_PARPLA         B,
       PAR_PLANOS         D,
       PAR_PATROCINADORAS E,
       BNF_BENFPLA        G,
       BNF_BENEFICIOS     H, 
       PAR_DEPENDENTES    I
WHERE  F.DTSISINC         < dDtPriDiaMes_TS
AND    F.SQBEN            > 0
AND    A.IDBNFCCD         = F.IDBNFCCD
AND    NVL(A.PRPAGUNC,0)  < 100
AND    B.IDPARPLA         = A.IDPARPLA
AND    D.IDPLA            = B.IDPLA
AND    D.NRPLA            = psNrPla
AND    E.IDPAT            = D.IDPAT
AND  ((E.CDPAT            IN ('001','002')      AND     psCdpat  = '001')
       OR
      (E.CDPAT            = psCdpat             AND     psCdpat <> '001'))
AND    G.IDBNFPLA         = A.IDBNFPLA
AND    H.IDBNF            = G.IDBNF
AND    H.TPBNF            = 'PS'
AND    I.IDPAR            = B.IDPAR
AND    I.SQDPD            = F.SQBEN
AND  ( TRUNC( MONTHS_BETWEEN( dDtUltDiaMesAnt, I.DTNSCDPD ) / 12 ) <>
       TRUNC( MONTHS_BETWEEN( dDtUltDiaMes_DT, I.DTNSCDPD ) / 12 ))
AND    NOT EXISTS(        SELECT 1
                          FROM   BNF_BENOCOR       J
                          WHERE  J.IDBEN           = F.IDBEN
                          AND    J.TPOCO           = 'E'
                          AND    J.DTSISOCO        = ( SELECT MAX(DTSISOCO)
                                                       FROM   BNF_BENOCOR
                                                       WHERE  IDBEN              = J.IDBEN
                                                       AND    DTSISOCO           < dDtPriDiaMes_TS )
                  );
                  

--|-----------------
--| Função Interna
--|-----------------

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



--|---------------------
--| Corpo da procedure
--|--------------------

Begin


  /*---------------------------
    Monta datas limites do mes
    ---------------------------*/

    dDtPriDiaMes_DT := to_date( psDtMesRef, 'YYYYMM' );
    dDtUltDiaMes_DT := last_day( dDtPriDiaMes_DT );
    
    dDtUltDiaMesAnt := last_day( to_date( psDtMesRefAnt, 'YYYYMM' ));

    dDtPriDiaMes_TS := to_timestamp( dDtPriDiaMes_DT ||' 23:59:59.000000000', 'dd/mm/rrrr hh24:mi:ss.ff' );
    dDtUltDiaMes_TS := to_timestamp( dDtUltDiaMes_DT ||' 23:59:59.000000000', 'dd/mm/rrrr hh24:mi:ss.ff' );


    open C_MOV_ENT_SAI;
    loop
   
        fetch C_MOV_ENT_SAI
        into  nIdOri, nTpMov, sCdPat, sNrMat, nSqDpd, nIdParpla, nIdBnfCcd, nIdBen, dDtNsc, sTpSex, sNrCpf;

        exit when C_MOV_ENT_SAI%notFound;

        nNrIda := trunc( months_between(dDtUltDiaMes_DT, dDtNsc ) / 12 );

        sCdLan := FN_RECUPERA_CODIGO( nIdOri, nNrIda );

        begin

          insert into BNF_HISIPCAP_MOV
          (      CDFUN,            NRPLA,             DTMESREF,          CDLAN,  
                 TPMOV,            CDPAT,             IDPARPLA,          IDBNFCCD,
                 IDBEN,            TPSEX,             NRCPF,             AUUSUULTALT,
                 AUDATULTALT,      AUVERREGATL,       TXCHV
          )
          values 
          (      psCdFun,          psNrPla,           psDtMesRef,        sCdLan, 
                 nTpMov,           psCdPat,           nIdParpla,         nIdBnfCcd, 
                 nIdBen,           sTpSex,            sNrCpf,            psCdUsu,
                 Sysdate,          0,                 sCdPat || '/' || sNrMat || '/' || SUBSTR(TO_CHAR(100 + nSqDpd),2,3)
          );

          
        exception
        when others then
             sDcErr := 'Erro ao incluir em BNF_T_HISIPCAP_PLANO (1). Codigo ' || sCdLan ||', Inscrição ' || sNrIsc;
             raise v_ErroSemRegistros;

        end;
        
    end loop;
    close C_MOV_ENT_SAI;


    COMMIT;

    open C_DIF_IDADE;
    loop
      
        fetch C_DIF_IDADE
        into  nIdOri, sCdPat, sNrMat, nSqDpd, nIdParpla, nIdBnfCcd, nIdBen, dDtNsc, sTpSex, sNrCpf;

        exit when C_DIF_IDADE%notFound;

        nNrIda    := trunc( months_between( dDtUltDiaMes_DT, dDtNsc ) / 12 );
        nNrIdaAnt := trunc( months_between( dDtUltDiaMesAnt, dDtNsc ) / 12 );

        sCdLan    := FN_RECUPERA_CODIGO( nIdOri, nNrIda    );
        sCdLanAnt := FN_RECUPERA_CODIGO( nIdOri, nNrIdaAnt );

        if (sCdLanAnt <> sCdLan) then   
                 
           begin

            insert into BNF_HISIPCAP_MOV
            (      CDFUN,            NRPLA,             DTMESREF,          CDLAN,  
                   TPMOV,            CDPAT,             IDPARPLA,          IDBNFCCD,
                   IDBEN,            TPSEX,             NRCPF,             AUUSUULTALT,
                   AUDATULTALT,      AUVERREGATL,       TXCHV
            )
            values 
            (      psCdFun,          psNrPla,           psDtMesRef,        sCdLan, 
                   1,                psCdPat,           nIdParpla,         nIdBnfCcd, 
                   nIdBen,           sTpSex,            sNrCpf,            psCdUsu,
                   Sysdate,          0,                 sCdPat || '/' || sNrMat || '/' || SUBSTR(TO_CHAR(100 + nSqDpd),2,3)
            );
            
            exception
            when others then
                 sDcErr := 'Erro ao incluir em BNF_T_HISIPCAP_PLANO (3). Codigo ' || sCdLanAnt ||', Inscrição ' || sNrIsc;
                 raise v_ErroSemRegistros;

          end;
          
           begin

            insert into BNF_HISIPCAP_MOV
            (      CDFUN,            NRPLA,             DTMESREF,          CDLAN,  
                   TPMOV,            CDPAT,             IDPARPLA,          IDBNFCCD,
                   IDBEN,            TPSEX,             NRCPF,             AUUSUULTALT,
                   AUDATULTALT,      AUVERREGATL,       TXCHV
            )
            values 
            (      psCdFun,          psNrPla,           psDtMesRef,        sCdLanAnt, 
                   2,                psCdPat,           nIdParpla,         nIdBnfCcd, 
                   nIdBen,           sTpSex,            sNrCpf,            psCdUsu,
                   Sysdate,          0,                 sCdPat || '/' || sNrMat || '/' || SUBSTR(TO_CHAR(100 + nSqDpd),2,3)

            );
              
            exception
            when others then
                 sDcErr := 'Erro ao incluir em BNF_T_HISIPCAP_PLANO(3). Codigo ' || sCdLanAnt ||', Inscrição ' || sNrIsc;
                 raise v_ErroSemRegistros;

          end;
          

        end if;

    end loop;
    close C_DIF_IDADE;


/*------------------- Tratamento de erros */

/*exception

    when v_ErroSemRegistros then
      prsDcErr := sDcErr || '[PR_BNF_GERA_HISIPCAP_MOV_POP]' || ' - Erro ' || SQLCODE;
      rollback;
      return;

    when others then
      prsDcErr := sDcErr || '[PR_BNF_GERA_HISIPCAP_MOV_POP]' || ' - Erro ' || SQLCODE;
      rollback;
      return;
*/

END PR_BNF_GERA_HISIPCAP_MOV_POP;
/
