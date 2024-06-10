/*------------------------------------------------------------
Autor      : Luis Adriano
Objeto     : PR_OLAMUNDO_ADRIANO 
Objetivo   : Imprime na tela a mensagem 'Olá Mundo!'.

Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- --------------------
Luis Adriano                 10/06/2024 Criação da Procedure 
------------------------------------------------------------*/

CREATE or ALTER PROCEDURE PR_OLAMUNDO_ADRIANO
AS
BEGIN
    
    PRINT 'Olá Mundo!';
    
    
    EXEC sp_executesql N'DROP PROCEDURE PR_OLAMUNDO_ADRIANO';
END
GO

EXEC PR_OLAMUNDO_ADRIANO;


