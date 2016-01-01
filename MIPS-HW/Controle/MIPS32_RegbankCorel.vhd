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
		clock		: IN 	STD_LOGIC;							-- Sinal de relógio para sincronia.
		reset		: IN 	STD_LOGIC := '0';					-- Sinal de reset do circuito, default = 0 (ativo por nível alto).
		
		address	: IN 	t_RegSelect;						-- Endereco a ser acessado na RAM de instruções.
		dataIn	: IN 	t_Word;								-- Byte a ser salvo na posicao "address" da RAM de instruções.
		dataOut	: OUT t_Word;								-- Byte lido da posicao "address" da RAM de instruções.
		
		opCode	: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);	-- Seletor de operação do circuito.
		ready		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);	-- Sinal indicador de conclusão da operação especificada por "opCode".
		
		
		stateOut1: OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Sinal de Debug: sinaliza a operação atual executada no circuito.
		stateOut2: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)	-- Sinal de Debug: sinaliza o estado atual dentro da FSM que executa a operação especificada em "opCode".
	);

END ENTITY;
-- Fim da declaração da entidade MIPS32_RegbankCore.

-- Início da declaração da arquitetura da entidade MIPS32_RegbankCore.
ARCHITECTURE Behavioral OF MIPS32_RegBankCore IS

	-- Sinais para conexao com o componente Regbnak.
	SIGNAL SIG_RegBank_clock 		:  STD_LOGIC;
	SIGNAL SIG_RegBank_we			:  STD_LOGIC;
	SIGNAL SIG_RegBank_regRead1 	:  t_RegSelect;
	SIGNAL SIG_RegBank_regRead2 	:  t_RegSelect;
	SIGNAL SIG_RegBank_regWrite 	:  t_RegSelect;
	SIGNAL SIG_RegBank_dataWrite 	:  t_Word;
	SIGNAL SIG_RegBank_dataRead1 	:  t_Word;
	SIGNAL SIG_RegBank_dataRead2 	:  t_Word;
	
	
	-- Declaração da máquina de estados para controle do circuito.
	TYPE InstRAMCore_FSM IS(state_RBC_IDLE,
	
									state_IRC_Write_IDLE, state_IRC_Write_Solicita, state_IRC_Write_Aguarda, state_IRC_Write_Encerra,
									
									state_IRC_Read_IDLE, state_IRC_Read_Solicita, state_IRC_Read_Envia, state_IRC_Read_Encerra,
	
									state_IRC_IF_IDLE, 
									state_IRC_IF_Solicita1, state_IRC_IF_Busca1,
									state_IRC_IF_Solicita2, state_IRC_IF_Busca2,
									state_IRC_IF_Solicita3, state_IRC_IF_Busca3,
									state_IRC_IF_Solicita4, state_IRC_IF_Busca4,
									state_IRC_IF_Envia, state_IRC_IF_Encerra
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

	-- Mapeamento de portas do componente RegBank.
	mapRegBank: ENTITY WORK.RegBank 
		PORT MAP
		(
			clock			=> SIG_RegBank_clock,
			we				=> SIG_RegBank_we,
			regRead1		=> SIG_RegBank_regRead1,
			regRead2		=> SIG_RegBank_regRead2,
			regWrite		=> SIG_RegBank_regWrite,
			dataWrite	=> SIG_RegBank_dataWrite,
			dataRead1	=> SIG_RegBank_dataRead1,
			dataRead2	=> SIG_RegBank_dataRead2
		);

END Behavioral;