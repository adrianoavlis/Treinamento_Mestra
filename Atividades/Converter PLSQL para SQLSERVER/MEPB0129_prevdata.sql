CREATE OR ALTER PROCEDURE MEPB0129(
      @PSCDFUN     CHAR(3),
      @PSCDPAT     CHAR(3),
      @PSNRPLA     CHAR(2),
      @PSDTMESREF  CHAR(6),
      @PSDCUSU     VARCHAR(255),
      @PSDCERR     VARCHAR(255) OUT
)
AS
BEGIN

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
	DECLARE @SDTMESANT				CHAR(6);
	DECLARE @STPSEXPAR				CHAR(1);
	DECLARE @SNRPLA					CHAR(2);
	DECLARE @SCDPAT					CHAR(3);
	DECLARE @SCDLAN					CHAR(5);

	DECLARE @DDTAUX					DATETIME;
	DECLARE @DDTAUX1				DATETIME;
	DECLARE @DDTULTDIAMESREF		DATETIME;

	DECLARE @NCDLAN					INT;
	DECLARE @NIDORI					INT;
	DECLARE @NNRIDA					INT;
	DECLARE @NQTPAR					INT;
	DECLARE @NQTREG					INT;

	DECLARE @SDCERR					VARCHAR(255);

	DECLARE @@C_POPULACAO CURSOR  

	--Declaracao de cursor
	SET @@C_POPULACAO = CURSOR FOR
	SELECT	1,
			ISNULL(@PSCDPAT,'999') AS CDPAT,
			ISNULL(@PSNRPLA,'99') AS NRPLA,
			DATEDIFF(MONTH,P.DTNSCPAR,@DDTULTDIAMESREF)/12,
			P.TPSEXPAR,
			COUNT(1)
	FROM	PAR_HISITPAR      H, 
			PAR_PARTICIPANTES P,
			PAR_PARPLA        A
	WHERE	H.CDFUN    = @PSCDFUN
	AND  (	H.CDPAT    = @PSCDPAT OR @PSCDPAT IS NULL)
	AND		H.NRPLA    = (  SELECT	NRPLA
							FROM	PAR_PARPLA
							WHERE	CDFUN = H.CDFUN
							AND		CDPAT = H.CDPAT
							AND		NRISC = H.NRISC
							AND		DTISCPAR = ( SELECT MAX(DTISCPAR)
												 FROM	PAR_PARPLA
												 WHERE	CDFUN = H.CDFUN
												 AND	CDPAT = H.CDPAT
												 AND	NRISC = H.NRISC)
												 AND   (NRPLA = @PSNRPLA OR @PSNRPLA IS NULL)
						 )
	AND    H.DTINISIT  =(	SELECT	MAX(DTINISIT)
							FROM	PAR_HISITPAR
							WHERE	CDFUN = H.CDFUN
							AND		CDPAT = H.CDPAT
							AND		NRISC = H.NRISC
							AND		NRPLA = H.NRPLA
							AND		DTINISIT <= @DDTULTDIAMESREF
							AND ( ( DTFIMSIT IS NULL)			  OR
								( ( DTFIMSIT >= @DDTULTDIAMESREF) OR
								   (DTSISFIM >= @DDTULTDIAMESREF)
								)
								)
							AND DTSISINI <= @DDTULTDIAMESREF
						)
	AND		H.SQSIT = (	SELECT	MAX(SQSIT)
						FROM	PAR_HISITPAR
						WHERE	CDFUN = H.CDFUN
						AND		CDPAT = H.CDPAT
						AND		NRISC = H.NRISC
						AND		NRPLA = H.NRPLA
						AND		DTINISIT = H.DTINISIT
						AND		DTINISIT <= @DDTULTDIAMESREF
						AND ( ( DTFIMSIT IS NULL)				 OR
								( (DTFIMSIT >= @DDTULTDIAMESREF) OR
								  (DTSISFIM >= @DDTULTDIAMESREF)
								)
							)
						AND DTSISINI <= @DDTULTDIAMESREF
						)
	--AND H.STISCATU IN('0','1','2')
	AND H.CDSITPLAATU IN('01','04','21','23')
	AND H.IDPARPLA = A.IDPARPLA
	--AND P.CDFUN = H.CDFUN
	--AND P.CDPAT = H.CDPAT
	--AND P.NRISC = H.NRISC
	AND P.IDPAR = A.IDPAR
	--AND  P.IDISCCTL = 'N'
	AND  ISNULL(P.IDISCCTL,'N') = 'N'
	GROUP BY DATEDIFF(MONTH,P.DTNSCPAR,@DDTULTDIAMESREF)/12, P.TPSEXPAR
	UNION
	SELECT	2, 
			ISNULL(@PSCDPAT,'999') AS CDPAT,
			ISNULL(@PSNRPLA,'99') AS NRPLA,
			DATEDIFF(MONTH,X.DTNSCPAR,@DDTULTDIAMESREF)/12,
			X.TPSEXPAR,
			COUNT(1)
	FROM	(	
				SELECT DISTINCT P.IDPAR, 
								P.DTNSCPAR,
								P.TPSEXPAR
				FROM			BNF_BNFCONCEDIDOS BC,  
								BNF_BENEFICIOS    BF,  
								BNF_BENEFICIARIOS BE,
								PAR_PARTICIPANTES P, 
								PAR_PARPLA        A
				WHERE			BC.CDFUN = @PSCDFUN
				AND			   (BC.CDPAT = @PSCDPAT OR @PSCDPAT IS NULL)
				AND				SUBSTRING((CONVERT(VARCHAR, BC.DTCOSBNF, 112)),1,6) <= @PSDTMESREF
				AND			   (BC.NRPLA = @PSNRPLA OR @PSNRPLA IS NULL)
				AND				ISNULL(BC.PRPAGUNC,0) < 100
				AND				BF.CDBNF = BC.CDBNF
				AND				BF.TPBNF IN ('AP','BP')
				AND NOT EXISTS (	SELECT 1
									FROM	BNF_BENOCOR BO
									WHERE	BO.CDFUN = BC.CDFUN
									AND		BO.NRPCSFUN = BC.NRPCSFUN
									AND	   (BO.TPOCO = 'E'
				OR
				UPPER(BO.DCMOTOCO) LIKE '%FALEC%'
				OR
				UPPER(BO.DCMOTOCO) LIKE '%ÓBITO%'
				OR
				UPPER(BO.DCMOTOCO) LIKE '%OBITO%')
				AND SUBSTRING((CONVERT(VARCHAR,BO.DTSISOCO,112)),1,6) < @PSDTMESREF
				AND BO.DTFIMOCO IS NULL)
				AND NOT EXISTS ( 
								 SELECT 1
								 FROM  BNF_BENOCOR BO
								 WHERE BO.CDFUN = BC.CDFUN
								 AND BO.NRPCSFUN = BC.NRPCSFUN
								 AND BO.TPOCO = 'E'
								 AND SUBSTRING((CONVERT(VARCHAR,BO.DTSISOCO,112)),1,6) = @PSDTMESREF
								 AND NOT EXISTS ( SELECT 1
												  FROM	 BNF_HIBENEFS HB
												  WHERE	 HB.CDFUN = BO.CDFUN
												  AND	 HB.NRPCSFUN = BO.NRPCSFUN
												  AND	 HB.DTMESREF = @PSDTMESREF )
								  )
				AND NOT EXISTS (
								SELECT	1
								FROM	BNF_BNFCONCEDIDOS
								WHERE	CDFUN       = BC.CDFUN
								AND		NRPCSFUNANT = BC.NRPCSFUN
								AND		SUBSTRING(CONVERT(VARCHAR,DTCOSBNF,112)),1,6) <= @PSDTMESREF
								)
				AND NOT EXISTS (
								SELECT	1
								FROM	BNF_HISITBNF
								WHERE	CDFUN    = BC.CDFUN
								AND		NRPCSFUN = BC.NRPCSFUN
								AND		STBNF IN('05','08')
								AND		SUBSTRING((CONVERT(VARCHAR,AUDATULTALT,112)),1,6) < @PSDTMESREF
								)
				AND BE.IDBNFCCD = BC.IDBNFCCD
				AND BC.IDPARPLA = A.IDPARPLA
				--AND P.CDFUN = BC.CDFUN
				--AND P.CDPAT = BC.CDPAT
				--AND P.NRISC = BC.NRISC
				AND P.IDPAR = A.IDPAR
				 --AND  P.IDISCCTL = 'N'
				AND  ISNULL(P.IDISCCTL,'N') = 'N'
			) X
	GROUP BY DATEDIFF(MONTH,X.DTNSCPAR,@DDTULTDIAMESREF)/12,
			 X.TPSEXPAR
	UNION
	SELECT	3, 
			ISNULL(@PSCDPAT,'999') AS CDPAT,
			ISNULL(@PSNRPLA,'99') AS NRPLA,
			DATEDIFF(MONTH,X.DTNSCDPD,@DDTULTDIAMESREF)/12, 
			X.TPSEXDPD, 
			COUNT(1)
	FROM (
			SELECT DISTINCT 
					D.IDDEP, 
					D.DTNSCDPD, 
					D.TPSEXDPD
			FROM	BNF_BENEFICIARIOS BE, 
					BNF_BNFCONCEDIDOS BC, 
					PAR_DEPENDENTES   D, 
					PAR_PARTICIPANTES P, 
					PAR_PARPLA        A
			WHERE	BE.CDFUN = @PSCDFUN
			AND	   (BC.CDPAT = @PSCDPAT OR @PSCDPAT IS NULL)
			AND    (BC.NRPLA = @PSNRPLA OR @PSNRPLA IS NULL)
			AND		BE.SQBEN > 0
			--AND SUBSTRING(REPLACE(STR(BE.DTSISINC),'-',''),1,6) <= PSDTMESREF
			--AND CONVERT(CHAR(6),BE.DTSISINC,112) <= PSDTMESREF
			AND SUBSTRING(CONVERT(VARCHAR,BE.DTCOSBNF,112),1,6) <= @PSDTMESREF
			AND NOT EXISTS (
								SELECT	1
								FROM	BNF_BENOCOR BO
								WHERE	BO.CDFUN = BE.CDFUN
								AND		BO.NRPCSFUN = BE.NRPCSFUN
								AND		BO.SQBEN = BE.SQBEN
								AND	   (
											BO.TPOCO = 'E'
											OR
											UPPER(BO.DCMOTOCO) LIKE '%FALEC%'
											OR
											UPPER(BO.DCMOTOCO) LIKE '%ÓBITO%'
											OR
											UPPER(BO.DCMOTOCO) LIKE '%OBITO%'
										)
								--AND SUBSTRING(REPLACE(STR(BO.DTSISOCO),'-',''),1,6) < PSDTMESREF
								AND		SUBSTRING(CONVERT(VARCHAR,BO.DTSISOCO, 112),1,6) < @PSDTMESREF
								AND		BO.DTFIMOCO IS NULL
							)
			AND NOT EXISTS (
								SELECT	1
								FROM	BNF_BENOCOR BO
								WHERE	BO.CDFUN = BE.CDFUN
								AND		BO.NRPCSFUN = BE.NRPCSFUN
								AND		BO.SQBEN = BE.SQBEN
								AND		BO.TPOCO = 'E'
								--AND SUBSTRING(REPLACE(STRING(BO.DTSISOCO),'-',''),1,6) = PSDTMESREF
								AND SUBSTRING(CONVERT(VARCHAR,BO.DTSISOCO,112),1,6) = @PSDTMESREF
								AND NOT EXISTS (
													SELECT	1
													FROM	BNF_HIBENEFS HB
													WHERE	HB.CDFUN    = BO.CDFUN
													AND		HB.NRPCSFUN = BO.NRPCSFUN
													AND		HB.DTMESREF = @PSDTMESREF
											   )
							)
					AND BC.CDFUN = BE.CDFUN
					AND BC.NRPCSFUN = BE.NRPCSFUN
					AND BC.IDPARPLA = A.IDPARPLA
					--AND P.CDFUN = BC.CDFUN
					--AND P.CDPAT = BC.CDPAT
					--AND P.NRISC = BC.NRISC
					AND P.IDPAR = A.IDPAR
					 --AND  P.IDISCCTL = 'N'
					AND  ISNULL(P.IDISCCTL,'N') = 'N'
					AND D.CDFUN = P.CDFUN
					AND D.CDPAT = P.CDPAT
					AND D.NRMAT = P.NRMAT
					AND D.SQDPD = BE.SQBEN 
			) X
	GROUP BY DATEDIFF(MONTH,X.DTNSCDPD,@DDTULTDIAMESREF)/12,  
			 X.TPSEXDPD;

	EXECUTE dbo.PR_BNF_GERA_HISIPCAP 
	@PSCDFUN, @PSCDPAT, @PSNRPLA, @PSDTMESREF, @PSDCUSU,  @PSDCERR OUTPUT    
   
	SET @SDCERR = 'Erro ao calcular data';

	--Calcular a ultima data do mes de referencia
	--22/11/2018 Danielson
	--DDTAUX1 = SUBSTRING(@PSDTMESREF,1,4) + '-' + SUBSTRING(PSDTMESREF,5,2) + '-' + '01-00.00.00';
	SET @DDTAUX1 = CONVERT(DATETIME,CONVERT(VARCHAR(10),SUBSTRING(@PSDTMESREF,1,4)+'-'+SUBSTRING(@PSDTMESREF,5,2)+'-'+'01-00.00.00',110))
  
	EXECUTE MEPG0002
	@DDTAUX1

	SET @DDTULTDIAMESREF = @DDTAUX1;

	IF (@PSDTMESREF >= '202001')
	BEGIN   
		SET @SDCERR = 'Erro ao limpar tabela SIPCAP';
    
		DELETE
		FROM  BNF_HISIPCAP_PLANO
		WHERE CDFUN = @PSCDFUN
		AND  (CDPAT = @PSCDPAT OR (CDPAT = '999' AND @PSCDPAT IS NULL))
		AND  (NRPLA = @PSNRPLA OR (NRPLA = '99' AND @PSNRPLA IS NULL))
		AND  DTMESREF = @PSDTMESREF;

		SET @SDCERR = 'Erro ao limpar tabela temporaria SIPCAP';

		/*	DELETE
			BNF_T_HISIPCAP_PLANO
			WHERE CDFUN = PSCDFUN
			AND  (CDPAT = PSCDPAT OR (CDPAT = '999' AND PSCDPAT IS NULL))
			AND  (NRPLA = PSNRPLA OR (NRPLA = '99' AND PSNRPLA IS NULL))
			AND  DTMESREF = PSDTMESREF;
		*/

    -- Executa procedimento que identifica as entradas e saídas do mes
    SET @SDCERR = 'Erro ao calcular mês anterior';
    SET @DDTAUX = DATEADD(MONTH, -1, @DDTAUX1);

    /* 13/08/2010: Alterado a forma como estava recuperando o mês anterior pois
    não estava gerando corretamente e os dados não estavam sendo gerados */
    --SET SDTMESANT = SUBSTRING(REPLACE(CONVERT(CHAR(20),DDTAUX),'-',''),1,6)

    IF (SUBSTRING(@PSDTMESREF,5,2) = '01')
	BEGIN
		SET @SDTMESANT = @PSDTMESREF - 89;
    END
    ELSE 
	BEGIN
       SET @SDTMESANT = @PSDTMESREF - 1;
    END 

    SET @SDCERR = 'Erro ao executar procedure MEPB0131';
    
	-- MEPB0131 (PSCDFUN,PSCDPAT,PSNRPLA,PSDTMESREF,SDTMESANT, PSDCUSU, SDCERR);    

    IF (@SDCERR <> 'OK')
	BEGIN
       SET @PSDCERR = @SDCERR;
          GOTO SAIDA;
    END 

    SET @SDCERR = 'Erro ao executar procedure MEPB0132';
    -- MEPB0132 (PSCDFUN,PSCDPAT,PSNRPLA,PSDTMESREF,SDTMESANT, PSDCUSU, SDCERR);

    IF (@SDCERR <> 'OK')
	BEGIN
		SET @PSDCERR = @SDCERR;
		GOTO SAIDA;
    END 

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

	IF (@PSDTMESREF = '200807')
	BEGIN
		SET @SDCERR = 'Erro ao executar procedure MEPB0134';
		EXECUTE dbo.MEPB0134 
		@PSCDFUN,@PSCDPAT,@PSNRPLA,@PSDTMESREF,@SDCERR
    END 

	IF (@SDCERR <> 'OK') 
	BEGIN
		SET @PSDCERR = @SDCERR;
		GOTO SAIDA;
	END
	ELSE 
	BEGIN
		SET @SDCERR = 'Erro na inclusão dos totais do mês anterior';
                 
		/* 13/08/2010: Ajustada a query que recupera os dados do mês anterior
		para quando o patrocinador e plano não forem informados */
		/*

		INSERT INTO BNF_HISIPCAP_PLANO
		(CDFUN,      NRPLA,		 DTMESREF,    
		 CDLAN,      QTCOSMES,   QTCANMES,
		 QTMESANT,   CDPAT,      AUUSUULTALT,  
		 AUDATULTALT,   AUVERREGATL )
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
        ( --IDHISSIPCAPPLA,
          CDFUN,      
		  NRPLA,    
		  DTMESREF,     
		  CDLAN,         
		  QTCOSMES,    
		  QTCANMES,
          QTMESANT,    
		  CDPAT,    
		  AUUSUULTALT,  
		  AUDATULTALT,   
		  AUVERREGATL
          )
        SELECT	--IDHISSIPCAPPLA,
	      @PSCDFUN,   
		  ISNULL(@PSNRPLA,'99'),
          @PSDTMESREF,
          CDLAN,
          0,
          0,
          CASE 
			WHEN CDLAN = '24100' THEN ABS(QTMESANT+QTCANMES) 
			ELSE ABS(QTMESANT+QTCOSMES -QTCANMES) 
		  END,
          ISNULL(@PSCDPAT,'999'),
          @PSDCUSU,
          GETDATE(),
          1
          FROM		BNF_HISIPCAP_PLANO
          WHERE		CDFUN = @PSCDFUN
		  AND		(
						(CDPAT = '999' AND @PSCDPAT IS NULL)
						OR
                        (CDPAT = @PSCDPAT)
					)
          AND		(
						(NRPLA = '99' AND @PSNRPLA IS NULL)
						OR
                        (NRPLA = @PSNRPLA)
					)
		  AND		DTMESREF = @SDTMESANT;
	END 

	--Incluido para tratamento da 1ª vez do codigo
	
	/*INSERT INTO BNF_HISIPCAP_PLANO
      ( --idhissipcappla,
        CDFUN,      NRPLA,   DTMESREF,       CDLAN,          QTCOSMES,     QTCANMES,
        QTMESANT,   CDPAT,   AUUSUULTALT,    AUDATULTALT,    AUVERREGATL
        )
	  SELECT --sq_pvdat_bnf_hisipcap_plano.nextval, 
			 x.*
      FROM
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
            FROM	(
						SELECT	A.CDLAN
						FROM	BNF_T_HISIPCAP_PLANO A
						WHERE	A.CDFUN    = PSCDFUN
						AND		A.DTMESREF = PSDTMESREF
						AND    (
									(A.CDPAT  = '999' AND PSCDPAT IS NULL)
									OR
									(A.CDPAT = PSCDPAT)
								)
						AND (
								(A.NRPLA = '99' AND PSNRPLA IS NULL)
								OR
								(A.NRPLA = PSNRPLA)
							)
						AND  NOT EXISTS ( SELECT	1 AS SWA_ColAl
										  FROM		BNF_HISIPCAP_PLANO
										  WHERE		CDFUN = A.CDFUN
										  AND		NRPLA = A.NRPLA
										  AND		DTMESREF = A.DTMESREF
										  AND		CDLAN = A.CDLAN)
										 ) B
            ) X;
			*/

	/*-----------------------------------------------------------------
	Zera os totais do mes anterior em caso de inicio de ano (MES = 01)
	------------------------------------------------------------------*/
	/* 19/08/2010 - Zerar a quantidade anterior quando o mês for Janeiro para os códigos específicos */
	IF SUBSTRING(@PSDTMESREF,5,2) = '01' 
	BEGIN
		UPDATE	BNF_HISIPCAP_PLANO
        SET		QTMESANT = 0
        WHERE	CDFUN = @PSCDFUN
        AND  (
				(CDPAT = '999' AND @PSCDPAT IS NULL)
                OR
                (CDPAT = @PSCDPAT)
			  )
        AND  (
				(NRPLA = '99' AND @PSNRPLA IS NULL)
                OR
                (NRPLA = @PSNRPLA)
			  )
        AND  DTMESREF = @PSDTMESREF
        AND  CDLAN IN ('16000','13000','15000','23000','24100','24200');
	END 

            --Atualiza os totais do mes
            SET @SDCERR = 'Erro na atualização dos totais de entradas do mês';

            IF (@PSCDPAT IS NULL)
			BEGIN
				/*
				UPDATE BNF_HISIPCAP_PLANO H
				SET (QTCOSMES) = (SELECT	COUNT(DISTINCT NRISC+TO_CHAR(SQDPD))
                                  FROM		BNF_T_HISIPCAP_PLANO
                                  WHERE		CDFUN = H.CDFUN
                                  AND		CDPAT = H.CDPAT
                                  AND		NRPLA = H.NRPLA
                                  AND		DTMESREF = H.DTMESREF
                                  AND		CDLAN = H.CDLAN
                                  AND		TPMOV = 1)
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
							AND TPMOV = 1);
							*/

			SET @SDCERR = 'Erro na atualização dos totais de saídas do mês(1)';
                 /* SQLINES DEMO *** AP_PLANO H
                  SET QTCANMES =( SELECT COUNT(DISTINCT NRISC+TO_CHAR(SQDPD))
                                                  FROM  BNF_T_HISIPCAP_PLANO
                                                  WHERE CDFUN = H.CDFUN
                                                  AND CDPAT = H.CDPAT
                                                  AND NRPLA = H.NRPLA
                                                  AND DTMESREF = H.DTMESREF
                                                  AND CDLAN = H.CDLAN
                                                  AND TPMOV = 2)
                  WHERE H.CDFUN = PSCDFUN
                  *AND H.CDPAT = '999'
                  AND H.NRPLA = '99'*
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
                              
			END
            ELSE 
			BEGIN
              
               /* SQLINES DEMO *** AP_PLANO H
                  SET QTCOSMES = (SELECT COUNT(DISTINCT NRISC+TO_CHAR(SQDPD))
                          FROM  BNF_T_HISIPCAP_PLANO
                          WHERE CDFUN = H.CDFUN
                          AND CDPAT = PSCDPAT
                          AND NRPLA = H.NRPLA
                          AND DTMESREF = H.DTMESREF
                          AND CDLAN = H.CDLAN
                          AND TPMOV = 1)
                  WHERE H.CDFUN = PSCDFUN
                  *AND H.CDPAT = PSCDPAT
                  AND H.NRPLA = PSNRPLA*
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


               SET @SDCERR = 'Erro na atualização dos totais de saídas do mês(2)';
                /* SQLINES DEMO *** PCAP_PLANO H
                  SET QTCANMES =( SELECT COUNT(DISTINCT NRISC+TO_CHAR(SQDPD))
                          FROM  BNF_T_HISIPCAP_PLANO
                          WHERE CDFUN = H.CDFUN
                          AND CDPAT = PSCDPAT
                          AND NRPLA = H.NRPLA
                          AND DTMESREF = H.DTMESREF
                          AND CDLAN = H.CDLAN
                          AND TPMOV = 2)
                  WHERE H.CDFUN = PSCDFUN
                  *AND (H.CDPAT = PSCDPAT OR PSCDPAT IS NULL)
                  AND H.NRPLA = PSNRPLA*
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
            END 

            SET @SDCERR = 'Erro ao abrir cursor @C_POPULACAO';
            OPEN @C_POPULACAO;

            SET @SDCERR = 'Erro primeiro fetch cursor @C_POPULACAO';
            FETCH @C_POPULACAO
            INTO @NIDORI,@SCDPAT,@SNRPLA,@NNRIDA,@STPSEXPAR,@NQTPAR;

            WHILE @@FETCH_STATUS = 0--@C_POPULACAO%FOUND 
			BEGIN
               SET @SDCERR = 'Erro ao recuperar o código';
                  -- Calcular código
                  IF @NIDORI = 1 
				  BEGIN
                     SET @NCDLAN = 41000;
                  END
                  ELSE 
				  BEGIN
                     IF @NIDORI = 2 
					 BEGIN
                           SET @NCDLAN = 42000;
                        END
                        ELSE 
						BEGIN
                           SET @NCDLAN = 43000;
                        END 
                  END 

                  IF @NNRIDA <= 24 
				  BEGIN
                     SET @SCDLAN = CONVERT(VARCHAR, @NCDLAN+100);
                  END
                  ELSE BEGIN
                     IF @NNRIDA <= 34 
					 BEGIN
                           SET @SCDLAN = CONVERT(VARCHAR, @NCDLAN+200);
                        END
                        ELSE BEGIN
                           IF @NNRIDA <= 54 
						   BEGIN
                                 SET @SCDLAN = CONVERT(VARCHAR, @NCDLAN+300);
                              END
                              ELSE BEGIN
                                 IF @NNRIDA <= 64 
								 BEGIN
                                       SET @SCDLAN = CONVERT(VARCHAR, @NCDLAN+400);
                                    END
                                    ELSE BEGIN
                                       IF @NNRIDA <= 74 
									   BEGIN
                                             SET @SCDLAN = CONVERT(VARCHAR, @NCDLAN+500);
                                          END
                                          ELSE BEGIN
                                             IF @NNRIDA <= 84 
											 BEGIN
                                                   SET @SCDLAN = CONVERT(VARCHAR, @NCDLAN+600);
                                                END
                                                ELSE 
												BEGIN
                                                   SET @SCDLAN = CONVERT(VARCHAR, @NCDLAN+700);
                                                END 
                                          END 
                                    END 
                              END 
                        END 
                  END 

                  SET @SDCERR = 'Erro ao recuperar BNF_HISIPCAP_PLANO';

                  SELECT @NQTREG = COUNT(1)
				 FROM  BNF_HISIPCAP_PLANO
				 WHERE CDFUN = @PSCDFUN

         /* SQLINES DEMO *** AT
         AND   NRPLA = SNRPLA*/
         AND  ((CDPAT = '999' AND @SCDPAT IS NULL)
              OR
              (CDPAT = @SCDPAT))
         AND  ((NRPLA = '99' AND @SNRPLA IS NULL)
              OR
              (NRPLA = @SNRPLA))
         AND  DTMESREF = @PSDTMESREF
         AND  CDLAN = @SCDLAN;

                  IF @NQTREG = 0 BEGIN
                     SET @SDCERR = 'Erro ao inserir BNF_HISIPCAP_PLANO';
                        -- SQLINES LICENSE FOR EVALUATION USE ONLY
                        INSERT INTO BNF_HISIPCAP_PLANO
                             (
                              CDFUN,         NRPLA,      DTMESREF,      CDLAN,
                              QTSEXMAS,      QTSEXFEM,   CDPAT,         AUUSUULTALT,
                              AUDATULTALT,   AUVERREGATL)
                        VALUES
                            (
                            @PSCDFUN,       @SNRPLA,     @PSDTMESREF,    @SCDLAN,
                            CASE @STPSEXPAR WHEN 'M' THEN @NQTPAR ELSE 0 END,
                            CASE @STPSEXPAR WHEN 'F' THEN @NQTPAR ELSE 0 END,
                            @SCDPAT,         @PSDCUSU,    GETDATE(),       1);
                  END
                  ELSE BEGIN
                     SET @SDCERR = 'Erro ao atualizar BNF_HISIPCAP_PLANO';
                        IF @STPSEXPAR = 'M' BEGIN
               UPDATE  BNF_HISIPCAP_PLANO
               SET QTSEXMAS = isnull(QTSEXMAS,0)+ @NQTPAR,
                   QTSEXFEM = isnull(QTSEXFEM,0)
               WHERE CDFUN = @PSCDFUN
               AND   CDPAT = @SCDPAT
               AND   NRPLA = @SNRPLA
               AND   DTMESREF = @PSDTMESREF
               AND   CDLAN = @SCDLAN;
            END
            ELSE BEGIN
               UPDATE BNF_HISIPCAP_PLANO
                              SET QTSEXFEM = isnull(QTSEXFEM,0)+ @NQTPAR,
                                    QTSEXMAS = isnull(QTSEXMAS,0)
                              WHERE CDFUN = @PSCDFUN
                              AND   CDPAT = @SCDPAT
                              AND   NRPLA = @SNRPLA
                              AND   DTMESREF = @PSDTMESREF
                              AND   CDLAN = @SCDLAN;
                        END 
                  END 

                  SET @SDCERR = 'Erro fetch dentro do loop cursor @C_POPULACAO';
               FETCH @C_POPULACAO
               INTO @NIDORI,@SCDPAT,@SNRPLA,@NNRIDA,@STPSEXPAR,@NQTPAR;
            END;
            SET @SDCERR = 'Erro ao fechar cursor @C_POPULACAO';
            CLOSE @C_POPULACAO;
            DEALLOCATE @C_POPULACAO;
  
  END
  ELSE 
  BEGIN  
    
    SET @PSDCERR = 'Processamento permitido apenas a partir do mês 01/2020.';
    RETURN;
    
  END 
      
      
      

 SET @SDCERR = 'OK';

   <<SAIDA>>
   SET @PSDCERR = @SDCERR;

EXCEPTION
   WHEN others THEN
      SET @PSDCERR = @SDCERR;


END;
