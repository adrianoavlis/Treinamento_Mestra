CREATE OR REPLACE PROCEDURE PR_BNF_GERA_XML_SIPCAP_DE
(  PSCDUSU        VARCHAR2,
   PNNRANO        SMALLINT,
   PNNRSEM        SMALLINT,
   PRSDCERR       OUT VARCHAR2
)

AS

SCDLAN            CHAR(05);
SDTMESREF         CHAR(06);
SNRPLA            CHAR(02);
SNRCNB            CHAR(10);

NCDETD            INTEGER;
NQTINI            INTEGER;

NIDAUX            SMALLINT;
NNRMES            SMALLINT;
NNRMESINI         SMALLINT;
NNRMESFIM         SMALLINT;
NQTENT            SMALLINT;
NQTSAI            SMALLINT;
NSQREG            SMALLINT;
NTPARQ            SMALLINT;

SDCEML001         VARCHAR2(100);
SDCEML002         VARCHAR2(100);
SDCEML003         VARCHAR2(100);
SDCERR            VARCHAR2(100);
STXREG            VARCHAR2(300);


CURSOR C_PLANOS
IS
SELECT 1, '99', NULL
FROM   DUAL
UNION
SELECT 2, NRPLA, NRCNB
FROM   PAR_PLANOS
WHERE  CDTIPPLA IN ('1','2')
ORDER BY 1, 2, 3;


CURSOR C_MOVIMENTACAO
IS
SELECT A.CDLAN, SUM(A.QTMESANT), SUM(A.QTCOSMES), SUM(A.QTCANMES)
FROM   BNF_HISIPCAP_PLANO A,
       BNF_SIPCAP_CDLAN   B
WHERE  A.DTMESREF         = sDTMESREF
AND    A.NRPLA            = SNRPLA
--AND    A.CDPAT            = '999'
AND    B.DTINIVIG         = ( SELECT MAX(DTINIVIG)
                              FROM   BNF_SIPCAP_CDLAN
                              WHERE  TO_CHAR( DTINIVIG, 'RRRRMM' ) <= TO_CHAR(PNNRANO) || SUBSTR(TO_CHAR(100 + NNRMESFIM),2,2))
AND    B.CDLAN            = A.CDLAN                       
AND    B.CDGRU            <> 4 
GROUP BY A.CDLAN                                                    
ORDER BY A.CDLAN;


FUNCTION FN_GRAVA_ARQUIVO(
  PNNRANO       integer,
  PNNRSEM       integer,
  PNTPARQ       integer,
  PNSQREG       in out integer,
  PSTXREG       varchar2,
  PSCDUSU       varchar2
)

  RETURN varchar2
AS

  sdcerr    varchar2(255);

BEGIN

  if PNSQREG is null then
    PNSQREG := 1;
  end if;

  sdcerr := 'Erro ao incluir registro ' || to_char(PNSQREG);

  insert into BNF_ARQ_SICADI
  (   NRANO,    NRSEM,    TPARQ,      SQREG,    TXREG,    AUUSUULTALT,  AUDATULTALT,    AUVERREGATL  )
  values
  (   PNNRANO,  PNNRSEM,  PNTPARQ,    PNSQREG,  PSTXREG,  PSCDUSU,      SYSDATE,        1);


  PNSQREG := PNSQREG + 1;

  Return 'OK';
  
  /***** Tratamento de erros. *****/
  EXCEPTION
    WHEN OTHERS THEN
         Return sdcerr;  

END FN_GRAVA_ARQUIVO;


BEGIN
  

NTPARQ := 1;
  
IF PNNRSEM = 1 THEN
  NNRMESINI := 1;
  NNRMESFIM := 6;
ELSE
  NNRMESINI := 7;
  NNRMESFIM := 12;
END IF;


DELETE
FROM   BNF_ARQ_SICADI
WHERE  NRANO   = PNNRANO
AND    NRSEM   = PNNRSEM
AND    TPARQ   = NTPARQ; 


NSQREG := NULL;

STXREG := '<?xml version="1.0" encoding="UTF-8"?>';

SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

IF SDCERR <> 'OK' THEN
  PRSDCERR := SDCERR;
END IF;

STXREG := '<balancetes-estatisticos xmlns="http://arquivosemestral.xml.modelo.comum.estatistico.dataprev.gov.br" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://arquivosemestral.xml.modelo.comum.estatistico.dataprev.gov.br dadosEstatisticosSemestral.xsd ">';

SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

IF SDCERR <> 'OK' THEN
  PRSDCERR := SDCERR;
END IF;


STXREG := '<balancetes-estatisticos>';

SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

IF SDCERR <> 'OK' THEN
  PRSDCERR := SDCERR;
END IF;


STXREG := '  <entidade>' || TO_CHAR(NCDETD) || '</entidade>';

SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

IF SDCERR <> 'OK' THEN
  PRSDCERR := SDCERR;
