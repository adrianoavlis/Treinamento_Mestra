
					-- DB SysPrev Núcleos Homologação 

USE [sysprevnucleos_hom]
GO

----------------------------------------------------------------------------------------------------------------------------------------------------
 
					-- PLANOS PARTICIPANTES

 SELECT 
	 IDPLA
	,IDPLABAS
	,IDPAT
	,CDFUN
	,CDPAT
	,NRPLA
	,DCPLA
	,CDTIPPLA
	,IDPLAIPO
	,CDPLASCTPVCCPR
	,NRCNB
	,NRCNPPLA
  FROM [sysprevnucleos_hom].[dbo].[PAR_PLANOS]
go

/*
Tabela de Planos Participante

IDPLA       IDPLABAS    IDPAT       CDFUN CDPAT NRPLA DCPLA                               CDTIPPLA IDPLAIPO CDPLASCTPVCCPR NRCNB      NRCNPPLA
----------- ----------- ----------- ----- ----- ----- ----------------------------------- -------- -------- -------------- ---------- --------------
1           3           1           001   001   01    PBB - PLANO BÁSICO DE BENEFÍCIOS    1        N        1979002274     1979002274 48306580000176
2           3           2           001   002   01    PBB - PLANO BÁSICO DE BENEFÍCIOS    1        N        NULL           1979002274 48306580000176
3           3           3           001   003   01    PBB - PLANO BÁSICO DE BENEFÍCIOS    1        N        NULL           1979002274 48306580000176
4           3           4           001   004   01    PBB - PLANO BÁSICO DE BENEFÍCIOS    1        N        NULL           1979002274 48306580000176
5           3           5           002   005   09    PLANO CAN                           1        N        NULL           1979002274 NULL
6           3           1           001   001   02    NUCLEOS - ASSISTENCIAL              1        N        NULL           1979002274 NULL
8           3           1           001   001   03    PGA - PLANO ADMINISTRATIVO          4        N        NULL           1979002274 NULL
9           3           1           001   001   10    PLANO DE AJUSTE                     1        N        NULL           1979002274 NULL
10          3           1           001   001   05    PLANO CD - INB                      2        N        2021001865     2021001865 48307783000187
11          3           1           001   001   06    PLANO CD - ELETRONUCLEAR            2        N        2021000419     2021000419 48307768000139
12          3           1           001   001   07    PLANO CD - NUCLEP                   2        N        2021000338     2021000338 48307767000194
*/

----------------------------------------------------------------------------------------------------------------------------------------------------
						
						
						-- FUNDOS


select	IDFUN
		,CDFUN
		,DCFUN
from PAR_FUNDOS
go

/*

IDFUN       CDFUN DCFUN
----------- ----- ------------------------------------------------------------
1           001   NUCLEOS - INSTITUTO DE SEGURIDADE SOCIAL
2           002   CAIXA DE ASSISTENCIA DO NUCLEOS - CAN

*/

----------------------------------------------------------------------------------------------------------------------------------------------------

					-- SITUAÇÃO PLANO 


SELECT IDSITPLA , DCSITPLA
  FROM [dbo].[PAR_SITPLANOS]

GO

/*

IDSITPLA    DCSITPLA
----------- -----------------------------------
1           ATIVO
2           CANCELADO
3           AUXÍLIO-DOENÇA
4           AUTOPATROCINADO
5           AFASTADO
6           CANCELADO SEM RESGATE
8           PENSÃO
9           APOSENTADORIA-INVALIDEZ
10          APOSENTADORIA-IDADE
11          APOS-TEMPO DE CONTRIBUIÇÃO
12          APOSENTADORIA ESPECIAL
13          APOS-TEMPO DE CONTR.ANTECIPADA
14          APOS-ESPECIAL ANTECIPADA
15          AGUARDANDO BEN PROP DIF
16          AGUARDANDO RESPOSTA
17          FALECIDO
18          INVALIDEZ S/ CARÊNCIA SUPL
19          AGUARDANDO OPÇÃO
20          PORTABILIDADE
21          BPD - BENEF.PROP.DIFERIDO
22          LICENÇA SEM VENCIMENTOS
23          AUTOPATROCINIO PARCIAL
24          MIGRADO
25          ASSISTIDO FALECIDO
26          AUXILIO-DOENÇA S/CARENCIA SUPL
27          BENEFÍCIO ENCERRADO

*/  

----------------------------------------------------------------------------------------------------------------------------------------------------


					-- CATEGORIA SITUAÇÃO


