CREATE OR REPLACE PROCEDURE PR_BNF_GERA_HISIPCAP_CONS_II
(psCdUsu          varchar2,
 psCdFun          char,
 psDtMesRef       char,
 prsDcErr         out varchar2)

as

--|------------------------------------
--| Declaração de Variáveis e Cursores
--|------------------------------------

v_ErroSemRegistros      exception;

sCdLan                  char(5);
sCdLanAnt               char(5);
sCdPat                  char(3);
sNrCpf                  char(11);
sNrMat                  char(10);
sTpPag                  char(1);
sTpSex                  char(1);
sTxChv                  char(17);

dDtIniVigMax            date;
dDtUltDiaRef            date;
dDtPriDiaMes_DT         date;
dDtUltDiaMes_DT         date;

nIdFun                  integer;

nCdGru                  smallint;
nFlGerMov               smallint;
nQtPlaMes                  smallint;
nQtPlaMesAnt               smallint;
nQtReg                  smallint;
nTpItu                  smallint;
nTpMov                  smallint;
nSqDpd                  smallint;

dDtPriDiaMes_TS         timestamp;
dDtUltDiaMes_TS         timestamp;

sDcErr                  varchar2(255);
sTpBnf                  varchar2(10);

cursor C_MOV_ENT_SAI is
select X.CDLAN, 
       X.TPMOV,
       X.CDPAT,
       X.NRMAT,
       X.SQDPD,
       X.TPSEX,
       X.NRCPF
from ( select distinct
              A.CDLAN             AS CDLAN,
              A.TPMOV             AS TPMOV,
              SUBSTR(TXCHV, 1, 3) AS CDPAT,
              SUBSTR(TXCHV, 5,10) AS NRMAT,
              TO_NUMBER(SUBSTR(TXCHV,16, 2)) AS SQDPD,
              A.TPSEX             AS TPSEX,
              A.NRCPF             AS NRCPF
       from   BNF_HISIPCAP_MOV    A                         
       where  A.DTMESREF          = psDtMesRef
       and    A.NRPLA             <> '99'
       and    A.CDPAT             <> '999'
       and    A.CDFUN             = psCdFun
       and    A.AUUSUULTALT       = psCdUsu
       union
       select distinct
              A.CDLAN             AS CDLAN,
              A.TPMOV             AS TPMOV,
              A.CDPAT             AS CDPAT,
              C.NRMAT             AS NRMAT,
              B.SQDPD             AS SQDPD,
              ''                  AS TPSEX,
              A.NRCPF             AS NRCPF
       from   BNF_HISIPCAP_LANCTO A,
              PAR_DEPENDENTES     B,
              PAR_PARTICIPANTES   C    
       where  A.DTMESREF          = psDtMesRef
       and    A.NRPLA             <> '99'
       and    A.CDPAT             <> '999'
       and    A.CDFUN             = psCdFun
       and    A.IDDEP             is not null
       and    B.IDDEP             = A.IDDEP
       and    C.IDPAR             = B.IDPAR 
       union
       select distinct
              A.CDLAN             AS CDLAN,
              A.TPMOV             AS TPMOV,
              A.CDPAT             AS CDPAT,
              D.NRMAT             AS NRMAT,
              0                   AS SQDPD,
              ''                  AS TPSEX,
              A.NRCPF             AS NRCPF
       from   BNF_HISIPCAP_LANCTO A,
              BNF_BENEFICIARIOS   B,
              BNF_BNFCONCEDIDOS   C,
              PAR_PARPLA          D    
       where  A.DTMESREF          = psDtMesRef
       and    A.NRPLA             <> '99'
       and    A.CDPAT             <> '999'
       and    A.CDFUN             = psCdFun
       and    A.IDDEP             is null
       and    A.IDBEN             is not null
       and    B.IDBEN             = A.IDBEN
       and    C.IDBNFCCD          = B.IDBNFCCD
       and    D.IDPARPLA          = C.IDPARPLA   
       union
       select distinct
              A.CDLAN             AS CDLAN,
              A.TPMOV             AS TPMOV,
              A.CDPAT             AS CDPAT,
              B.NRMAT             AS NRMAT,
              0                   AS SQDPD,
              ''                  AS TPSEX,
              A.NRCPF             AS NRCPF
       from   BNF_HISIPCAP_LANCTO A,
              PAR_PARPLA          B    
       where  A.DTMESREF          = psDtMesRef
       and    A.NRPLA             <> '99'
       and    A.CDPAT             <> '999'
       and    A.CDFUN             = psCdFun
       and    A.IDDEP             is null
       and    A.IDBEN             is null
       and    B.IDPARPLA          = A.IDPARPLA   
     ) X    
