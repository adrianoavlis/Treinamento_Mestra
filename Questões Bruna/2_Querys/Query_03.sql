
-----------------------------------------------------------------------------------------------------

-- 1 – Crie 2 tabelas na base de homologação, PAR_PARTICIPANTES_HOJE e PAR_PARTICIPANTES_SALARIOS.
-- A tabela PAR_PARTICIPANTES deverá ter os seguintes campos: Identificador do participante do tipo
-- inteiro e não nulo, código da patrocinadora do tipo char(3) não nulo, matrícula do tipo char(10)
-- não nulo, inscrição do tipo char(9) nulo, nome do tipo varchar(60) não nulo e tipo do sexo do
-- participante do tipo char(1). A tabela PAR_PARTICIPANTES deverá também ter o campo Identificador
-- do Participante declarado como chave-primária. A tabela PAR_PARTICIPANTES_SALARIOS deverá ter
-- os seguintes campos: Identificador do salário (IDSAL) do tipo inteiro não nulo, Identificador
-- do participante do tipo inteiro não nulo, Data do Mês de Referência do tipo char(6) não nulo
-- e Valor do Salário (VRSPA) do tipo decimal (12,2) não nulo. A tabela PAR_PARTICIPANTES_SALARIOS
-- deverá também ter o campo Identificador do Salário declarado como chave-primária e Identificador
-- do Participante declarado como chave-extrangeira. 



-------------------------------------------------------------------------------------------------------

-- 2 –  O próximo passo após a criação das 2 tabelas será popula-las (fazer a inserção de valores
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

-- 3 – Após popular as 2 tabelas vocês deverá realizar algumas alterações: 

-- a) Na tabela PAR_PARTICIPANTES_HOJE alterar o sexo da Dilma Lalau e da Rita Guedes para F
-- (Feminino).



-- b) Na tabela PAR_PARTICIPANTES_SALARIOS alterar o salário do Lula da Silva para 3200.00 e o
-- mês de referência do salário do Neymar para 201312.



-----------------------------------------------------------------------------------------------------

-- 4 – Realizadas as devidas alterações nas 2 tabelas, você deverá deletar alguns registros: 

-- a) Delete o Participante Lula da Silva.



-----------------------------------------------------------------------------------------------------

-- 5 – Após realizar as operações acima, faça uma consulta que retorne o Identificador do
-- Participante, a Inscrição, o Número de Matrícula, a patrocinadora do participante que tenha
-- o maior salário. 



-----------------------------------------------------------------------------------------------------

-- 6 – Listar a soma e a média de todos os salários da tabela PAR_PARTICIPANTES_SALARIOS.



-----------------------------------------------------------------------------------------------------

-- 7 – Após realizar todas essas tarefas, salve no seu controle de treinamento e em seguida delete
-- as 2 tabelas que você criou na base de homologação.


