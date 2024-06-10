/*------------------------------------------------------------
Autor      : Luis Adriano
Objeto     : PROC_MSG_BOAS_VINDAS_ADRIANO
Objetivo   : Retorna uma mensagem personalizada de acordo com a hora do dia.

Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- --------------------
Luis Adriano                 10/06/2024 Criação da Procedure 
------------------------------------------------------------*/

USE sysprevnucleos_hom
GO

CREATE PROCEDURE PROC_MSG_BOAS_VINDAS_ADRIANO
AS
BEGIN

    DECLARE @usuario_banco NVARCHAR(128);
    SET @usuario_banco = SYSTEM_USER;
    PRINT 'Seja Bem-vindo, ' + @usuario_banco + '!';

  
    DECLARE @hora_atual INT;
    SET @hora_atual = DATEPART(HOUR, GETDATE());

    
    IF @hora_atual > 8 AND @hora_atual < 12
    BEGIN
        PRINT 'Bom dia!!!';
    END
    ELSE IF @hora_atual >= 12 AND @hora_atual <= 18
    BEGIN
        PRINT 'Boa Tarde!!!';
    END
    ELSE
    BEGIN
        PRINT 'Boa Noite!!!';
    END
END;
GO


EXEC PROC_MSG_BOAS_VINDAS_ADRIANO;
