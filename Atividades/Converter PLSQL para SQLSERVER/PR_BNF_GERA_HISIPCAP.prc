CREATE OR REPLACE PROCEDURE PR_BNF_GERA_HISIPCAP
(psCdFun          char,
 psCdPat          char,
 psNrPla          char,
 psDtMesRef       char,
 psCdUsu          varchar2,
 prsDcErr         out varchar2)
     
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

sDtMesAnt          char(6);
sDtMesRefIni       char(6);
sNrPla             char(2);
sNrPlaAux          char(2);
sCdPat             char(3);
sCdPatAux          char(3);
sCdPatAuxPRM       char(3);

dDtUltDiaMes_DT    date;
dDtIniVigMax       date;
dDtSis             date;

nIdFun             integer;
nIdPat             integer;
nIdPla             integer;

nQtReg             smallint;

sDcErr             varchar2(255);


cursor C_PATROCINADORAS is
SELECT A.IDFUN, 
       B.IDPAT, 
       B.CDPAT
FROM   PAR_FUNDOS          A,
       PAR_PATROCINADORAS  B
WHERE  A.CDFUN             = psCdFun
and    B.IDFUN             = A.IDFUN
and  ((psCdPat             IS NULL)
       OR
      (psCdPat             in ('001','002')       AND   CDPAT in ('001','002'))
       OR
      (psCdPat             not in ('001','002')   AND   CDPAT = psCdPat))
ORDER BY B.CDPAT;      


cursor C_PLANOS is
SELECT IDPLA, 
       NRPLA
FROM   PAR_PLANOS
WHERE  nIdPat   IS NOT NULL
AND    IDPAT    = nIdPat
AND   (NRPLA    = psNrPla   OR    psNrPla IS NULL)
UNION
SELECT NULL, 
       '99'
FROM   DUAL
WHERE  nIdPat   IS NULL         
ORDER BY 2;      



-----
Begin
-----
  
  select count(1)
  into   nQtReg
  from   BNF_HISIPCAP_INIC;
  
  if nQtReg > 0 then
    
    select max(DTMESREF)
    into   sDtMesRefIni
    from   BNF_HISIPCAP_INIC;

    if psDtMesRef <= sDtMesRefIni then
      prsDcErr := 'Só é possível gerar os dados do SICADI para meses posteriores a ' || 
                  substr(sDtMesRefIni,5,2) || '/' || substr(sDtMesRefIni,1,4) || '!';
      return;
    end if;
  end if;


