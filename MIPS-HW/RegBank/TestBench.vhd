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
 --# Test Bench para Register Bank 														#
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
	SIGNAL sig_clock 			: 	STD_LOGIC;
	SIGNAL sig_we				: 	STD_LOGIC;
	SIGNAL sig_regRead1		:	STD_LOGIC_VECTOR (REGISTER_SELECT - 1 DOWNTO 0);
	SIGNAL sig_regRead2		:	STD_LOGIC_VECTOR (REGISTER_SELECT - 1 DOWNTO 0);
	SIGNAL sig_regWrite		:	STD_LOGIC_VECTOR (REGISTER_SELECT - 1 DOWNTO 0);
	SIGNAL sig_dataWrite		:	t_Word;
	SIGNAL sig_dataRead1		:	t_Word;
	SIGNAL sig_dataRead2		:	t_Word;
  
  
   -- Importação do componente RegBank já construido  
	COMPONENT RegBank
		PORT 
		(
			clock			: IN 	STD_LOGIC;														-- Sinal de relógio.
			we				: IN 	STD_LOGIC := '1';												--	Sinal de Write Enable (1 - Habilitado | 0 - Desabilitado)
			regRead1		: IN 	STD_LOGIC_VECTOR (REGISTER_SELECT - 1 DOWNTO 0);	-- Endereço do 1º registrador a ser lido.
			regRead2		: IN 	STD_LOGIC_VECTOR (REGISTER_SELECT - 1 DOWNTO 0);	-- Endereço do 2º registrador a ser lido.
			regWrite		: IN 	STD_LOGIC_VECTOR (REGISTER_SELECT - 1 DOWNTO 0);	-- Endereço do registrador a ser escrito.
			dataWrite	: IN 	t_Word;															-- Dado a ser escrito no registrador "regWrite".
			dataRead1	: OUT t_Word;															-- Dado lido no registrador "regRead1".
			dataRead2	: OUT t_Word															-- Dado lido no registrador "regRead2".
		);
	END COMPONENT;	
  

BEGIN

	-- Mapeamento de portas do componente RegBank com sinais do Test Bench
	UUT_RegBank: RegBank PORT MAP                                          			    
	(
		clock			=> sig_clock,
		we				=> sig_we,
		regRead1		=> sig_regRead1,
		regRead2		=> sig_regRead2,
		regWrite		=> sig_regWrite,
		dataWrite	=> sig_dataWrite,
		dataRead1	=> sig_dataRead1,
		dataRead2	=> sig_dataRead2
	);
   
	
	
	-- Início do controle de clock	
	P_clockGen: PROCESS IS  
	BEGIN
		 	
		sig_clock <= '0';   -- Clock em nível baixo por 10 ns
		
		WAIT FOR 10 ns; 
		
		sig_clock <= '1';   -- Clock em nível alto por 10 ns
		
		WAIT FOR 10 ns;
		
	END PROCESS P_clockGen;
	-- Fim do controle de clock

	
	
	-- Início do Processo de Escrita (WRITE) e Leitura (READ) de dados presentes no Banco de Registradores.
	P_WriteRead: PROCESS IS                                               				 
	BEGIN

		-- Início do Processo de Escrita.
	
		-- Aguarda a próxima borda de subida do clock
		WAIT UNTIL RISING_EDGE(sig_clock);                    			 					

		-- Ativa o sinal Write Enabled.
		sig_we 				<= '1';     
		
		-- Atribui ao sinal "sig_regWrite" o valor 0.
		sig_regWrite		<= STD_LOGIC_VECTOR(TO_UNSIGNED(0, sig_regWrite'length));
		
		-- Atribui ao sinal "sig_dataWrite" o valor 0.
		sig_dataWrite  	<= STD_LOGIC_VECTOR(TO_UNSIGNED(0, sig_dataWrite'length));

		-- Insere valores no intervalo de 0 à 31 nos registradores de 0 à 31, respectivamente.
		WHILE UNSIGNED(sig_regWrite) /= (QTD_GPRS - 1) LOOP					

			-- Aguarda a próxima borda de subida do clock.
			WAIT UNTIL RISING_EDGE(sig_clock);                     			 				
			
			-- Incrementa o valor no sinal "sig_regWrite" que seleciona o registrador em que
			-- os dados informados em "sig_dataWrite" serão escritos.
			sig_regWrite 	<= STD_LOGIC_VECTOR(UNSIGNED(sig_regWrite) + 1);  
			
			-- Incrementa o valor do dado "sig_dataWrite" a ser inserido no registrador.
			sig_dataWrite  <= STD_LOGIC_VECTOR(UNSIGNED(sig_dataWrite) + 1);
				
		END LOOP;

		-- Fim do Processo de Escrita.
		
		
		-- Início do Processo de Leitura.
		WAIT UNTIL RISING_EDGE(sig_clock);

		-- Desativa o sinal Write Enabled.
		sig_we 				<= '0';   
		
		-- Atribui ao sinal "sig_regRead1" o valor 0.
		sig_regRead1 		<= STD_LOGIC_VECTOR(TO_UNSIGNED(0, sig_regRead1'length));
		
		-- Atribui ao sinal "sig_regRead2" o valor 31.
		sig_regRead2 		<= STD_LOGIC_VECTOR(TO_UNSIGNED(31, sig_regRead2'length));
		
		-- Lê valores nos registradores de 0 à 31, os registradores a serem lidos são seleciondos
		-- pelos valores especificados nos sinais "sig_regRead1" e "sig_dataRead2" respectivamente.
		-- "sig_regRead1" lê os dados de forma crescente, e contrário ocorre com "sig_regRead2".
		WHILE UNSIGNED(sig_regRead1) /= (QTD_GPRS - 1) LOOP
			
			-- Aguarda a próxima borda de subida do clock.
			WAIT UNTIL RISING_EDGE(sig_clock);                           	
			
			-- Incrementa o sinal "sig_regRead1".
			sig_regRead1 <= STD_LOGIC_VECTOR(UNSIGNED(sig_regRead1) + 1);	
			
			-- Decrementa o sinal "sig_regRead2".
			sig_regRead2 <= STD_LOGIC_VECTOR(UNSIGNED(sig_regRead2) - 1);
				
		END LOOP;
		
		-- Fim do Processo de Leitura.
			
	END PROCESS P_WriteRead;
	-- Fim do Processo de Escrita (WRITE) e Leitura (READ) de dados presentes no Banco de Registradores.
	
END ARCHITECTURE sinais;
-- Fim da declaração da arquitetura da entidade TestBench