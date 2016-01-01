-- Importa as bibliotecas de sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Importa as bibliotecas de usuário.
LIBRARY WORK;
USE WORK.funcoes.ALL;


-- Início da declaração da entidade MIPS32_RegbankCore.
ENTITY MIPS32_RegBankCore IS

	PORT 
	(
		clock				: IN 	STD_LOGIC;							-- Sinal de relógio para sincronia.
		reset				: IN 	STD_LOGIC := '0';					-- Sinal de reset do circuito, default = 0 (ativo por nível alto).
		
		addressRead1	: IN 	t_RegSelect;						-- Endereco a ser acessado na RAM de instruções.
		addressRead2	: IN 	t_RegSelect;						-- Endereco a ser acessado na RAM de instruções.
		addressWrite1	: IN 	t_RegSelect;						-- Endereco a ser acessado na RAM de instruções.
		addressWrite2	: IN 	t_RegSelect;						-- Endereco a ser acessado na RAM de instruções.
		dataIn1			: IN 	t_Word;								-- Byte a ser salvo na posicao "address" da RAM de instruções.
		dataIn2			: IN 	t_Word;								-- Byte a ser salvo na posicao "address" da RAM de instruções.
		dataOut1			: OUT t_Word;								-- Byte lido da posicao "address" da RAM de instruções.
		dataOut2			: OUT t_Word;								-- Byte lido da posicao "address" da RAM de instruções.
		
		bytes		: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		
		opCode			: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);	-- Seletor de operação do circuito.
		ready				: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);	-- Sinal indicador de conclusão da operação especificada por "opCode".
		
		
		stateOut1		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Sinal de Debug: sinaliza a operação atual executada no circuito.
		stateOut2		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)	-- Sinal de Debug: sinaliza o estado atual dentro da FSM que executa a operação especificada em "opCode".
	);

END ENTITY;
-- Fim da declaração da entidade MIPS32_RegbankCore.

