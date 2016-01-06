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
 --# Arquivo: MIPS32_RegBankCore.vhd													#
 --#                                                                      	#
 --# Sobre: Entidade responsável pela interface e gerência de operações   	#
 --#        com o Banco de Registradores.	                              	#
 --#                                                                      	#
 --# Operações Disponíveis:                                               	#
 --#        																					#
 --#       * Escrita de de word em um ou dois registradores						#
 --#       * Leitura do 1º, 2º, 3º, 4º ou todos os bytes de um registrador	#
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


-- Início da declaração da entidade MIPS32_RegbankCore.
ENTITY MIPS32_RegBankCore IS

	PORT 
	(
		clock				: IN 	STD_LOGIC;							-- Sinal de clock.
		reset				: IN 	STD_LOGIC := '0';					-- Sinal de reset do circuito, default = 0 (ativo por nível alto).
		
		addressRead1	: IN 	t_RegSelect;						-- Endereco para leitura 1 a ser acessado na RAM de instruções.
		addressRead2	: IN 	t_RegSelect;						-- Endereco para leitura 2 a ser acessado na RAM de instruções.
		addressWrite1	: IN 	t_RegSelect;						-- Endereco para escrita 1 a ser acessado na RAM de instruções.
		addressWrite2	: IN 	t_RegSelect;						-- Endereco para escrita 2 a ser acessado na RAM de instruções.
		dataIn1			: IN 	t_Word;								-- Byte 1 a ser salvo na posicao "addressWrite1" da RAM de instruções.
		dataIn2			: IN 	t_Word;								-- Byte 2 a ser salvo na posicao "addressWrite2" da RAM de instruções.
		dataOut1			: OUT t_Word;								-- Byte 1 lido da posicao "addressRead1" da RAM de instruções.
		dataOut2			: OUT t_Word;								-- Byte 2 lido da posicao "addressRead2" da RAM de instruções.
		
		bytes		: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		
		opCode			: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);	-- Seletor de operação do circuito.
		ready				: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);	-- Sinal indicador de conclusão da operação especificada por "opCode".
		
		
		stateOut1		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Sinal de Debug: sinaliza a operação atual executada no circuito.
		stateOut2		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)	-- Sinal de Debug: sinaliza o estado atual dentro da FSM que executa a operação especificada em "opCode".
	);

END ENTITY;
-- Fim da declaração da entidade MIPS32_RegbankCore.

