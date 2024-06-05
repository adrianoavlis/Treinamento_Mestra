/*
Desenvolver script para inserir 15 registros na tabela de TREINAMENTO_SEUNOME:

A tabela deverá seguir o seguinte padrão, com variações conforme os seguintes campos abaixo:
	   
*/

SET NOCOUNT ON;

DECLARE @ID INT = 1;

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
    
    INSERT INTO Treinamento_Adriano (
        CDFUN,
        CDPAT,
        NRPLA,
        NRISC,
        NMPAR,
        DTNSC,
        VRSAL
    ) VALUES (
        @CDFUN,
        @CDPAT,
        @NRPLA,
        @NRISC,
        @NMPAR,
        @DTNSC,
        @VRSAL
    );
    
    SET @ID = @ID + 1;
END;
GO





select * from Treinamento_Adriano
go


