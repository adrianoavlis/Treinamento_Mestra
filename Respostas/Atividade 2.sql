 
 
 
/*************************************** Atividade 2 ***************************************/
 
 
				-- Desenvolver script para criar a seguinte tabela --

					-- Nome da tabela: Treinamento_Nome --

/*		Código de Fundo - char(3)  				
		Código da Patrocinadora - char(3)
		Número do Plano - char(2)
		Número de Inscrição - char(9)
		Nome do Participante - varchar(60)
		Descrição de Logradouro - varchar(45)
		Data de Nascimento - date
		Valor de Salário – decimal(12,2)
*/

 -- Obs.: Somente a Descrição de Logradouro não é obrigatória.
 
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
