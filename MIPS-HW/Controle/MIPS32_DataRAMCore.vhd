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
 --# Arquivo: MIPS32_DataRAMCore.vhd													#
 --#                                                                      	#
 --# Sobre: Entidade responsável pela interface e gerência de operações   	#
 --#        com a memória RAM de Dados.	                              	#
 --#                                                                      	#
 --# Operações Disponíveis:                                               	#
 --#                                                                      	#
 --#     * Escrita de 1, 2, 3 ou 4 bytes em uma determinada posiçao da RAM #
 --#     * Leitura de 1, 2, 3 ou 4 bytes em uma determinada posiçao da RAM	#
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


-- Início da declaração da entidade DataRAMCore.
ENTITY MIPS32_DataRAMCore IS

	PORT 
	(
		clock		: IN 	STD_LOGIC;							-- Sinal de clock.
		reset		: IN 	STD_LOGIC := '0';					-- Sinal de reset do circuito, default = 0 (ativo por nível alto).
		
		address	: IN 	t_AddressDATA;						-- Endereco a ser acessado na RAM de dados.
		dataIn	: IN 	t_Word;								-- Byte a ser salvo na posicao "address" da RAM de dados.
		dataOut	: OUT t_Word;								-- Byte lido da posicao "address" da RAM de dados.
		
		bytes		: IN STD_LOGIC_VECTOR(1 DOWNTO 0);	-- Controla a quantidade de bytes a serem lidos ou escritos.
		
		opCode	: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);	-- Seletor de operação do circuito.
		ready		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);	-- Sinal indicador de conclusão da operação especificada por "opCode".
		
		
		stateOut1: OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Sinal de Debug: sinaliza a operação atual executada no circuito.
		stateOut2: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)	-- Sinal de Debug: sinaliza o estado atual dentro da FSM que executa a operação especificada em "opCode".
	);

END ENTITY;
-- Fim da declaração da entidade DataRAMCore.