where  not exists( select 1
                   from   BNF_HISIPCAP_EXC
                   where  DTMESREF       = psDtMesRef
                   and    NRPLA          = '99'
                   and    CDPAT          = '999'
                   and    CDFUN          = psCdFun
                   and    CDLAN          = X.CDLAN
                   and    TPMOV          = X.TPMOV
                   and    CDPATORI       = X.CDPAT
                   and    NRMAT          = X.NRMAT
                   and    SQDPD          = X.SQDPD
                 )
order by 1, 2, 3;



begin
  

dDtPriDiaMes_DT := to_date(psDtMesRef || '01', 'rrrrmmdd');
dDtUltDiaMes_DT := last_day(dDtPriDiaMes_DT);

dDtPriDiaMes_TS := to_timestamp( dDtPriDiaMes_DT ||' 00:00:01.000000000', 'dd/mm/rrrr hh24:mi:ss.ff' );
dDtUltDiaMes_TS := to_timestamp( dDtUltDiaMes_DT ||' 23:59:59.000000000', 'dd/mm/rrrr hh24:mi:ss.ff' );


select IDFUN
into   nIdFun
from   PAR_FUNDOS
where  CDFUN    = psCdFun;


-- recupera a maior data de vigência de BNF_SIPCAP_CDLAN

select MAX( DTINIVIG )
into   dDtIniVigMax
from   BNF_SIPCAP_CDLAN
where  DTINIVIG <= last_day( to_date( psDtMesRef, 'RRRRMM' ));
  

sCdLanAnt := NULL;

-- processa as entradas e saídas por matrícula
                                     
