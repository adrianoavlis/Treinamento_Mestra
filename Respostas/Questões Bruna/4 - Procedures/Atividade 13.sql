USE [sysprevnucleos_hom]
GO
/*

 Desenvolver nova procedure para retornar a quantidade de participantes (PR_RTOPAR_NOME) de acordo com os parâmetros informados pelo usuário. 
 
 Fazer o tratamento de erro, utilizar a procedure MEPC0010 da Nucleos como exemplo. 
 
 Utilizar um CURSOR para recuperar os registros das tabelas PAR_PARTICIPANTES e PAR_PARPLA.

*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[PR_RTOPAR_ADRIANO]
    @PSIDPAR INT,
    @PSCDPAT CHAR(3),
    @PSNRPLA CHAR(2),
    @PRSDCERR VARCHAR(255) OUTPUT
AS
BEGIN
   
	SET NOCOUNT ON

	DECLARE @IDPAR INT;
    DECLARE @CDPAT CHAR(3);
    DECLARE @NRPLA CHAR(2);
    DECLARE @ParticipantCount INT;

  
    SET @PRSDCERR = NULL;

   
    DECLARE participant_cursor CURSOR FOR
    SELECT P.IDPAR, P.CDPAT, PL.NRPLA
    FROM PAR_PARTICIPANTES P
    JOIN PAR_PARPLA PL ON P.IDPAR = PL.IDPAR
    WHERE P.IDPAR = @PSIDPAR
    AND P.CDPAT = @PSCDPAT
    AND PL.NRPLA = @PSNRPLA;

   
    OPEN participant_cursor;

    
    FETCH NEXT FROM participant_cursor INTO  @IDPAR, @CDPAT, @NRPLA;

   
    SET @ParticipantCount = 0;

    
    WHILE @@FETCH_STATUS = 0
    BEGIN

        SET @ParticipantCount = @ParticipantCount + 1;

        -- Fetch the next row
        FETCH NEXT FROM participant_cursor INTO  @IDPAR, @CDPAT, @NRPLA;
    END

  
    CLOSE participant_cursor;
    DEALLOCATE participant_cursor;

    
    SET @PRSDCERR = CAST(@ParticipantCount AS VARCHAR(10));

    -- Handle errors
    IF @@ERROR <> 0
    BEGIN
        SET @PRSDCERR = 'Error occurred while processing the request. SQLCODE: ' + CAST(@@ERROR AS VARCHAR(10));
        ROLLBACK;
        RETURN -1;
    END
    ELSE
    BEGIN
        RETURN 0;
    END
END
GO


DECLARE @OUTPUT VARCHAR(255)
execute PR_RTOPAR_ADRIANO @PSIDPAR = '45', @PSCDPAT = '001', @PSNRPLA = '01', @PRSDCERR = @OUTPUT OUTPUT
SELECT @OUTPUT
go