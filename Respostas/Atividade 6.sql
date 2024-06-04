/*



Desenvolver um script que recupere os participantes que estejam contidas 
com o sal�rio entre R$1000,00 e R$1500,00. 
E que recupere os campos C�digo de Fundo,
						C�digo de Patrocinadora, 
						N�mero de Inscri��o, 
						Nome do Participante, 
						Descri��o de Logradouro, 
						Data de Nascimento, 
						Descri��o do Bairro, 
						Sigla de Unidade Federativa do Participante e 
						Valor do Sal�rio de Participa��o (da tabela CTB_HISALARIOS).

*/

select	p.CDFUN,
		p.CDPAT,
		p.NRISC,
		p.DCLOGCSP,
		p.DTNSCPAR,
		p.DCBAIPAR,
		p.SGUFSPAR,
		ctb.VRSPA

from PAR_PARTICIPANTES p 

JOIN CTB_HISALARIOS ctb ON ctb.NRMAT = p.NRMAT

where ctb.VRSPA between 1000 and 1500

order by ctb.VRSPA
go

----------------------------------------------------------------------------------------------------
/*
Criar um script com inner join que recupere o 
C�digo da Patrocinadora, 
Descri��o da Patrocinadora, 
Nome do Participante, 
N�mero de Matr�cula, 
N�mero de Inscri��o, 
N�mero de Plano, 
Descri��o do Plano, 
C�digo da Situa��o do Plano e 
Descri��o da Situa��o do Plano. 
Todos esses participantes dever�o estar ordenados pelo nome, 
e todos devem ter Situa��o do Plano como Ativo e sal�rio acima de R$5000,00.
Tabelas: PAR_PARPLA, PAR_PARTICIPANTES, PAR_PLANOS, PAR_SITPLANOS, PAR_PATROCINADORAS, CTB_HISALARIOS. 	
OBS* Nessa atividade a patrocinadora, plano e situa��o dever�o estar concatenados. 
*/ 


SELECT 
    pat.CDPAT AS [C�digo da Patrocinadora],
    pat.DCPAT AS [Descri��o da Patrocinadora],
    p.NMPAR AS [Nome do Participante],
    p.NRMAT AS [N�mero de Matr�cula],
    pp.NRISC AS [N�mero de Inscri��o],
    pp.NRPLA AS [N�mero de Plano],
    pl.DCPLA AS [Descri��o do Plano],
    sp.CDSITPLA AS [C�digo da Situa��o do Plano],
    sp.DCSITPLA AS [Descri��o da Situa��o do Plano]
FROM 
    PAR_PARTICIPANTES p
INNER JOIN 
    PAR_PARPLA pp ON p.NRISC = pp.NRISC
INNER JOIN 
    PAR_PLANOS pl ON pp.NRPLA = pl.NRPLA
INNER JOIN 
    PAR_SITPLANOS sp ON pp.CDSITPLA = sp.CDSITPLA
INNER JOIN 
    PAR_PATROCINADORAS pat ON pp.CDPAT = pat.CDPAT
INNER JOIN 
    CTB_HISALARIOS hs ON p.NRMAT = hs.NRMAT
WHERE 
    sp.DCSITPLA = 'Ativo'
    AND hs.VRSPA > 5000.00
ORDER BY 
    p.NMPAR;
GO


----------------------------------------------------------------------------------------------------
/*
Desenvolver um insert para os campos pass�veis de serem preenchidos na tabela TREINAMENTO_Adriano 
a partir das tabelas PAR_PARTICIPANTES e CTB_HISALARIOS.
Contudo, dever� inserir apenas os 10 primeiros registros da sele��o, ordenado pelo sal�rio de forma descrescente.  
Al�m disso os participantes sempre devem ser Ativos.
OBS* Tudo dever� ser feito em uma mesma query. Deve-se incluir a tabela de VRSPA.
*/


insert into Treinamento_Adriano(
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
	p.CDFUN, 
	p.CDPAT,
	pla.NRPLA,
    p.NRISC,
    p.NMPAR,
	p.DCLOGPAR, 
    p.DTNSCPAR AS DTNSC,
    hs.VRSPA AS VRSAL
FROM 
    PAR_PARTICIPANTES p
INNER JOIN 
    CTB_HISALARIOS hs ON p.NRMAT = hs.NRMAT
INNER JOIN
	PAR_PARPLA pla ON pla.NRMAT =p.NRMAT
WHERE 
    pla.CDSITPLA = 1 
ORDER BY 
    hs.VRSPA DESC


select * from Treinamento_Adriano
GO