open C_MOV_ENT_SAI;
loop

  fetch C_MOV_ENT_SAI
  into  sCdLan, nTpMov, sCdPat, sNrMat, nSqDpd, sTpSex, sNrCpf; 
  
  exit when C_MOV_ENT_SAI%notFound;
   
  -- inicializa flag de geração da movimentação
  nFlGerMov := 1;
  
  sTxChv := sCdPat || '/' || sNrMat || '/' || substr(to_char( 100 + nSqDpd ),2,3);
    
  -- verifica em quantos planos a matrícula se encontrava antes do início do mês
  select count(distinct b.NRPLA)
  into   nQtPlaMesAnt
  from   PAR_PARTICIPANTES   a,
         PAR_PARPLA          b,
         PAR_HISITPAR        c
  where  a.CDFUN             = psCdFun
  and    a.CDPAT             = sCdPat
  and    a.NRMAT             = sNrMat
  and    b.IDPAR             = a.IDPAR
  and    c.IDPARPLA          = b.IDPARPLA
  and    c.DTSISINI          = ( select max( DTSISINI )
                                 from   PAR_HISITPAR
                                 where  IDPARPLA      = c.IDPARPLA
                                 and    DTSISINI      < dDtPriDiaMes_TS
                                 and    DTINISIT      < dDtPriDiaMes_DT
                               )
  and    c.SQSIT             = ( select max( SQSIT )
                                 from   PAR_HISITPAR
                                 where  IDPARPLA      = c.IDPARPLA
                                 and    DTSISINI      = c.DTSISINI
                                 and    DTINISIT      < dDtPriDiaMes_DT
                               )
  and    c.STISCATU          <> '5';
  
  -- verifica em quantos planos a matrícula se encontrava no final do mês
  select count(distinct b.NRPLA)
  into   nQtPlaMes
  from   PAR_PARTICIPANTES   a,
         PAR_PARPLA          b,
         PAR_HISITPAR        c
  where  a.CDFUN             = psCdFun
  and    a.CDPAT             = sCdPat
  and    a.NRMAT             = sNrMat
  and    b.IDPAR             = a.IDPAR
  and    c.IDPARPLA          = b.IDPARPLA
  and    c.DTSISINI          = ( select max( DTSISINI )
                                 from   PAR_HISITPAR
                                 where  IDPARPLA      = c.IDPARPLA
                                 and    DTSISINI      <= dDtUltDiaMes_TS
                                 and    DTINISIT      <= dDtUltDiaMes_DT
                               )
  and    c.SQSIT             = ( select max( SQSIT )
                                 from   PAR_HISITPAR
                                 where  IDPARPLA      = c.IDPARPLA
                                 and    DTSISINI      = c.DTSISINI
                                 and    DTINISIT      <= dDtUltDiaMes_DT
                               )
  and    c.STISCATU          <> '5';
  
  
  -- se em algum momento a matrícula se encontrava em mais de um plano, verifica se é para 
  -- gerar a movimentação
  if (nQtPlaMesAnt > 1) or (nQtPlaMes > 1) then
    
    -- recupera as características do lançamento   
    if (sCdLanAnt is null) or (sCdLanAnt <> sCdLan ) then
      
      select CDGRU,
             TPBNF,
             TPPAG,
             TPITU
      into   nCdGru,
             sTpBnf,
             sTpPag,
             nTpItu
      from   BNF_SIPCAP_CDLAN
      where  DTINIVIG       = dDtIniVigMax
      and    CDLAN          = sCdLan;
      
      sCdLanAnt := sCdLan;
    
    end if;
    
    /*
    CÓDIGO DO GRUPO:        1 - Dados de Benefícios, 
                            2 - Dados de Institutos, 
                            3 - Dados de População, 
                            4 - Demonstrativo de Sexo/Idade
                            
    TIPO DE BENEÍCIO:       AP - Aposentadoria Programada, 
                            IN - Aposentadoria por Invalidez, 
                            AD - Auxílio Doença, 
                            AF - Auxílio Funeral, 
                            AM - Auxílio Maternidade, 
                            AR - Auxílio Reclusão, 
                            PS - Pensão por Morte, 
                            PE - Pecúlio, 
                            OU - Outros
                            
    TIPO DE PAGAMENTO:      C - Contínuo, 
                            U - Único
    
    TIPO DE INSTITUTO:      1 - Benefício Proporcional Diferido, 
                            2 - Autopatrocínio, 
                            3 - Resgate, 
                            4 - Portabilidade de Entrada, 
                            5 - Portabilidade de Saída
    */
  
    --|----------------------------------------
    --| trata benefícios de pagamento contínuo
    --|----------------------------------------
    if (nCdGru = 1) and (sTpPag ='C') then
      
      -- verifica se existe movimentação no mesmo mês e de mesmo tipo (E/S), de benefício semelhante, 
      -- em outro plano
       
      select count(1)
      into   nQtReg
      from   BNF_HISIPCAP_MOV A       
      where  A.DTMESREF       = psDtMesRef
      and    A.NRPLA          <> '99'
      and    A.CDPAT          <> '999'
      and    A.CDFUN          = psCdFun
      and    A.CDLAN          = sCdLan
      and    A.TPMOV          = nTpMov
      and    A.TXCHV          = sTxChv
      and    A.AUUSUULTALT    = psCdUsu
      and    EXISTS(          select 1
                              from   PAR_PATROCINADORAS     B,   
                                     PAR_PARTICIPANTES      C,
                                     PAR_PARPLA             D,
                                     BNF_BNFCONCEDIDOS      E,
                                     BNF_BENFPLA            F,
                                     BNF_BENEFICIOS         G,
                                     BNF_HISITBNF           H   
                              where  B.IDFUN                = nIdFun
                              and    B.CDPAT                = sCdPat
                              and    C.IDPAT                = B.IDPAT
                              and    C.NRMAT                = sNrMat
                              and    D.IDPAR                = C.IDPAR
                              and    D.IDPARPLA             <> A.IDPARPLA
                              and    E.IDPARPLA             = D.IDPARPLA
                              and    F.IDBNFPLA             = E.IDBNFPLA
                              and    G.IDBNF                = F.IDBNF
                              and    INSTR(G.TPBNF || ',' || NVL(G.TPBNFCPL,G.TPBNF), sTpBnf) > 0
                              and    H.IDBNFCCD             = E.IDBNFCCD
                              and    H.AUDATULTALT          = ( select max( AUDATULTALT )
                                                                from   BNF_HISITBNF
                                                                where  IDBNFCCD    = H.IDBNFCCD
                                                                and    AUDATULTALT < dDtPriDiaMes_TS  )
                              and    H.STBNF                in ('10','11'));
      
    --|---------------------
    --| trata os institutos
    --|---------------------
        
    elsif (nCdGru = 2) then

      if nTpItu = 1 then            -- Benefício Proporcional Diferido
        
        select count(1)
        into   nQtReg
        from   BNF_HISIPCAP_MOV A       
        where  A.DTMESREF       = psDtMesRef
        and    A.NRPLA          <> '99'
        and    A.CDPAT          <> '999'
        and    A.CDFUN          = psCdFun
        and    A.CDLAN          = sCdLan
        and    A.TPMOV          = nTpMov
        and    A.NRCPF          = sNrCpf
        and    EXISTS(          select 1
                                from   PAR_PARTICIPANTES C,
                                       PAR_PARPLA        D,
                                       PAR_HISITPAR      E
                                where  C.NRCPFPAR        = A.NRCPF
                                and    D.IDPAR           = C.IDPAR
                                and    D.IDPARPLA        <> A.IDPARPLA
                                and    E.IDPARPLA        = D.IDPARPLA
                                and    E.STISCATU        = '9'
                                and   (E.DTSISFIM is null  or E.DTSISFIM > dDtUltDiaRef )
                                and   (E.DTFIMSIT is null  or E.DTFIMSIT > dDtUltDiaRef ));
        
      elsif nTpItu = 2 then         -- Autopatrocínio
        
        select count(1)
        into   nQtReg
        from   BNF_HISIPCAP_MOV A       
        where  A.DTMESREF       = psDtMesRef
        and    A.NRPLA          <> '99'
        and    A.CDPAT          <> '999'
        and    A.CDFUN          = psCdFun
        and    A.CDLAN          = sCdLan
        and    A.TPMOV          = nTpMov
        and    A.NRCPF          = sNrCpf
        and    EXISTS(          select 1
                                from   PAR_PARTICIPANTES C,
                                       PAR_PARPLA        D,
                                       PAR_HISITPAR      E
                                where  C.NRCPFPAR        = A.NRCPF
                                and    D.IDPAR           = C.IDPAR
                                and    D.IDPARPLA        <> A.IDPARPLA
                                and    E.IDPARPLA        = D.IDPARPLA
                                and    E.STISCATU        = '1'
                                and   (E.DTSISFIM is null  or E.DTSISFIM > dDtUltDiaRef )
                                and   (E.DTFIMSIT is null  or E.DTFIMSIT > dDtUltDiaRef ));

        
      elsif nTpItu = 3 then         -- Resgate
        
        select count(1)
        into   nQtReg
        from   BNF_HISIPCAP_MOV A       
        where  A.DTMESREF       = psDtMesRef
        and    A.NRPLA          <> '99'
        and    A.CDPAT          <> '999'
        and    A.CDFUN          = psCdFun
        and    A.CDLAN          = sCdLan
        and    A.TPMOV          = nTpMov
        and    A.NRCPF          = sNrCpf
        and    EXISTS(          select 1
                                from   PAR_PARTICIPANTES C,
                                       PAR_PARPLA        D,
                                       CTB_RESPOUP       E
                                where  C.NRCPFPAR        = A.NRCPF
                                and    D.IDPAR           = C.IDPAR
                                and    D.IDPARPLA        <> A.IDPARPLA
                                and    E.IDPARPLA        = D.IDPARPLA
                                and    TO_CHAR(E.DTPVTPAG,'RRRR') = SUBSTR(psDtMesRef,1,4));
        
  /*  elsif nTpItu = 4 then         -- Portabilidade de Saída
        
      elsif nTpItu = 5 then         -- Portabilidade de Entrada*/
        
      end if;

    --|-------------------
    --| trata a população
    --|-------------------

    elsif (nCdGru = 3) then
      /*
      31100 Participante - com custeio exclusivamente patronal
      31200 Participante - com custeio patronal e do participante
      31300 Participante - com custeio exclusivamente do participante
      31310 Benefício Proporcional Diferido
      31320 Autopatrocínio
      32000 Assistidos - Aposentados
      33000 Assistidos - Beneficiários de Pensão
      34000 Designados
      34100 Designados Participantes
      34200 Designados Assistidos
      */
      if sCdLan = '31200' then         -- Participante - com custeio patronal e do participante
        
        select count(1)
        into   nQtReg
        from   BNF_HISIPCAP_MOV A       
        where  A.DTMESREF       = psDtMesRef
        and    A.NRPLA          <> '99'
        and    A.CDPAT          <> '999'
        and    A.CDFUN          = psCdFun
        and    A.CDLAN          = sCdLan
        and    A.TPMOV          = nTpMov
        and    A.NRCPF          = sNrCpf
        and    EXISTS(          select 1
                                from   PAR_PARTICIPANTES C,
                                       PAR_PARPLA        D,
                                       PAR_HISITPAR      E
                                where  C.NRCPFPAR        = A.NRCPF
                                and    D.IDPAR           = C.IDPAR
                                and    D.IDPARPLA        <> A.IDPARPLA
                                and    E.IDPARPLA        = D.IDPARPLA
                                and    E.STISCATU        in ('0','2','7')
                                and   (E.DTSISFIM is null  or E.DTSISFIM > dDtUltDiaRef )
                                and   (E.DTFIMSIT is null  or E.DTFIMSIT > dDtUltDiaRef ));
        
      elsif sCdLan = '31300' then      -- Participante - com custeio exclusivamente do participante
        
        select count(1)
        into   nQtReg
        from   BNF_HISIPCAP_MOV A       
        where  A.DTMESREF       = psDtMesRef
        and    A.NRPLA          <> '99'
        and    A.CDPAT          <> '999'
        and    A.CDFUN          = psCdFun
        and    A.CDLAN          = sCdLan
        and    A.TPMOV          = nTpMov
        and    A.NRCPF          = sNrCpf
        and    EXISTS(          select 1
                                from   PAR_PARTICIPANTES C,
                                       PAR_PARPLA        D,
                                       PAR_HISITPAR      E
                                where  C.NRCPFPAR        = A.NRCPF
                                and    D.IDPAR           = C.IDPAR
                                and    D.IDPARPLA        <> A.IDPARPLA
                                and    E.IDPARPLA        = D.IDPARPLA
                                and    E.STISCATU        in ('1','9')
                                and   (E.DTSISFIM is null  or E.DTSISFIM > dDtUltDiaRef )
                                and   (E.DTFIMSIT is null  or E.DTFIMSIT > dDtUltDiaRef ));

      elsif sCdLan = '32000' then      -- Assistidos - Aposentados
        
        select count(1)
        into   nQtReg
        from   BNF_HISIPCAP_MOV A       
        where  A.DTMESREF       = psDtMesRef
        and    A.NRPLA          <> '99'
        and    A.CDPAT          <> '999'
        and    A.CDFUN          = psCdFun
        and    A.CDLAN          = sCdLan
        and    A.TPMOV          = nTpMov
        and    A.TXCHV          = sTxChv
        and    EXISTS(          select 1
                                from   PAR_PATROCINADORAS B,   
                                       PAR_PARTICIPANTES  C,
                                       PAR_PARPLA         D,
                                       BNF_BNFCONCEDIDOS  E,
                                       BNF_BENFPLA        F,
                                       BNF_BENEFICIOS     G,
                                       BNF_HISITBNF       H   
                                where  B.IDFUN            = nIdFun
                                and    B.CDPAT            = sCdPat
                                and    C.IDPAT            = B.IDPAT
                                and    C.NRMAT            = sNrMat
                                and    D.IDPAR            = C.IDPAR
                                and    D.IDPARPLA         <> A.IDPARPLA
                                and    E.IDPARPLA         = D.IDPARPLA
                                and    F.IDBNFPLA         = E.IDBNFPLA
                                and    G.IDBNF            = F.IDBNF
                                and    G.TPBNF            in ('AP','BP')
                                and    H.IDBNFCCD         = E.IDBNFCCD
                                and    H.AUDATULTALT      = ( select max( AUDATULTALT )
                                                              from   BNF_HISITBNF
                                                              where  IDBNFCCD    = H.IDBNFCCD
                                                              and    AUDATULTALT < dDtPriDiaMes_TS  )
                                and    H.STBNF            in ('10','11'));

      elsif sCdLan = '33000' then      -- Assistidos - Beneficiários de Pensão
        
        select count(1)
        into   nQtReg
        from   BNF_HISIPCAP_MOV A       
        where  A.DTMESREF       = psDtMesRef
        and    A.NRPLA          <> '99'
        and    A.CDPAT          <> '999'
        and    A.CDFUN          = psCdFun
        and    A.CDLAN          = sCdLan
        and    A.TPMOV          = nTpMov
        and    A.TXCHV          = sTxChv
        and    EXISTS(          select 1
                                from   PAR_PATROCINADORAS B,   
                                       PAR_PARTICIPANTES  C,
                                       PAR_PARPLA         D,
                                       BNF_BNFCONCEDIDOS  E,
                                       BNF_BENFPLA        F,
                                       BNF_BENEFICIOS     G,
                                       BNF_HISITBNF       H,
                                       BNF_BENEFICIARIOS  I   
                                where  B.IDFUN            = nIdFun
                                and    B.CDPAT            = sCdPat
                                and    C.IDPAT            = B.IDPAT
                                and    C.NRMAT            = sNrMat
                                and    D.IDPAR            = C.IDPAR
                                and    D.IDPARPLA         <> A.IDPARPLA
                                and    E.IDPARPLA         = D.IDPARPLA
                                and    F.IDBNFPLA         = E.IDBNFPLA
                                and    G.IDBNF            = F.IDBNF
                                and    G.TPBNF            = 'PS'
                                and    H.IDBNFCCD         = E.IDBNFCCD
                                and    H.AUDATULTALT      = ( select max( AUDATULTALT )
                                                              from   BNF_HISITBNF
                                                              where  IDBNFCCD    = H.IDBNFCCD
                                                              and    AUDATULTALT < dDtPriDiaMes_TS  )
                                and    H.STBNF            in ('10','11')
                                and    I.IDBNFCCD         = E.IDBNFCCD
                                and    I.SQBEN            = nSqDpd        
                       );

      --elsif sCdLan = '34000' then      -- Designados
        
      end if;

    end if;  

    if nQtReg > 0 then
      nFlGerMov := 0;
    end if;        

  end if;  
  
  
  if (nFlGerMov = 1) then
    
    insert into BNF_HISIPCAP_MOV
    (      DTMESREF,      CDFUN,         CDPAT,        NRPLA,      CDLAN,        TPMOV,
           TPSEX,         NRCPF,         TXCHV,
           AUUSUULTALT,   AUDATULTALT,   AUVERREGATL )
    values
    (      psDtMesRef,    psCdFun,       '999',        '99',       sCdLan,       nTpMov,
           sTpSex,        sNrCpf,        sTxChv,
           psCdUsu,       sysdate,        0
    );
    
  end if;
  
end loop;
close C_MOV_ENT_SAI;

/*------------------- Tratamento de erros */

exception

    when v_ErroSemRegistros then
      prsDcErr := sDcErr || '[PR_BNF_GERA_HISIPCAP_CONSOLIDADO]' || ' - Erro ' || SQLCODE;
      rollback;
      return;

    when others then
      prsDcErr := sDcErr || '[PR_BNF_GERA_HISIPCAP_CONSOLIDADO]' || ' - Erro ' || SQLCODE;
      rollback;
      return;


END PR_BNF_GERA_HISIPCAP_CONS_II;
/
