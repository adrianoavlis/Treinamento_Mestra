/*------------------------------------------------------------
Autor      : Luis Adriano
Objeto     : PR_OLAMUNDO_ADRIANO 
Objetivo   : Imprime na tela a mensagem 'Ol� Mundo!'.

Hist�rico:        
Autor                  IDBug Data       Descri��o        
---------------------- ----- ---------- --------------------
Luis Adriano                 10/06/2024 Cria��o da Procedure 
------------------------------------------------------------*/

CREATE or ALTER PROCEDURE PR_OLAMUNDO_ADRIANO
AS
BEGIN
    
    PRINT 'Ol� Mundo!';
    
    
    EXEC sp_executesql N'DROP PROCEDURE PR_OLAMUNDO_ADRIANO';
END
GO

EXEC PR_OLAMUNDO_ADRIANO;