SELECT TOP (1000) IDCAT
      ,STISC as situacao
      ,DCISC as descricao
      
  FROM PAR_CATEGORIA 
  go 

/*

IDCAT       situacao descricao
----------- -------- -------------------------
1           0        ATIVO
2           1        AUTOPATROCINADO
3           2        AUTOPATROCINADO PARCIAL
4           3        SUSPENSO
5           4        ASSISTIDO
6           5        DESLIGADO
7           8        MIGRADO
8           9        DIFERIDO

*/

----------------------------------------------------------------------------------------------------------------------------------------------------

							-- PARTICIPANTES-PLANOS

SELECT TOP (100) [IDPARPLA]
      ,[IDPAR] 
      ,[IDPLA] as idParticipante 
      ,[IDTIPISC] as plano 
      ,[IDSITPLACAT] as tipoInscrição
      ,[IDSITPLA] as idSituacao
      ,[CDFUN] as cdFuncionario
      ,[CDPAT] as cdPatrocinadora
      ,[NRISC] as nrInscricao
      ,[NRPLA] as nrPlano
      ,[NRMAT] as nrMatricula
      ,[DTISCPAR] as dtInscricao
      ,[CDCAT] as categoriaSituacao
      ,[CDSITPLA] as cdSituacao
      ,[STISC]as situacaoInscricao
  FROM [sysprevnucleos_hom].[dbo].[PAR_PARPLA]
  go


  /*

  23 TIPO DE SITUACAO
  2  CATEGORIA DE SITUACAO 
  
IDPARPLA    IDPAR       idParticipante plano       tipoInscrição idSituacao  cdFuncionario cdPatrocinadora nrInscricao nrPlano nrMatricula dtInscricao             categoriaSituacao cdSituacao situacaoInscricao
----------- ----------- -------------- ----------- ------------- ----------- ------------- --------------- ----------- ------- ----------- ----------------------- ----------------- ---------- -----------------
1           10364       2              2           11            11          001           002             000000596   01      0000215332  1979-09-30 00:00:00.000 F                 11         4
2           10330       2              2           8             8           001           002             000000190   01      0050020207  1979-09-30 00:00:00.000 F                 08         4
3           10338       2              2           11            11          001           002             000000281   01      0000215301  1979-09-30 00:00:00.000 F                 11         4
4           10346       4              4           13            13          001           004             000000380   01      0070000237  1979-09-30 00:00:00.000 F                 13         4
5           2266        2              2           11            11          001           002             000030353   01      0000215443  1979-11-30 00:00:00.000 F                 11         4
6           2268        1              1           11            11          001           001             000030403   01      0000000269  1979-11-30 00:00:00.000 F                 11         4
7           2280        1              1           13            13          001           001             000030551   01      0000000267  1979-11-09 00:00:00.000 F                 13         4
8           2215        2              2           11            11          001           002             000029694   01      0000215119  1979-11-30 00:00:00.000 F                 11         4
9           2216        2              2           11            11          001           002             000029702   01      0000215118  1979-11-30 00:00:00.000 F                 11         4
10          2220        1              1           11            11          001           001             000029769   01      0000000266  1979-11-22 00:00:00.000 F                 11         4

*/

----------------------------------------------------------------------------------------------------------------------------------------------------
	
							-- PARTICIPANTES

SELECT [IDPAR]
      ,[SQBEN] as sequencial_beneficiario
      ,[CDPAT] as codigo_patrocinadoras
      ,[NRMAT] as nr_matricula
      ,[NRISC] as nr_inscrição
      ,[NMPAR] as nome_participante
      ,[NMPAI] as nome_pai
      ,[NMMAE] as nome_mae
      ,[DTNSCPAR] as nasc_participante
      ,[TPSEXPAR] as sexo_participante
      ,[DCNACPAR] as nacionalidade 
      ,[DCNATPAR] as naturalidade
      ,[NRTELRESPAR] as telefone
      ,[NRRAMRESPAR] as ddd
      ,[NRTELCELPAR] as celular
      ,[CDESTCIVPAR] as estado_civil
      ,[NMCJGPAR] as nome_conjuge
      ,[NRCPFPAR] as cpf
      ,[NRIDTPAR] as identidade
      ,[NMORGEXDIDT] as org_expeditor
      ,[SGUFSIDT] as ident_UF_Sigla
      ,[DCLOGPAR] as  logradouro
      ,[NRLOGPAR] as nr_logrado
      ,[DCCPLPAR] as complemento
      ,[DCBAIPAR] as bairro
      ,[DCCIDPAR] as cidade
      ,[NRCEPPAR] as cep
      ,[SGUFSPAR] as UF
      ,[DCEMLPAR] as email
      ,[DCEMLATN] as email_alternativo
  FROM [dbo].[PAR_DADOS_ANT_RECAD]

