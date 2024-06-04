 
 
 
/*************************************** Atividade 4 ***************************************/


	-- Desenvolver script para inserir a seguinte coluna na tabela:

	-- Identificador de Participante – integer com incrementação automática

ALTER TABLE Treinamento_Adriano
ADD IDPAR INT
IDENTITY (1,1) 
GO 

sp_help Treinamento_Adriano