 /*
 1) Criar as seguintes tabelas de acordo com a estrutura abaixo:

    • EMPR	(Tabela Empregados)
    • DEPT	(Tabela Departamentos)
    • PROJETO (Tabela Projetos) 
 */



 CREATE TABLE EMPR_ADRIANO (
     MATR		CHAR(6) NOT NULL,
     NOME		VARCHAR(12) NOT NULL,
     SOBRENOME	VARCHAR(15) NOT NULL,
     DEPT		CHAR(3),
     FONE		CHAR(14),
	 DINANDIM	DATETIME,
	 CARGO		CHAR(100),
	 NIVELED	INT,
	 SEXO		CHAR(1),
	 DATANAS	DATETIME,
	 SALARIO	DECIMAL(12,2),
	 BONUS		DECIMAL(12,2),
	 COMIS		DECIMAL(12,2)
)

CREATE TABLE DEPT_ADRIANO(
	DCODIGO	CHAR (3) NOT NULL,	
	DNOME	VARCHAR(36) NOT NULL,
	GERENTE	CHAR(6),
	DSUPER	CHAR(3)
)



CREATE TABLE PROJETO_ADRIANO(
	PCODIGO	CHAR(6) NOT NULL,
	PNOME	VARCHAR(24) NOT NULL,
	DCODIGO	CHAR(3) NOT NULL,
	RESP	CHAR(6) NOT NULL,
	EQUIPE	INT,
	DATAINI	DATETIME,
	DATAFIM DATETIME,
	PSUPER CHAR(6)
)
 go


--	TABELAS POPULADAS

-- Selects tabelas

select * from EMPR_ADRIANO
select * from DEPT_ADRIANO
select * from PROJETO_ADRIANO
GO 

SP_HELP EMPR_ADRIANO
SP_HELP DEPT_ADRIANO
SP_HELP PROJETO_ADRIANO
GO


/* 

Mostre o sobrenome, 
primeiro nome, 
departamentos, 
data de nascimento, 
data de admissão e 
salário de 
todos os empregados que ganham mais que $30.000 por ano.

*/

SELECT 
		NOME,
		SOBRENOME,
		DEPT,
		DATANAS,
		DINANDIM, 
		SALARIO
FROM	EMPR_ADRIANO

WHERE	30000 < (SALARIO)

ORDER BY SALARIO
GO

--------------------------------------------------------------------------------------------
/*

Liste todas as informações de qualquer departamento cujo gerente seja desconhecido.

*/

SELECT	* 
FROM	dept_adriano 
WHERE	GERENTE IS NULL
GO

--------------------------------------------------------------------------------------------
/*

Mostre o sobrenome, 
primeiro nome, 
departamento, 
data de nascimento, 
data de admissão e 
salário 
de todos os empregados 
que ganhem menos de $20.000 por ano. 
Classifique o resultado pelo sobrenome e primeiro nome.

*/

SELECT	SOBRENOME,
		NOME,
		DEPT,
		DATANAS,
		DINANDIM, 
		SALARIO
FROM	EMPR_ADRIANO
WHERE	SALARIO < 20000
ORDER BY SOBRENOME, NOME 
GO

--------------------------------------------------------------------------------------------
/*

Liste tudo sobre os departamentos subordinados ao departamento A00.

*/

SELECT	* 
FROM	DEPT_ADRIANO 
WHERE	DSUPER = 'A00'
GO

--------------------------------------------------------------------------------------------
/*

Liste o código e o nome dos departamento que apresentam “SERVIÇO” compondo seu nome.

*/

SELECT	* 
FROM	DEPT_ADRIANO 
WHERE	DNOME LIKE '%SERVIÇO%'
GO

--------------------------------------------------------------------------------------------
/*

Mostre a matricula, sobrenome, departamento e telefone dos empregados 
cujo código de departamento estejam compreendidos entre D11 e D21 (inclusive).

*/

SELECT		MATR, 
			SOBRENOME, 
			DEPT,
			FONE
FROM		EMPR_ADRIANO
WHERE		DEPT BETWEEN 'D11' AND 'D21'
GO


--------------------------------------------------------------------------------------------
/*

Produza uma lista dos empregados nos departamentos B0l, C0l e D01, 

mostrando o sobrenome, 
departamento e 
rendimento (salário + comissão) 
Liste a saída em ordem descendente de rendimento dentro de cada departamento.

*/

SELECT	SOBRENOME,
		DEPT,
		SALARIO+COMIS AS CALCULADO

FROM EMPR_ADRIANO
WHERE COMIS IS NOT NULL
GO

--------------------------------------------------------------------------------------------
/*

Mostre o sobrenome, 
salário anual e 
departamento dos 
empregados 
com salário mensal maior que $3000. 
Classifique a lista pelo sobrenome.

*/

SELECT	SOBRENOME,
		SALARIO,
		DEPT

FROM EMPR_ADRIANO

WHERE SALARIO > 3000

ORDER BY SOBRENOME 
GO 

--------------------------------------------------------------------------------------------
/*

Produza uma lista de todos os empregados cujo departamento comece com “E”. 
Mostre a matricula, primeiro nome e sobrenome. Classifique pelo sobrenome.

*/

SELECT	MATR,
		NOME,
		SOBRENOME, DEPT

FROM EMPR_ADRIANO

WHERE DEPT LIKE 'E%'

ORDER BY SOBRENOME
GO

--------------------------------------------------------------------------------------------
/*

Produza uma lista dos homens cujo salário mensal seja menor do que $1600. 
Mostre a matricula, sobrenome e salário mensal. 
Classifique cm ordem descendente de salário.

*/
/*
DECLARE @MENSAL DECIMAL(12,2)
DECLARE @MATR char(10)
DECLARE @SOBRENOME VARCHAR(50)
*/

SELECT	
		MATR,
		SOBRENOME,
		SALARIO/12 AS M

FROM EMPR_ADRIANO

WHERE (SALARIO/12) < 1600

ORDER BY SALARIO DESC
GO

/*

Para cada representante de vendas (REPVENDA),
apresente a comissão em porcentagem do total de rendimento (salário, bônus e comissão). 
Liste nome e porcentagem.

*/

SELECT 
    E.NOME,
    (E.COMIS * 100/ (E.SALARIO + E.BONUS + E.COMIS))  AS PERCENTUAL_COMISSAO
FROM 
    EMPR_ADRIANO E
JOIN 
    DEPT_ADRIANO D ON E.DEPT = D.DCODIGO
WHERE 
    D.DNOME = 'REPVENDA';
GO

/*

Mostre todas as informações referentes aos departamentos “E01” e 
departamentos subordinados ao departamento “E01”.

*/

SELECT	* 

FROM	DEPT_ADRIANO

WHERE	DCODIGO='E01' OR DSUPER = 'E01'
GO

/*
Liste o sobrenome, salário, função e nível de educação de qualquer empregado que se enquadre numa
das seguintes condições:

•	Salário maior que $40.000;

•	Função gerente com nível menor que 16.
*/


SELECT 
    SOBRENOME, 
    SALARIO, 
    CARGO, 
    NIVELED
FROM 
    EMPR_ADRIANO
WHERE 
    SALARIO > 40000
    OR (CARGO = 'GERENTE' AND NIVELED <= 16);


