 
 
 
/*************************************** Atividade 2 ***************************************/
 
 
				-- Desenvolver script para criar a seguinte tabela --

					-- Nome da tabela: Treinamento_Nome --

/*		C�digo de Fundo - char(3)  				
		C�digo da Patrocinadora - char(3)
		N�mero do Plano - char(2)
		N�mero de Inscri��o - char(9)
		Nome do Participante - varchar(60)
		Descri��o de Logradouro - varchar(45)
		Data de Nascimento - date
		Valor de Sal�rio � decimal(12,2)
*/

 -- Obs.: Somente a Descri��o de Logradouro n�o � obrigat�ria.
 
DROP TABLE Treinamento_Adriano;

 CREATE TABLE Treinamento_Adriano (
     CDFUN CHAR(3) NOT NULL,
     CDPAT CHAR(3) NOT NULL,
     NRPLA CHAR(2) NOT NULL,
     NRISC CHAR(9) NOT NULL,
     NMPAR VARCHAR(60) NOT NULL,
     DCLOG VARCHAR(45) NULL,
     DTNSC datetime NOT NULL,
     VRSAL DECIMAL(12,2) NOT NULL
 )
 go




 sp_help Treinamento_Adriano
