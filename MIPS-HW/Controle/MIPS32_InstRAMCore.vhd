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
 --# Arquivo: MIPS32_InstRAMCore.vhd													#
 --#                                                                      	#
 --# Sobre: Entidade responsável pela interface e gerência de operações   	#
 --#        com a memória RAM de instruções.                              	#
 --#                                                                      	#
 --# Operações Disponíveis:                                               	#
 --#                                                                      	#
 --#			* Leitura de instrução (32 bits);				               	#
 --#        * Escrita de byte em uma determinada posiçao da RAM           	#
 --#        * Leitura de byte em uma determinada posiçao da RAM           	#
 --#                                                                      	#
 --# 23/12/15 - Formiga - MG                                              	#
 --#########################################################################

 
-- Importa as bibliotecas de sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Importa as bibliotecas de usuário.
LIBRARY WORK;
USE WORK.funcoes.ALL;


-- Início da declaração da entidade InstRamCore.
ENTITY MIPS32_InstRAMCore IS

	PORT 
	(
		clock		: IN 	STD_LOGIC;							-- Sinal de relógio para sincronia.
		reset		: IN 	STD_LOGIC := '0';					-- Sinal de reset do circuito, default = 0 (ativo por nível alto).
		
		address	: IN 	t_AddressINST;						-- Endereco a ser acessado na RAM de instruções.
		dataIn	: IN 	t_Byte;								-- Byte a ser salvo na posicao "address" da RAM de instruções.
		dataOut	: OUT t_Byte;								-- Byte lido da posicao "address" da RAM de instruções.
		instrucao: OUT t_Word;								-- Instrucao lida da memória de instruções (32 bits) a partir da posiçao "address".
		
		opCode	: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);	-- Seletor de operação do circuito.
		ready		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);	-- Sinal indicador de conclusão da operação especificada por "opCode".
		
		
		stateOut1: OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Sinal de Debug: sinaliza a operação atual executada no circuito.
		stateOut2: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)	-- Sinal de Debug: sinaliza o estado atual dentro da FSM que executa a operação especificada em "opCode".
	);

END ENTITY;
-- Fim da declaração da entidade InstRamCore.


-- Início da declaração da arquitetura da entidade InstRamCore.
ARCHITECTURE Behavioral OF MIPS32_InstRAMCore IS

	-- Sinais para conexao com o componente RAM de Instruções.
	SIGNAL SIG_RAM_INST_clock 		:  STD_LOGIC;
	SIGNAL SIG_RAM_INST_we			:  STD_LOGIC;
	SIGNAL SIG_RAM_INST_address 	:  t_AddressINST;
	SIGNAL SIG_RAM_INST_dataIn 	:  t_Byte;
	SIGNAL SIG_RAM_INST_dataOut 	:  t_Byte;
	
	
	-- Declaração da máquina de estados para controle do circuito.
	TYPE InstRAMCore_FSM IS(state_IRC_IDLE,
	
									state_IRC_Write_IDLE, state_IRC_Write_Solicita, state_IRC_Write_Encerra,
									
									state_IRC_Read_IDLE, state_IRC_Read_Solicita, state_IRC_Read_Envia,
	
									state_IRC_IF_IDLE, state_IRC_IF_BuscaPC, 
									state_IRC_IF_Solicita1, state_IRC_IF_Busca1,
									state_IRC_IF_Solicita2, state_IRC_IF_Busca2,
									state_IRC_IF_Solicita3, state_IRC_IF_Busca3,
									state_IRC_IF_Solicita4, state_IRC_IF_Busca4,
									state_IRC_IF_Envia
									);
	
	-- Sinal que armazena o estado atual da FSM.
	SIGNAL currentState	: InstRAMCore_FSM := state_IRC_IDLE;
	
	-- Sinais para conexão interna com os pinos de entrada e saída da entidade.
	SIGNAL SIG_address	: t_AddressINST;
	SIGNAL SIG_dataIn		: t_Byte;
	SIGNAL SIG_dataOut	: t_Byte;
	SIGNAL SIG_instrucao : t_Word;
	SIGNAL SIG_opCode 	: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL SIG_ready 		: STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	SIGNAL SIG_stateOut1	: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_stateOut2	: STD_LOGIC_VECTOR(3 DOWNTO 0);	
	
	
	
		
