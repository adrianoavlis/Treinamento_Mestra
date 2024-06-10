

	-- RECUPERA TABELAS DE UMA BASE

SELECT TABLE_NAME
FROM [sysprevnucleos_hom].INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
GO

	-- Pesquisa em campo de uma tabela no sistema

SELECT COLUMN_NAME, TABLE_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%IDSITPLA%'
ORDER BY TABLE_NAME
GO


	-- ENCONTRAR DUAS COLUNAS NA MESMA TABLEA

SELECT s.TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES AS s
WHERE s.TABLE_TYPE='BASE TABLE'
AND EXISTS (SELECT 1
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME=s.TABLE_NAME AND COLUMN_NAME LIKE 'idparpla')
AND EXISTS (SELECT 1
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME=s.TABLE_NAME AND COLUMN_NAME LIKE 'CDRUB');






/*************************************** Exemplos de Querys SQL ***************************************/


----------------------------------------------CREATE----------------------------------------------

CREATE DATABASE sysprevnucleos_hom; 
use sysprevnucleos_hom;

CREATE TABLE Treinamento_Adriano2 (
     CDFUN CHAR(3) NOT NULL,
     CDPAT CHAR(3) NOT NULL,
     NRPLN CHAR(2) NOT NULL,
     NRISC CHAR(9) NOT NULL,
     NMPAR VARCHAR(60) NOT NULL,
     DCLOG VARCHAR(45) NULL,	
     VRSAL DECIMAL(12,2) NOT NULL
)
 go


select top(10) * from Treinamento_Adriano
go

----------------------------------------------

CREATE TABLE Treinamento_Adriano3 ( 
		ClienteCodigo int IDENTITY (1,1) , 
		ClienteCPF varchar(11), CONSTRAINT PK_Cliente PRIMARY KEY (ClienteCodigo,ClienteCPF) 
);
go

----------------------------------------------CREATE----------------------------------------------

CREATE TABLE Contas (
		AgenciaCodigo int,
		ContaNumero VARCHAR (10) CONSTRAINT PK_CONTA PRIMARY KEY,
		ClienteCodigo int, 
		ContaSaldo MONEY, 
		ContaAbertura datetime
		CONSTRAINT FK_CLIENTES_CONTAS FOREIGN KEY (ClienteCPF) REFERENCES Treinamento_Adriano3()
);

----------------------------------------------ALTER----------------------------------------------
ALTER TABLE Pessoas ADD PessoaSexo CHAR(2);

ALTER TABLE Contas ADD CONSTRAINT FK_CLIENTES_CONTAS FOREIGN KEY (ClienteCodigo)
REFERENCES Clientes(ClienteCodigo);

ALTER TABLE Clientes ADD CONSTRAINT TESTE CHECK ([ClienteNascimento] < GETDATE());

------------------------------------------------------
/*
INSERT Clientes (ClienteCodigo, ClienteNome) VALUES (1, 'Nome do Cliente');

CREATE TABLE Clientes (
ClienteCodigo int CONSTRAINT PK_CLIENTES PRIMARY KEY...

INSERT Clientes (colunas) VALUES (valores);

INSERT INTO Clientes SELECT * FROM ... */
--------------------------------------------------

UPDATE Treinamento_Adriano SET NRISC = 1000 WHERE CDPAT = 1;
-------------------------------------------

SELECT * FROM Clientes;
SELECT ClienteNome FROM Clientes WHERE ClienteCodigo=1;
------------------------------------------

/*
Um comando que pode auxiliar na obtenção de metadados da tabela que você deseja consultar é o comando sp_help. 

Esse comando mostrar a estrutura da tabela, seus atributos, relacionamentos e o mais importante, se ela possui índice ou não.
*/

execute sp_help 

---------------------------------------------/* Usos de Select  */---------------------------------------------

SELECT Clientes.ClienteNome AS Nome FROM Clientes;
go

SELECT C.ClienteNome FROM Clientes AS C;
go

SELECT Clientes.ClienteNome FROM Clientes
ORDER BY Clientes.ClienteNome;
go

SELECT Clientes.ClienteNome FROM Clientes
ORDER BY Clientes.ClienteNome DESC;
go

SELECT TOP 2 ContaNumero, ContaSaldo FROM Contas
ORDER BY ContaSaldo DESC;
go

SELECT TOP 2 ContaNumero, ContaSaldo FROM Contas
ORDER BY ContaSaldo;
go

SELECT CLientes.ClienteNome, Contas.ContaSaldo
FROM Clientes, Contas
WHERE Clientes.ClienteCodigo=Contas.ClienteCodigo;
go 

---------------------------------------------/* DATE  */---------------------------------------------

SET DATEFORMAT YDM

SET LANGUAGE PORTUGUESE

SELECT 
	DATEDIFF(YEAR, P.DTNSCPAR, GETDATE()) AS IDADE ,
	DATEPART(yy, P.DTNSCPAR) AS ANO_NASCIMENTO,
	DATEADD(YY,0,P.DTNSCPAR),
	P.DTNSCPAR AS RECUPERADO,
	EOMONTH(P.DTNSCPAR),
	DATENAME(MONTH, (P.DTNSCPAR))
FROM PAR_PARTICIPANTES p;