 --#########################################################################
 --#	 Bacharelado em Ciência da Computação - IFMG campus Formiga - 2015	#
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
 --# Arquivo: TestBench.vhd																#
 --#                                                                      	#
 --# Test Bench para ROM			 														#
 --#                                                                      	#
 --# 12/08/15 - Formiga - MG                                              	#
 --#########################################################################


-- Importa bibliotecas do sistema
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;


-- Importa as bibliotecas de usuário
LIBRARY WORK;
USE WORK.funcoes.ALL;

-- Início da declaração da entidade TestBench
ENTITY TestBench IS
END ENTITY TestBench;
-- Fim da declaração da entidade TestBench


-- Início da declaração da arquitetura da entidade TestBench
ARCHITECTURE sinais OF TestBench IS
	
	-- Sinais internos
	SIGNAL sig_clock 		: 	STD_LOGIC;
	SIGNAL sig_address	:	t_Address;
	SIGNAL sig_dataOut	:	t_Byte;
  
  
   -- Importação do componente ROM já construido  
	COMPONENT ROM
		PORT 
		(
			clock		: IN 	STD_LOGIC;	-- Sinal de relógio.
			address	: IN 	t_Address;	-- Endereço da posição de memória a ser Lida.
			dataOut	: OUT t_Byte		-- Dado lido da ROM.
		);
	END COMPONENT;	
  

BEGIN

	-- Mapeamento de portas do componente ROM com sinais do Test Bench
	UUT_ROM: ROM PORT MAP                                          			    
	(
		clock		=> sig_clock,
		address	=> sig_address,
		dataOut	=> sig_dataOut
	);
   
	
	-- Início do controle de clock	
	P_clockGen: PROCESS IS  
	BEGIN
		 	
		sig_clock <= '0';   -- Clock em nível baixo por 10 ns.
		
		WAIT FOR 10 ns; 
		
		sig_clock <= '1';   -- Clock em nível alto por 10 ns.
		
		WAIT FOR 10 ns;
		
	END PROCESS P_clockGen;
	-- Fim do controle de clock

	
	
	-- Início do Processo de Leitura (READ) de dados presentes na memória ROM.
	P_WriteRead: PROCESS IS                                               				 
	BEGIN
		
		-- Aguarda primeira borda de subida do clock.
		WAIT UNTIL RISING_EDGE(sig_clock);
	
		-- Zera sinal de endereço.
		sig_address		<= STD_LOGIC_VECTOR(TO_UNSIGNED(0, sig_address'LENGTH));
			
		-- Lê os dados em 32 endereços (4 posições de memória - 4 * 8 = 32).
		WHILE UNSIGNED(sig_address) /= 32 LOOP	
			
			-- Aguarda por 20 ns até ler o próximo dado.
			WAIT FOR 20 ns;
		
			-- Altera o valor do sinal de endereço para o próximo endereço na memória.
			sig_address		<= STD_LOGIC_VECTOR(UNSIGNED(sig_address) + 1);
			
		END LOOP;
		
	END PROCESS P_WriteRead;
	-- Fim do Processo de Leitura (READ) de dados presentes na memória ROM.
	
END ARCHITECTURE sinais;
-- Fim da declaração da arquitetura da entidade TestBench