BEGIN

	-- Mapeamento de portas do componente RAM de Instruções.
	mapramINST: ENTITY WORK.ramINST
		PORT MAP
		(
			clock		=> SIG_RAM_INST_clock,
			we			=> SIG_RAM_INST_we,
			address	=> SIG_RAM_INST_address,
			dataIn	=> SIG_RAM_INST_dataIn,
			dataOut	=> SIG_RAM_INST_dataOut
		);
		
		
	-- Carrega os valores dos pinos de IO da entidade nos seus respectivos sinais.
	SIG_address	<= address;
	SIG_dataIn	<= dataIn;
	dataOut		<= SIG_dataOut;
	SIG_opCode 	<= opcode;
	ready			<= SIG_ready;
	instrucao 	<= SIG_instrucao;
	
	stateOut1 	<= SIG_stateOut1;
	stateOut2 	<= SIG_stateOut2;
	
	-- Conecta o pino de clock da entidade com o pino da memória RAM de instruções para sincronia.
	SIG_RAM_INST_clock <= clock;
	
	
	
	-- Process para controle da máquina de estados (FSM).
	PROCESS(clock, reset) 
		VARIABLE byte0: t_byte;	-- Variável responsável por armazenar o 1º byte da RAM na operação de leitura da instrução.
		VARIABLE byte1: t_byte;	-- Variável responsável por armazenar o 2º byte da RAM na operação de leitura da instrução.
		VARIABLE byte2: t_byte;	-- Variável responsável por armazenar o 3º byte da RAM na operação de leitura da instrução.
		VARIABLE byte3: t_byte;	-- Variável responsável por armazenar o 4º byte da RAM na operação de leitura da instrução.
		
		--VARIABLE PC				: t_addressINST;
	BEGIN
		
		-- Caso seja solicitado reset do circuito (i.e. reset = '1').
		IF (reset = '1') THEN
		
			-- Verifica qual a operação selecionada pelo "opCode".
			CASE SIG_opCode IS
				
				-- Circuito ocioso, ou em IDLE.
				WHEN "000" =>
				
					currentState <= state_IRC_IDLE;
				
				-- Leitura de instruçao da RAM.
				WHEN "001" =>
				
					currentState <= state_IRC_IF_Solicita1;
				
				-- Escrita de byte na RAM.
				WHEN "010" =>
				
					currentState <= state_IRC_Write_Solicita;
					
				-- Leitura de byte na RAM.	
				WHEN "011" =>
				
					currentState <= state_IRC_Read_Solicita;
					
				-- Outros.
				WHEN OTHERS =>
				
					NULL;
			
			END CASE;
		
		-- Caso reset = 0 e clock = 1.
		ELSIF (RISING_EDGE(clock)) THEN
		
			-- Filtra de acordo com o estado atual da FSM apontado por "currentState".
			CASE currentState IS
			
				-- Estado de IDLE geral da entidade.
				WHEN state_IRC_IDLE =>
				
					SIG_stateOut1 <= "1111";
					SIG_stateOut2 <= "1111";

					currentState <= state_IRC_IDLE;
			
				
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM PARA LEITURA DE INSTRUCAO %%%%%%%%%%%%%%%	
			
				-- Estado Ocioso da FSM de Leitura.
				WHEN state_IRC_IF_IDLE =>
				
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "1011";
					
					SIG_ready <= "000";
					
					--PC := SIG_address;
				
					currentState <= state_IRC_IF_IDLE;
				
				
				WHEN state_IRC_IF_BuscaPC =>
				
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0001";
					
					SIG_ready <= "000";
					
					--PC := SIG_address;
					
					currentState <= state_IRC_IF_Solicita1;
			
			
				-- Solicita a leitura do primeiro byte do PC.
				WHEN state_IRC_IF_Solicita1 =>
				
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0001";
					
					SIG_ready <= "000";
					
					SIG_RAM_INST_we 		<= '1';
					SIG_RAM_INST_dataIn 	<= (OTHERS => '0');
					SIG_RAM_INST_address <= SIG_address;
					
					currentState <= state_IRC_IF_Busca1;
					
					
				-- Recupera o valor lido da posicçao solicitada anteriormente.
				WHEN state_IRC_IF_Busca1 =>
				
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0010";
					
					SIG_ready <= "000";
					
					byte0 := SIG_RAM_INST_dataOut;
					
					--PC := PC + 1;
					
					currentState <= state_IRC_IF_Solicita2;
				
				
				WHEN state_IRC_IF_Solicita2 =>
				
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0011";
					
					SIG_ready <= "000";
					
					SIG_RAM_INST_we 		<= '1';
					SIG_RAM_INST_dataIn 	<= (OTHERS => '0');
					SIG_RAM_INST_address <= SIG_address + 1;
					
					currentState <= state_IRC_IF_Busca2;
					
					
				WHEN state_IRC_IF_Busca2 =>
				
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0100";
					
					SIG_ready <= "000";
				
					byte1 := SIG_RAM_INST_dataOut;
					
					--PC := PC + 1;
					
					currentState <= state_IRC_IF_Solicita3;
					
					
				WHEN state_IRC_IF_Solicita3 =>
					
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0101";
				
					SIG_ready <= "000";
				
					SIG_RAM_INST_we 		<= '1';
					SIG_RAM_INST_dataIn 	<= (OTHERS => '0');
					SIG_RAM_INST_address <= SIG_address + 2;
					
					currentState <= state_IRC_IF_Busca3;
				
					
				WHEN state_IRC_IF_Busca3 =>
					
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0110";
					
					SIG_ready <= "000";
					
					byte2 := SIG_RAM_INST_dataOut;
					
					--PC := PC + 1;
					
					currentState <= state_IRC_IF_Solicita4;
					

				WHEN state_IRC_IF_Solicita4 =>
				
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0111";
					
					SIG_ready <= "000";
					
					SIG_RAM_INST_we 		<= '1';
					SIG_RAM_INST_dataIn 	<= (OTHERS => '0');
					SIG_RAM_INST_address <= SIG_address + 3;
					
					currentState <= state_IRC_IF_Busca4;
					
					
				WHEN state_IRC_IF_Busca4 =>
				
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "1000";
					
					SIG_ready <= "000";
					
					byte3 := SIG_RAM_INST_dataOut;
					
					--PC := PC + 1;
					
					currentState <= state_IRC_IF_Envia;
					
					
				WHEN state_IRC_IF_Envia =>
				
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "1001";
				
					SIG_instrucao <= byte3 & byte2 & byte1 & byte0;
					
					SIG_ready <= "001";
					
					currentState <= state_IRC_IF_IDLE;
					
				
				--WHEN state_IRC_IF_Encerra =>
				
				--	SIG_stateOut1 <= "0001";
				--	SIG_stateOut2 <= "1010";
				
				--	SIG_ready <= "001";
				
				--	currentState <= state_IRC_IF_IDLE;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM PARA LEITURA DE INSTRUCAO %%%%%%%%%%%%%%%	
				
			
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM PARA ESCRITA DE BYTE %%%%%%%%%%%%%%%	
				
				WHEN state_IRC_Write_IDLE =>
				
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0100";
					
					SIG_RAM_INST_we <= '1';
					
					SIG_ready <= "000";
	
					currentState <= state_IRC_Write_IDLE;
					
				
				WHEN state_IRC_Write_Solicita =>
				
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0001";
					
					SIG_ready <= "000";
				
					SIG_RAM_INST_we <= '0';
					SIG_RAM_INST_address <= SIG_address;
					SIG_RAM_INST_dataIn 	<= SIG_dataIn;
					
					currentState <= state_IRC_Write_Encerra;
					
					
				--WHEN state_IRC_Write_Aguarda =>
					
				--	SIG_stateOut1 <= "0010";
				--	SIG_stateOut2 <= "0010";
					
				--	SIG_ready <= "010";
					
				--	SIG_RAM_INST_we <= '0';
					
				--	currentState <= state_IRC_Write_Encerra;
					
					
				WHEN state_IRC_Write_Encerra =>
					
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0011";
		
					SIG_ready <= "010";
				
					SIG_RAM_INST_we <= '0';
					
					currentState <= state_IRC_Write_IDLE;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM PARA ESCRITA DE BYTE %%%%%%%%%%%%%%%	
				
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM PARA LEITURA DE BYTE %%%%%%%%%%%%%%%
				
				WHEN state_IRC_Read_IDLE =>
				
					SIG_stateOut1 <= "0011";
					SIG_stateOut2 <= "0100";
				
					SIG_ready <= "000";
				
					currentState <= state_IRC_Read_IDLE;
				
			
				WHEN state_IRC_Read_Solicita =>
				
					SIG_stateOut1 <= "0011";
					SIG_stateOut2 <= "0001";
				
					SIG_RAM_INST_we <= '1';
					
					SIG_ready <= "000";
					
					SIG_RAM_INST_address <= SIG_address;
					SIG_RAM_INST_dataIn	<= (OTHERS => '0');
					
					currentState <= state_IRC_Read_Envia;
					
					
				WHEN state_IRC_Read_Envia =>
				
					SIG_stateOut1 <= "0011";
					SIG_stateOut2 <= "0010";
				
					SIG_dataOut	<= SIG_RAM_INST_dataOut;
				
					SIG_ready <= "011";
				
					currentState <= state_IRC_Read_IDLE;
					
					
				--WHEN state_IRC_Read_Encerra =>
				
				--	SIG_stateOut1 <= "0011";
				--	SIG_stateOut2 <= "0011";
					
				--	SIG_ready <= "011";
				
				--	currentState <= state_IRC_Read_IDLE;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM PARA LEITURA DE BYTE %%%%%%%%%%%%%%%
					
					
				-- Outros.
				WHEN OTHERS =>
					
					NULL;
				
			END CASE;
		
		END IF;
		
	END PROCESS;
	
END Behavioral;
-- Fim da declaração da arquitetura da entidade InstRamCore.