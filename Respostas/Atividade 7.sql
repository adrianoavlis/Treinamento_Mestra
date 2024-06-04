
/*

Alterar o Identificador de Participante da tabela TREINAMENTO_SEUNOME para Chave Primária. 

Deletar Identificador de Participante e criar de volta como Chave Primária.

*/


-- Remover a tabela existente, se necessário
 
DROP TABLE Treinamento_Adriano;
 
GO



-- Recriar a tabela com NRISC como chave primária

CREATE TABLE Treinamento_Adriano (
	
IDPAR int,
    
CDFUN CHAR(3) NOT NULL,
    
CDPAT CHAR(3) NOT NULL,
    
NRPLA CHAR(2) NOT NULL,
    
NRISC CHAR(9) NOT NULL PRIMARY KEY,
    
NMPAR VARCHAR(60) NOT NULL,
    
DCLOG VARCHAR(45) NULL,
    
DTNSC datetime NOT NULL,
    
VRSAL DECIMAL(12,2) NOT NULL
);

GO



-- Ou, alternativamente, para uma tabela já existente



-- Remover a chave primária existente (se houver)


ALTER TABLE Treinamento_Adriano DROP CONSTRAINT [NomeDaConstraintPrimaria];

GO



-- Adicionar NRISC como chave primária


ALTER TABLE Treinamento_Adriano

ADD CONSTRAINT PK_Treinamento_Adriano PRIMARY KEY (NRISC);

GO

-------------------------------------------------------------------------------------------------

-----------
 /* 
 Desenvolver script criar tabela TREINAMENTO_ADRIANO_DEPEN:
 */

 



CREATE TABLE TREINAMENTO_ADRIANO_DEPEN (
    
IDDPD INT NOT NULL PRIMARY KEY,
    
NRISCPAR char(9) NOT NULL,
    
NMDPD VARCHAR(60) NOT NULL,
    
DCLOGDPD VARCHAR(45) NOT NULL,
    
DTNSCDPD DATETIME NOT NULL,
    
TPSEXDPD CHAR(1) NOT NULL,
    
NRTELCELDPD VARCHAR(10) NOT NULL,
    
CONSTRAINT FK_IDPARTICIPANTE FOREIGN KEY (NRISCPAR) 
    REFERENCES Treinamento_Adriano (NRISC)
);


------------------------------------------------------------------------------------------------------------

