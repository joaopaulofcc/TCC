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
 --# Arquivo: MIPS32_InstRAMCore.vhd													#
 --#                                                                      	#
 --# Sobre: Entidade responsável pela interface e gerência de operações   	#
 --#        com a memória RAM de instruções.                              	#
 --#                                                                      	#
 --# Operações Disponíveis:                                               	#
 --#                                                                      	#
 --#			* Leitura de instrução (32 bits)					               	#
 --#        * Escrita de um byte em uma determinada posiçao da RAM        	#
 --#        * Leitura de um byte em uma determinada posiçao da RAM        	#
 --#                                                                      	#
 --# 05/01/16 - Formiga - MG                                              	#
 --#########################################################################

 
-- Importa as bibliotecas de sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Importa as bibliotecas de usuário.
LIBRARY WORK;
USE WORK.MIPS32_Funcoes.ALL;


-- Início da declaração da entidade InstRamCore.
ENTITY MIPS32_InstRAMCore IS

	PORT 
	(
		clock		: IN 	STD_LOGIC;							-- Sinal de clock.
		reset		: IN 	STD_LOGIC := '0';					-- Sinal de reset do circuito, default = 0 (ativo por nível alto).
		
		address	: IN 	t_AddressINST;						-- Endereco a ser acessado na RAM de instruçoes.
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
ARCHITECTURE BEHAVIOR OF MIPS32_InstRAMCore IS

	-- Sinais para conexao com o componente RAM de Instruções.
	SIGNAL SIG_RAM_INST_clock 		:  STD_LOGIC;
	SIGNAL SIG_RAM_INST_we			:  STD_LOGIC;
	SIGNAL SIG_RAM_INST_address 	:  t_AddressINST;
	SIGNAL SIG_RAM_INST_dataIn 	:  t_Byte;
	SIGNAL SIG_RAM_INST_dataOut 	:  t_Byte;
	
	
	-- Máquina de estados da controladora.
	
		-- state_IRC_IDLE					: Estado de IDLE geral da entidade.
		
		--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
		
		-- %%%%%% FSM de controle de escrita de byte %%%%%%
		
		-- state_IRC_Write_IDLE			: Estado Ocioso da FSM de escrita de byte.
		-- state_IRC_Write_Solicita	: Estado onde é solicitada a escrita do byte, no endereço especificado pelo barramento externo.
		-- state_IRC_Write_Encerra		: Estado onde a gravaçao do byte solicitado foi bem sucedida e então a controladora informa tal fato ao ciruicto solicitante da operaçao.
		
		--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
		
		-- %%%%%% FSM de controle de leitura de byte %%%%%%
		
		-- state_IRC_Read_IDLE			: Estado Ocioso da FSM de leitura de byte.
		-- state_IRC_Read_Solicita		: Estado onde é solicitada a leitura do byte, no endereço especificado pelo barramento externo.
		-- state_IRC_Read_Envia			: Estado onde o byte já foi lido da memória e agora é enviado para o circuito solicitante. A controladora informa que a operaçao foi concluida.
		
		--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
		
		-- %%%%%% FSM de controle de leitura de instrucao %%%%%%
		
		-- state_IRC_IF_IDLE				: Estado Ocioso da FSM de leitura de instruçao.
		-- state_IRC_IF_Solicita1		: Estado onde é solicitada a leitura do primeiro byte, a partir de um determinado endereço especificado pelo barramento externo.
		-- state_IRC_IF_Busca1			: Estado onde o valor do primeiro byte lido, solicitado anteriormente é recuperado.
		-- state_IRC_IF_Solicita2		: Estado onde é solicitada a leitura do segundo byte, a partir de um determinado endereço especificado pelo barramento externo.
		-- state_IRC_IF_Busca2			: Estado onde o valor do segundo byte lido, solicitado anteriormente é recuperado.
		-- state_IRC_IF_Solicita3		: Estado onde é solicitada a leitura do terceiro byte, a partir de um determinado endereço especificado pelo barramento externo.
		-- state_IRC_IF_Busca3			: Estado onde o valor do terceiro byte lido, solicitado anteriormente é recuperado.
		-- state_IRC_IF_Solicita4		: Estado onde é solicitada a leitura do quarto byte, a partir de um determinado endereço especificado pelo barramento externo.
		-- state_IRC_IF_Busca4			: Estado onde o valor do quarto byte lido, solicitado anteriormente é recuperado.
		-- state_IRC_IF_Envia			: Estado onde os bytes lidos anteriormente são enviados de forma concatenada para fora da controladora, 
		-- 									  para o circuito solicitante da operaçao, formando assim a instruçao atual lida.
	
	-- Declaração da máquina de estados para controle do circuito.
	TYPE InstRAMCore_FSM IS(state_IRC_IDLE,
	
									state_IRC_Write_IDLE,   state_IRC_Write_Solicita, state_IRC_Write_Encerra,
									
									state_IRC_Read_IDLE,    state_IRC_Read_Solicita,  state_IRC_Read_Envia,
	
									state_IRC_IF_IDLE, 
									state_IRC_IF_Solicita1, state_IRC_IF_Busca1,
									state_IRC_IF_Solicita2, state_IRC_IF_Busca2,
									state_IRC_IF_Solicita3, state_IRC_IF_Busca3,
									state_IRC_IF_Solicita4, state_IRC_IF_Busca4,
									state_IRC_IF_Envia
									);
	
	SIGNAL currentState	: InstRAMCore_FSM := state_IRC_IDLE; -- Define o estado inicial da máquina como sendo o "state_IRC_IDLE".
	
	-- Sinais para conexão com barramentos externos do circuito, evitando assim que flutuaçoes na entrada propaguem no circuito.
	SIGNAL SIG_address	: t_AddressINST;
	SIGNAL SIG_dataIn		: t_Byte;
	SIGNAL SIG_dataOut	: t_Byte;
	SIGNAL SIG_instrucao : t_Word;
	SIGNAL SIG_opCode 	: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL SIG_ready 		: STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	SIGNAL SIG_stateOut1	: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_stateOut2	: STD_LOGIC_VECTOR(3 DOWNTO 0);	
		
BEGIN

	-- Mapeamento de portas do componente RAM de instruções.
	mapramINST: ENTITY WORK.MIPS32_RamInst
		PORT MAP
		(
			clock		=> SIG_RAM_INST_clock,
			we			=> SIG_RAM_INST_we,
			address	=> SIG_RAM_INST_address,
			dataIn	=> SIG_RAM_INST_dataIn,
			dataOut	=> SIG_RAM_INST_dataOut
		);
		
		
	-- Direciona os sinais dos barramentos externos para os respectivos sinais internos.
	SIG_address	<= address;
	SIG_dataIn	<= dataIn;
	dataOut		<= SIG_dataOut;
	SIG_opCode 	<= opcode;
	ready			<= SIG_ready;
	instrucao 	<= SIG_instrucao;
	
	stateOut1 	<= SIG_stateOut1;
	stateOut2 	<= SIG_stateOut2;
	
	
	-- Conecta o pino de clock da entidade com o pino da memória RAM de instruçoes para sincronia.
	SIG_RAM_INST_clock <= clock;
	
	
	
	-- Esse process é ativado com alteraçao de valores nos sinais: "clock" e "reset".
	PROCESS(clock, reset) 
		VARIABLE byte0: t_byte;	-- Variável responsável por armazenar o 1º byte da RAM na operação de leitura da instrução.
		VARIABLE byte1: t_byte;	-- Variável responsável por armazenar o 2º byte da RAM na operação de leitura da instrução.
		VARIABLE byte2: t_byte;	-- Variável responsável por armazenar o 3º byte da RAM na operação de leitura da instrução.
		VARIABLE byte3: t_byte;	-- Variável responsável por armazenar o 4º byte da RAM na operação de leitura da instrução.
	BEGIN
		
		-- Reset do circuito.
		IF (reset = '1') THEN
		
			-- Após o sinal de reset, de acordo com o valor presente no barramento de opCode (carregado em SIG_opCode), desvia a FSM para o estado correto.
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
					
				-- Leitura de byte da RAM.	
				WHEN "011" =>
				
					currentState <= state_IRC_Read_Solicita;
					
				-- Estados invalidos.
				WHEN OTHERS =>
				
					NULL;
			
			END CASE;
		
		-- Caso o sinal de reset não esteja ativo (alto) e seja borda de subida do clock, executa os comandos da FSM.
		ELSIF (RISING_EDGE(clock)) THEN
		
			-- Filtra de acordo com o estado atual da FSM apontado por "currentState".
			CASE currentState IS
			
				-- Estado de IDLE geral da controladora.
				WHEN state_IRC_IDLE =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "1111";
					SIG_stateOut2 <= "1111";
					
					-- Encaminha a FSM para o próprio estado atual.
					currentState <= state_IRC_IDLE;
			
					
					
					
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM PARA LEITURA DE INSTRUCAO %%%%%%%%%%%%%%%	
			
				-- Estado Ocioso da FSM de leitura de instruçao.
				WHEN state_IRC_IF_IDLE =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "1011";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
				
					-- Encaminha a FSM para o próprio estado atual.
					currentState <= state_IRC_IF_IDLE;
				
				
				-- %%	
			
			
				-- Estado onde é solicitada a leitura do primeiro byte, a partir de um determinado endereço especificado pelo barramento externo.
				WHEN state_IRC_IF_Solicita1 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0001";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais da memória RAM de instruçoes.
					SIG_RAM_INST_we 		<= '1';					-- Informa a memória que a operaçao a ser executada é a de leitura de instrucao.
					SIG_RAM_INST_dataIn 	<= (OTHERS => '0');	-- Garante o valor '0' no barramento de instruçoe.
					SIG_RAM_INST_address <= SIG_address;		-- Envia o valor presente no barramento "address" desse circuito para a memória informando o endereço a ser lido.
					
					-- Encaminha a FSM para o estado de Busca do primeiro byte da instruçao.
					currentState <= state_IRC_IF_Busca1;
					
				
				-- %%	
			
			
				-- Estado onde o valor do primeiro byte lido, solicitado anteriormente é recuperado.
				WHEN state_IRC_IF_Busca1 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0010";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Armazena o dado lido da memória na variável correspondente.
					byte0 := SIG_RAM_INST_dataOut;
					
					-- Encaminha a FSM para o estado de solicitaçao de leitura do segundo byte.
					currentState <= state_IRC_IF_Solicita2;
				
				
				-- %%	
			
				
				-- Estado onde é solicitada a leitura do segundo byte, a partir de um determinado endereço especificado pelo barramento externo.
				WHEN state_IRC_IF_Solicita2 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0011";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais da memória RAM de instruçoes.
					SIG_RAM_INST_we 		<= '1';					-- Informa a memória que a operaçao a ser executada é a de leitura de instrucao.
					SIG_RAM_INST_dataIn 	<= (OTHERS => '0');	-- Garante o valor '0' no barramento de instruçoe.
					SIG_RAM_INST_address <= SIG_address + 1;	-- Envia o valor presente no barramento "address" + 1 desse circuito para a memória informando o endereço a ser lido.
					
					-- Encaminha a FSM para o estado de Busca do segundo byte da instruçao.
					currentState <= state_IRC_IF_Busca2;
					
				
				-- %%	
			
			
				-- Estado onde o valor do segundo byte lido, solicitado anteriormente é recuperado.
				WHEN state_IRC_IF_Busca2 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0100";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
				
					-- Armazena o dado lido da memória na variável correspondente.
					byte1 := SIG_RAM_INST_dataOut;
					
					
					-- Encaminha a FSM para o estado de solicitaçao de leitura do segundo byte.
					currentState <= state_IRC_IF_Solicita3;
					
				
				-- %%	
			
			
				-- Estado onde é solicitada a leitura do terceiro byte, a partir de um determinado endereço especificado pelo barramento externo.
				WHEN state_IRC_IF_Solicita3 =>
					
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0101";
				
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
				
					-- Preenche os sinais da memória RAM de instruçoes.
					SIG_RAM_INST_we 		<= '1';					-- Informa a memória que a operaçao a ser executada é a de leitura de instrucao.
					SIG_RAM_INST_dataIn 	<= (OTHERS => '0');	-- Garante o valor '0' no barramento de instruçoe.
					SIG_RAM_INST_address <= SIG_address + 2;	-- Envia o valor presente no barramento "address" + 2 desse circuito para a memória informando o endereço a ser lido.
					
					-- Encaminha a FSM para o estado de Busca do terceiro byte da instruçao.
					currentState <= state_IRC_IF_Busca3;
				
				
				-- %%	
			
			
				-- Estado onde o valor do terceiro byte lido, solicitado anteriormente é recuperado.
				WHEN state_IRC_IF_Busca3 =>
					
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0110";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Armazena o dado lido da memória na variável correspondente.
					byte2 := SIG_RAM_INST_dataOut;
					
					-- Encaminha a FSM para o estado de solicitaçao de leitura do segundo byte.
					currentState <= state_IRC_IF_Solicita4;
					
				
				-- %%	
			
			
				-- Estado onde é solicitada a leitura do quarto byte, a partir de um determinado endereço especificado pelo barramento externo.
				WHEN state_IRC_IF_Solicita4 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0111";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais da memória RAM de instruçoes.
					SIG_RAM_INST_we 		<= '1';					-- Informa a memória que a operaçao a ser executada é a de leitura de instrucao.
					SIG_RAM_INST_dataIn 	<= (OTHERS => '0');	-- Garante o valor '0' no barramento de instruçoes.
					SIG_RAM_INST_address <= SIG_address + 3;	-- Envia o valor presente no barramento "address" + 3 desse circuito para a memória informando o endereço a ser lido.
					
					-- Encaminha a FSM para o estado de Busca do quarto byte da instruçao.
					currentState <= state_IRC_IF_Busca4;
					
				
				-- %%	
			
			
				-- Estado onde o valor do quarto byte lido, solicitado anteriormente é recuperado.
				WHEN state_IRC_IF_Busca4 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "1000";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Armazena o dado lido da memória na variável correspondente.
					byte3 := SIG_RAM_INST_dataOut;
					
					-- Encaminha a FSM para o estado de envio de todos os bytes lidos da memória, formando a instruçao atual.
					currentState <= state_IRC_IF_Envia;
					
				
				-- %%	
			
				
				-- Estado onde os bytes lidos anteriormente são enviados de forma concatenada para fora da controladora, 
				-- para o circuito solicitante da operaçao, formando assim a instruçao atual lida.
				WHEN state_IRC_IF_Envia =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "1001";
				
					-- Concatena os bytes lidos e envia para o barramento de instruçao.
					SIG_instrucao <= byte3 & byte2 & byte1 & byte0;
					
					-- Sinaliza no barramento "ready" que a operação foi concluida.
					SIG_ready <= "001";
					
					-- Encaminha a FSM para o estado IDLE do processo de leitura de instruçao.
					currentState <= state_IRC_IF_IDLE;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM PARA LEITURA DE INSTRUCAO %%%%%%%%%%%%%%%	
				
					
					
					
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM PARA ESCRITA DE BYTE %%%%%%%%%%%%%%%	
				
				-- Estado Ocioso da FSM de escrita de byte.
				WHEN state_IRC_Write_IDLE =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0100";
					
					-- Garante que a memória de instruçoes está setada somente para leitura, evitando processos de escrita indesejados.
					SIG_RAM_INST_we <= '1';
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
	
					-- Encaminha a FSM para o próprio estado atual.
					currentState <= state_IRC_Write_IDLE;
					
				
				-- %%	
			
			
				-- Estado onde é solicitada a escrita do byte, no endereço especificado pelo barramento externo.
				WHEN state_IRC_Write_Solicita =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0001";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
				
					-- Preenche os sinais da memória RAM de instruçoes.
					SIG_RAM_INST_we <= '0';						-- Informa a memória que a operaçao a ser executada é a de escrita de byte.
					SIG_RAM_INST_address <= SIG_address;	-- Envia o valor presente no barramento "address" desse circuito para a memória informando o endereço que será escrito.
					SIG_RAM_INST_dataIn 	<= SIG_dataIn;		-- Envia o valor presente no barramento "dataIn" desse circuito para a memória informando o valor que será escrito.
					
					-- Encaminha a FSM para de encerramento da escrita de byte.
					currentState <= state_IRC_Write_Encerra;
					
				
				-- %%	
			
			
				-- Estado onde a gravaçao do byte solicitado foi bem sucedida e então a controladora informa tal fato ao ciruicto solicitante da operaçao.
				WHEN state_IRC_Write_Encerra =>
					
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0011";
		
					-- Sinaliza no barramento "ready" que a operação foi concluida.
					SIG_ready <= "010";
					
					-- Encaminha a FSM para o estado IDLE do processo de escrita de byte.
					currentState <= state_IRC_Write_IDLE;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM PARA ESCRITA DE BYTE %%%%%%%%%%%%%%%	
				
					
					
					
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM PARA LEITURA DE BYTE %%%%%%%%%%%%%%%
				
				-- Estado Ocioso da FSM de leitura de byte.
				WHEN state_IRC_Read_IDLE =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0011";
					SIG_stateOut2 <= "0011";
				
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
				
					-- Encaminha a FSM para o próprio estado atual.
					currentState <= state_IRC_Read_IDLE;
				
				
				-- %%	
			
			
				-- Estado onde é solicitada a leitura do byte, no endereço especificado pelo barramento externo.
				WHEN state_IRC_Read_Solicita =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0011";
					SIG_stateOut2 <= "0001";
				
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais da memória RAM de instruçoes.
					SIG_RAM_INST_we <= '1';							-- Informa a memória que a operaçao a ser executada é a de leitura de byte.
					SIG_RAM_INST_address <= SIG_address;		-- Envia o valor presente no barramento "address" desse circuito para a memória informando o endereço que será lido.	
					SIG_RAM_INST_dataIn	<= (OTHERS => '0');	-- Garante o valor '0' no barramento de dados.
					
					-- Encaminha a FSM para o estado de envio do byte lido.
					currentState <= state_IRC_Read_Envia;
					
				
				-- %%	
			
			
				-- Estado onde o byte já foi lido da memória e agora é enviado para o circuito solicitante. A controladora informa que a operaçao foi concluida.
				WHEN state_IRC_Read_Envia =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0011";
					SIG_stateOut2 <= "0010";
				
					-- Encaminha o byte lido para o barramento de saida de byte.
					SIG_dataOut	<= SIG_RAM_INST_dataOut;
				
					-- Sinaliza no barramento "ready" que a operação foi concluida.
					SIG_ready <= "011";
				
					-- Encaminha a FSM para o estado IDLE do processo de leitura de byte.
					currentState <= state_IRC_Read_IDLE;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM PARA LEITURA DE BYTE %%%%%%%%%%%%%%%
					
					
				-- Estados invalidos;
				WHEN OTHERS =>
					
					NULL;
				
			END CASE;
		
		END IF;
		
	END PROCESS;
	
END BEHAVIOR;
-- Fim da declaração da arquitetura da entidade InstRAMCore.