GO

/*
IDPAR       sequencial_beneficiario codigo_patrocinadoras nr_matricula nr_inscrição nome_participante                                            nome_pai                                                     nome_mae                                                     nasc_participante       sexo_participante nacionalidade                  naturalidade                   telefone             ddd        celular              estado_civil nome_conjuge                                                 cpf         identidade    org_expeditor ident_UF_Sigla logradouro                                                   nr_logrado complemento                    bairro                         cidade                                   cep      UF   email                                         email_alternativo
----------- ----------------------- --------------------- ------------ ------------ ------------------------------------------------------------ ------------------------------------------------------------ ------------------------------------------------------------ ----------------------- ----------------- ------------------------------ ------------------------------ -------------------- ---------- -------------------- ------------ ------------------------------------------------------------ ----------- ------------- ------------- -------------- ------------------------------------------------------------ ---------- ------------------------------ ------------------------------ ---------------------------------------- -------- ---- --------------------------------------------- ---------------------------------------------
10338       0                       002                   0000215301   000000281    ROBERTO VALVERDE HOFFMANN                                    LUIZ CARLOS HOFFMANN                                         HELIA CANDIDA VALVERDE HOFFMANN                              1956-06-06 00:00:00.000 M                 BRASILEIRA                     RIO DE JANEIRO                 21 2523-4455         NULL       21 8884-2569         01           NULL                                                         38764288749 139894        CRA           RJ             RUA XAVIER LEAL                                              16         APTO 103                       IPANEMA                        RIO DE JANEIRO                           22081050 RJ   robhoff@uol.com.br                            robhoff@eletronuclear.gov.br
10346       0                       004                   0070000237   000000380    LUCIA MONTEIRO MARQUES                                       FRANCISCO TEIXEIRA MARQUES                                   ANA MONTEIRO                                                 1955-10-14 00:00:00.000 F                 BRASILEIRA                     RIO DE JANEIRO-RJ              27185407             21         96315072             02           NULL                                                         39080617768 29.527.568-9  DETRAN/RJ     RJ             AV. JOAO BRASIL                                              150        BL. 2 APTO. 308                FONSECA                        NITEROI                                  24130082 RJ   lucia-marques@hotmail.com                     
27          0                       001                   0000000135   000000901    ARSENIO FRANCO TRINDADE                                      AMANDIO MAYER TRINDADE                                       ARSENIA FRANCO TRINDADE                                      1947-07-15 00:00:00.000 M                 BRASILEIRA                     JUIZ DE FORA-MG                33541949             24         99987788             02           BEATRIZ HELENA DE CASTRO TRINDADE                            15112403691 273397059     DETRAN        RJ             MARCILIO DIAS                                                126        APTO 502                       JARDIM JALISCO                 RESENDE                                  27510080 RJ   arsenio@inb.gov.br                            
1490        0                       001                   0000000063   000019877    LUIZ CARLOS VENTURA BÁRCIA                                   OSMAR BARCIA RODRIGUES                                       ADAHIR VENTURA BARCIA RODRIGUES                              1949-06-21 00:00:00.000 M                 BRASILEIRA                     RIO DE JANEIRO-RJ              31718748             21         96465561             02           MARIA LUCIA BRANDAO BARCIA                                   34648542720 23657034      DETRAN        RJ             AV. JORNALISTA RICARDO MARINHO                               150        aptº 1207                      BARRA DA TIJUCA                RIO DE JANEIRO                           22631350 RJ   lcvbarcia@inb.gov.br                          luizcbarcia@gmail.com
2202        0                       001                   0000000268   000029538    TEREZINHA DE JESUS C. BRANCO SIRZINA                         LIVIO FERREIRA CASTELO BRANCO NETO                           HELENA FERNANDEZ CASTELO BRANCO                              1956-11-29 00:00:00.000 F                 BRASILEIRA                     RIO DE JANEIRO                 22811260             21         96212945             02           MARCUS LUIZ SIRZINA                                          50992945704 037548088     DETRAN        RJ             R. VISC. DE SANTA CRUZ                                       205        CASA 4  APTO 102               ENGENHO NOVO                   RIO DE JANEIRO                           20950340 RJ   terezinha@inb.gov.br                          sirzina@globo.com
4120        0                       002                   0000215169   000049775    OTMAR CARLOS HOLLERBACH                                      FREDERICO PAULO HOLLERBACH                                   SENTA HOLLERBACH                                             1946-01-01 00:00:00.000 M                 BRASILEIRA                     RIO DE JANEIRO                 2467-7447            NULL       21-93795571          02           JANDIRA NAVARRO DE C. HOLLERBACH                             10931643791 02082773-9    IFP-          NULL           R. PRACINHA CESÁRIO AGUIAR                                   265        NULL                           ILHA DO GOVERNADOR             RIO DE JANEIRO                           21930230 RJ   otmarh@terra.com.br                           otmarch@eletrobras.com
1100        0                       001                   0000000208   000015057    EZIO TEMPERINE                                               ANTONIO TEMPERINE                                            NAIR CARDOSO TEMPERINE                                       1959-06-12 00:00:00.000 M                 BRASILEIRA                     RIO DE JANEIRO                 21 30195931          NULL       21 99671153          02           CELIA REGINA R. S. TEMPERINE                                 62783866749 049886849     IFP           RJ             RUA ANGELA PINTO                                             235        CASA 2                         PAVUNA                         RIO DE JANEIRO                           21650010 RJ   eziotemperine@inb.gov.br                      
1119        0                       002                   0000215369   000015263    ELY RIBEIRO                                                  GERSON FERNANDES RIBEIRO                                     AIDA MENDES RIBEIRO                                          1949-09-16 00:00:00.000 M                 BRASILEIRA                     SAO PAULO                      002124640922         NULL       21 9722-3589         02           NULL                                                         26575450768 0110385-7     CRA           NULL           RUA BARONESA                                                 330 f      APTO 204                       JACAREPAGUA                    RIO DE JANEIRO                           21321000 RJ   elyrib@eletronuclear.gov.br                   NULL
329         0                       001                   0000000167   000004747    LUIZ ANTONIO MELLO                                           ANTONIO ASSIS MELLO                                          DULCE SACRAMENTO MELLO                                       1956-03-31 00:00:00.000 M                 BRASILEIRA                     RIO DE JANEIRO                 24 3352-5373         NULL       24 9813-1526         02           MARIA DO ROSARIO SILVA MELLO                                 53030265749 045139169     IFP           RJ             RUA 41                                                       53         NULL                           JD. ITATIAIA                   ITATIAIA                                 27580000 RJ   luizmello@inb.gov.br                          
4224        0                       001                   0000000414   000050831    VALDECI RIBEIRO DA SILVA                                     NULL                                                         NULL                                                         NULL                    NULL              NULL                           NULL                           24 33571182          NULL       2499985539           NULL         NULL                                                         47036630744 NULL          NULL          NULL           HOTEL FAZENDA VILA FORTE                                     s/n                                       ENG. PASSOS                    RESENDE                                  27555000 RJ                                                 NULL
7692        0                       003                   0006002403   000086165    ELISABETE BRONZATO                                           ARALDO BRONZATO FILHO                                        MARIA APARECIDA DA SILVA BRONZATO                            1973-11-04 00:00:00.000 F                 BRASILEIRA                     NULL                           3787-3543            21         7808-8027            01           NULL                                                         03248425709 0097314462    IFP/RJ        NULL           RUA ENGENHEIRO KONRAD DOOR                                   s/nº       LOTE 11 QUADRA 22              CAMPO LINDO                    SEROPÉDICA                               23845440 RJ   elisabete@nuclep.gov.br                       betebronzato@hotmail.com
4422        0                       001                   0000000431   000052852    UILTON RODRIGUES DE ARAUJO                                   MANOEL RODRIGUES DE ARAUJO                                   MARIA INES DE SENA ARAUJO                                    1953-03-14 00:00:00.000 M                 BRASILEIRA                     RIO DE JANEIRO                 33555832             24                              02           LUCIA REGINA DE ARAUJO                                       30429960778 3058016       IFP           RJ             RUA DOS EUCALIPTOS                                           342        NULL                           CIDADE ALEGRIA                 RESENDE                                  27525040 RJ                                                 
604         0                       002                   0000215385   000008235    MARCOS FABRINO RAMOS                                         EDSON FABRINO RAMOS                                          DORILA CARDOSO RAMOS                                         1949-07-06 00:00:00.000 F                 BRASILEIRA                     RIO DE JANEIRO-RJ              2611 6915            021        9640 7895            03           NULL                                                         27906124715 1005386       IFP           RJ             RUA GUARANIS                                                 61         CASA                           SAO FRANCISCO                  NITEROI                                  24360390 RJ   fabrino@eletronuclear.gov.br                  
1406        0                       001                   0002006005   000018846    JOSE DE ASSIS GALV¦O DE CARVALHO                             NULL                                                         NULL                                                         NULL                    NULL              NULL                           NULL                           32430055             NULL       NULL                 NULL         NULL                                                         03975215534 NULL          NULL          NULL           ALAMEDA MURANO                                               63         ED. RESIDENCIAL MURANO 1304    PITUBA                         SALVADOR                                 41830610 BA   JASSISGCARVALHO@TERRA.COM.BR                  
4926        0                       001                   0000000458   000058198    ADALBERTO DA COSTA FARIA                                     ANTONIO CARDOSO FARIA                                        NILZA DA COSTA FARIA                                         1960-10-10 00:00:00.000 M                 BRASILEIRA                     RIO DE JANEIRO                 NULL                 NULL       24 99827421          02           Mª CRISTINA CAETANO FARIA                                    73441520700 066791849     IFP           RJ             RUA CRISANTEMOS                                              93         CASA                           ENG. PASSOS                    RESENDE                                  27555000 RJ   NULL                                          
719         0                       002                   0000215427   000009688    CARLOS ALBERTO BRITIS                                        JOSE BRITIS                                                  NELI DAMASIO DA SILVA                                        1953-04-22 00:00:00.000 M                 BRASILEIRO                     RIO DE JANEIRO                 24 33628290          NULL       21 80001897          01           NULL                                                         41129059715 039812631     IFP           RJ             RUA CARLOS PALUT                                             359        BL. 5 - 303                    TAQUARA                        RIO DE JANEIRO                           22710310 RJ   britis@eletronuclear.gov.br                   
8861        0                       002                   0000216445   000097594    ELIANA SALGADO NOGUEIRA                                      CARLOS JOSE SALGADO                                          GEORGINA DA SILVA SALGADO                                    1963-07-23 00:00:00.000 F                 BRASILEIRA                     RIO DE JANEIRO                 00                   NULL       2194160525           05           NULL                                                         72735864715 20337272      CRA           RJ             R. CEARA                                                     17         VILA RESIDENCIAL               MAMBUCABA                      PARATY                                   23970000 RJ   eliana@eletronuclear.gov.br                   
831         0                       001                   0000000132   000011163    JOSE AUGUSTO DE C MEIRELLES                                  JOSE RANGEL MEIRELLES                                        MARIA NAZARETH DE CASTRO MEIRELLES                           1954-07-15 00:00:00.000 M                 BRASILEIRA                     GUARATINGUETA-SP               31324848             12         NULL                 02           CELIA APARECIDA DE OLIVEIRA CASTRO MEIRELLES                 88716619820 6102109X      SSP           SP             R.  ANTONIO LEMES BARBOSA                                    74         NULL                           VILA ANTUNES                   GUARATINGUETA                            12502170 SP   jmeirelles@inb.gov.br                         jacmeire@yahoo.com.br
851         0                       003                   0006000731   000011429    JOSE MARCOS FAVALESSA                                        JOSE FAVALESSA                                               AUREA ANTONIA POSSATO FAVALESSA                              1959-03-27 00:00:00.000 M                 BRASILEIRA                     ESPIRITO SANTO                 26873420             21         86664080             02           FERNANDA SCHELCK ESTEFANELLI FAVALESSA                       54738032704 046691101     IFP           RJ             RUA SANTA BARBARA                                            18         QD. 49                         BRISAMAR                       ITAGUAI                                  23825220 RJ   JFAVALESSA@TERRA.COM.BR                       
5045        0                       003                   0006001793   000059436    CLERIMAR DA SILVA MOUTTA                                     ESMAEL RODRIGUES MOUTTA                                      MARIA DA SILVA MOUTTA                                        1960-06-15 00:00:00.000 M                 BRASILEIRA                     NULL                           3158-9523            21          8874-3717           05           NULL                                                         60633514772 56963846      IFP-RJ        NULL           ESTRADA DA PEDRA                                             189        depois do campestre clube      SANTA CRUZ                     RIO DE JANEIRO                           23520241 RJ   cdmoutta@bol.com.br                           
962         0                       001                   0000000166   000013052    PAULO MENDES DE QUEIROZ                                      OZORIO MENDES DE QUEIROZ                                     CELITA MARIA DA CONCEICAO                                    1954-01-03 00:00:00.000 M                 BRASILEIRA                     RIO DE JANEIRO                 33830026             24         81166790             02           ROSANGELA SANTOS DE QUEIROZ                                  33597030734 3972020-6     I.F.P.        NULL           RUA DR. JOAO CABRAL FLECHA                                   353        NULL                           PARAISO                        RESENDE                                  27535010 RJ   pauloqueiroz@inb.gov.br                       NULL
5206        0                       002                   0000215316   000061044    MARILENE DOS SANTOS VELOSO                                   MANOEL COELHO VELOSO                                         ALDOZINDA DOS SANTOS VELOSO                                  1957-01-28 00:00:00.000 F                 BRASILEIRA                     RIO DE JANEIRO                 24 3362-5267         NULL       NULL                 05           NULL                                                         53211421734 04353967-5    IFP-RJ        NULL           RUA MARANHAO                                                 7          CASA - VILA RES. MAMBUCABA     MAMBUCABA                      PARATY                                   23970000 RJ   veloso@eletronuclear.gov.br                   
1062        0                       001                   0000000142   000014563    BEATRIZ DE PAIVA DIAS CAMPOS                                 ANTONIO DE PAIVA DIAS                                        ANESIA GOMES DOS SANTOS                                      1958-08-17 00:00:00.000 F                 BRASILEIRA                     RIO DE JANEIRO                 22267749             21         96483349             05           NULL                                                         53208960778 038025060     DETRAN        RJ             RUA EDUARDO GUINLE                                           55         BL. 2 / APTO.103               BOTAFOGO                       RIO DE JANEIRO                           22260090 RJ   biacampos@inb.gov.br                          
5353        1                       002                   0050016498   000062521    ILDA DA SILVA FURTADO                                        NULL                                                         NULL                                                         NULL                    NULL              NULL                           NULL                           1732233340           NULL       1788011336           NULL         NULL                                                         00388027754 NULL          NULL          NULL           AV. 25 DE JANEIRO                                            1463       NULL                           ANCHIETA                       SÃO JOSE DO RIO PRETO                    15050130 SP   FURTADO_ELAINE@YAHOO.COM.BR                   
1151        0                       004                   0070000202   000015685    RENATO GERALDO DA CONCEICAO                                  MANOEL GERALDO                                               MARIA JESUS DA CONCEIÇAO                                     1954-01-15 00:00:00.000 M                 BRASILEIRA                     RIO DE JANEIRO-RJ              32760996             21         96474103             01                                                                        42657890725 039758172     IFP           RJ             RUA CATULO CEARENSE                                          84         NULL                           ENG. DE DENTRO                 RIO DE JANEIRO                           20730320 RJ   rgeraldo@nucleos.com.br                       
1189        0                       001                   0000000054   000016170    WAGNER NAZARETH A DE OLIVEIRA                                HEITOR FERREIRA DE OLIVEIRA                                  DULCINEIA ANGELITO DE OLIVEIRA                               1946-09-13 00:00:00.000 M                 BRASILEIRO                     RIO DE JANEIRO                 2717-9179            21         NULL                 02           SYLVIA REGINA CABRAL S. DE OLIVEIRA                          32382570725 12592         CORECON       RJ             R. MARQUES DE CAXIAS                                         21         APTO 202 B                     CENTRO                         NITEROI                                  24030050 RJ   wagner@inb.gov.br                             
1190        0                       001                   0000000074   000016188    WALTER HENRIQUE GURSCHING                                    WALTHER ERNESTO GURSCHING                                    RAYMONDE GURSCHING                                           1939-12-27 00:00:00.000 M                 BRASILEIRA                     RIO DE JANEIRO - RJ            22663651             21         88620248             03                                                                        04505646734 017572/O-4    CRC/RJ        RJ             RUA ASSUNCAO                                                 02         BL 01/204                      BOTAFOGO                       RIO DE JANEIRO                           22251030 RJ   gursching@yahoo.com.br                        gursching@ig.com.br
1345        0                       001                   0000000768   000018119    ARIALDO DE SOUSA PEREIRA                                     ANANIAS PEREIRA ROSA                                         ANTENORA CAETANO DE SOUSA                                    1958-09-28 00:00:00.000 M                 BRASILEIRA                     RIO DE JANEIRO                 27890089             22         99187355             02           EDMA BATISTA GOMES PEREIRA                                   48269328715 043590173     IFP           RJ             PÇ. ANIBAL ABREU VIANA                                       s/n        CASA                           BUENA                          S. FRANCISCO DE ITABAPOANA               28230000 RJ   arialdo@inb.gov.br                            arialdo-pereira@bol.com.br
1512        0                       001                   0000000176   000020131    SHEILA BRASIL NERI                                           NULL                                                         NULL                                                         NULL                    NULL              NULL                           NULL                           24251805             NULL       91067658             NULL         NULL                                                         53480716768 NULL          NULL          NULL           EST. DO PAU FERRO                                            204        BL 3 APTO. 202 PECHINCHA       JACAREPAGUA                    RIO DE JANEIRO                           22743051 RJ   sheilabrasil@easyline.com.br                  brasilsheila@yahoo.com.br
1546        0                       002                   0000215099   000020552    JOSE HENRIQUE COSTA CUTRIM                                   FILINTO ELISIO CUTRIM FILHO                                  MARIA DE JESUS DA COSTA CUTRIM                               1955-12-27 00:00:00.000 M                 BRASILEIRA                     SAO LUIS-MA                    22470549             21         76978107             02           BIANCA MARTINEZ CUTRIM                                       34446400720 2001479972    CREA          RJ             AV. RAINHA ELIZABETH                                         463        APTO. 301                      IPANEMA                        RIO DE JANEIRO                           22081030 RJ   cutrim@eletronucelar.gov.br                   jhcut@hotmail.com
1559        0                       002                   0000215084   000020719    MAURICIO RONDON MIRILLI                                      GYL MIRILLI                                                  CLORY RONDON MIRILLI                                         1951-11-18 00:00:00.000 M                 BRASILEIRA                     RIO DE JANEIRO-RJ              22252112             24         98756172             02           MARIA HELENA CAMPOS MAESTRELLI                               17534305772 791044948     CREA          RJ             RUA DAS DALIAS                                               63         NULL                           ARARAS                         PETROPOLIS                               25725020 RJ   mirilli@eletronuclear.gov.br                  mrmirilli@hotmail.com
1572        0                       002                   0000215086   000020875    MARIA CAROLINA RODRIGUES SILVA                               NESTOR RODRIGUES SILVA FILHO                                 ELIZABETH RODRIGUES SILVA                                    1952-02-04 00:00:00.000 F                 BRASILEIRA                     CURITIBA-PR                    22679326             21         94767113             01           NULL                                                         40285065734 25105131      SECC          RJ             RUA RAIMUNDO CORREIA                                         19         APTO. 302                      COPACABANA                     RIO DE JANEIRO                           22411040 RJ   mcarol@eletronuclear.gov.br                   
2008        0                       002                   0000215103   000026807    LEONARDO ARAUJO DE GREGORIO                                  PAULO DE GREGORIO                                            LAURA ARAUJO DE GREGORIO                                     1953-07-07 00:00:00.000 M                 BRASILEIRA                     RIO DE JANEIRO                 27121449             21         98751859             02           LUCINIAR OLIVEIRA DE GREGORIO                                35526971791 03179753-3    IFP           RJ             RUA PEREIRA RIBEIRO                                          306        NULL                           ZE GAROTO                      SAO GONCALO                              24440080 RJ   leogreg@eletronuclear.gov.br                  
1590        0                       002                   0000215058   000021055    BEATRIZ AUGUSTA BERNARDES                                    RAYMUNDO JOSE BERNARDES                                      IVA RODRIGUES BERNARDES                                      1954-01-18 00:00:00.000 F                 BRASILEIRA                     RIO DE JANEIRO                 25277225             21         99242089             02           RONALDO LIMA SANTOS                                          43497438715 202772103     CREA          RJ             RUA  HUMAITA                                                 318        APTO 101                       HUMAITA                        RIO DE JANEIRO                           22261001 RJ   begusta@eletronuclear.gov.br                  begustard@hotmail.com
1596        0                       002                   0000215019   000021121    VERA LUCIA LOVISI MEDEIROS                                   AMANDO LOVISI                                                GESSY COSTA LOVISI                                           1953-09-19 00:00:00.000 F                 BRASILEIRA                     RIO DE JANEIRO                 22560582             21         92567354             02           MAROLDO MEDEIROS                                             42487846704 29241106      DETRAN        RJ             RUA TONELEROS                                                362        APTO 401                       COPACABANA                     RIO DE JANEIRO                           22030002 RJ   vlovisi@eletronuclear.gov.br                  vlovisi@globo.com
2010        0                       002                   0000215105   000026823    EVANDRO MAIA DA SILVA                                        JOSE ALVES DA SILVA                                          ELZA MAIA DE SA SILVA                                        1959-11-21 00:00:00.000 M                 BRASILEIRA                     RIO DE JANEIRO                 22702286             21         96256731             02           IONE FEITOSA MALAFAIA                                        59929391720 048927750     IFP           RJ             RUA JOSE ROBERTO                                             141        APTO 201                       HIGIENOPOLIS                   RIO DE JANEIRO                           21050530 RJ   esilva@eletronuclear.gov.br                   
*/