-- Início da declaração da arquitetura da entidade MIPS32_RegbankCore.
ARCHITECTURE BEHAVIOR OF MIPS32_RegBankCore IS

	-- Sinais para conexao com o componente RegBank.
	SIGNAL SIG_RegBank_clock 		:  STD_LOGIC;
	SIGNAL SIG_RegBank_we			:  STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL SIG_RegBank_regRead1 	:  t_RegSelect;
	SIGNAL SIG_RegBank_regRead2 	:  t_RegSelect;
	SIGNAL SIG_RegBank_regWrite1 	:  t_RegSelect;
	SIGNAL SIG_RegBank_regWrite2 	:  t_RegSelect;
	SIGNAL SIG_RegBank_dataWrite1 :  t_Word;
	SIGNAL SIG_RegBank_dataWrite2	:  t_Word;
	SIGNAL SIG_RegBank_dataRead1 	:  t_Word;
	SIGNAL SIG_RegBank_dataRead2 	:  t_Word;
	
	
	-- Máquina de estados da controladora.
	
		-- state_RBC_IDLE					:	Estado de IDLE geral da controladora.
		
		--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
		
		-- %%%%%% FSM de controle de escrita %%%%%%
		
		-- state_RBC_Write_IDLE			:	Estado Ocioso da FSM de escrita de registrador.
		
		-- state_RBC_Write_Solicita	: 	Estado onde é solicitada a escrita de uma word no registrador de endereço especificado pelo barramento externo.
		
		-- state_RBC_Write_Encerra		: 	Estado onde o dado já foi salvo no registrador, e a controladora deverá informar ao circuito requerente a finalizaçao por meio do barramento "ready".
		
		--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
		
		-- %%%%%% FSM de controle de leitura %%%%%%
		
		-- state_RBC_Read_IDLE			: 	Estado Ocioso da FSM de leitura de registrador.
		
		-- state_RBC_Read_Solicita		:	Estado onde é solicitada a leitura dos 4 bytes do registrador de endereço especificado pelo barramento externo.
		
		-- state_RBC_Read_Busca			:	Estado onde a leitura dos registradores já foi finalizada e então deve-se armazenar nas devidas variáveis
		-- 										os bytes solicitados dos registradores lidos.
		
		-- state_RBC_Read_Envia			: 	Estado onde os dados lidos dos registradores e armazenados nas variáveis são enviados ao circuito
		--											requerente por meio do barramento de saida da controladora.
	
	TYPE RegBankCore_FSM IS(state_RBC_IDLE,
	
									state_RBC_Write_IDLE, state_RBC_Write_Solicita, state_RBC_Write_Encerra,
									
									state_RBC_Read_IDLE,  state_RBC_Read_Solicita,  state_RBC_Read_Busca,    state_RBC_Read_Envia
									);
	
	SIGNAL nextState	: RegBankCore_FSM := state_RBC_IDLE; -- Define o estado inicial da máquina como sendo o "state_RBC_IDLE".
	
	-- Sinais para conexão com barramentos externos do circuito, evitando assim que flutuaçoes na entrada propaguem no circuito.
	SIGNAL SIG_addressRead1		: t_RegSelect;
	SIGNAL SIG_addressRead2		: t_RegSelect;
	SIGNAL SIG_addressWrite1	: t_RegSelect;
	SIGNAL SIG_addressWrite2	: t_RegSelect;
	SIGNAL SIG_bytes				: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL SIG_dataIn1			: t_Word;
	SIGNAL SIG_dataIn2			: t_Word;
	SIGNAL SIG_dataOut1			: t_Word;
	SIGNAL SIG_dataOut2			: t_Word;
	SIGNAL SIG_opCode 			: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL SIG_ready 				: STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	SIGNAL SIG_stateOut1			: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_stateOut2			: STD_LOGIC_VECTOR(3 DOWNTO 0);	
	
		
