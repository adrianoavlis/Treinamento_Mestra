
-----------------------------------------------------------------------------------------------------
/*
1 – Crie 2 tabelas na base de homologação, PAR_PARTICIPANTES_HOJE e PAR_PARTICIPANTES_SALARIOS.

A tabela PAR_PARTICIPANTES_HOJE deverá ter os seguintes campos: 
Identificador do participante do tipo inteiro e não nulo, 
código da patrocinadora do tipo char(3) não nulo, 
matrícula do tipo char(10) não nulo, 
inscrição do tipo char(9) nulo, 
nome do tipo varchar(60) não nulo e 
tipo do sexo do participante do tipo char(1). 
A tabela PAR_PARTICIPANTES_HOJE deverá também ter o campo Identificador do Participante declarado como chave-primária. 

A tabela PAR_PARTICIPANTES_SALARIOS deverá ter os seguintes campos: 
Identificador do salário (IDSAL) do tipo inteiro não nulo, 
Identificador do participante do tipo inteiro não nulo, 
Data do Mês de Referência do tipo char(6) não nulo 
Valor do Salário (VRSPA) do tipo decimal (12,2) não nulo. 
A tabela PAR_PARTICIPANTES_SALARIOS deverá também ter o campo Identificador do Salário declarado como chave-primária e 
Identificador do Participante declarado como chave-extrangeira. 

*/

CREATE TABLE PAR_PARTICIPANTES_HOJE (
    IDPAR INT NOT NULL PRIMARY KEY,
    CDPAT CHAR(3) NOT NULL,
    NRMAT CHAR(10) NOT NULL,
    NRISC CHAR(9),
    NMPAR VARCHAR(60) NOT NULL,
    TPSEXPAR CHAR(1),
    CONSTRAINT CHK_Sexo CHECK (TPSEXPAR IN ('M', 'F'))
)


CREATE TABLE PAR_PARTICIPANTES_SALARIOS (
    IDSAL INT NOT NULL PRIMARY KEY,
    IDPAR INT NOT NULL,
    DTREF CHAR(6) NOT NULL,
    VRSPA DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (IDPAR) REFERENCES PAR_PARTICIPANTES_HOJE(IDPAR)
    ON DELETE CASCADE ON UPDATE CASCADE, -- Garante integridade referencial
    CONSTRAINT CHK_MesReferencia CHECK (DTREF LIKE '[0-9][0-9][0-9][0-9][0-1][0-9]') 
)
go


-------------------------------------------------------------------------------------------------------

-- 2 –  O próximo passo após a criação das 2 tabelas será popula-las (fazer a inserção de valores
-- nos campos criados). 

-- Tabela PAR_PARTICIPANTES_HOJE 

-- (1231, 001, 0000000100, 000002119, Neymar Junior, M) 
-- (1232, 002, 0000000101, 000002118, Lula da Silva, M)  
-- (1233, 003, 0000000102, 000002117, Dilma Lalau, M)  
-- (1234, 004, 0000000103, 000002116, Pedro Campos, M)  
-- (1235, 005, 0000000104, 000002115, Rita Guedes, M) 



-- Tabela PAR_PARTICIPANTES_SALARIOS

-- (0001, 1235, 201301, 1000.00)
-- (0002, 1234, 201305, 1500.00)
-- (0003, 1233, 201304, 1820.00)
-- (0004, 1232, 201303, 2000.00)
-- (0005, 1231, 201302, 2100.00)

BEGIN TRANSACTION;
	
INSERT INTO PAR_PARTICIPANTES_HOJE(
					IDPAR,
					CDPAT,
					NRMAT,
					NRISC,
					NMPAR,
					TPSEXPAR
)
VALUES	(1231, '001', '0000000100', '000002119', 'Neymar Junior', 'M'),
		(1232, '002', '0000000101', '000002118', 'Lula da Silva', 'M'),
		(1233, '003', '0000000102', '000002117', 'Dilma Lalau', 'M'),
		(1234, '004', '0000000103', '000002116', 'Pedro Campos', 'M'),
		(1235, '005', '0000000104', '000002115', 'Rita Guedes', 'M');


INSERT INTO PAR_PARTICIPANTES_SALARIOS(
					IDSAL, 
					IDPAR,
					DTREF,
					VRSPA
)
VALUES	
		(0001, 1235, '201301', 1000.00),
		(0002, 1234, '201305', 1500.00),
		(0003, 1233, '201304', 1820.00),
		(0004, 1232, '201303', 2000.00),
		(0005, 1231, '201302', 2100.00);

COMMIT
GO


-----------------------------------------------------------------------------------------------------

-- 3 – Após popular as 2 tabelas vocês deverá realizar algumas alterações: 

-- a) Na tabela PAR_PARTICIPANTES_HOJE alterar o sexo da Dilma Lalau e da Rita Guedes para F
-- (Feminino).

BEGIN TRANSACTION;

	UPDATE PAR_PARTICIPANTES_HOJE
	SET TPSEXPAR='F'
	WHERE NMPAR IN ('Dilma Lalau', 'Rita Guedes');

COMMIT
GO

-- b) Na tabela PAR_PARTICIPANTES_SALARIOS alterar o salário do Lula da Silva para 3200.00 e o
-- mês de referência do salário do Neymar para 201312.

BEGIN TRANSACTION

	UPDATE PAR_PARTICIPANTES_SALARIOS
		SET VRSPA=3200.00
		WHERE IDPAR='1232'

	UPDATE PAR_PARTICIPANTES_SALARIOS
		SET DTREF='201312'
		WHERE IDPAR='1231'

COMMIT
GO


-----------------------------------------------------------------------------------------------------

-- 4 – Realizadas as devidas alterações nas 2 tabelas, você deverá deletar alguns registros: 

-- a) Delete o Participante Lula da Silva.


BEGIN TRANSACTION;


DELETE FROM PAR_PARTICIPANTES_HOJE
WHERE NMPAR = 'Lula da Silva';

COMMIT
GO

-----------------------------------------------------------------------------------------------------

-- 5 – Após realizar as operações acima, faça uma consulta que retorne o Identificador do
-- Participante, a Inscrição, o Número de Matrícula, a patrocinadora do participante que tenha
-- o maior salário. 

SELECT TOP(1) p.IDPAR, p.NRISC, p.NRMAT, p.CDPAT
FROM PAR_PARTICIPANTES_HOJE p
JOIN PAR_PARTICIPANTES_SALARIOS s ON p.IDPAR = s.IDPAR
ORDER BY s.VRSPA DESC
GO


-----------------------------------------------------------------------------------------------------

-- 6 – Listar a soma e a média de todos os salários da tabela PAR_PARTICIPANTES_SALARIOS.

SELECT 
	SUM(VRSPA) AS SomaTotalSalarios,
	AVG(VRSPA) AS MediaSalarios
FROM 
	PAR_PARTICIPANTES_SALARIOS
GO


-----------------------------------------------------------------------------------------------------

-- 7 – Após realizar todas essas tarefas, salve no seu controle de treinamento e em seguida delete
-- as 2 tabelas que você criou na base de homologação.

BEGIN TRANSACTION 

DROP TABLE PAR_PARTICIPANTES_SALARIOS
DROP TABLE PAR_PARTICIPANTES_HOJE

COMMIT
GO