----------------------------------------------------------------------------------------------------------------------------------------------------


						-- PATROCINADORAS

SELECT TOP (1000) [IDPAT]
      ,[IDFUN] as fundos
      ,[IDUNDFED] as idUnidadeFederal
      ,[CDFUN] as cdFundos
      ,[CDPAT] as cdPatrocinadora
      ,[DCPAT] as nome
      ,[DCLOGPAT] as logradouro
      ,[NRLOGPAT] as numero
      ,[DCBAIPAT] as bairro
      ,[DCCIDPAT] as cidade 
      ,[NRCEPPAT] as cep
      ,[SGUFSPAT] as UF
      ,[NRTELPAT] as nrTelefone
      ,[DTMESREFFOL] as dataMesFolha
      ,[NRCGCPAT] as cgc
      ,[DCPATRDZ] as siglaPatrocinadora
  FROM [sysprevnucleos_hom].[dbo].[PAR_PATROCINADORAS]

  go

/*
  
IDPAT       fundos      idUnidadeFederal cdFundos cdPatrocinadora nome                                               logradouro                                              numero bairro                         cidade                                   cep      UF   nrTelefone           dataMesFolha cgc            siglaPatrocinadora
----------- ----------- ---------------- -------- --------------- -------------------------------------------------- ------------------------------------------------------- ------ ------------------------------ ---------------------------------------- -------- ---- -------------------- ------------ -------------- ------------------
1           1           20               001      001             INDUSTRIAS NUCLEARES DO BRASIL S/A                 RUA MENA BARRETO, 161                                   NULL   BOTAFOGO                       RIO DE JANEIRO                           22271100 RJ   NULL                 202205       00322818000120 INB
2           1           20               001      002             ELETROBRAS TERMONUCLEAR S/A                        RUA DA CANDELÁRIA                                       65     CENTRO                         RIO DE JANEIRO                           20091020 RJ   02125362727          202205       42540211000167 ETN
3           1           20               001      003             NUCLEBRAS EQUIPAMENTOS PESADOS S/A                 AV.GENERAL EUCLYDES DE OLIVEIRA                         NULL   BRISAMAR                       ITAGUAI                                  NULL     RJ   0XX-21-2688-1050     202205       42515882000178 NUCLEP
4           1           20               001      004             NUCLEOS- INSTITUTO DE SEGURIDADE SOCIAL            RUA RODRIGO SILVA Nº 26 - 15º ANDAR                     NULL   CENTRO                         RIO DE JANEIRO                           20011040 RJ   2139703682           202205       30022727000130 NUCLEOS
5           2           20               002      005             CAIXA DE ASSISTENCIA DO NUCLEOS - CAN              RUA MENA BARRETO, 161                                   NULL   BOTAFOGO                       RIO DE JANEIRO                           22271100 RJ   NULL                 201005       00322818000120 INB

*/


