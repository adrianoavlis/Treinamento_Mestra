/*------------------------------------------------------------
Autor      : Luis Adriano
Objeto     : PR_RET_MSG_ADRIANO 
Objetivo   : Retorna o texto informado no parâmetro.

Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- --------------------
Luis Adriano                 10/06/2024 Criação da Procedure 
------------------------------------------------------------*/

USE sysprevnucleos_hom;
GO


CREATE OR ALTER PROCEDURE PR_RET_MSG_ADRIANO
    @psMEUTEXTO VARCHAR(100)
AS
BEGIN
    -- Exibir mensagem com o texto informado
    PRINT 'TEXTO INFORMADO: ' + @psMEUTEXTO;
END;
GO

EXEC PR_RET_MSG_ADRIANO @psMEUTEXTO = 'Olá Luis Adriano!';
