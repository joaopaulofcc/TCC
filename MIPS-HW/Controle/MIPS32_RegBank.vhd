 --#########################################################################
 --#	 Bacharelado em Ciência da Computação - IFMG campus Formiga - 2016	#
 --#                                                                      	#
 --# 						  Trabalho de Conclusão de Curso								#
 --#																								#
 --# 		Implementação de processador baseado no MIPS32 utilizando 			#
 --# 							hardware reconfigurável										#
 --#																							  	#
 --# ALUNO                                                             		#
 --#                                                                      	#
 --# João Paulo Fernanades de Cerqueira César                             	#
 --#                                                                      	#
 --# ORIENTADOR                                                           	#
 --#                                                                      	#
 --# Otávio de Souza Martins Gomes                                        	#
 --#                                                                      	#
 --# Arquivo: MIPS32_RegBank.vhd		 													#
 --#                                                                      	#
 --# Sobre: Esse arquivo descreve a estrutura e comportamento do banco de 	#
 --# 			registradores utilizado pelo MIPS. Nesse estão presentes 34		#
 --# 			registradores de 32 bits de largura cada.	                     #
 --#                                                                      	#
 --# 05/01/16 - Formiga - MG                                              	#
 --#########################################################################

 
-- Importa as bibliotecas de sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


-- Importa as bibliotecas de usuário.
LIBRARY WORK;
USE WORK.MIPS32_Funcoes.ALL;


-- Início da declaração da entidade MIPS32_RegBank.
ENTITY MIPS32_RegBank IS

	PORT 
	(
		clock			: IN 	STD_LOGIC;										-- Sinal de clock.
		
		we				: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";	--	Sinal de Write Enable 
																						-- (00 - escreve no 1º registrador   | 01 - escreve no 2º registrador |
																						-- (10 - escreve nos 2 registradores | 11 - lê os dois registradores )
																						
		reset			: IN 	STD_LOGIC := '0';								-- Sinal de Reset dos registradores.
																						
		regRead1		: IN 	t_RegSelect;									-- Endereço do 1º registrador a ser lido.
		regRead2		: IN 	t_RegSelect;									-- Endereço do 2º registrador a ser lido.
		
		regWrite1	: IN 	t_RegSelect;									-- Endereço do 1º registrador a ser escrito.
		regWrite2	: IN 	t_RegSelect;									-- Endereço do 2º registrador a ser escrito.
		
		dataWrite1	: IN 	t_Word;											-- Dado a ser escrito no registrador "regWrite1".
		dataWrite2	: IN 	t_Word;											-- Dado a ser escrito no registrador "regWrite2".
		
		dataRead1	: OUT t_Word := (OTHERS => '0');					-- Dado lido do registrador "regRead1".
		dataRead2	: OUT t_Word := (OTHERS => '0')					-- Dado lido do registrador "regRead2".
	);

END ENTITY;
-- Fim da declaração da entidade MIPS32_RegBank.


-- Início da declaração da arquitetura da entidade MIPS32_RegBank.
ARCHITECTURE BEHAVIOR OF MIPS32_RegBank IS

	-- Função utilizada para inicializar o Banco de Registradores,
	-- para isso escreve em seus endereços o próprio valor do endereço.
	FUNCTION init_reg
	RETURN t_RegBank IS
		VARIABLE tmp : t_RegBank := (OTHERS => (OTHERS => '0'));
	BEGIN 
	
		FOR addr_pos IN 0 TO QTD_GPRs - 1 LOOP
		
			tmp(addr_pos) := x"00000000"; --STD_LOGIC_VECTOR(TO_UNSIGNED(0, REGISTER_WIDTH));
			
		END LOOP;
		
		RETURN tmp;
		
	END init_reg;

	-- Declara sinal que será um vetor que representará o Banco de registadores do tipo t_MIPS32_RegBank.
	SIGNAL registers : t_RegBank := init_reg;

BEGIN
	
	-- Process que permite que o circuito seja síncrono, é ativado por alteraçao de valores no sinal "clock" e "reset".
	PROCESS(clock, reset)
	BEGIN
		
		-- Caso o sinal de reset esteja em nível alto, aciona a funçao de preenchimento dos registradores com valores default.
		IF(reset = '1') THEN
		
			registers <= init_reg;
			
		-- Caso seja borda de subida do sinal "clock".
		ELSIF(RISING_EDGE(clock)) THEN
		
			-- Escreve no primeiro registrador.
			IF(we = "00") THEN
			
				registers(TO_INTEGER(UNSIGNED(regWrite1))) <= dataWrite1;
			
			-- Escreve no segundo registrador.
			ELSIF(we = "01") THEN
			
				registers(TO_INTEGER(UNSIGNED(regWrite2))) <= dataWrite2;
				
			-- Escreve nos dois registradores.
			ELSIF(we = "10") THEN
			
				registers(TO_INTEGER(UNSIGNED(regWrite1))) <= dataWrite1;
				registers(TO_INTEGER(UNSIGNED(regWrite2))) <= dataWrite2;
		
			END IF;
			
		END IF;
		
	END PROCESS;
	
	-- Realiza a leitura dos dois registradores especificados. Esse processo é assíncrono e sempre ocorre,
	-- independente de terem sido executadas escritas.
	dataRead1 <= registers(TO_INTEGER(UNSIGNED(regRead1)));
	dataRead2 <= registers(TO_INTEGER(UNSIGNED(regRead2)));

END BEHAVIOR;
-- Fim da declaração da arquitetura da entidade MIPS32_RegBank.