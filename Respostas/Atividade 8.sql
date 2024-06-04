
/*

Para essa atividade você deverá deletar a tabela TREINAMENTO_SEUNOME, 
e em seguida inserir os mesmos registros da Atividade 3 duas vezes.

*/

sp_help Treinamento_Adriano

go

select * from Treinamento_Adriano

go


alter table TREINAMENTO_ADRIANO_DEPEN
drop constraint  FK_IDPARTICIPANTE;
go

drop table Treinamento_Adriano
go

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

-- Inserir os mesmos registros da Atividade 3 duas vezes
SET NOCOUNT ON;

DECLARE @ID INT = 1;

-- Loop para a primeira inserção dos registros
WHILE @ID <= 15
BEGIN
    DECLARE @idFicticio INT = (SELECT (ABS(CHECKSUM(NEWID())) % 1000) + 1);
    DECLARE @nomeFicticio VARCHAR(60) = (SELECT NMPAR FROM PAR_PARTICIPANTES WHERE IDPAR = @idFicticio);
    
    DECLARE @CDFUN CHAR(3) = RIGHT('00' + CAST((@ID % 2 + 1) AS VARCHAR), 3);
    DECLARE @CDPAT CHAR(3) = RIGHT('00' + CAST((@ID % 3 + 1) AS VARCHAR), 3);
    DECLARE @NRPLA CHAR(2) = RIGHT('0' + CAST((@ID % 3 + 1) AS VARCHAR), 2);
    DECLARE @NRISC CHAR(9) = RIGHT('000000000' + CAST(@ID AS VARCHAR), 9);
    DECLARE @NMPAR VARCHAR(60) = @nomeFicticio;
    DECLARE @DTNSC DATE = DATEADD(YEAR, -20 - @ID, GETDATE());
    DECLARE @VRSAL DECIMAL(12, 2) = 1000 + (@ID - 1) * 1000;
    
    INSERT INTO Treinamento_Adriano(
        IDPAR,
        CDFUN,
        CDPAT,
        NRPLA,
        NRISC,
        NMPAR,
        DTNSC,
        VRSAL
    ) VALUES (
        @idFicticio,
        @CDFUN,
        @CDPAT,
        @NRPLA,
        @NRISC,
        @NMPAR,
        @DTNSC,
        @VRSAL
    );
    
    SET @ID = @ID + 1;
END

SET @ID = 16;

-- Loop para a segunda inserção dos registros
WHILE @ID  <= 30
BEGIN
    DECLARE @idFicticio2 INT = (SELECT (ABS(CHECKSUM(NEWID())) % 1000) + 1);
    DECLARE @nomeFicticio2 VARCHAR(60) = (SELECT NMPAR FROM PAR_PARTICIPANTES WHERE IDPAR = @idFicticio2);
    
    DECLARE @CDFUN2 CHAR(3) = RIGHT('00' + CAST((@ID % 2 + 1) AS VARCHAR), 3);
    DECLARE @CDPAT2 CHAR(3) = RIGHT('00' + CAST((@ID % 3 + 1) AS VARCHAR), 3);
    DECLARE @NRPLA2 CHAR(2) = RIGHT('0' + CAST((@ID % 3 + 1) AS VARCHAR), 2);
    DECLARE @NRISC2 CHAR(9) = RIGHT('000000000' + CAST(@ID AS VARCHAR), 9);
    DECLARE @NMPAR2 VARCHAR(60) = @nomeFicticio2;
    DECLARE @DTNSC2 DATE = DATEADD(YEAR, -20 - @ID, GETDATE());
    DECLARE @VRSAL2 DECIMAL(12, 2) = 1000 + (@ID - 1) * 1000;
    
    INSERT INTO Treinamento_Adriano (
        IDPAR,
        CDFUN,
        CDPAT,
        NRPLA,
        NRISC,
        NMPAR,
        DTNSC,
        VRSAL
    ) VALUES (
        @idFicticio2,
        @CDFUN2,
        @CDPAT2,
        @NRPLA2,
        @NRISC2,
        @NMPAR2,
        @DTNSC2,
        @VRSAL2
    );
    
    SET @ID = @ID + 1;
END

GO 


--  MELHORAR ESSE CÓDIGO 


--------------------------------------------------------------------------------------------------------------
/*
Duplique os registros da tabela de Treinamento_Adriano com uma query.
*/

DELETE FROM Treinamento_Adriano
WHERE IDPAR IS NULL;

select * from Treinamento_Adriano
go

ALTER TABLE Treinamento_Adriano ADD Temp_NRISC CHAR(9);
GO

	UPDATE Treinamento_Adriano
	SET Temp_NRISC = RIGHT('000000000' + CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR), 9);


	INSERT INTO Treinamento_Adriano (
		IDPAR,
		CDFUN,
		CDPAT,
		NRPLA,
		NRISC,
		NMPAR,
		DCLOG,
		DTNSC,
		VRSAL
	)
	SELECT
		IDPAR,
		CDFUN,
		CDPAT,
		NRPLA,
		Temp_NRISC,
		NMPAR,
		DCLOG,
		DTNSC,
		VRSAL
	FROM Treinamento_Adriano;

ALTER TABLE Treinamento_Adriano DROP COLUMN Temp_NRISC;

SELECT * FROM Treinamento_Adriano order by VRSAL;
GO

--------------------------------------------------------------------------------------------------------------

/*
 Desenvolver um script para retirar os registros que tenham o nome repetido na tabela TREINAMENTO_SEUNOME. 
 Utilizar um único comando.
*/

DELETE T
FROM
(
SELECT *
, DupRank = ROW_NUMBER() OVER (
              PARTITION BY IDPAR
              ORDER BY (SELECT NULL)
            )
FROM Treinamento_Adriano
) AS T
WHERE DupRank > 1

select * from Treinamento_Adriano

go
