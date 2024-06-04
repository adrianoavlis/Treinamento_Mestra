
-----------------------------------------------------------------------------------------------------

-- 1 � Crie 2 tabelas na base de homologa��o, PAR_PARTICIPANTES_HOJE e PAR_PARTICIPANTES_SALARIOS.
-- A tabela PAR_PARTICIPANTES dever� ter os seguintes campos: Identificador do participante do tipo
-- inteiro e n�o nulo, c�digo da patrocinadora do tipo char(3) n�o nulo, matr�cula do tipo char(10)
-- n�o nulo, inscri��o do tipo char(9) nulo, nome do tipo varchar(60) n�o nulo e tipo do sexo do
-- participante do tipo char(1). A tabela PAR_PARTICIPANTES dever� tamb�m ter o campo Identificador
-- do Participante declarado como chave-prim�ria. A tabela PAR_PARTICIPANTES_SALARIOS dever� ter
-- os seguintes campos: Identificador do sal�rio (IDSAL) do tipo inteiro n�o nulo, Identificador
-- do participante do tipo inteiro n�o nulo, Data do M�s de Refer�ncia do tipo char(6) n�o nulo
-- e Valor do Sal�rio (VRSPA) do tipo decimal (12,2) n�o nulo. A tabela PAR_PARTICIPANTES_SALARIOS
-- dever� tamb�m ter o campo Identificador do Sal�rio declarado como chave-prim�ria e Identificador
-- do Participante declarado como chave-extrangeira. 



-------------------------------------------------------------------------------------------------------

-- 2 �  O pr�ximo passo ap�s a cria��o das 2 tabelas ser� popula-las (fazer a inser��o de valores
-- nos campos criados). 

-- Tabela PAR_PARTICIPANTES_HOJE 

-- (1231, 001, 0000000100, 000002119, Neymar Junior, M) 
-- (1232, 002, 0000000101, 000002118, Lula da Silva, M)  
-- (1233, 003, 0000000102, 000002117, Dilma Lalau, M)  
-- (1234, 004, 0000000103, 000002116, Pedro Campos, M)  
-- (1235, 005, 0000000104, 000002115, Rita Guedes, M) 



-- Tabela PAR_PARTICIPANTES_SALARIOS

-- (0001, 1235, 201301, 1000.00)
-- (0002, 1234, 201305, 1500.00)
-- (0003, 1233, 201304, 1820.00)
-- (0004, 1232, 201303, 2000.00)
-- (0005, 1231, 201302, 2100.00)



-----------------------------------------------------------------------------------------------------

-- 3 � Ap�s popular as 2 tabelas voc�s dever� realizar algumas altera��es: 

-- a) Na tabela PAR_PARTICIPANTES_HOJE alterar o sexo da Dilma Lalau e da Rita Guedes para F
-- (Feminino).



-- b) Na tabela PAR_PARTICIPANTES_SALARIOS alterar o sal�rio do Lula da Silva para 3200.00 e o
-- m�s de refer�ncia do sal�rio do Neymar para 201312.



-----------------------------------------------------------------------------------------------------

-- 4 � Realizadas as devidas altera��es nas 2 tabelas, voc� dever� deletar alguns registros: 

-- a) Delete o Participante Lula da Silva.



-----------------------------------------------------------------------------------------------------

-- 5 � Ap�s realizar as opera��es acima, fa�a uma consulta que retorne o Identificador do
-- Participante, a Inscri��o, o N�mero de Matr�cula, a patrocinadora do participante que tenha
-- o maior sal�rio. 



-----------------------------------------------------------------------------------------------------

-- 6 � Listar a soma e a m�dia de todos os sal�rios da tabela PAR_PARTICIPANTES_SALARIOS.



-----------------------------------------------------------------------------------------------------

-- 7 � Ap�s realizar todas essas tarefas, salve no seu controle de treinamento e em seguida delete
-- as 2 tabelas que voc� criou na base de homologa��o.