-- Início da declaração da arquitetura da entidade DataRAMCore.
ARCHITECTURE BEHAVIOR OF MIPS32_DataRAMCore IS

	-- Sinais para conexao com o componente RAM de Dados.
	SIGNAL SIG_RAM_DATA_clock 		:  STD_LOGIC;
	SIGNAL SIG_RAM_DATA_we			:  STD_LOGIC;
	SIGNAL SIG_RAM_DATA_reset		:  STD_LOGIC;
	SIGNAL SIG_RAM_DATA_address 	:  t_AddressINST;
	SIGNAL SIG_RAM_DATA_dataIn 	:  t_Byte;
	SIGNAL SIG_RAM_DATA_dataOut 	:  t_Byte;
	
	
	-- Máquina de estados da controladora.
	
		-- state_DRC_IDLE 				: Filtra de acordo com o estado atual da FSM apontado por "nextState".
		
		-- state_DRC_Reset				: Estado de Reset da memória.
		
		--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
		
		-- %%%%%% FSM de controle de leitura %%%%%%
		
		-- state_DRC_Read_IDLE			: Estado Ocioso da FSM de Leitura.
		-- state_DRC_Read_Solicita1	: Estado onde é solicitada a leitura do primeiro byte, a partir de um determinado endereço especificado pelo barramento externo.
		-- state_DRC_Read_Busca1		: Estado onde o valor do primeiro byte lido, solicitado anteriormente é recuperado.
		-- state_DRC_Read_Solicita2	: Estado onde é solicitada a leitura do segundo byte, a partir de um determinado endereço especificado pelo barramento externo.
		-- state_DRC_Read_Busca2		: Estado onde o valor do segundo byte lido, solicitado anteriormente é recuperado.
		-- state_DRC_Read_Solicita3	: Estado onde é solicitada a leitura do terceiro byte, a partir de um determinado endereço especificado pelo barramento externo.
		-- state_DRC_Read_Busca3		: Estado onde o valor do terceiro byte lido, solicitado anteriormente é recuperado.
		-- state_DRC_Read_Solicita4	: Estado onde é solicitada a leitura do quarto byte, a partir de um determinado endereço especificado pelo barramento externo.
		-- state_DRC_Read_Busca4		: Estado onde o valor do quarto byte lido, solicitado anteriormente é recuperado.
		
		--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
		
		-- %%%%%% FSM de controle de escrita %%%%%%
		
		-- state_DRC_Write_IDLE			: Estado Ocioso da FSM de Leitura.
		-- state_DRC_Write_Solicita1	: Estado onde é solicitada a escrita do primeiro byte (7 DOWNTO 0) do dado presente no barramento de entrada.
		-- state_DRC_Write_Solicita2	: Estado onde é solicitada a escrita do segundo byte (15 DOWNTO 8) do dado presente no barramento de entrada.
		-- state_DRC_Write_Solicita3	: Estado onde é solicitada a escrita do terceiro byte (23 DOWNTO 16) do dado presente no barramento de entrada.
		-- state_DRC_Write_Solicita4	: Estado onde é solicitada a escrita do terceiro byte (31 DOWNTO 24) do dado presente no barramento de entrada.
		-- state_DRC_Write_Encerra		: Estado onde ocorre a finalizaçao do processo de escrita após a solicitaçao de escrita do 4º byte.
	
	-- Declaração da máquina de estados para controle do circuito.
	TYPE DataRAMCore_FSM IS(state_DRC_IDLE,			  state_DRC_Reset,
	
									state_DRC_Read_IDLE,
									state_DRC_Read_Solicita1, state_DRC_Read_Busca1,
									state_DRC_Read_Solicita2, state_DRC_Read_Busca2,
									state_DRC_Read_Solicita3, state_DRC_Read_Busca3,
									state_DRC_Read_Solicita4, state_DRC_Read_Busca4,
									
									state_DRC_Write_IDLE,
									state_DRC_Write_Solicita1, state_DRC_Write_Solicita2, 
									state_DRC_Write_Solicita3, state_DRC_Write_Solicita4, 
									state_DRC_Write_Encerra
									);
	
	SIGNAL nextState	: DataRAMCore_FSM := state_DRC_IDLE; -- Define o estado inicial da máquina como sendo o "state_DRC_IDLE".
	
	-- Sinais para conexão com barramentos externos do circuito, evitando assim que flutuaçoes na entrada propaguem no circuito.
	SIGNAL SIG_address	: t_AddressDATA;
	SIGNAL SIG_dataIn		: t_Word;
	SIGNAL SIG_dataOut	: t_Word;
	SIGNAL SIG_bytes		: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL SIG_opCode 	: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL SIG_ready 		: STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	SIGNAL SIG_stateOut1	: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_stateOut2	: STD_LOGIC_VECTOR(3 DOWNTO 0);	
		
