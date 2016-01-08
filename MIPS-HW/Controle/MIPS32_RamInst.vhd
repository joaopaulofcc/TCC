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
 --# Arquivo: MIPS32_RamInst.vhd		 													#
 --#                                                                      	#
 --# Sobre: Esse arquivo descreve a estrutura e comportamento de uma		 	#
 --# 			memória RAM de instruçoes utilizada no MIPS.							#
 --#                                                                      	#
 --# 05/01/16 - Formiga - MG                                              	#
 --#########################################################################

-- Importa as bibliotecas de sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Importa as bibliotecas de usuário.
LIBRARY WORK;
USE WORK.MIPS32_Funcoes.ALL;


-- Início da declaração da entidade MIPS32_RamInst.
ENTITY MIPS32_RamInst IS

	PORT 
	(
		clock		: IN 	STD_LOGIC;			-- Sinal de clock.
		we			: IN 	STD_LOGIC := '1';	--	Sinal de Write Enable (1 - Leitura | 0 - Escrtia), default = 1.
		reset		: IN 	STD_LOGIC := '0';	-- Sinal de Reset da memória.
		address	: IN 	t_AddressINST;		-- Endereço da posição de memória a ser Escrita/Lida.
		dataIn	: IN 	t_Byte;				-- Dado a ser escrito na RAM.
		dataOut	: OUT t_Byte				-- Dado lido da RAM.
	);

END ENTITY;
-- Fim da declaração da entidade MIPS32_RamInst.


-- Início da declaração da arquitetura da entidade MIPS32_RamInst.
ARCHITECTURE BEHAVIOR OF MIPS32_RamInst IS

	-- Função utilizada para inicializar a memória RAM de instruçoes, 
	-- para isso escreve em seus endereços o próprio valor do endereço.
	FUNCTION init_ram
	RETURN t_RAM_INST IS
		VARIABLE tmp : t_RAM_INST := (OTHERS => (OTHERS => '0'));
	BEGIN 
	
		FOR addr_pos IN 0 TO 2 ** ADDRESS_INST_WIDTH - 1 LOOP
		
			tmp(addr_pos) := x"00"; --STD_LOGIC_VECTOR(TO_UNSIGNED(0, DATA_WIDTH));
			
		END LOOP;
		
		RETURN tmp;
		
	END init_ram;

	-- Declara sinal que será um vetor que representará a RAM de instruçoes do tipo t_RAM_INST.
	SIGNAL ram : t_RAM_INST := init_ram;
		
BEGIN
	
	-- Process que permite que o circuito seja síncrono, é ativado por alteraçao de valores no sinal "clock" e "reset".
	PROCESS(clock, reset)
	BEGIN
	
		-- Caso o sinal de reset esteja em nível alto, aciona a funçao de preenchimento da memória com valores default.
		IF(reset = '1') THEN
		
			ram <= init_ram;
	
		-- Caso seja borda de subida do sinal "clock".
		ELSIF(RISING_EDGE(clock)) THEN
		
			-- Escreve dado na posiçao especifica da RAM.
			IF(we = '0') THEN
			
				ram(TO_INTEGER(UNSIGNED(address))) <= dataIn;
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	-- Realiza a leitura da posiçao de memória especificada no barramento. Esse processo é assíncrono e sempre ocorre,
	-- independente de ter sido executado o processo de escrita.
	dataOut <= ram(TO_INTEGER(UNSIGNED(address)));
			
END BEHAVIOR;
-- Fim da declaração da arquitetura da entidade MIPS32_RamInst.