-- Início da declaração da arquitetura da entidade MIPS32_RegbankCore.
ARCHITECTURE Behavioral OF MIPS32_RegBankCore IS

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
	
	
	-- Declaração da máquina de estados para controle do circuito.
	TYPE RegBankCore_FSM IS(state_RBC_IDLE,
	
									state_RBC_Write_IDLE, state_RBC_Write_Solicita, state_RBC_Write_Aguarda, state_RBC_Write_Encerra,
									
									state_RBC_Read_IDLE, state_RBC_Read_Solicita, state_RBC_Read_Envia, state_RBC_Read_Encerra
									);
	
	-- Sinal que armazena o estado atual da FSM.
	SIGNAL currentState	: RegBankCore_FSM := state_RBC_IDLE;
	
	-- Sinais para conexão interna com os pinos de entrada e saída da entidade.
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
	mapRegBank: ENTITY WORK.RegBank 
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
		
	-- Carrega os valores dos pinos de IO da entidade nos seus respectivos sinais.
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
	
	-- Conecta o pino de clock da entidade com o pino do RegBank para sincronia.
	SIG_RegBank_clock <= clock;
	
	
	
	-- Process para controle da máquina de estados (FSM).
	PROCESS(clock, reset) 
	
		VARIABLE dataReg : t_Word;
		VARIABLE VAR_dataOut1 : t_Word;
		VARIABLE VAR_dataOut2 : t_Word;
	
	BEGIN
		
		-- Caso seja solicitado reset do circuito (i.e. reset = '1').
		IF (reset = '1') THEN
		
			-- Verifica qual a operação selecionada pelo "opCode".
			CASE SIG_opCode IS
				
				-- Circuito ocioso, ou em IDLE.
				WHEN "000" =>
				
					currentState <= state_RBC_IDLE;
				
				-- Leitura no RegBank.
				WHEN "001" =>
				
					currentState <= state_RBC_Read_Solicita;
				
				-- Escrita de word no RegBank.
				WHEN "010" =>
				
					currentState <= state_RBC_Write_Solicita;
					
				-- Outros.
				WHEN OTHERS =>
				
					NULL;
			
			END CASE;
		
		-- Caso reset = 0 e clock = 1.
		ELSIF (RISING_EDGE(clock)) THEN
		
			-- Filtra de acordo com o estado atual da FSM apontado por "currentState".
			CASE currentState IS
			
				-- Estado de IDLE geral da entidade.
				WHEN state_RBC_IDLE =>
				
					SIG_stateOut1 <= "1111";
					SIG_stateOut2 <= "1111";
					
					SIG_ready <= "000";

					currentState <= state_RBC_IDLE;
					
				
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM PARA LEITURA %%%%%%%%%%%%%%%	
				
				WHEN state_RBC_Read_IDLE =>
				
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0100";
				
					SIG_ready <= "000";
			
					currentState <= state_RBC_Read_IDLE;
					
					
				WHEN state_RBC_Read_Solicita =>
				
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0001";
					
					SIG_ready <= "000";
				
					SIG_RegBank_we 			<= "11";
					SIG_RegBank_regRead1 	<= SIG_addressRead1;
					SIG_RegBank_regRead2 	<= SIG_addressRead2;
					
					currentState <= state_RBC_Read_Envia;
					
					
				WHEN state_RBC_Read_Envia =>
				
					SIG_stateOut1 <= "0001";
					SIG_stateOut2 <= "0010";
					
					CASE SIG_bytes IS
						
						WHEN "000" =>
						
							VAR_dataOut1	:= x"000000" & SIG_RegBank_dataRead1(7 DOWNTO 0);
							VAR_dataOut2	:= x"000000" & SIG_RegBank_dataRead2(7 DOWNTO 0);
						
						WHEN "001" =>
						
							VAR_dataOut1	:= x"000000" & SIG_RegBank_dataRead1(15 DOWNTO 8);
							VAR_dataOut2	:= x"000000" & SIG_RegBank_dataRead2(15 DOWNTO 8);
						
						WHEN "010" =>
						
							VAR_dataOut1	:= x"000000" & SIG_RegBank_dataRead1(23 DOWNTO 16);
							VAR_dataOut2	:= x"000000" & SIG_RegBank_dataRead2(23 DOWNTO 16);
						
						WHEN "011" =>
						
							VAR_dataOut1	:= x"000000" & SIG_RegBank_dataRead1(31 DOWNTO 24);
							VAR_dataOut2	:= x"000000" & SIG_RegBank_dataRead2(31 DOWNTO 24);
						
						WHEN "100" =>
						
							VAR_dataOut1	:= SIG_RegBank_dataRead1;
							VAR_dataOut2	:= SIG_RegBank_dataRead2;
							
						WHEN OTHERS =>
						
							NULL;
				
					END CASE;
				
					SIG_ready <= "000";
				
					currentState <= state_RBC_Read_Encerra;
					
					
				WHEN state_RBC_Read_Encerra =>
				
					SIG_stateOut1 <= "0011";
					SIG_stateOut2 <= "0011";
					
					SIG_dataOut1 <= VAR_dataOut1;
					SIG_dataOut2 <= VAR_dataOut2;
					
					SIG_ready <= "001";
				
					currentState <= state_RBC_Read_IDLE;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM PARA LEITURA %%%%%%%%%%%%%%%	
					
				
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM PARA ESCRITA DE WORD %%%%%%%%%%%%%%%	
				
				WHEN state_RBC_Write_IDLE =>
				
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0100";
					
					SIG_ready <= "000";
	
					currentState <= state_RBC_Write_IDLE;
					
				
				WHEN state_RBC_Write_Solicita =>
				
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0001";
					
					SIG_ready <= "000";
				
					SIG_RegBank_we 			<= SIG_bytes(1 DOWNTO 0);
					SIG_RegBank_regWrite1 	<= SIG_addressWrite1;
					SIG_RegBank_dataWrite1	<= SIG_dataIn1;
					
					SIG_RegBank_regWrite2 	<= SIG_addressWrite2;
					SIG_RegBank_dataWrite2	<= SIG_dataIn2;
					
					currentState <= state_RBC_Write_Aguarda;
					
					
				WHEN state_RBC_Write_Aguarda =>
					
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0010";
					
					SIG_ready <= "000";
					
					SIG_RegBank_we <= SIG_bytes(1 DOWNTO 0);
					
					currentState <= state_RBC_Write_Encerra;
					
					
				WHEN state_RBC_Write_Encerra =>
					
					SIG_stateOut1 <= "0010";
					SIG_stateOut2 <= "0011";
					
					SIG_RegBank_we <= "11";
		
					SIG_ready <= "010";
					
					currentState <= state_RBC_Write_IDLE;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM PARA ESCRITA DE WORD %%%%%%%%%%%%%%%	
				
				
			END CASE;
			
		END IF;
		
	END PROCESS;

END Behavioral;