----------------------------------------------------------------------------------------------------------------------------------------------------








WITH TodasSituacoes AS (
    SELECT DISTINCT CDSITPLA
    FROM dbo.PAR_SITPLANOS
    WHERE DCSITPLA <> 'AUTOPATROCINIO PARCIAL'
),
ParticipantesComTodasSituacoes AS (
    SELECT 
        p.CodPatrocinadora,
        p.Matricula,
        p.NomeParticipante
    FROM 
        dbo.Participantes p
    WHERE 
        NOT EXISTS (
            SELECT 1 
            FROM dbo.PAR_SITPLANOS s 
            WHERE 
                p.CodPatrocinadora = s.CodPatrocinadora AND 
                p.Matricula = s.Matricula AND 
                s.DCSITPLA = 'AUTOPATROCINIO PARCIAL'
        ) 
        AND NOT EXISTS (
            SELECT 1
            FROM TodasSituacoes ts
            LEFT JOIN dbo.PAR_SITPLANOS s
            ON ts.CDSITPLA = s.CDSITPLA
            AND p.CodPatrocinadora = s.CodPatrocinadora
            AND p.Matricula = s.Matricula
            WHERE s.CDSITPLA IS NULL
        )
)
SELECT 
    p.CodPatrocinadora,
    p.Matricula,
    p.NomeParticipante
FROM 
    ParticipantesComTodasSituacoes p
ORDER BY 
    p.CodPatrocinadora,
    p.NomeParticipante;


