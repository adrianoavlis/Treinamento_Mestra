
	
CREATE OR ALTER PROCEDURE PR_CONVERTER_ADRIANO
    @IDIDC VARCHAR(2),
    @VRSAL DECIMAL(12, 2),
    @VRCOV DECIMAL(12, 2) OUTPUT,
    @TTMERRO VARCHAR(255) OUTPUT
AS
BEGIN
    DECLARE @NVRFIN DECIMAL(12, 2)
    DECLARE @NVRIDC DECIMAL(16, 9)
    DECLARE @SERRO VARCHAR(255)

    BEGIN TRY
        -- Recupera o valor do �ndice da tabela FIN_VALINDICE
        SELECT TOP 1 @NVRIDC = VRIDCVAR
        FROM FIN_VALINDICE
        WHERE IDIDC = @IDIDC AND VRIDCVAR <> 0
        ORDER BY DTINIVIG DESC;

        -- Verifica se o �ndice foi encontrado
        IF @NVRIDC IS NULL
        BEGIN
            SET @SERRO = '�ndice n�o encontrado'
            SET @TTMERRO = @SERRO
            RETURN -1
        END

        -- Calcula o valor convertido
        SET @NVRFIN = @NVRIDC * @VRSAL
        SET @VRCOV = @NVRFIN

        -- Define a mensagem de sucesso
        SET @SERRO = 'Convers�o realizada com sucesso'
        SET @TTMERRO = @SERRO
    END TRY
    BEGIN CATCH
        -- Trata erros durante a execu��o
        SET @SERRO = ERROR_MESSAGE()
        SET @TTMERRO = @SERRO
        RETURN -1
    END CATCH
END
GO


DECLARE @VRCOV DECIMAL(12, 2)
DECLARE @TTMERRO VARCHAR(255)

EXEC dbo.PR_CONVERTER_ADRIANO
    @IDIDC = '4',
    @VRSAL = 1000.00,
    @VRCOV = @VRCOV OUTPUT,
    @TTMERRO = @TTMERRO OUTPUT;

-- Exibe o valor convertido e a mensagem de erro/sucesso
SELECT @VRCOV AS ValorConvertido, @TTMERRO AS Mensagem;