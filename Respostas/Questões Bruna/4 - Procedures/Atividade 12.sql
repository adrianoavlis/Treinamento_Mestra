
	
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
      
        SELECT TOP 1 @NVRIDC = VRIDCVAR
        FROM FIN_VALINDICE
        WHERE IDIDC = @IDIDC AND VRIDCVAR <> 0
        ORDER BY DTINIVIG DESC;

        IF @NVRIDC IS NULL
        BEGIN
            SET @SERRO = 'Índice não encontrado'
            SET @TTMERRO = @SERRO
            RETURN -1
        END

 
        SET @NVRFIN = @NVRIDC * @VRSAL
        SET @VRCOV = @NVRFIN


        SET @SERRO = 'Conversão realizada com sucesso'
        SET @TTMERRO = @SERRO
    END TRY
    BEGIN CATCH

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


------------------------------------------------

USE [sysprevnucleos_hom]
GO

/****** Object:  StoredProcedure [dbo].[PR_CONVERTER_NADIA]    Script Date: 29/07/2021 14:06:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

       
 
	   CREATE PROCEDURE [dbo].[PR_CONVERTER_NADIA]
              @IDIDC VARCHAR(2),
              @VRSAL DECIMAL(12,2),
       	      @VRCOV DECIMAL(12,2) OUTPUT,
			  @TTMERRO VARCHAR(255) OUTPUT
       
             AS 
       
       BEGIN
				SET NOCOUNT ON;
       
       			DECLARE @NVRFIN DECIMAL(12,2)
       			DECLARE @NVRIDC DECIMAL(16,9)
				DECLARE @SERRO VARCHAR(255)

				SET @SERRO = 'Erro ao recuperar o indice'

				BEGIN TRY

       				SELECT @NVRIDC = CDIDC
					FROM FIN_VALINDICE
       				WHERE IDIDC = @IDIDC AND DTINIVIG = (SELECT MAX(DTINIVIG) FROM FIN_VALINDICE WHERE DTINIVIG <= getdate())

					IF @NVRIDC IS NULL 
					BEGIN 
						SET @SERRO = ' ÍNDICE NÃO ENCONTRADO PARA O IDIDC FORNECIDO';
						THROW 51000, @SERRO, 1;
					END

					SET @NVRFIN = @NVRIDC * @VRSAL;       
       				SET @VRCOV = @NVRFIN;

					SET @TTMERRO = 'CONVERSAO REALIZADA COM SUCESSO';
				END TRY
				BEGIN CATCH
					SET @TTMERRO = ERROR_MESSAGE();
					RETURN -1;
				END CATCH
		END
GO