BEGIN

	-- Mapeamento de portas do componente RegBank.
	mapRegBank: ENTITY WORK.MIPS32_RegBank 
		PORT MAP
		(
			clock			=> SIG_RegBank_clock,
			we				=> SIG_RegBank_we,
			regRead1		=> SIG_RegBank_regRead1,
			regRead2		=> SIG_RegBank_regRead2,
			regWrite1	=> SIG_RegBank_regWrite1,
			regWrite2	=> SIG_RegBank_regWrite2,
			dataWrite1	=> SIG_RegBank_dataWrite1,
			dataWrite2	=> SIG_RegBank_dataWrite2,
			dataRead1	=> SIG_RegBank_dataRead1,
			dataRead2	=> SIG_RegBank_dataRead2
		);
		
	-- Direciona os sinais dos barramentos externos para os respectivos sinais internos.
	SIG_addressRead1	<= addressRead1;
	SIG_addressRead2	<= addressRead2;
	SIG_addressWrite1	<= addressWrite1;
	SIG_addressWrite2	<= addressWrite2;
	SIG_dataIn1			<= dataIn1;
	SIG_dataIn2			<= dataIn2;
	dataOut1				<= SIG_dataOut1;
	dataOut2				<= SIG_dataOut2;
	
	SIG_bytes	<= bytes;
	
	SIG_opCode 	<= opcode;
	ready			<= SIG_ready;
	
	stateOut1 	<= SIG_stateOut1;
	stateOut2 	<= SIG_stateOut2;
	
	
	-- Conecta o pino de clock da entidade com o pino da memória RAM de instruçoes para sincronia.
	SIG_RegBank_clock <= clock;
	
	
	
	-- Esse process é ativado com alteraçao de valores nos sinais: "clock" e "reset".
	PROCESS(clock, reset) 
	
		VARIABLE dataReg : t_Word;			--
		VARIABLE VAR_dataOut1 : t_Word;	--
		VARIABLE VAR_dataOut2 : t_Word;	--
	
	BEGIN
		
		-- Reset do circuito.
		IF (reset = '1') THEN
		
			-- Após o sinal de reset, de acordo com o valor presente no barramento de opCode (carregado em SIG_opCode), desvia a FSM para o estado correto.
			CASE SIG_opCode IS
				
				-- Circuito ocioso, ou em IDLE.
				WHEN "000" =>
				
					nextState <= state_RBC_IDLE;
				
				-- Leitura de registrador.
				WHEN "001" =>
				
					nextState <= state_RBC_Read_Solicita;
				
				-- Escrita de word em registrador.
				WHEN "010" =>
				
					nextState <= state_RBC_Write_Solicita;
					
				-- Estados inválidos.
				WHEN OTHERS =>
				
					NULL;
			
			END CASE;
		
		-- Caso o sinal de reset não esteja ativo (alto) e seja borda de subida do clock, executa os comandos da FSM.
		ELSIF (RISING_EDGE(clock)) THEN
		
			-- Filtra de acordo com o estado atual da FSM apontado por "nextState".
			CASE nextState IS
			
				-- Estado de IDLE geral da controladora.
				WHEN state_RBC_IDLE =>

					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "1111";
					SIG_stateOut2 <= "1111";

					-- Encaminha a FSM para o próprio estado atual.
					nextState <= state_RBC_IDLE;
					
					
					
					
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM PARA LEITURA %%%%%%%%%%%%%%%	
				
				-- Estado Ocioso da FSM de leitura de registrador.
				WHEN state_RBC_Read_IDLE =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0100";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
			
					-- Encaminha a FSM para o próprio estado atual.
					nextState <= state_RBC_Read_IDLE;
					
				
				-- %%	
			
				
				-- Estado onde é solicitada a leitura dos 4 bytes do registrador de endereço especificado pelo barramento externo.
				WHEN state_RBC_Read_Solicita =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0001";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
				
					-- Preenche os sinais da Banco de Registradores.
					SIG_RegBank_we 			<= "11";					-- Informa ao banco que a operaçao a ser executada é a de 4 bytes de um registrador.
					SIG_RegBank_regRead1 	<= SIG_addressRead1;	-- Envia o valor presente no barramento "addressRead1" desse circuito para a memória informando o endereço do 1º registrador a ser lido.
					SIG_RegBank_regRead2 	<= SIG_addressRead2; -- Envia o valor presente no barramento "addressRead2" desse circuito para a memória informando o endereço do 2º registrador a ser lido.
					
					-- Encaminha a FSM para o estado de armazenamento nas variáveis dos dados lidos dos registradores.
					nextState <= state_RBC_Read_Busca;
					
				
				-- %%	
			
			
				-- Estado onde a leitura dos registradores já foi finalizada e então deve-se armazenar nas devidas variáveis
				-- os bytes solicitados dos registradores lidos.
				WHEN state_RBC_Read_Busca =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0010";
					
					-- Filtra de acordo com o valor informado no barramento "SIG_bytes".
					CASE SIG_bytes IS
						
						-- Armazena o 1º byte de ambos os registradores.
						WHEN "000" =>
						
							VAR_dataOut1	:= x"000000" & SIG_RegBank_dataRead1(7 DOWNTO 0);
							VAR_dataOut2	:= x"000000" & SIG_RegBank_dataRead2(7 DOWNTO 0);
						
						-- Armazena o 2º byte de ambos os registradores.
						WHEN "001" =>
						
							VAR_dataOut1	:= x"000000" & SIG_RegBank_dataRead1(15 DOWNTO 8);
							VAR_dataOut2	:= x"000000" & SIG_RegBank_dataRead2(15 DOWNTO 8);
						
						-- Armazena o 3º byte de ambos os registradores.
						WHEN "010" =>
						
							VAR_dataOut1	:= x"000000" & SIG_RegBank_dataRead1(23 DOWNTO 16);
							VAR_dataOut2	:= x"000000" & SIG_RegBank_dataRead2(23 DOWNTO 16);
						
						-- Armazena o 4º byte de ambos os registradores.
						WHEN "011" =>
						
							VAR_dataOut1	:= x"000000" & SIG_RegBank_dataRead1(31 DOWNTO 24);
							VAR_dataOut2	:= x"000000" & SIG_RegBank_dataRead2(31 DOWNTO 24);
						
						-- Armazena toda a word de ambos os registradores.
						WHEN "100" =>
						
							VAR_dataOut1	:= SIG_RegBank_dataRead1;
							VAR_dataOut2	:= SIG_RegBank_dataRead2;
							
						-- Estados inválidos.
						WHEN OTHERS =>
						
							NULL;
				
					END CASE;
				
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
				
					-- Encaminha a FSM para o estado de envio dos dados lidos.
					nextState <= state_RBC_Read_Envia;
					
				
				-- %%	
			
			
				-- Estado onde os dados lidos dos registradores e armazenados nas variáveis são enviados ao circuito
				-- requerente por meio do barramento de saida da controladora.
				WHEN state_RBC_Read_Envia =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0011";
					SIG_stateOut2 <= "0011";
					
					-- Encaminha os dados contidos nas variáveis para os respectivos barramentos de saída.
					SIG_dataOut1 <= VAR_dataOut1;
					SIG_dataOut2 <= VAR_dataOut2;
					
					-- Sinaliza no barramento "ready" que a operação foi concluida.
					SIG_ready <= "001";
				
					-- Encaminha a FSM para o estado IDLE do processo de leitura de registradores.
					nextState <= state_RBC_Read_IDLE;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM PARA LEITURA %%%%%%%%%%%%%%%	
					
					
					
					
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM PARA ESCRITA DE WORD %%%%%%%%%%%%%%%	
				
				-- Estado Ocioso da FSM de escrita de registrador.
				WHEN state_RBC_Write_IDLE =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0100";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
	
					-- Encaminha a FSM para o próprio estado atual.
					nextState <= state_RBC_Write_IDLE;
					
				
				-- %%	
			
			
				-- Estado onde é solicitada a escrita de uma word no registrador de endereço especificado pelo barramento externo.
				WHEN state_RBC_Write_Solicita =>
				
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0001";
					
					-- Sinaliza no barramento "ready" que não há operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
				
					-- Preenche os sinais da Banco de Registradores.
					SIG_RegBank_we 			<= SIG_bytes(1 DOWNTO 0);	-- Informa ao Banco de Registradores quais dos 2 registradores endereçados serão salvos.
					
					SIG_RegBank_regWrite1 	<= SIG_addressWrite1;		-- Envia o valor presente no barramento "addressWrite1" desse circuito para a memória informando o 1º registrador.
					SIG_RegBank_dataWrite1	<= SIG_dataIn1;				-- Envia o valor presente no barramento "dataIn1" desse circuito para a memória informando o dado a ser escrito em "addressWrite1".
					
					SIG_RegBank_regWrite2 	<= SIG_addressWrite2;		-- Envia o valor presente no barramento "addressWrite2" desse circuito para a memória informando o 2º registrador.
					SIG_RegBank_dataWrite2	<= SIG_dataIn2;				-- Envia o valor presente no barramento "dataIn1" desse circuito para a memória informando o dado a ser escrito em "addressWrite1".
					
					-- Encaminha a FSM para o estado de encerramento do processo de escrita.
					nextState <= state_RBC_Write_Encerra;
					
				
				-- %%	
			
			
				-- Estado onde o dado já foi salvo no registrador, e a controladora deverá informar ao circuito requerente a finalizaçao por meio do barramento "ready".
				WHEN state_RBC_Write_Encerra =>
					
					-- Sinaliza no barramento de debug o estado atual da FSM.
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0011";
					
					-- Altera o circuito do Banco de Regsitradores para realizar leitura, evitando assim que dados sejam gravados sem que seja solicitado.
					SIG_RegBank_we <= "11";
		
					-- Sinaliza no barramento "ready" que a operação foi concluida.
					SIG_ready <= "010";
					
					-- Encaminha a FSM para o estado IDLE do processo de escrita de registradore.
					nextState <= state_RBC_Write_IDLE;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM PARA ESCRITA DE WORD %%%%%%%%%%%%%%%	
				
				
			END CASE;
			
		END IF;
		
	END PROCESS;

END BEHAVIOR;
-- Fim da declaração da arquitetura da entidade RegBankCore.