/*  IF psCdPat IS NULL AND psNrPla IS NULL THEN
    
      delete from BNF_T_SIPCAP_PLANO where DTMESREF = psDtMesRef;
  
  END IF;*/


  dDtSis          := sysdate;
  sDtMesAnt       := to_char(add_months(to_date(psDtMesRef,'yyyymm'),-1),'yyyymm');
  
  dDtUltDiaMes_DT := last_day( to_date( psDtMesRef, 'RRRRMM' ));


  select MAX( DTINIVIG )
  into   dDtIniVigMax
  from   BNF_SIPCAP_CDLAN
  where  DTINIVIG <= dDtUltDiaMes_DT;
  
  -- 07/03/2023: comentado o teste de psCdPat
  IF /*psCdPat IS NULL AND*/ psNrPla IS NOT NULL THEN
    
      sCdPatAuxPRM := '001';
    
  ELSIF psCdPat IS NULL AND psNrPla IS NULL THEN
  
      sCdPatAuxPRM := NULL;
  
  END IF; ---TRATAMENTO PARA POSSIBILITAR O NAO PREENCHIMENTO DA PATROCINADORA 19/01/22
                                                                                              
    
 
  /*--------------------
  APAGA TABELAS GERADAS
  ---------------------*/
  
  if sCdPatAuxPRM is null then
    sCdPatAux := '999';
    sNrPlaAux := '99';
  else    
    sNrPlaAux := psNrPla;
       
    if sCdPatAuxPRM in ('001','002') then
      sCdPatAux := '001';
    else
      sCdPatAux := sCdPatAuxPRM;
    end if;
  end if;
  

  delete
  from   BNF_HISIPCAP_PLANO
  where  DTMESREF    = psDtMesRef
  and    NRPLA       = sNrPlaAux
  and    CDPAT       = sCdPatAux         
  and    CDFUN       = psCdFun; 


  delete
  from   BNF_HISIPCAP_MOV
  where  DTMESREF    = psDtMesRef
  and    NRPLA       = sNrPlaAux
  and  ((CDPAT       = sCdPatAux        and  sCdPatAux <> '001')
         or
        (CDPAT       in ('001','002')   and  sCdPatAux =  '001'))            
  and    CDFUN       = psCdFun;
  
  delete
  from   BNF_T_SIPCAP_PLANO
  where  DTMESREF    = psDtMesRef
  and    (NRPLA       = sNrPlaAux OR sNrPlaAux = '99')  --- ADICIONADO 24/01/23 D.D.
  and    (CDPAT       = sCdPatAux OR sCdPatAux = '999') --- ADICIONADO 24/01/23 D.D.
  and    CDFUN       = psCdFun; 
      
  commit;

  /*--------------------------------------------------------------
  Executa procedimento que identifica as entradas e saidas do mes
  ---------------------------------------------------------------*/
  
  if sNrPlaAux <> '99' then
          
    PR_BNF_GERA_HISIPCAP_MOV
          ( psCdUsu, psCdFun, sCdPatAux, sNrPlaAux, psDtMesRef, sDcErr);

    if sDcErr is not NULL then
       prsDcErr := sDcErr;
       return;
    end if;


    PR_BNF_GERA_HISIPCAP_MOV_POP
          ( psCdUsu, psCdFun, sCdPatAux, sNrPlaAux, psDtMesRef, sDtMesAnt, sDcErr);

    if sDcErr is not NULL then
       prsDcErr := sDcErr;
       return;
    end if;
        
  else

    --PR_BNF_GERA_HISIPCAP_CONS       17/03/2023
    PR_BNF_GERA_HISIPCAP_CONS_II
          ( psCdUsu, psCdFun, psDtMesRef, sDcErr);

    if sDcErr is not NULL then
       prsDcErr := sDcErr;
       return;
    end if;
         
  end if;


  /*--------------------------------
  Insere todos os códigos do SIPCAP
  ---------------------------------*/
              
  insert into BNF_HISIPCAP_PLANO
         (IDHISSIPCAPPLA,
          CDFUN,
          DTMESREF,
          NRPLA,
          CDPAT,
          CDLAN,
          QTMESANT,
          QTCOSMES,
          QTCANMES,
          QTSEXMAS,
          QTSEXFEM,
          AUUSUULTALT,
          AUDATULTALT,
          AUVERREGATL )
  select  SQ_PVDAT_BNF_HISIPCAP_PLANO.Nextval,
          psCdFun,
          psDtMesRef,
          sNrPlaAux,
          sCdPatAux,
          CDLAN,    
          0,          
          0,
          0,
          0,
          0,
          psCdUsu,
          dDtSis,
          1
  from    BNF_SIPCAP_CDLAN
  where   DTINIVIG  = dDtIniVigMax  
  -- incluída a restrição abaixo porque o Java já gera os totalizadores com exceção dos códigos
  -- 31300 e 31400, que passaram a ser totalizadores para atender a Prevdata !!!!!!! 
  and   ((FLCODTOT  = 'N')  
          OR 
         (FLCODTOT  = 'S' and CDGRU = 3 and TPPOP is not null));
                  
                                 
  /*--------------------------------
  Atualiza os totais do mês anterior
  ---------------------------------*/

  sDcErr  := 'Erro na atualização dos totais do mes anterior (CDLAN <> 24100)';
      
  if (sDtMesRefIni is not NULL) then
        
    if (sDtMesAnt > sDtMesRefIni) then
      
      update BNF_HISIPCAP_PLANO A
      set    A.QTMESANT         = ( select ABS(QTMESANT + QTCOSMES - QTCANMES)
                                    from   BNF_HISIPCAP_PLANO
                                    where  DTMESREF       = sDtMesAnt
                                    and    NRPLA          = A.NRPLA
                                    and    CDPAT          = A.CDPAT
                                    and    CDFUN          = A.CDFUN
                                    and    CDLAN          = A.CDLAN
                                  )
      where  A.DTMESREF         = psDtMesRef
      and    A.NRPLA            = sNrPlaAux
      and    A.CDPAT            = sCdPatAux
      and    A.CDFUN            = psCdFun
      and    A.CDLAN            <> '24100'
      and    A.AUUSUULTALT      = psCdUsu
      and    EXISTS(                select 1
                                    from   BNF_HISIPCAP_PLANO
                                    where  DTMESREF       = sDtMesAnt
                                    and    NRPLA          = A.NRPLA
                                    and    CDPAT          = A.CDPAT
                                    and    CDFUN          = A.CDFUN
                                    and    CDLAN          = A.CDLAN
                   );
          
          

      sDcErr  := 'Erro na atualização dos totais do mes anterior (CDLAN = 24100)';
          
      update BNF_HISIPCAP_PLANO A
      set    A.QTMESANT         = ( select ABS(QTMESANT + QTCOSMES) ---alterado QTCANMES para QTCOSMES ---23/01/23 D.D.
                                    from   BNF_HISIPCAP_PLANO
                                    where  DTMESREF       = sDtMesAnt
                                    and    NRPLA          = A.NRPLA
                                    and    CDPAT          = A.CDPAT
                                    and    CDFUN          = A.CDFUN
                                    and    CDLAN          = A.CDLAN
                                  )
      where  A.DTMESREF         = psDtMesRef
      and    A.NRPLA            = sNrPlaAux
      and    A.CDPAT            = sCdPatAux
      and    A.CDFUN            = psCdFun
      and    A.CDLAN            = '24100'
      and    A.AUUSUULTALT      = psCdUsu
      and    EXISTS(                select 1
                                    from   BNF_HISIPCAP_PLANO
                                    where  DTMESREF       = sDtMesAnt
                                    and    NRPLA          = A.NRPLA
                                    and    CDPAT          = A.CDPAT
                                    and    CDFUN          = A.CDFUN
                                    and    CDLAN          = A.CDLAN
                   );

    else
          
      update BNF_HISIPCAP_PLANO A
      set    A.QTMESANT         = ( select QTLAN
                                    from   BNF_HISIPCAP_INIC
                                    where  DTMESREF       = sDtMesRefIni
                                    and    NRPLA          = A.NRPLA
                                    and    CDPAT          = A.CDPAT
                                    and    CDFUN          = A.CDFUN
                                    and    CDLAN          = A.CDLAN
                                  )
      where  A.DTMESREF         = psDtMesRef
      and    A.NRPLA            = sNrPlaAux
      and    A.CDPAT            = sCdPatAux
      and    A.CDFUN            = psCdFun
      and    EXISTS(                select 1
                                    from   BNF_HISIPCAP_INIC
                                    where  DTMESREF       = sDtMesRefIni
                                    and    NRPLA          = A.NRPLA
                                    and    CDPAT          = A.CDPAT
                                    and    CDFUN          = A.CDFUN
                                    and    CDLAN          = A.CDLAN
                   );
    end if;
        
  end if;
      
                         
  /*------------------------------------------------------------------------------------------
  Zera os totais do mes anterior em caso de inicio de ano (MES = 01) para determinados códigos
  --------------------------------------------------------------------------------------------*/

  If substr(psDtMesRef, 5, 2) = '01' then

    sDcErr  := 'Erro na inicialização de QTMESANT';

    update BNF_HISIPCAP_PLANO
    set    QTMESANT     = 0
    where  DTMESREF     = psDtMesRef
    and    NRPLA        = sNrPlaAux
    and    CDPAT        = sCdPatAux
    and    CDFUN        = psCdFun
    and    CDLAN        in ( select CDLAN
                             from   BNF_SIPCAP_CDLAN
                             where  DTINIVIG = dDtIniVigMax
                             and    FLZERANO = 'S'
                           )
    and    AUUSUULTALT  = psCdUsu;

  End If;


  /*-------------------------
  Atualiza os totais do mes
  --------------------------*/

  sDcErr  := 'Erro na atualização dos totais de entradas do mes (1)';

  update  BNF_HISIPCAP_PLANO h
  set     h.QTCOSMES         = ( select h.QTCOSMES + count( 1 )
                                 from   BNF_HISIPCAP_MOV
                                 where  DTMESREF = h.DTMESREF
                                 and    NRPLA    = h.NRPLA
                                 and  ((CDPAT    = sCdPatAux        and  sCdPatAux <> '001')
                                        or
                                       (CDPAT    in ('001','002')   and  sCdPatAux =  '001'))            
                                 and    CDFUN    = h.CDFUN
                                 and    CDLAN    = h.CDLAN
                                 and    TPMOV    = 1 )
  where   h.DTMESREF         = psDtMesRef
  and     h.NRPLA            = sNrPlaAux
  and     h.CDPAT            = sCdPatAux
  and     h.CDFUN            = psCdFun
  and     h.AUUSUULTALT      = psCdUsu
  and     exists (               select 1
                                 from   BNF_HISIPCAP_MOV
                                 where  DTMESREF = h.DTMESREF
                                 and    NRPLA    = h.NRPLA   
                                 and  ((CDPAT    = sCdPatAux        and  sCdPatAux <> '001')
                                        or
                                       (CDPAT    in ('001','002')   and  sCdPatAux =  '001'))            
                                 and    CDFUN    = h.CDFUN                          
                                 and    CDLAN    = h.CDLAN
                                 and    TPMOV    = 1 );

                               
  sDcErr  := 'Erro na atualização dos totais de entradas do mes (2)';

  update  BNF_HISIPCAP_PLANO h
  set     h.QTCOSMES         = ( select h.QTCOSMES + count(1)
                                 from   BNF_HISIPCAP_LANCTO
                                 where  DTMESREF = h.DTMESREF
                                 and    NRPLA    = h.NRPLA
                                 and  ((CDPAT    = sCdPatAux        and  sCdPatAux <> '001')
                                        or
                                       (CDPAT    in ('001','002')   and  sCdPatAux =  '001'))            
                                 and    CDFUN    = h.CDFUN
                                 and    CDLAN    = h.CDLAN
                                 and    TPMOV    = 1 )
  where   h.DTMESREF         = psDtMesRef
  and     h.NRPLA            = sNrPlaAux
  and     h.CDPAT            = sCdPatAux
  and     h.CDFUN            = psCdFun
  and     h.AUUSUULTALT      = psCdUsu
  and     exists (               select 1
                                 from   BNF_HISIPCAP_LANCTO
                                 where  DTMESREF = h.DTMESREF
                                 and    NRPLA    = h.NRPLA  
                                 and  ((CDPAT    = sCdPatAux        and  sCdPatAux <> '001')
                                        or
                                       (CDPAT    in ('001','002')   and  sCdPatAux =  '001'))            
                                 and    CDFUN    = h.CDFUN                          
                                 and    CDLAN    = h.CDLAN
                                 and    TPMOV    = 1 );



  sDcErr  := 'Erro na atualização dos totais de saidas do mes (1)';

  update  BNF_HISIPCAP_PLANO h
  set     h.QTCANMES         = ( select h.QTCANMES + count( 1 )
                                 from   BNF_HISIPCAP_MOV
                                 where  DTMESREF = h.DTMESREF
                                 and    NRPLA    = h.NRPLA
                                 and  ((CDPAT    = sCdPatAux        and  sCdPatAux <> '001')
                                        or
                                       (CDPAT    in ('001','002')   and  sCdPatAux =  '001'))            
                                 and    CDFUN    = h.CDFUN
                                 and    CDLAN    = h.CDLAN
                                 and    TPMOV    = 2 )
  where   h.DTMESREF         = psDtMesRef
  and     h.NRPLA            = sNrPlaAux
  and     h.CDPAT            = sCdPatAux
  and     h.CDFUN            = psCdFun
  and     h.AUUSUULTALT      = psCdUsu
  and     exists (               select 1
                                 from   BNF_HISIPCAP_MOV
                                 where  DTMESREF = h.DTMESREF
                                 and    NRPLA    = h.NRPLA
                                 and  ((CDPAT    = sCdPatAux        and  sCdPatAux <> '001')
                                        or
                                       (CDPAT    in ('001','002')   and  sCdPatAux =  '001'))            
                                 and    CDFUN    = h.CDFUN                          
                                 and    CDLAN    = h.CDLAN
                                 and    TPMOV    = 2 );

                             
  sDcErr  := 'Erro na atualização dos totais de saidas do mes (2)';

  update  BNF_HISIPCAP_PLANO h
  set     h.QTCANMES         = ( select h.QTCANMES + count(1)
                                 from   BNF_HISIPCAP_LANCTO
                                 where  DTMESREF = h.DTMESREF
                                 and    NRPLA    = h.NRPLA
                                 and  ((CDPAT    = sCdPatAux        and  sCdPatAux <> '001')
                                        or
                                       (CDPAT    in ('001','002')   and  sCdPatAux =  '001'))            
                                 and    CDFUN    = h.CDFUN
                                 and    CDLAN    = h.CDLAN
                                 and    TPMOV    = 2 )
  where   h.DTMESREF         = psDtMesRef
  and     h.NRPLA            = sNrPlaAux
  and     h.CDPAT            = sCdPatAux
  and     h.CDFUN            = psCdFun
  and     h.AUUSUULTALT      = psCdUsu
  and     exists (               select 1
                                 from   BNF_HISIPCAP_LANCTO
                                 where  DTMESREF = h.DTMESREF
                                 and    NRPLA    = h.NRPLA
                                 and  ((CDPAT    = sCdPatAux        and  sCdPatAux <> '001')
                                        or
                                       (CDPAT    in ('001','002')   and  sCdPatAux =  '001'))            
                                 and    CDFUN    = h.CDFUN                          
                                 and    CDLAN    = h.CDLAN
                                 and    TPMOV    = 2 );


  /*--------------------------------
  Atualiza os códigos totalizadores
  ---------------------------------*/
          
  update  BNF_HISIPCAP_PLANO h
  set     h.QTMESANT         = ( select SUM( QTMESANT )
                                 from   BNF_HISIPCAP_PLANO
                                 where  DTMESREF = h.DTMESREF
                                 and    NRPLA    = h.NRPLA     
                                 and    CDPAT    = sCdPatAux
                                 and    CDFUN    = h.CDFUN                            
                                 and    CDLAN    IN  ( select b.CDLAN
                                                       from   BNF_SIPCAP_CDLAN       a,
                                                              BNF_SIPCAP_TOTALIZADOR b
                                                       where  a.DTINIVIG             = dDtIniVigMax
                                                       and    a.CDLAN                = h.CDLAN
                                                       and    b.IDSIPCAPLAN          = a.IDSIPCAPLAN
                                                     )
                               ),          
          h.QTCOSMES         = ( select SUM( QTCOSMES )
                                 from   BNF_HISIPCAP_PLANO
                                 where  DTMESREF = h.DTMESREF
                                 and    NRPLA    = h.NRPLA     
                                 and    CDPAT    = sCdPatAux
                                 and    CDFUN    = h.CDFUN                            
                                 and    CDLAN    IN  ( select b.CDLAN
                                                       from   BNF_SIPCAP_CDLAN       a,
                                                              BNF_SIPCAP_TOTALIZADOR b
                                                       where  a.DTINIVIG             = dDtIniVigMax
                                                       and    a.CDLAN                = h.CDLAN
                                                       and    b.IDSIPCAPLAN          = a.IDSIPCAPLAN
                                                     )
                               ),
          h.QTCANMES         = ( select SUM( QTCANMES )
                                 from   BNF_HISIPCAP_PLANO
                                 where  DTMESREF = h.DTMESREF
                                 and    NRPLA    = h.NRPLA     
                                 and    CDPAT    = sCdPatAux
                                 and    CDFUN    = h.CDFUN                            
                                 and    CDLAN    IN  ( select b.CDLAN
                                                       from   BNF_SIPCAP_CDLAN       a,
                                                              BNF_SIPCAP_TOTALIZADOR b
                                                       where  a.DTINIVIG             = dDtIniVigMax
                                                       and    a.CDLAN                = h.CDLAN
                                                       and    b.IDSIPCAPLAN          = a.IDSIPCAPLAN
                                                     )
                               )
  where   h.DTMESREF         = psDtMesRef
  and     h.NRPLA            = sNrPlaAux
  and     h.CDPAT            = sCdPatAux
  and     h.CDFUN            = psCdFun
  and     h.CDLAN            in ( select CDLAN
                                  from   BNF_SIPCAP_CDLAN
                                  where  DTINIVIG = dDtIniVigMax
                                  -- 13/10/2022: incluídas as restrições de CDGRU e TPPOP porque os demais códigos 
                                  --             totalizadores são atualizados pelo Java no momento da geração do
                                  --             relatório
                                  -- 29/11/2022: excluída a restrição TPPOP    = 4
                                  and    CDGRU    = 3  
                                  and    TPPOP    is not null
                                  and    FLCODTOT = 'S'
                                 )
  and     h.AUUSUULTALT      = psCdUsu;


  /*------------------------------
  Insere os totais de população
  -------------------------------*/
      
  PR_BNF_GERA_HISIPCAP_POP
        ( psCdUsu, psCdFun, sCdPatAux, psNrPla, psDtMesRef, sDcErr);

  if sDcErr is not NULL then
     prsDcErr := sDcErr;
     return;
  end if;
      
   
  commit;
  

/*------------------- Tratamento de erros  */

/*exception

    when v_ErroSemRegistros then
      prsDcErr := sDcErr || ' [PR_BNF_GERA_HISIPCAP_V2] "' || SQLCODE || '"';
      rollback;
      return;

    when others then
      prsDcErr := sDcErr || ' - Erro ' || SQLCODE;
      rollback;
      return;
*/

End PR_BNF_GERA_HISIPCAP;
/
