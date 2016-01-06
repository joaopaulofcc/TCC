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
 --# Arquivo: MIPS32_Testbench.vhd	 													#
 --#                                                                      	#
 --# Sobre: Esse arquivo descreve um arquivo de testbench para o arquivo	#
 --# 			MIPS32_Control.																#
 --#                                                                      	#
 --# 05/01/16 - Formiga - MG                                              	#
 --#########################################################################
 
-- Importa bibliotecas do sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

-- Importa as bibliotecas de usuário.
LIBRARY WORK;
USE WORK.MIPS32_Funcoes.ALL;
USE STD.TEXTIO.ALL;

-- Início da declaração da entidade MIPS32_Testbench.
ENTITY MIPS32_Testbench IS


END ENTITY MIPS32_Testbench;
-- Fim da declaração da entidade MIPS32_Testbench.


-- Início da declaração da arquitetura da entidade MIPS32_Testbench
ARCHITECTURE BEHAVIOR OF MIPS32_Testbench IS
	
	-- Sinais internos
	SIGNAL SIG_address	: 	t_AddressDATA;
	SIGNAL SIG_dataOUT	: 	t_Byte;
	SIGNAL SIG_dataIN		:	t_Byte;
	SIGNAL SIG_clockOUT	: 	STD_LOGIC;
	SIGNAL SIG_clockIN	: 	STD_LOGIC;
	SIGNAL SIG_opCode		: 	STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL SIG_ready		: 	STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL SIG_error		: 	STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL SIG_reset		:	STD_LOGIC;
  
  
	-- Funçao responsável por converter uma string em um vetor STD_LOGIC_VECTOR.
	FUNCTION str2vec(str : STRING) RETURN STD_LOGIC_VECTOR IS
		VARIABLE vtmp: STD_LOGIC_VECTOR(str'RANGE);
	BEGIN
	
		FOR i IN str'RANGE LOOP
		
			IF str(i) = '1' THEN
			
				vtmp(i) := '1';
				
			ELSIF str(i) = '0' THEN
			
				vtmp(i) := '0';
				
			ELSE
			
				vtmp(i) := 'X';
				
			END IF;
			
		END LOOP;
		
		RETURN vtmp;
		
	END str2vec;
	
	
	-- Funçao utilizada para converter um vetor STD_LOGIC_VECTOR em string.
	FUNCTION vec2str(vec : STD_LOGIC_VECTOR) RETURN STRING IS
		VARIABLE stmp : string(vec'LEFT+1 DOWNTO 1);
	BEGIN
	
		FOR i IN vec'REVERSE_RANGE LOOP
		
			IF vec(i) = '1' THEN
			
				stmp(i + 1) := '1';
				
			ELSIF vec(i) = '0' THEN
			
				stmp(i + 1) := '0';
				
			ELSE
			
				stmp(i + 1) := 'X';
				
			END IF;
			
		END LOOP;
		
		RETURN stmp;
		
	END vec2str;
  

BEGIN

	-- Importaçao e mapeamento de portas do componente MIPS32_Control com sinais do TestBench
	UUT_MIPS32_Control: ENTITY WORK.MIPS32_Control PORT MAP                                          			    
	(
		address			=> SIG_address,
		dataOUT			=> SIG_dataOUT,
		dataIN			=> SIG_dataIN,
		PIN_clockOut	=> SIG_clockOUT,
		PIN_clockIN		=> SIG_clockIN,
		opCode			=> SIG_opCode,
		ready				=> SIG_ready,
		error				=> SIG_error,
		reset				=> SIG_reset
	);	
	
					
					
				
	-- Início do controle de clock	
	P_clockGen: PROCESS IS  
	BEGIN
		 	
		-- 10ns alto e 10ns baixo = 50MHz
			
		SIG_clockIN <= '0';   -- Clock em nível baixo por 10 ns
		
		WAIT FOR 10 ns; 
		
		SIG_clockIN <= '1';   -- Clock em nível alto por 10 ns
		
		WAIT FOR 10 ns;
		
	END PROCESS P_clockGen;
	-- Fim do controle de clock
	
					
					
				
	-- Início do process para execução do circuito (Carregar dados do arquivo, Executar e Ler Registradores)
	P_LeREGS: PROCESS IS
		
		FILE vector_file: TEXT IS IN "fatorial7.txt";				-- Declara uma variável do tipo arquivo e aponta para o path do arquivo de instruçoes que deverá ser carregado.
		VARIABLE file_line : LINE; 									-- Armazena uma linha lido do arquivo.
		VARIABLE str_stimulus_in: STRING(32 DOWNTO 1);			-- Armazena a instruçao da linha lida (32 bites).
		VARIABLE stimulus_in : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Armazena a instruçao lida pós conversão para STD_LOGIC_VECTOR.
		
		VARIABLE indexByteDataINF 	: INTEGER; 						-- Variáveis auxiliares.
		VARIABLE indexByteDataSUP 	: INTEGER;
		VARIABLE contAddress 		: INTEGER;
		
	BEGIN
		
		
		-- %%%%%%%%%%%%%%% SOLICITAÇAO DE RESET DO MIPS %%%%%%%%%%%%%%%
		
		-- Envia ao MIPS opCode para reset do MIPS.
		SIG_opCode <= "101";
		
		-- Aguarda primeira borda de subida do clock.
		WAIT UNTIL RISING_EDGE(SIG_clockOUT);
			
		-- Reseta circuito.
		SIG_reset 		<= '1';
		
		-- Aguarda primeira borda de subida do clock.
		WAIT UNTIL RISING_EDGE(SIG_clockOUT);			 					
	
		SIG_reset 		<= '0';
		
		-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
					
					
				
		-- %%%%%%%%%%%%%%% SOLICITAÇAO DE CARREGAMENTO DAS INSTRUÇOÕES CONTIDAS NO ARQUIVO TEXTO %%%%%%%%%%%%%%%
		
		-- Inicializa contador de endereço.
		contAddress := 0;	
		
		-- Percorre todas as linhas do arquivo texto.
		while NOT ENDFILE(vector_file) LOOP	
		
			-- Lê a próxima linha do arquivo.
			READLINE(vector_file, file_line);
			
			-- Extrai dessa linha a instruçao.
			READ(file_line, str_stimulus_in);
			
			-- Converte a instruçao lida para STD_LOGIC_VECTOR.
			stimulus_in := str2vec(str_stimulus_in);
			
			-- Inicializa os índices para leitura e envio dos bytes da instruçao.
			indexByteDataINF := 0;
			indexByteDataSUP := 7;
				
			-- Envia ao MIPS, byte a byte a instruçao lida.
			FOR i IN 0 TO 3 LOOP
			
				-- Envia ao MIPS opCode para envio de instruçao.
				SIG_opCode <= "001";
			
				-- Envia endereço onde o byte será escrito.
				SIG_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(contAddress, SIG_address'LENGTH));
				
				-- Envia byte a ser escrito.
				SIG_dataIN <= stimulus_in(indexByteDataSUP DOWNTO indexByteDataINF);
				
				
				-- Aguarda primeira borda de subida do clock.
				WAIT UNTIL RISING_EDGE(SIG_clockOUT);
					
				-- Reseta circuito.
				SIG_reset 		<= '1';
				
				-- Aguarda primeira borda de subida do clock.
				WAIT UNTIL RISING_EDGE(SIG_clockOUT);			 					
			
				SIG_reset 		<= '0';
			
		
				-- Aguarda confirmaçao de conclusão da escrita do byte.
				WAIT UNTIL SIG_ready = "001";
				
				-- Incrementa índices.
				indexByteDataINF := indexByteDataINF + 8;
				indexByteDataSUP := indexByteDataSUP + 8;
				
				-- Incrementa contador de endereço.
				contAddress := contAddress + 1;
				
			END LOOP;
			
		END LOOP;
		
		-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			
					
					
		
		-- %%%%%%%%%%%%%%% SOLICITAÇAO DE EXECUÇAO DAS INSTRUÇOES CARREGADAS %%%%%%%%%%%%%%%
		
		-- Envia ao MIPS opCode para execução das instruçoes.
		SIG_opCode <= "111";
		
		-- Aguarda primeira borda de subida do clock.
		WAIT UNTIL RISING_EDGE(SIG_clockOUT);
			
		-- Reseta circuito.
		SIG_reset 		<= '1';
		
		-- Aguarda primeira borda de subida do clock.
		WAIT UNTIL RISING_EDGE(SIG_clockOUT);			 					

		SIG_reset 		<= '0';
		
		-- Aguarda confirmaçao de conclusão da escrita do byte.
		WAIT UNTIL SIG_ready = "101";
		
		-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
					
					
		
		-- %%%%%%%%%%%%%%% SOLICITAÇAO DE LEITURA DE TODOS OS REGISTRADORES %%%%%%%%%%%%%%%
		
		-- Percorre todos os registradores.
		FOR i IN 0 TO 33 LOOP
		
			-- Solicita byte a byte o conteúdo do i-ésimo registrador.
			FOR j IN 0 TO 3 LOOP
			
				-- Envia ao MIPS opCode para leitura do Banco de Registradores.
				SIG_opCode <= "011";
				
				-- Envia o endereço do registrador a ser lido
				SIG_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, SIG_address'LENGTH));
				
				-- Envia qual e o byte que deve ser lido do dado contido no registrador.
				SIG_dataIN <= STD_LOGIC_VECTOR(TO_UNSIGNED(j, SIG_dataIN'LENGTH));
				
				
				-- Aguarda primeira borda de subida do clock.
				WAIT UNTIL RISING_EDGE(SIG_clockOUT);
					
				-- Reseta circuito.
				SIG_reset 		<= '1';
				
				-- Aguarda primeira borda de subida do clock.
				WAIT UNTIL RISING_EDGE(SIG_clockOUT);			 					

				SIG_reset 		<= '0';
				
				-- Aguarda confirmaçao de conclusão da leitura do byte.
				WAIT UNTIL SIG_ready = "011";
				
				END LOOP;
			
		END LOOP;	
		
		-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
		-- Delay até próxima execução do testbench.
		WAIT FOR 1 sec;
			
	END PROCESS P_LeREGS;
	
	
END ARCHITECTURE BEHAVIOR;
-- Fim da declaração da arquitetura da entidade MIPS32_Testbench