BEGIN

	-- Mapeamento de portas do componente RAM de dados.
	mapramData: ENTITY WORK.MIPS32_RamData
		PORT MAP
		(
			clock		=> SIG_RAM_DATA_clock,
			we			=> SIG_RAM_DATA_we,
			reset		=> SIG_RAM_DATA_reset,
			address	=> SIG_RAM_DATA_address,
			dataIn	=> SIG_RAM_DATA_dataIn,
			dataOut	=> SIG_RAM_DATA_dataOut
		);
		
		
	-- Direciona os sinais dos barramentos externos para os respectivos sinais internos.
	SIG_address	<= address;
	SIG_dataIn	<= dataIn;
	dataOut		<= SIG_dataOut;
	SIG_bytes	<= bytes;
	SIG_opCode 	<= opcode;
	ready			<= SIG_ready;
	
	stateOut1 	<= SIG_stateOut1;
	stateOut2 	<= SIG_stateOut2;
	
	
	-- Conecta o pino de clock da entidade com o pino da memória RAM de dados para sincronia.
	SIG_RAM_DATA_clock <= clock;
	
	
	
	-- Esse process é ativado com alteraçao de valores nos sinais: "clock" e "reset".
	PROCESS(clock, reset) 
		VARIABLE byte0: t_byte;	-- Variável responsável por armazenar o 1º byte da RAM na operação de leitura da dados.
		VARIABLE byte1: t_byte;	-- Variável responsável por armazenar o 2º byte da RAM na operação de leitura da dados.
		VARIABLE byte2: t_byte;	-- Variável responsável por armazenar o 3º byte da RAM na operação de leitura da dados.
		VARIABLE byte3: t_byte;	-- Variável responsável por armazenar o 4º byte da RAM na operação de leitura da dados.
	BEGIN
		
		-- Reset do circuito.
		IF (reset = '1') THEN
		
			-- Após o sinal de reset, de acordo com o valor presente no barramento de opCode (carregado em SIG_opCode), desvia a FSM para o estado correto.
			CASE SIG_opCode IS
				
				-- Circuito ocioso, ou em IDLE.
				WHEN "000" =>
				
					nextState <= state_DRC_IDLE;
				
				-- Leitura de bytes da RAM.
				WHEN "001" =>
				
					nextState <= state_DRC_Read_Solicita1;
				
				-- Escrita de bytes na RAM.
				WHEN "010" =>
				
					nextState <= state_DRC_Write_Solicita1;
					
				-- Estado de Reset da RAM.
				WHEN "011" =>
				
					nextState <= state_DRC_Reset;
					
				-- Estados inválidos.
				WHEN OTHERS =>
				
					NULL;
			
			END CASE;
		
		-- Caso o sinal de reset não esteja ativo (alto) e seja borda de subida do clock, executa os comandos da FSM.
		ELSIF (RISING_EDGE(clock)) THEN
		
			-- Filtra de acordo com o estado atual da FSM apontado por "nextState".
			CASE nextState IS
			
				-- Estado de IDLE geral da controladora.
				WHEN state_DRC_IDLE =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "1111";
					SIG_stateOut2 <= "1111";
					
					-- Mantém nível baixo no sinal de reset da memória.
					SIG_RAM_DATA_reset <= '0';

					-- Encaminha a FSM para o próprio estado atual.
					nextState <= state_DRC_IDLE;
				
				
				-- %%	
			
			
				-- Estado de reset da memória.
				WHEN state_DRC_Reset =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "1111";
					SIG_stateOut2 <= "1110";
				
					-- Mantém nível alto no sinal de reset da memória.
					SIG_RAM_DATA_reset <= '1';
				
					nextState <= state_DRC_IDLE;
			
					
					
					
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE LEITURA DE BYTES NA RAM DE DADOS %%%%%%%%%%%%%%%
			
				-- Estado Ocioso da FSM de Leitura.
				WHEN state_DRC_Read_IDLE =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "1001";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Encaminha a FSM para o próprio estado atual.
					nextState <= state_DRC_Read_IDLE;
				
				
				-- %%	
					
				
				-- Estado onde é solicitada a leitura do primeiro byte, a partir de um determinado endereço especificado pelo barramento externo.
				WHEN state_DRC_Read_Solicita1 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0001";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais da memória RAM de dados.
					SIG_RAM_DATA_we 		<= '1';					-- Informa a memória que a operaçao a ser executada é a de leitura de dados.
					SIG_RAM_DATA_dataIn 	<= (OTHERS => '0');	-- Garante o valor '0' no barramento de dados.
					SIG_RAM_DATA_address <= SIG_address;		-- Envia o valor presente no barramento "address" desse circuito para a memória informando o endereço a ser lido.
					
					-- Encaminha a FSM para o estado de Busca do primeiro byte.
					nextState <= state_DRC_Read_Busca1;
					
				
				-- %%	
					
				
				-- Estado onde o valor do primeiro byte lido, solicitado anteriormente é recuperado.
				WHEN state_DRC_Read_Busca1 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0010";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Armazena o valor lido da memória na variável "byte0".
					byte0 := SIG_RAM_DATA_dataOut;
					
					-- Caso tenha sido solicitado a controladora a leitura de apenas 1 byte,
					IF SIG_bytes = "00" THEN
					
						-- Encaminha o valor lido e armazenado em "byte0" (preenchido com '0' a esquerda) para o barramento externo.
						SIG_dataOut <= x"000000" & byte0;
						
						-- Sinaliza no barramento "ready" que a operação foi concluida.
						SIG_ready <= "001";
					
						-- Encaminha a FSM para o estado IDLE do processo de leitura.
						nextState <= state_DRC_Read_IDLE;
					
					-- Caso contrário,
					ELSE
						
						-- Encaminha a FSM para o estado de leitura do próximo byte da RAM.
						nextState <= state_DRC_Read_Solicita2;
						
					END IF;
				
				
				-- %%	
					
				
				-- Estado onde é solicitada a leitura do segundo byte, a partir de um determinado endereço especificado pelo barramento externo.
				WHEN state_DRC_Read_Solicita2 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0011";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais da memória RAM de dados.
					SIG_RAM_DATA_we 		<= '1';					-- Informa a memória que a operaçao a ser executada é a de leitura de dados.
					SIG_RAM_DATA_dataIn 	<= (OTHERS => '0');	-- Garante o valor '0' no barramento de dados.
					SIG_RAM_DATA_address <= SIG_address + 1;	-- Envia o valor presente no barramento "address" + 1 desse circuito para a memória informando o endereço a ser lido.
					
					-- Encaminha a FSM para o estado de Busca do segundo byte.
					nextState <= state_DRC_Read_Busca2;
					
				
				-- %%	
					
				
				-- Estado onde o valor do segundo byte lido, solicitado anteriormente é recuperado.
				WHEN state_DRC_Read_Busca2 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0100";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
				
					-- Armazena o valor lido da memória na variável "byte1".
					byte1 := SIG_RAM_DATA_dataOut;
					
					-- Caso tenha sido solicitado a controladora a leitura de apenas 2 bytes,
					IF SIG_bytes = "01" THEN
					
						-- Encaminha o valor lido e armazenado em "byte1" concatenado de "byte0" (preenchido com '0' a esquerda) para o barramento externo.
						SIG_dataOut <= x"0000" & byte1 & byte0;
						
						-- Sinaliza no barramento "ready" que a operação foi concluida.
						SIG_ready <= "001";
					
						-- Encaminha a FSM para o estado IDLE do processo de leitura.
						nextState <= state_DRC_Read_IDLE;
					
					-- Caso contrário,
					ELSE
					
						-- Encaminha a FSM para o estado de leitura do próximo byte da RAM.
						nextState <= state_DRC_Read_Solicita3;
						
					END IF;
					
				
				-- %%	
					
				
				-- Estado onde é solicitada a leitura do terceiro byte, a partir de um determinado endereço especificado pelo barramento externo.
				WHEN state_DRC_Read_Solicita3 =>
					
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0101";
				
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
				
					-- Preenche os sinais da memória RAM de dados.
					SIG_RAM_DATA_we 		<= '1';					-- Informa a memória que a operaçao a ser executada é a de leitura de dados.
					SIG_RAM_DATA_dataIn 	<= (OTHERS => '0');	-- Garante o valor '0' no barramento de dados.
					SIG_RAM_DATA_address <= SIG_address + 2;	-- Envia o valor presente no barramento "address" + 2 desse circuito para a memória informando o endereço a ser lido.
					
					-- Encaminha a FSM para o estado de Busca do terceiro byte.
					nextState <= state_DRC_Read_Busca3;
				
				
				-- %%	
					
				
				-- Estado onde o valor do terceiro byte lido, solicitado anteriormente é recuperado.
				WHEN state_DRC_Read_Busca3 =>
					
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0110";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Armazena o valor lido da memória na variável "byte2".
					byte2 := SIG_RAM_DATA_dataOut;
					
					-- Caso tenha sido solicitado a controladora a leitura de apenas 3 bytes,
					IF SIG_bytes = "10" THEN
					
						-- Encaminha o valor lido e armazenado em "byte2" concatenado de "byte1" e "byte0" (preenchido com '0' a esquerda) para o barramento externo.
						SIG_dataOut <= x"00" & byte2 & byte1 & byte0;
						
						-- Sinaliza no barramento "ready" que a operação foi concluida.
						SIG_ready <= "001";
					
						-- Encaminha a FSM para o estado IDLE do processo de leitura.
						nextState <= state_DRC_Read_IDLE;
					
					-- Caso contrário,
					ELSE
					
						-- Encaminha a FSM para o estado de leitura do próximo byte da RAM.
						nextState <= state_DRC_Read_Solicita4;
						
					END IF;
					
				
				-- %%	
					
				
				-- Estado onde é solicitada a leitura do quarto byte, a partir de um determinado endereço especificado pelo barramento externo.
				WHEN state_DRC_Read_Solicita4 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0111";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais da memória RAM de dados.
					SIG_RAM_DATA_we 		<= '1';					-- Informa a memória que a operaçao a ser executada é a de leitura de dados.
					SIG_RAM_DATA_dataIn 	<= (OTHERS => '0');	-- Garante o valor '0' no barramento de dados.
					SIG_RAM_DATA_address <= SIG_address + 3;	-- Envia o valor presente no barramento "address" + 3 desse circuito para a memória informando o endereço a ser lido.
					
					-- Encaminha a FSM para o estado de Busca do terceiro byte.
					nextState <= state_DRC_Read_Busca4;
					
				
				-- %%	
					
				
				-- Estado onde o valor do quarto byte lido, solicitado anteriormente é recuperado.
				WHEN state_DRC_Read_Busca4 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "1000";
					
					-- Armazena o valor lido da memória na variável "byte2".
					byte3 := SIG_RAM_DATA_dataOut;
					
					-- Encaminha o valor lido e armazenado em "byte3" concatenado de "byte2", "byte1" e "byte0" para o barramento externo.
					SIG_dataOut <= byte3 & byte2 & byte1 & byte0;
					
					-- Sinaliza no barramento "ready" que a operação foi concluida.
					SIG_ready <= "001";
					
					-- Encaminha a FSM para o estado IDLE do processo de leitura.
					nextState <= state_DRC_Read_IDLE;
				
				-- %%%%%%%%%%%%%%% FIM DA FSM DE LEITURA DE BYTES NA RAM DE DADOS %%%%%%%%%%%%%%%	
				
					
					
					
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE ESCRITA DE BYTES NA RAM DE DADOS %%%%%%%%%%%%%%%
			
				-- Estado Ocioso da FSM de Leitura.
				WHEN state_DRC_Write_IDLE =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0110";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
				
					-- Encaminha a FSM para o próprio estado atual.
					nextState <= state_DRC_Write_IDLE;
				
				
				-- %%	
					
				
				-- Estado onde é solicitada a escrita do primeiro byte (7 DOWNTO 0) do dado presente no barramento de entrada.
				WHEN state_DRC_Write_Solicita1 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0001";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
				
					-- Preenche os sinais da memória RAM de dados.
					SIG_RAM_DATA_we <= '0';									-- Informa a memória que a operaçao a ser executada é a de escrita de dados.
					SIG_RAM_DATA_address <= SIG_address;				-- Envia o valor presente no barramento "address" desse circuito para a memória informando o endereço onde será escrito.
					SIG_RAM_DATA_dataIn 	<= SIG_dataIn(7 DOWNTO 0); -- Envia o primeiro byte presente no sinal do barramento de dados para ser salvo na memória.
					
					-- Encaminha a FSM para o estado de solicitaçao de escrita do 2º byte.
					nextState <= state_DRC_Write_Solicita2;
					
				
				-- %%	
					
					
				
				-- Estado onde é solicitada a escrita do segundo byte (15 DOWNTO 8) do dado presente no barramento de entrada.
				WHEN state_DRC_Write_Solicita2 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0010";
					
					-- Caso seja solicitado a controlador que escreva apenas o primeiro byte, encerra o processo de escrita.
					IF SIG_bytes = "00" THEN
					
						-- Sinaliza no barramento "ready" que a operação foi concluida.
						SIG_ready <= "010";
					
						-- Encaminha a FSM para o estado IDLE do processo de escrita.
						nextState <= state_DRC_Write_IDLE;
					
					-- Caso contrário, solicita escrita do 2º byte.
					ELSE
						
						-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
						SIG_ready <= "000";
				
						-- Preenche os sinais da memória RAM de dados.
						SIG_RAM_DATA_we <= '0';										-- Informa a memória que a operaçao a ser executada é a de escrita de dados.
						SIG_RAM_DATA_address <= SIG_address + 1;				-- Envia o valor presente no barramento "address"  + 1 desse circuito para a memória informando o endereço onde será escrito.
						SIG_RAM_DATA_dataIn 	<= SIG_dataIn(15 DOWNTO 8);	-- Envia o segundo byte presente no sinal do barramento de dados para ser salvo na memória.
						
						-- Encaminha a FSM para o estado de solicitaçao de escrita do 3º byte.
						nextState <= state_DRC_Write_Solicita3;
						
					END IF;
					
				
				-- %%	
					
				
				-- Estado onde é solicitada a escrita do terceiro byte (23 DOWNTO 16) do dado presente no barramento de entrada.
				WHEN state_DRC_Write_Solicita3 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0011";
				
					-- Caso seja solicitado a controlador que escreva apenas os dois primeiros bytes, encerra o processo de escrita.
					IF SIG_bytes = "01" THEN
					
						-- Sinaliza no barramento "ready" que a operação foi concluida.
						SIG_ready <= "010";
					
						-- Encaminha a FSM para o estado IDLE do processo de escrita.
						nextState <= state_DRC_Write_IDLE;
					
					-- Caso contrário, solicita escrita do 3º byte.
					ELSE
					
						-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
						SIG_ready <= "000";
				
						-- Preenche os sinais da memória RAM de dados.
						SIG_RAM_DATA_we <= '0';										-- Informa a memória que a operaçao a ser executada é a de escrita de dados.
						SIG_RAM_DATA_address <= SIG_address + 2;				-- Envia o valor presente no barramento "address" + 2 desse circuito para a memória informando o endereço onde será escrito.
						SIG_RAM_DATA_dataIn 	<= SIG_dataIn(23 DOWNTO 16);	-- Envia o terceiro byte presente no sinal do barramento de dados para ser salvo na memória.
						
						-- Encaminha a FSM para o estado de solicitaçao de escrita do 4º byte.
						nextState <= state_DRC_Write_Solicita4;
						
					END IF;
					
				
				-- %%	
					
				
				-- Estado onde é solicitada a escrita do terceiro byte (31 DOWNTO 24) do dado presente no barramento de entrada.
				WHEN state_DRC_Write_Solicita4 =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0100";
					
					-- Caso seja solicitado a controlador que escreva apenas os três primeiros bytes, encerra o processo de escrita.
					IF SIG_bytes = "10" THEN
					
						-- Sinaliza no barramento "ready" que a operação foi concluida.
						SIG_ready <= "010";
					
						-- Encaminha a FSM para o estado IDLE do processo de escrita.
						nextState <= state_DRC_Write_IDLE;
					
					-- Caso contrário, solicita escrita do 4º byte.
					ELSE
					
						-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
						SIG_ready <= "000";
				
						-- Preenche os sinais da memória RAM de dados.
						SIG_RAM_DATA_we <= '0';										-- Informa a memória que a operaçao a ser executada é a de escrita de dados.
						SIG_RAM_DATA_address <= SIG_address + 3;				-- Envia o valor presente no barramento "address" + 3 desse circuito para a memória informando o endereço onde será escrito.
						SIG_RAM_DATA_dataIn 	<= SIG_dataIn(31 DOWNTO 24);	-- Envia o quarto byte presente no sinal do barramento de dados para ser salvo na memória.
						
						-- Encaminha a FSM para o estado de busca do 4º byte.
						nextState <= state_DRC_Write_Encerra;
						
					END IF;
					
				
				-- %%	
					
				
				-- Estado onde ocorre a finalizaçao do processo de escrita após a solicitaçao de escrita do 4º byte.
				WHEN state_DRC_Write_Encerra =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0101";
					
					-- Sinaliza no barramento "ready" que a operação foi concluida.
					SIG_ready <= "010";
					
					-- Encaminha a FSM para o estado IDLE do processo de escrita.
					nextState <= state_DRC_Write_IDLE;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM DE ESCRITA DE BYTES NA RAM DE DADOS %%%%%%%%%%%%%%%
					
				
				-- Estados inválidos.
				WHEN OTHERS =>
					
					NULL;
				
			END CASE;
		
		END IF;
		
	END PROCESS;
	
END BEHAVIOR;
-- Fim da declaração da arquitetura da entidade MIPS32_DataRAMCore.