/*



Desenvolver um script que recupere os participantes que estejam contidas 
com o salário entre R$1000,00 e R$1500,00. 
E que recupere os campos Código de Fundo,
						Código de Patrocinadora, 
						Número de Inscrição, 
						Nome do Participante, 
						Descrição de Logradouro, 
						Data de Nascimento, 
						Descrição do Bairro, 
						Sigla de Unidade Federativa do Participante e 
						Valor do Salário de Participação (da tabela CTB_HISALARIOS).

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
Código da Patrocinadora, 
Descrição da Patrocinadora, 
Nome do Participante, 
Número de Matrícula, 
Número de Inscrição, 
Número de Plano, 
Descrição do Plano, 
Código da Situação do Plano e 
Descrição da Situação do Plano. 
Todos esses participantes deverão estar ordenados pelo nome, 
e todos devem ter Situação do Plano como Ativo e salário acima de R$5000,00.
Tabelas: PAR_PARPLA, PAR_PARTICIPANTES, PAR_PLANOS, PAR_SITPLANOS, PAR_PATROCINADORAS, CTB_HISALARIOS. 	
OBS* Nessa atividade a patrocinadora, plano e situação deverão estar concatenados. 
*/ 


SELECT 
    pat.CDPAT AS [Código da Patrocinadora],
    pat.DCPAT AS [Descrição da Patrocinadora],
    p.NMPAR AS [Nome do Participante],
    p.NRMAT AS [Número de Matrícula],
    pp.NRISC AS [Número de Inscrição],
    pp.NRPLA AS [Número de Plano],
    pl.DCPLA AS [Descrição do Plano],
    sp.CDSITPLA AS [Código da Situação do Plano],
    sp.DCSITPLA AS [Descrição da Situação do Plano]
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
Desenvolver um insert para os campos passíveis de serem preenchidos na tabela TREINAMENTO_Adriano 
a partir das tabelas PAR_PARTICIPANTES e CTB_HISALARIOS.
Contudo, deverá inserir apenas os 10 primeiros registros da seleção, ordenado pelo salário de forma descrescente.  
Além disso os participantes sempre devem ser Ativos.
OBS* Tudo deverá ser feito em uma mesma query. Deve-se incluir a tabela de VRSPA.
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