END IF;


STXREG := '  <ano>' || TO_CHAR(PNNRANO) || '</ano>';

SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

IF SDCERR <> 'OK' THEN
  PRSDCERR := SDCERR;
END IF;


STXREG := '  <semestre>' || TO_CHAR(PNNRSEM) || '</semestre>';

SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

IF SDCERR <> 'OK' THEN
  PRSDCERR := SDCERR;
END IF;


STXREG := '  <email>' || TRIM(SDCEML001) || '</email>';

SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

IF SDCERR <> 'OK' THEN
  PRSDCERR := SDCERR;
END IF;

IF SDCEML002 IS NOT NULL THEN
  STXREG := '  <email>' || TRIM(SDCEML002) || '</email>';

  SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

  IF SDCERR <> 'OK' THEN
    PRSDCERR := SDCERR;
  END IF;
END IF;

IF SDCEML003 IS NOT NULL THEN
  STXREG := '  <email>' || TRIM(SDCEML003) || '</email>';

  SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

  IF SDCERR <> 'OK' THEN
    PRSDCERR := SDCERR;
  END IF;
END IF;


NNRMES := NNRMESINI;

WHILE NNRMES <= NNRMESFIM
LOOP
  STXREG := '  <balancete-estatistico mes="' || TO_CHAR(NNRMES) || '">';

  SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

  IF SDCERR <> 'OK' THEN
    PRSDCERR := SDCERR;
  END IF;
  
  
  OPEN C_PLANOS;
  
  FETCH C_PLANOS
  INTO  NIDAUX, SNRPLA, SNRCNB;
  
  WHILE C_PLANOS%FOUND
  LOOP
  
    IF SNRPLA = '99' THEN
      STXREG := '    <consolidado>';   
    ELSE
      STXREG := '    <plano-beneficio cnpb="' || TRIM(SNRCNB) || '">' ;   
    END IF;

    SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

    IF SDCERR <> 'OK' THEN
      PRSDCERR := SDCERR;
    END IF;
  
    
    SDTMESREF := TO_CHAR(PNNRANO) || SUBSTR(TO_CHAR(100 + NNRMES),2,2);
        
    OPEN C_MOVIMENTACAO;
    
    FETCH C_MOVIMENTACAO
    INTO  SCDLAN, NQTINI, NQTENT, NQTSAI;
    
    WHILE C_MOVIMENTACAO%FOUND
    LOOP
      
      STXREG := '      <movimentacao codigo-beneficio="' || SCDLAN || '">';

      SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

      IF SDCERR <> 'OK' THEN
        PRSDCERR := SDCERR;
      END IF;


      STXREG := '        <inicial>' || TO_CHAR(NQTINI) || '</inicial>';

      SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

      IF SDCERR <> 'OK' THEN
        PRSDCERR := SDCERR;
      END IF;


      STXREG := '        <entradas>' || TO_CHAR(NQTENT) || '</entradas>';

      SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

      IF SDCERR <> 'OK' THEN
        PRSDCERR := SDCERR;
      END IF;


      STXREG := '        <saidas>' || TO_CHAR(NQTSAI) || '</saidas>';

      SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

      IF SDCERR <> 'OK' THEN
        PRSDCERR := SDCERR;
      END IF;


      STXREG := '      </movimentacao>';

      SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

      IF SDCERR <> 'OK' THEN
        PRSDCERR := SDCERR;
      END IF;
      
      FETCH C_MOVIMENTACAO
      INTO  SCDLAN, NQTINI, NQTENT, NQTSAI;
        
    END LOOP;
    CLOSE C_MOVIMENTACAO;
    
   
    IF SNRPLA = '99' THEN
      STXREG := '    </consolidado>';     
    ELSE
      STXREG := '    </plano-beneficio>';    
    END IF;

    SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

    IF SDCERR <> 'OK' THEN
      PRSDCERR := SDCERR;
    END IF;
    
  
    FETCH C_PLANOS
    INTO  NIDAUX, SNRPLA, SNRCNB;
      
  END LOOP;
  CLOSE C_PLANOS;
  
  
  STXREG := '  </balancete-estatistico>';

  SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

  IF SDCERR <> 'OK' THEN
    PRSDCERR := SDCERR;
  END IF;
   
  NNRMES := NNRMES + 1;
  
END LOOP;   


STXREG := '</balancetes-estatisticos>';

SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

IF SDCERR <> 'OK' THEN
  PRSDCERR := SDCERR;
END IF;


STXREG := '</balancetes-estatisticos>';

SDCERR := FN_GRAVA_ARQUIVO( PNNRANO, PNNRSEM, NTPARQ, NSQREG, STXREG, PSCDUSU );

IF SDCERR <> 'OK' THEN
  PRSDCERR := SDCERR;
END IF;

PRSDCERR := 'OK';

END PR_BNF_GERA_XML_SIPCAP_DE;
/
