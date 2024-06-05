use sysprevnucleos_hom
go
/*--------------------------------------------------------------------------------------------        

Desenvolver select para recuperar os registros que tenham a data de nascimento entre 01-01-1930 e 01-01-1940.

Deverá recuperar somente as colunas CDFUN,CDPAT,NRISC,NMPAR E DTNSCPAR.( TABELA: PAR_PARTICIPANTES)

----------------------------------------------------------------------------------------------*/

SELECT CDFUN, CDPAT, NRISC, NMPAR, DTNSCPAR
FROM PAR_PARTICIPANTES
WHERE DTNSCPAR BETWEEN '1930-01-01' AND '1940-01-01';

go

/*
CDFUN CDPAT NRISC     NMPAR                                                        DTNSCPAR
----- ----- --------- ------------------------------------------------------------ -----------------------
001   001   000000018 JOHN MILNE A. FORMAN                                         1938-02-10 00:00:00.000
001   001   000000760 MAURICIO DA CUNHA DONATI                                     1931-09-22 00:00:00.000
001   001   000000786 CARLOS ALBERTO GUERREIRO                                     1931-12-04 00:00:00.000
001   001   000000885 ANAITES G B S CAMPOS                                         1936-03-23 00:00:00.000
001   001   000000984 ANTONIO NEY PEREIRA                                          1933-02-28 00:00:00.000
001   001   000000992 AUGUSTA DE CASTRO                                            1934-07-12 00:00:00.000
001   001   000001016 YOLANDA FERNANDES DA CRUZ                                    1936-03-27 00:00:00.000
001   001   000001065 RENATO DE SOUZA                                              1939-03-28 00:00:00.000
001   001   000001180 CLOVIS VERDE DELBOUX                                         1939-03-14 00:00:00.000
001   001   000001198 GERSON VIEIRA FERREIRA                                       1932-10-25 00:00:00.000

(10 linhas afetadas) */


/*--------------------------------------------------------------------------------------------        

Desenvolver select que recupere somente as inscrições (sem repetir) que estejam contidas nos filtros 

do select acima e também tenham registro na tabela CTB_HISALARIOS)

----------------------------------------------------------------------------------------------*/

SELECT DISTINCT (NRISC) 
FROM PAR_PARTICIPANTES par, CTB_HISALARIOS as ctb
WHERE DTNSCPAR BETWEEN '1930-01-01' AND '1940-01-01' AND ctb.NRMAT= par.NRMAT
go

/* 
NRISC
---------
000000125
000000141
000000158
000000208
000000265
000000349
000000760
000000786
000000984

*/

/*--------------------------------------------------------------------------------------------        

DESENVOLVER INSERT/SELECT PARA INSERIR OS 10 primeiros REGISTROS 
(outros campos além do número de inscrição que estejam no contexto da tabela) 
ACIMA NA TABELA DE TREINAMENTO com o insert usando o salário decrescente. 
A COLUNA NRPLA DEVERÁ SEMPRE INSERIR O PLANO 04 E O LOGRADOURO É NULL. 
A COLUNA CORRESPONDENTE AO SALÁRIO É VRSPA DE HISALARIOS.

----------------------------------------------------------------------------------------------*/

WITH Top10Records AS (
    SELECT TOP 10 
        par.NRISC,
        par.NMPAR,
        par.DTNSCPAR,
        ctb.VRSPA
    FROM 
        PAR_PARTICIPANTES par
    JOIN 
        CTB_HISALARIOS ctb ON ctb.NRMAT = par.NRMAT
    WHERE 
        par.DTNSCPAR BETWEEN '1930-01-01' AND '1940-01-01'
    ORDER BY 
        ctb.VRSPA DESC
)
INSERT INTO Treinamento_Adriano (
    CDFUN,
    CDPAT,
    NRPLN,
    NRISC,
    NMPAR,
	DCLOG,
    DTNSC,
    VRSAL
)
SELECT
    '001', 
    '001', 
    '04',  
    NRISC,
    NMPAR,
	null, 
    DTNSCPAR,
    VRSPA 
       
FROM 
    Top10Records;
GO


select top 100 * from Treinamento_Adriano 



-------------------------------------------------------------------------------------------- 
/*

A tabela PAR_PARPLA é uma tabela onde vemos os dados do plano dos participantes. 
Recupere as o número das incrições distintas na PAR_PARPLA

*/

select count(distinct(NRISC)) as InscricoesDistintas from PAR_PARPLA
go

/* 
InscricoesDistintas
-------------------
12317

(1 linha afetada)
*/

--------------------------------------------------------------------------------------------

/*
Desenvolver um insert trazendo os 10 primeiros registros ordenados de forma decrescente pela inscrição da tabela 
PAR_PARTICIPANTES para a tabela Treinamento_SeuNome onde: 
Código de Fundo = 001 
Código de Patrocinadora = 001
Tipo de Sexo do Participante = M

Selecionar o Código de Fundo, 
			Código de Patrocinadora, 
			Número de Inscrição, 
			Nome do Participante, 
			Descrição de Logradouro, 
			Data de Nascimento

*/

-----------------------------------------------------------------



INSERT INTO Treinamento_Adriano (
    CDFUN,
    CDPAT,
    NRPLA,
    NRISC,
    NMPAR,
    DCLOG,
    DTNSC,
    VRSAL
)
SELECT TOP 10
    '001' AS CDFUN,
    '001' AS CDPAT,
    '04' AS NRPLA,
    p.NRISC,
    p.NMPAR,
    p.DCLOGPAR AS DCLOG,
    p.DTNSCPAR AS DTNSC,
    hs.VRSPA AS VRSAL
FROM 
    PAR_PARTICIPANTES p
INNER JOIN 
    CTB_HISALARIOS hs ON p.NRMAT = hs.NRMAT
WHERE 
    p.TPSEXPAR = 'M'
ORDER BY 
    p.NRISC DESC;
GO

select * from Treinamento_Adriano 
go

sp_help Treinamento_Adriano
go