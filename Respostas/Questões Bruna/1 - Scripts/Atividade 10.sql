/*

Mostre a soma dos salários de toda a companhia, salário médio, salário mínimo e o salário máximo.

*/

select sum(VRSPA),avg(VRSPA), min(VRSPA), max(VRSPA) from CTB_HISALARIOS
GO

/*

Qual é o primeiro sobrenome em ordem alfabética?

*/

WITH NameParts AS (
    SELECT 
        NMPAR,
        CASE 
            WHEN CHARINDEX(' ', NMPAR) > 0 
            THEN SUBSTRING(NMPAR, CHARINDEX(' ', NMPAR) + 1, LEN(NMPAR))
            ELSE NMPAR
        END AS LastName
    FROM PAR_PARTICIPANTES
)
SELECT TOP 1 LastName
FROM NameParts
ORDER BY LastName ASC
GO



/*

Quantos departamentos tem empregados?

*/


SELECT COUNT(DISTINCT e.DEPT) AS NumDepartamentosComEmpregados
FROM EMPR_ADRIANO e
WHERE e.DEPT IS not null
GO
/*

Mostre o salário médio para cada função.

*/

SELECT 
    CARGO, 
    AVG(SALARIO) AS Salario_Medio
FROM 
    EMPR_ADRIANO
GROUP BY 
    CARGO;
GO
/*

Liste a média salarial das funções onde o salário médio seja maior que $35.000.

*/

SELECT 
		CARGO, 
		AVG(SALARIO) AS Salario_Medio
FROM 
		EMPR_ADRIANO
GROUP BY 
		CARGO
HAVING 
		AVG(SALARIO) > 35000
GO
/*

Mostre o sobrenome e função dos empregados dos departamentos cujo nome inclua “PLAN”.

*/

SELECT 
    e.SOBRENOME, 
    e.CARGO
FROM 
    EMPR_ADRIANO e
JOIN 
    DEPT_ADRIANO d
ON 
    e.DEPT = d.DCODIGO
WHERE 
    d.DNOME LIKE '%PLAN%'
GO
/* 

Mostre o sobrenome e primeiro nome de todos os empregados que trabalham no mesmo departamento do Adamson.

*/

SELECT 
    e1.SOBRENOME, 
    e1.NOME
FROM 
    EMPR_ADRIANO e1
JOIN 
    EMPR_ADRIANO e2
ON 
    e1.DEPT = e2.DEPT
WHERE 
    e2.SOBRENOME = 'Adamson'
GO

/*

Produza uma lista mostrando 
departamento, 
média salarial e 
quantidade de empregados para cada 	
departamento excluindo a função “ATENDTE”.

*/

SELECT 
    d.DNOME AS Departamento,
    AVG(e.SALARIO) AS Media_Salarial,
    COUNT(e.MATR) AS Quantidade_Empregados
FROM 
    EMPR_ADRIANO e
JOIN 
    DEPT_ADRIANO d
ON 
    e.DEPT = d.DCODIGO
WHERE 
    e.CARGO <> 'ATENDTE'
GROUP BY 
    d.DNOME;
GO

/*

Exclua departamentos com menos de quatro empregados.

*/

WITH DepartamentosParaExcluir AS (
    SELECT 
        DEPT, 
        COUNT(*) AS NumeroDeEmpregados
    FROM 
        EMPR_ADRIANO
    GROUP BY 
        DEPT
    HAVING 
        COUNT(*) < 4
)

-- SELECT * FROM DepartamentosParaExcluir

DELETE FROM EMPR_ADRIANO
WHERE DEPT IN (SELECT DEPT FROM DepartamentosParaExcluir)

DELETE FROM DEPT_ADRIANO
WHERE DCODIGO IN (SELECT DEPT FROM DepartamentosParaExcluir)
GO

/*

Classifique a lista em ordem descendente de quantidade de empregados.

*/

SELECT 
    d.DNOME AS Departamento,
    AVG(e.SALARIO) AS Media_Salarial,
    COUNT(e.MATR) AS Quantidade_Empregados
FROM 
    EMPR_ADRIANO e
JOIN 
    DEPT_ADRIANO d
ON 
    e.DEPT = d.DCODIGO
WHERE 
    e.CARGO <> 'ATENDTE'
GROUP BY 
    d.DNOME
ORDER BY 
    Quantidade_Empregados DESC
GO

/*

Liste o departamento e sobrenome dos gerentes dos departamentos subordinados ao departamento D01.

*/

SELECT 
    d.DNOME AS Departamento,
    e.SOBRENOME AS Gerente_Sobrenome
FROM 
    DEPT_ADRIANO d
JOIN 
    EMPR_ADRIANO e
ON 
    d.GERENTE = e.MATR
WHERE 
    d.DSUPER = 'D01'
GO

/*

Mostre a média salarial dos homens e a média salarial das mulheres de cada departamento. 
Identifique os departamentos pelo código e pelo nome. 
Classifique o resultado em ordem descendente de salário dentro de cada departamento.

*/

SELECT 
    d.DCODIGO AS Departamento_Codigo,
    d.DNOME AS Departamento_Nome,
    e.SEXO,
    AVG(e.SALARIO) AS Media_Salarial
FROM 
    EMPR_ADRIANO e
JOIN 
    DEPT_ADRIANO d
ON 
    e.DEPT = d.DCODIGO
GROUP BY 
    d.DCODIGO,
    d.DNOME,
    e.SEXO
ORDER BY 
    d.DCODIGO,
    Media_Salarial DESC
GO

-- ALTERNATIVAMENTE 

SELECT 
    d.DCODIGO AS Departamento_Codigo,
    d.DNOME AS Departamento_Nome,
    AVG(CASE WHEN e.SEXO = 'M' THEN e.SALARIO END) AS Media_Salarial_Homens,
    AVG(CASE WHEN e.SEXO = 'F' THEN e.SALARIO END) AS Media_Salarial_Mulheres
FROM 
    EMPR_ADRIANO e
JOIN 
    DEPT_ADRIANO d
ON 
    e.DEPT = d.DCODIGO
GROUP BY 
    d.DCODIGO,
    d.DNOME
ORDER BY 
    d.DCODIGO,
    Media_Salarial_Homens DESC,
    Media_Salarial_Mulheres DESC;
