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
 --# Arquivo: MIPS32_Control.vhd 														#
 --#                                                                      	#
 --# 12/08/15 - Formiga - MG                                              	#
 --#########################################################################

 
-- Importa as bibliotecas de sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Importa as bibliotecas de usuário.
LIBRARY WORK;
USE WORK.funcoes.ALL;


-- Início da declaração da entidade MIPS32_Control.
ENTITY MIPS32_Control IS

	PORT 
	(
		address			: IN t_AddressINST;
		dataOUT			: OUT t_Byte;
		dataIN			: IN t_Byte;
		
		PIN_clockOUT	: OUT STD_LOGIC;
		PIN_clockIN		: IN STD_LOGIC;
		
		opCode			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		
		ready				: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		
		reset				: IN STD_LOGIC;
				
		
		A1			: OUT STD_LOGIC;
		B1			: OUT STD_LOGIC;
		C1			: OUT STD_LOGIC;
		D1			: OUT STD_LOGIC;
		E1			: OUT STD_LOGIC;
		F1			: OUT STD_LOGIC;
		G1			: OUT STD_LOGIC;
		
		A2			: OUT STD_LOGIC;
		B2			: OUT STD_LOGIC;
		C2			: OUT STD_LOGIC;
		D2			: OUT STD_LOGIC;
		E2			: OUT STD_LOGIC;
		F2			: OUT STD_LOGIC;
		G2			: OUT STD_LOGIC;
		
		A3			: OUT STD_LOGIC;
		B3			: OUT STD_LOGIC;
		C3			: OUT STD_LOGIC;
		D3			: OUT STD_LOGIC;
		E3			: OUT STD_LOGIC;
		F3			: OUT STD_LOGIC;
		G3			: OUT STD_LOGIC;
		
		A4			: OUT STD_LOGIC;
		B4			: OUT STD_LOGIC;
		C4			: OUT STD_LOGIC;
		D4			: OUT STD_LOGIC;
		E4			: OUT STD_LOGIC;
		F4			: OUT STD_LOGIC;
		G4			: OUT STD_LOGIC;
		
		A5			: OUT STD_LOGIC;
		B5			: OUT STD_LOGIC;
		C5			: OUT STD_LOGIC;
		D5			: OUT STD_LOGIC;
		E5			: OUT STD_LOGIC;
		F5			: OUT STD_LOGIC;
		G5			: OUT STD_LOGIC;
		
		A6			: OUT STD_LOGIC;
		B6			: OUT STD_LOGIC;
		C6			: OUT STD_LOGIC;
		D6			: OUT STD_LOGIC;
		E6			: OUT STD_LOGIC;
		F6			: OUT STD_LOGIC;
		G6			: OUT STD_LOGIC;
		
		A7			: OUT STD_LOGIC;
		B7			: OUT STD_LOGIC;
		C7			: OUT STD_LOGIC;
		D7			: OUT STD_LOGIC;
		E7			: OUT STD_LOGIC;
		F7			: OUT STD_LOGIC;
		G7			: OUT STD_LOGIC;
		
		A8			: OUT STD_LOGIC;
		B8			: OUT STD_LOGIC;
		C8			: OUT STD_LOGIC;
		D8			: OUT STD_LOGIC;
		E8			: OUT STD_LOGIC;
		F8			: OUT STD_LOGIC;
		G8			: OUT STD_LOGIC
		
	);

END ENTITY;
-- Fim da declaração da entidade MIPS32_Control.


-- Início da declaração da arquitetura da entidade ROM.
ARCHITECTURE RTL OF MIPS32_Control IS

	
	-- Sinais para conexao com o componente ALU_MIPS32.
	SIGNAL SIG_ALU_MIPS32_clock 		:  STD_LOGIC;
	SIGNAL SIG_ALU_MIPS32_reset		:  STD_LOGIC;
	SIGNAL SIG_ALU_MIPS32_opCode 		:  t_opCode;
	SIGNAL SIG_ALU_MIPS32_in0 			: 	t_Word;
	SIGNAL SIG_ALU_MIPS32_in1 			: 	t_Word;
	SIGNAL SIG_ALU_MIPS32_out0 		:  t_DWord;
	SIGNAL SIG_ALU_MIPS32_outFlags 	:  t_Byte;
	SIGNAL SIG_ALU_MIPS32_ready 		:  STD_LOGIC;
	
	-- Sinais para conexão com o componente ClockMIPS.
	SIGNAL SIG_ClockMIPS_clockIN	: STD_LOGIC;
	SIGNAL SIG_ClockMIPS_clockOUT	: STD_LOGIC;
	
	
	SIGNAL SIG_IRC_clock			: STD_LOGIC;
	SIGNAL SIG_IRC_reset			: STD_LOGIC := '0';
	SIGNAL SIG_IRC_opCode		: STD_LOGIC_VECTOR(2 DOWNTO 0); 
	SIGNAL SIG_IRC_address		: t_AddressINST; 
	SIGNAL SIG_IRC_dataIn		: t_Byte; 
	SIGNAL SIG_IRC_dataOut		: t_Byte; 
	SIGNAL SIG_IRC_instrucao	: t_Word;
	SIGNAL SIG_IRC_ready			: STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	SIGNAL SIG_DRC_clock			: STD_LOGIC;
	SIGNAL SIG_DRC_reset			: STD_LOGIC := '0';
	SIGNAL SIG_DRC_opCode		: STD_LOGIC_VECTOR(2 DOWNTO 0); 
	SIGNAL SIG_DRC_address		: t_AddressINST; 
	SIGNAL SIG_DRC_dataIn		: t_Word; 
	SIGNAL SIG_DRC_dataOut		: t_Word; 
	SIGNAL SIG_DRC_bytes			: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL SIG_DRC_ready			: STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	SIGNAL SIG_RBC_clock				: STD_LOGIC;
	SIGNAL SIG_RBC_reset				: STD_LOGIC := '0';
	SIGNAL SIG_RBC_opCode			: STD_LOGIC_VECTOR(2 DOWNTO 0); 
	SIGNAL SIG_RBC_addressRead1	: t_RegSelect; 
	SIGNAL SIG_RBC_addressRead2	: t_RegSelect; 
	SIGNAL SIG_RBC_addressWrite1	: t_RegSelect;
	SIGNAL SIG_RBC_addressWrite2	: t_RegSelect;	
	SIGNAL SIG_RBC_dataIn1			: t_Word; 
	SIGNAL SIG_RBC_dataIn2			: t_Word; 
	SIGNAL SIG_RBC_dataOut1			: t_Word; 
	SIGNAL SIG_RBC_dataOut2			: t_Word; 
	SIGNAL SIG_RBC_bytes				: STD_LOGIC_VECTOR(2 DOWNTO 0); 
	SIGNAL SIG_RBC_ready				: STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	
	SIGNAL SIG_Display1_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display1_A		:  STD_LOGIC;
	SIGNAL SIG_Display1_B		:  STD_LOGIC;
	SIGNAL SIG_Display1_C		:  STD_LOGIC;
	SIGNAL SIG_Display1_D		:  STD_LOGIC;
	SIGNAL SIG_Display1_E		:  STD_LOGIC;
	SIGNAL SIG_Display1_F		:  STD_LOGIC;
	SIGNAL SIG_Display1_G		:  STD_LOGIC;
	
	SIGNAL SIG_Display2_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display2_A		:  STD_LOGIC;
	SIGNAL SIG_Display2_B		:  STD_LOGIC;
	SIGNAL SIG_Display2_C		:  STD_LOGIC;
	SIGNAL SIG_Display2_D		:  STD_LOGIC;
	SIGNAL SIG_Display2_E		:  STD_LOGIC;
	SIGNAL SIG_Display2_F		:  STD_LOGIC;
	SIGNAL SIG_Display2_G		:  STD_LOGIC;
	
	SIGNAL SIG_Display3_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display3_A		:  STD_LOGIC;
	SIGNAL SIG_Display3_B		:  STD_LOGIC;
	SIGNAL SIG_Display3_C		:  STD_LOGIC;
	SIGNAL SIG_Display3_D		:  STD_LOGIC;
	SIGNAL SIG_Display3_E		:  STD_LOGIC;
	SIGNAL SIG_Display3_F		:  STD_LOGIC;
	SIGNAL SIG_Display3_G		:  STD_LOGIC;
	
	SIGNAL SIG_Display4_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display4_A		:  STD_LOGIC;
	SIGNAL SIG_Display4_B		:  STD_LOGIC;
	SIGNAL SIG_Display4_C		:  STD_LOGIC;
	SIGNAL SIG_Display4_D		:  STD_LOGIC;
	SIGNAL SIG_Display4_E		:  STD_LOGIC;
	SIGNAL SIG_Display4_F		:  STD_LOGIC;
	SIGNAL SIG_Display4_G		:  STD_LOGIC;
	
	SIGNAL SIG_Display5_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display5_A		:  STD_LOGIC;
	SIGNAL SIG_Display5_B		:  STD_LOGIC;
	SIGNAL SIG_Display5_C		:  STD_LOGIC;
	SIGNAL SIG_Display5_D		:  STD_LOGIC;
	SIGNAL SIG_Display5_E		:  STD_LOGIC;
	SIGNAL SIG_Display5_F		:  STD_LOGIC;
	SIGNAL SIG_Display5_G		:  STD_LOGIC;
	
	-- Sinais para conexao com o componente RAM.
	SIGNAL SIG_Display6_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display6_A		:  STD_LOGIC;
	SIGNAL SIG_Display6_B		:  STD_LOGIC;
	SIGNAL SIG_Display6_C		:  STD_LOGIC;
	SIGNAL SIG_Display6_D		:  STD_LOGIC;
	SIGNAL SIG_Display6_E		:  STD_LOGIC;
	SIGNAL SIG_Display6_F		:  STD_LOGIC;
	SIGNAL SIG_Display6_G		:  STD_LOGIC;
	
	SIGNAL SIG_Display7_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display7_A		:  STD_LOGIC;
	SIGNAL SIG_Display7_B		:  STD_LOGIC;
	SIGNAL SIG_Display7_C		:  STD_LOGIC;
	SIGNAL SIG_Display7_D		:  STD_LOGIC;
	SIGNAL SIG_Display7_E		:  STD_LOGIC;
	SIGNAL SIG_Display7_F		:  STD_LOGIC;
	SIGNAL SIG_Display7_G		:  STD_LOGIC;
	
	SIGNAL SIG_Display8_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display8_A		:  STD_LOGIC;
	SIGNAL SIG_Display8_B		:  STD_LOGIC;
	SIGNAL SIG_Display8_C		:  STD_LOGIC;
	SIGNAL SIG_Display8_D		:  STD_LOGIC;
	SIGNAL SIG_Display8_E		:  STD_LOGIC;
	SIGNAL SIG_Display8_F		:  STD_LOGIC;
	SIGNAL SIG_Display8_G		:  STD_LOGIC;
	
	
	TYPE controlFSM IS (state_IDLE1, state_IDLE2,
	
							  stateMIPS_Reset,
	
							  state_IF_InitPC, state_IF_IDLE, state_IF_Solicita, state_IF_Wait1, state_IF_Wait2,
							  
							  state_INST_Write_IDLE, state_INST_Write_Solicita, state_INST_Write_Wait1, state_INST_Write_Wait2,
							  
							  state_INST_Read_IDLE, state_INST_Read_Solicita, state_INST_Read_Wait1, state_INST_Read_Wait2,
							  
							  state_DATA_Write_Solicita, state_DATA_Write_Wait1, state_DATA_Write_Wait2,
							  
							  state_DATA_Read_Solicita, state_DATA_Read_Wait1, state_DATA_Read_Wait2,
							  
							  state_DATA_Debug_IDLE, state_DATA_Debug_Solicita, state_DATA_Debug_Wait1, state_DATA_Debug_Wait2,
							  
							  state_REG_Debug_IDLE, state_REG_Debug_Solicita, state_REG_Debug_Wait1, state_REG_Debug_Wait2,
							  
							  state_REG_Read_Solicita, state_REG_Read_Wait1, state_REG_Read_Wait2,
							  
							  state_REG_Write_Solicita, state_REG_Write_Wait1, state_REG_Write_Wait2,
							  
							  stateDECLoad, stateDECFilter,
							  
							  stateEXFilter, stateEXWait1, stateEXWait2,
							  
							  stateWBFilter							  
							  );
							  
	SIGNAL currentState	: controlFSM := state_IDLE1;
	
	-- Contador de programa.
	SIGNAL PC					: t_AddressINST ;
	
	-- Registradores HI e LO.
	--SIGNAL LO					: t_Register;
	--SIGNAL HI					: t_Register;
	
	-- OpCode extraído da instrução atual.
	SIGNAL SIG_INST_opCode	: t_opCode;
	
	-- Campo Funct, utilizado para identificação de instruções tipo R.
	SIGNAL SIG_INST_funct	: t_opCode;
	
	
	SIGNAL SIG_address 	: t_AddressINST;
	SIGNAL SIG_dataIn		: t_Byte;
	SIGNAL SIG_dataOut	: t_Byte;
	SIGNAL SIG_opCode		: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL SIG_ready		: STD_LOGIC_VECTOR(4 DOWNTO 0);
		
		
	CONSTANT CONST_addrHI : t_RegSelect := "100000";
	CONSTANT CONST_addrLO : t_RegSelect := "100001";
	
BEGIN

	A1 <= SIG_Display1_A;
	B1 <= SIG_Display1_B;
	C1 <= SIG_Display1_C;
	D1 <= SIG_Display1_D;
	E1 <= SIG_Display1_E;
	F1 <= SIG_Display1_F;
	G1 <= SIG_Display1_G;
	
	A2 <= SIG_Display2_A;
	B2 <= SIG_Display2_B;
	C2 <= SIG_Display2_C;
	D2 <= SIG_Display2_D;
	E2 <= SIG_Display2_E;
	F2 <= SIG_Display2_F;
	G2 <= SIG_Display2_G;
	
	A3 <= SIG_Display3_A;
	B3 <= SIG_Display3_B;
	C3 <= SIG_Display3_C;
	D3 <= SIG_Display3_D;
	E3 <= SIG_Display3_E;
	F3 <= SIG_Display3_F;
	G3 <= SIG_Display3_G;
	
	A4 <= SIG_Display4_A;
	B4 <= SIG_Display4_B;
	C4 <= SIG_Display4_C;
	D4 <= SIG_Display4_D;
	E4 <= SIG_Display4_E;
	F4 <= SIG_Display4_F;
	G4 <= SIG_Display4_G;
	
	A5 <= SIG_Display5_A;
	B5 <= SIG_Display5_B;
	C5 <= SIG_Display5_C;
	D5 <= SIG_Display5_D;
	E5 <= SIG_Display5_E;
	F5 <= SIG_Display5_F;
	G5 <= SIG_Display5_G;
	
	A6 <= SIG_Display6_A;
	B6 <= SIG_Display6_B;
	C6 <= SIG_Display6_C;
	D6 <= SIG_Display6_D;
	E6 <= SIG_Display6_E;
	F6 <= SIG_Display6_F;
	G6 <= SIG_Display6_G;
	
	A7 <= SIG_Display7_A;
	B7 <= SIG_Display7_B;
	C7 <= SIG_Display7_C;
	D7 <= SIG_Display7_D;
	E7 <= SIG_Display7_E;
	F7 <= SIG_Display7_F;
	G7 <= SIG_Display7_G;
	
	A8 <= SIG_Display8_A;
	B8 <= SIG_Display8_B;
	C8 <= SIG_Display8_C;
	D8 <= SIG_Display8_D;
	E8 <= SIG_Display8_E;
	F8 <= SIG_Display8_F;
	G8 <= SIG_Display8_G;
	
	-- Mapeamento de portas do componente RAM.
	mapDisplay1: ENTITY WORK.bin_7seg 
		PORT MAP
		(
			DADO	=> SIG_Display1_DADO,
			A		=> SIG_Display1_A,
			B		=> SIG_Display1_B,
			C		=> SIG_Display1_C,
			D		=> SIG_Display1_D,
			E		=> SIG_Display1_E,
			F		=> SIG_Display1_F,
			G		=> SIG_Display1_G			
		);
		
	-- Mapeamento de portas do componente RAM.
	mapDisplay2: ENTITY WORK.bin_7seg 
		PORT MAP
		(
			DADO	=> SIG_Display2_DADO,
			A		=> SIG_Display2_A,
			B		=> SIG_Display2_B,
			C		=> SIG_Display2_C,
			D		=> SIG_Display2_D,
			E		=> SIG_Display2_E,
			F		=> SIG_Display2_F,
			G		=> SIG_Display2_G			
		);
		
	-- Mapeamento de portas do componente RAM.
	mapDisplay3: ENTITY WORK.bin_7seg 
		PORT MAP
		(
			DADO	=> SIG_Display3_DADO,
			A		=> SIG_Display3_A,
			B		=> SIG_Display3_B,
			C		=> SIG_Display3_C,
			D		=> SIG_Display3_D,
			E		=> SIG_Display3_E,
			F		=> SIG_Display3_F,
			G		=> SIG_Display3_G			
		);
		
	
	-- Mapeamento de portas do componente RAM.
	mapDisplay4: ENTITY WORK.bin_7seg 
		PORT MAP
		(
			DADO	=> SIG_Display4_DADO,
			A		=> SIG_Display4_A,
			B		=> SIG_Display4_B,
			C		=> SIG_Display4_C,
			D		=> SIG_Display4_D,
			E		=> SIG_Display4_E,
			F		=> SIG_Display4_F,
			G		=> SIG_Display4_G			
		);
		
		
	-- Mapeamento de portas do componente RAM.
	mapDisplay5: ENTITY WORK.bin_7seg 
		PORT MAP
		(
			DADO	=> SIG_Display5_DADO,
			A		=> SIG_Display5_A,
			B		=> SIG_Display5_B,
			C		=> SIG_Display5_C,
			D		=> SIG_Display5_D,
			E		=> SIG_Display5_E,
			F		=> SIG_Display5_F,
			G		=> SIG_Display5_G			
		);
	
	
	-- Mapeamento de portas do componente RAM.
	mapDisplay6: ENTITY WORK.bin_7seg 
		PORT MAP
		(
			DADO	=> SIG_Display6_DADO,
			A		=> SIG_Display6_A,
			B		=> SIG_Display6_B,
			C		=> SIG_Display6_C,
			D		=> SIG_Display6_D,
			E		=> SIG_Display6_E,
			F		=> SIG_Display6_F,
			G		=> SIG_Display6_G			
		);
		

	-- Mapeamento de portas do componente RAM.
	mapDisplay7: ENTITY WORK.bin_7seg 
		PORT MAP
		(
			DADO	=> SIG_Display7_DADO,
			A		=> SIG_Display7_A,
			B		=> SIG_Display7_B,
			C		=> SIG_Display7_C,
			D		=> SIG_Display7_D,
			E		=> SIG_Display7_E,
			F		=> SIG_Display7_F,
			G		=> SIG_Display7_G			
		);
		
	mapDisplay8: ENTITY WORK.bin_7seg 
		PORT MAP
		(
			DADO	=> SIG_Display8_DADO,
			A		=> SIG_Display8_A,
			B		=> SIG_Display8_B,
			C		=> SIG_Display8_C,
			D		=> SIG_Display8_D,
			E		=> SIG_Display8_E,
			F		=> SIG_Display8_F,
			G		=> SIG_Display8_G			
		);
		
		
	
		
		
	-- Mapeamento de portas do componente ALU_MIPS32.
	mapALU_MIPS32: ENTITY WORK.ALU_MIPS32 
		PORT MAP
		(
			clock			=> SIG_ALU_MIPS32_clock,
			reset			=> SIG_ALU_MIPS32_reset,
			opCode		=> SIG_ALU_MIPS32_opCode,
			in0			=> SIG_ALU_MIPS32_in0,
			in1			=> SIG_ALU_MIPS32_in1,
			out0			=> SIG_ALU_MIPS32_out0,
			outFlags		=> SIG_ALU_MIPS32_outFlags,
			ready			=> SIG_ALU_MIPS32_ready
		);
		
	-- Mapeamento de portas do componente ALU_MIPS32.
	mapClockMIPS: ENTITY WORK.ClockMIPS
		PORT MAP
		(
			clockIN	=> SIG_ClockMIPS_clockIN,
			clockOUT	=> SIG_ClockMIPS_clockOUT
		);
		
	
	-- Mapeamento de portas do componente ALU_MIPS32.
	mapMIPS32_InstRAMCore: ENTITY WORK.MIPS32_InstRAMCore
		PORT MAP
		(
			clock			=> SIG_IRC_clock,
			reset			=>	SIG_IRC_reset,
			
			opCode		=> SIG_IRC_opCode,
			address		=>	SIG_IRC_address,
			dataIn		=> SIG_IRC_dataIn,
			dataOut		=> SIG_IRC_dataOut,
			instrucao	=> SIG_IRC_instrucao,
			ready			=> SIG_IRC_ready
			
			--stateOut1	=> SIG_Display2_DADO,
			--stateOut2	=> SIG_Display1_DADO
			
			--clockOUT		=> SIG_Display3_DADO,
			--resetOUT		=> SIG_Display2_DADO
		);	
		
		
	-- Mapeamento de portas do componente ALU_MIPS32.
	mapMIPS32_DataRAMCore: ENTITY WORK.MIPS32_DataRAMCore
		PORT MAP
		(
			clock			=> SIG_DRC_clock,
			reset			=>	SIG_DRC_reset,
			
			opCode		=> SIG_DRC_opCode,
			address		=>	SIG_DRC_address,
			dataIn		=> SIG_DRC_dataIn,
			dataOut		=> SIG_DRC_dataOut,
			bytes			=> SIG_DRC_bytes,
			ready			=> SIG_DRC_ready
			
			--stateOut1	=> SIG_Display2_DADO,
			--stateOut2	=> SIG_Display1_DADO
			
			--clockOUT		=> SIG_Display3_DADO,
			--resetOUT		=> SIG_Display2_DADO
		);		
	
		
	-- Mapeamento de portas do componente ALU_MIPS32.
	mapMIPS32_RegBankCore: ENTITY WORK.MIPS32_RegBankCore
		PORT MAP
		(
			clock				=> SIG_RBC_clock,
			reset				=>	SIG_RBC_reset,
			
			addressRead1	=>	SIG_RBC_addressRead1,
			addressRead2	=>	SIG_RBC_addressRead2,
			addressWrite1	=>	SIG_RBC_addressWrite1,
			addressWrite2	=>	SIG_RBC_addressWrite2,
			dataIn1			=> SIG_RBC_dataIn1,
			dataIn2			=> SIG_RBC_dataIn2,
			dataOut1			=> SIG_RBC_dataOut1,
			dataOut2			=> SIG_RBC_dataOut2,
			
			bytes 			=> SIG_RBC_bytes,
			
			opCode			=> SIG_RBC_opCode,
			ready				=> SIG_RBC_ready
		);	
	
	
	SIG_ClockMIPS_clockIN <= PIN_clockIN;
	
	-- Sincroniza o clock dos componentes (ambos componentes recebem o mesmo sinal de clock).
	SIG_ALU_MIPS32_clock <= SIG_ClockMIPS_clockOUT;
	SIG_IRC_clock			<= SIG_ClockMIPS_clockOUT;
	SIG_DRC_clock			<= SIG_ClockMIPS_clockOUT;
	SIG_RBC_clock			<= SIG_ClockMIPS_clockOUT;
	PIN_clockOUT			<= SIG_ClockMIPS_clockOUT;
	
	
	--sig_Display6_DADO <= "0000";
	--sig_Display5_DADO <= "0000";
	--sig_Display4_DADO <= "0000";
	--sig_Display3_DADO <= "0000";
	--sig_Display2_DADO <= "0000";
	--sig_Display1_DADO <= "0000";
	
	SIG_address <= address;
	SIG_dataIn 	<= dataIN;
	SIG_opCode 	<= opCode;
	dataOUT 		<= SIG_dataOut;
	ready			<= SIG_ready;
	
	
	-- Process de controle de reset e de currentState.
	PROCESS(SIG_ClockMIPS_clockOUT, reset) 
		VARIABLE VAR_addrRBRead1 		: t_RegSelect;
		VARIABLE VAR_addrRBRead2 		: t_RegSelect;
		VARIABLE VAR_addrRBWrite1 		: t_RegSelect;
		VARIABLE VAR_dataInRB1			: t_Word;
		VARIABLE VAR_addrRBWrite2 		: t_RegSelect;
		VARIABLE VAR_dataInRB2			: t_Word;
		VARIABLE VAR_addrDATAWrite		: t_addressDATA;
		VARIABLE VAR_addrDATARead		: t_addressDATA;
		VARIABLE VAR_dataInDATA			: t_Word;
		VARIABLE VAR_instrucaoAtual	: t_Word;
		VARIABLE VAR_ALUresult			: t_DWord;
		VARIABLE VAR_ALUflags			: t_Byte;
		--VARIABLE VAR_contINSTLoad		: INTEGER := 0;
		--VARIABLE VAR_contINSTFetch		: INTEGER := 0;
		VARIABLE PC							: t_addressINST;
		VARIABLE PC_MAX					: t_addressINST;
	BEGIN
		
		-- Reset do circuito.
		IF (reset = '1') THEN
			
			CASE SIG_opCode IS
			
				WHEN "000" =>
				
					currentState	<= state_IDLE1;
				
				WHEN "001" =>
				
					currentState	<= state_INST_Write_Solicita;
				
				WHEN "010" =>
				
					currentState	<= state_INST_Read_Solicita;
				
				WHEN "011" =>
				
					currentState	<= state_REG_Debug_Solicita;
								
				WHEN "100" =>
				
					currentState	<= state_DATA_Debug_Solicita;
				
				WHEN "101" =>
				
					currentState	<= stateMIPS_Reset;
				
				--WHEN "110" =>
				
				--	currentState	<= stateREGDEBUG_Solicita4;
				
				WHEN "111" =>
			
					-- Direciona a FSM para o estado de reset do processo de Busca.
					currentState	<= state_IF_Solicita;	
					
				WHEN OTHERS =>
				
					NULL;
				
			END CASE;			
				
		-- Caso reset = 0 e clock = 1.
		ELSIF (RISING_EDGE(SIG_ClockMIPS_clockOUT)) THEN
			
			-- Verifica o estado atual da FSM de Busca.
			CASE currentState IS
			
				-- Estado em que a máquina não realiza nenhuma operação.
				WHEN state_IDLE1	=>
				
					sig_Display8_DADO <= "1110";
					sig_Display7_DADO <= "1110";
					
					SIG_ready <= "00000";
					
					currentState <= state_IDLE1;
					
					
				WHEN state_IDLE2	=>
				
					--sig_Display8_DADO <= "1111";
					--sig_Display7_DADO <= "1111";
					
					sig_Display8_DADO <= "00" & SIG_INST_opCode(5 DOWNTO 4);
					sig_Display7_DADO <= SIG_INST_opCode(3 DOWNTO 0);
					
					sig_Display6_DADO <= "00" & SIG_INST_funct(5 DOWNTO 4);
					sig_Display5_DADO <= SIG_INST_funct(3 DOWNTO 0);
					
					sig_Display4_DADO <= PC(3 DOWNTO 0);
					
					sig_Display3_DADO <= VAR_ALUresult(3 DOWNTO 0);
					
					--sig_Display3_DADO <= std_logic_vector(to_unsigned(VAR_contINSTFetch, 4));
					
					sig_Display2_DADO <= SIG_RBC_dataOut1(3 DOWNTO 0);
					
					sig_Display1_DADO <= SIG_RBC_dataOut2(3 DOWNTO 0);
										
					
					
					--sig_Display8_DADO <= VAR_instrucaoAtual(31 DOWNTO 28);
					--sig_Display7_DADO <= VAR_instrucaoAtual(27 DOWNTO 24);
					--sig_Display6_DADO <= VAR_instrucaoAtual(23 DOWNTO 20);
					--sig_Display5_DADO <= VAR_instrucaoAtual(19 DOWNTO 16);
					--sig_Display4_DADO <= VAR_instrucaoAtual(15 DOWNTO 12);
					--sig_Display3_DADO <= VAR_instrucaoAtual(11 DOWNTO 8);
					--sig_Display2_DADO <= VAR_instrucaoAtual(7 DOWNTO 4);
					--sig_Display1_DADO <= VAR_instrucaoAtual(3 DOWNTO 0);
					
					SIG_ready <= "01110";
					
					currentState <= state_IDLE2;
					
					
				WHEN stateMIPS_Reset =>
				
					sig_Display8_DADO <= "1101";
					sig_Display7_DADO <= "1101";
					
					VAR_addrRBRead1 	:= (OTHERS => '0');
					VAR_addrRBRead2 	:= (OTHERS => '0');
					VAR_addrRBWrite1 	:= (OTHERS => '0');
					VAR_dataInRB1		:= (OTHERS => '0');
					VAR_addrRBWrite2 	:= (OTHERS => '0');
					VAR_dataInRB2		:= (OTHERS => '0');
					VAR_addrDATAWrite	:= (OTHERS => '0');
					VAR_addrDATARead	:= (OTHERS => '0');
					VAR_dataInDATA		:= (OTHERS => '0');
					VAR_instrucaoAtual:= (OTHERS => '0');
					VAR_ALUresult		:= (OTHERS => '0');
					VAR_ALUflags		:= (OTHERS => '0');
					--VAR_contINSTLoad	:= 0;
					--VAR_contINSTFetch	:= 0;
					PC						:= (OTHERS => '0');
				
					currentState <= state_IDLE1;
					
					
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE ESCRITA DE BYTES NA RAM DE INSTRUÇÕES %%%%%%%%%%%%%%%
				
				WHEN state_INST_Write_IDLE =>
				
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0101";
					
					SIG_IRC_reset <= '0';
					
					SIG_ready <= "00001";
				
					currentState <= state_INST_Write_IDLE;
				
				
				WHEN state_INST_Write_Solicita =>
				
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0001";
					
					SIG_ready <= "00000";
					
					SIG_IRC_opCode 	<= "010";
					SIG_IRC_reset 		<= '1';
					SIG_IRC_address 	<= SIG_address;
					SIG_IRC_dataIn 	<= SIG_dataIn;
					
					currentState <= state_INST_Write_Wait1;
			
				
				WHEN state_INST_Write_Wait1 =>
				
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0010";
					
					SIG_ready <= "00000";
			
					SIG_IRC_reset <= '0';
					
					currentState <= state_INST_Write_Wait2;
			
			
				WHEN state_INST_Write_Wait2 =>
				
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0011";
					
					SIG_IRC_reset <= '0';
					
					IF SIG_IRC_ready = "010" THEN
					
						--VAR_contINSTLoad := VAR_contINSTLoad + 1;;
						
						PC_MAX := PC_MAX + 1;
					
						currentState <= state_INST_Write_IDLE;
						
					ELSE
						
						currentState <= state_INST_Write_Wait2;
					
					END IF;
						
			-- %%%%%%%%%%%%%%% FIM DA FSM DE ESCRITA DE BYTES NA RAM DE INSTRUÇÕES %%%%%%%%%%%%%%%
			
			
			
			-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE DEBUG (DUMP) DA MEMÓRIA DE INSTRUÇÕES %%%%%%%%%%%%%%%
			
				WHEN state_INST_Read_IDLE =>
				
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0101";
					
					SIG_IRC_reset <= '0';
					
					SIG_dataOut <= SIG_IRC_dataOut;
					
					SIG_ready <= "00010";
					
					currentState <= state_INST_Read_IDLE;
				
				
				WHEN state_INST_Read_Solicita =>
				
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0001";
					
					SIG_ready <= "00000";
					
					SIG_IRC_opCode 	<= "011";
					SIG_IRC_reset 		<= '1';
					SIG_IRC_address 	<= SIG_address;
					
					currentState <= state_INST_Read_Wait1;
			
				
				WHEN state_INST_Read_Wait1 =>
				
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0010";
					
					SIG_ready <= "00000";
			
					SIG_IRC_reset <= '0';
					
					currentState <= state_INST_Read_Wait2;
			
			
				WHEN state_INST_Read_Wait2 =>
				
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0011";
					
					SIG_IRC_reset <= '0';
					
					IF SIG_IRC_ready = "011" THEN
					
						currentState <= state_INST_Read_IDLE;
						
					ELSE
						
						currentState <= state_INST_Read_Wait2;
					
					END IF;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM DE DEBUG (DUMP) DA MEMÓRIA DE INSTRUÇOES %%%%%%%%%%%%%%%
				
				
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE ESCRITA DE BYTES NA RAM DE DADOS %%%%%%%%%%%%%%%				
				
				WHEN state_DATA_Write_Solicita =>
				
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0001";
					
					SIG_ready <= "00000";
					
					SIG_DRC_opCode 	<= "010";
					SIG_DRC_reset 		<= '1';
					SIG_DRC_address 	<= VAR_addrDATAWrite;
					SIG_DRC_dataIn 	<= VAR_dataInDATA;
					
					currentState <= state_DATA_Write_Wait1;
			
				
				WHEN state_DATA_Write_Wait1 =>
				
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0010";
					
					SIG_ready <= "00000";
			
					SIG_DRC_reset <= '0';
					
					currentState <= state_DATA_Write_Wait2;
			
			
				WHEN state_DATA_Write_Wait2 =>
				
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0011";
					
					IF SIG_DRC_ready = "010" THEN
					
						IF PC = PC_MAX THEN
					
							--VAR_contINSTLoad 	:= 0;
							--VAR_contINSTFetch := 0;
							PC 		:= (OTHERS => '0');
							PC_MAX 	:= (OTHERS => '0');
					
							currentState <= state_IDLE2;
						
						ELSE
						
							PC := PC + 4;
						
							currentState <= state_IF_Solicita;
							
						END IF;
						
					ELSE
						
						currentState <= state_DATA_Write_Wait2;
					
					END IF;
						
				-- %%%%%%%%%%%%%%% FIM DA FSM DE ESCRITA DE BYTES NA RAM DE DADOS %%%%%%%%%%%%%%%
				
				
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE LEITURA DE BYTES NA RAM DE DADOS %%%%%%%%%%%%%%%
				
				
				WHEN state_DATA_Read_Solicita =>
				
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0001";
					
					SIG_ready <= "00000";
					
					SIG_DRC_opCode 	<= "001";
					SIG_DRC_reset 		<= '1';
					SIG_DRC_address 	<= VAR_addrDATARead;
					
					currentState <= state_DATA_Read_Wait1;
			
				
				WHEN state_DATA_Read_Wait1 =>
				
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0010";
					
					SIG_ready <= "00000";
			
					SIG_DRC_reset <= '0';
					
					currentState <= state_DATA_Read_Wait2;
			
			
				WHEN state_DATA_Read_Wait2 =>
				
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0011";
					
					IF SIG_DRC_ready = "001" THEN
					
						CASE SIG_INST_opCode IS
						
							-- LB
							WHEN "100000" =>
							
								VAR_dataInRB1 		:= STD_LOGIC_VECTOR( RESIZE(SIGNED(SIG_DRC_dataOut(7 DOWNTO 0)), VAR_dataInRB1'LENGTH) );
								VAR_addrRBWrite1 	:= "0" & VAR_instrucaoAtual(20 DOWNTO 16);
						
								currentState <= state_REG_Write_Solicita;
								
							-- LH
							WHEN "100001" =>
							
								VAR_dataInRB1 		:= STD_LOGIC_VECTOR( RESIZE(SIGNED(SIG_DRC_dataOut(15 DOWNTO 0)), VAR_dataInRB1'LENGTH) );
								VAR_addrRBWrite1 	:= "0" & VAR_instrucaoAtual(20 DOWNTO 16);
						
								currentState <= state_REG_Write_Solicita;
								
							-- LW, LBU, LHU
							WHEN "100011" | "100100" | "100101" =>
							
								VAR_dataInRB1 		:= SIG_DRC_dataOut;
								VAR_addrRBWrite1 	:= "0" & VAR_instrucaoAtual(20 DOWNTO 16);
						
								currentState <= state_REG_Write_Solicita;
							
							WHEN OTHERS =>
							
								NULL;
						
						END CASE;
					
						
					ELSE
						
						currentState <= state_DATA_Read_Wait2;
					
					END IF;
						
				-- %%%%%%%%%%%%%%% FIM DA FSM DE LEITURA DE BYTES NA RAM DE DADOS %%%%%%%%%%%%%%%
				
				
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE DEBUG (DUMP) DA MEMÓRIA DE DADOS %%%%%%%%%%%%%%%
			
				WHEN state_DATA_Debug_IDLE =>
				
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0101";
					
					SIG_DRC_reset <= '0';
					
					SIG_dataOut <= SIG_DRC_dataOut(7 DOWNTO 0);
					
					SIG_ready <= "00100";
					
					currentState <= state_DATA_Debug_IDLE;
			
			
				WHEN state_DATA_Debug_Solicita =>
				
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0001";
					
					SIG_ready <= "00000";
					
					SIG_DRC_opCode 	<= "001";
					SIG_DRC_reset 		<= '1';
					SIG_DRC_address 	<= SIG_address;
					SIG_DRC_bytes		<= "00";
					
					currentState <= state_DATA_Debug_Wait1;
					
					
				WHEN state_DATA_Debug_Wait1 =>	
				
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0010";
					
					SIG_ready <= "00000";
			
					SIG_DRC_reset <= '0';
					
					currentState <= state_DATA_Debug_Wait2;
			
			
				WHEN state_DATA_Debug_Wait2 =>
				
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0011";
					
					SIG_DRC_reset <= '0';
					
					IF SIG_DRC_ready = "001" THEN
					
						currentState <= state_DATA_Debug_IDLE;
						
					ELSE
						
						currentState <= state_DATA_Debug_Wait2;
					
					END IF;
					
					
				-- %%%%%%%%%%%%%%% FIM DA FSM DE DEBUG (DUMP) DA MEMÓRIA DE DADOS %%%%%%%%%%%%%%%
				
				
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE DEBUG (DUMP) DO REGBANK %%%%%%%%%%%%%%%
			
				WHEN state_REG_Debug_IDLE =>
				
					sig_Display8_DADO <= "0011";
					sig_Display7_DADO <= "0101";
					
					SIG_dataOut <= SIG_RBC_dataOut1(7 DOWNTO 0);
					
					SIG_ready <= "00011";
				
					currentState <= state_REG_Debug_IDLE;
			
			
				WHEN state_REG_Debug_Solicita =>
				
					sig_Display8_DADO <= "0011";
					sig_Display7_DADO <= "0001";
				
					SIG_ready <= "00000";
					
					SIG_RBC_opCode 			<= "001";
					SIG_RBC_reset 				<= '1';
					SIG_RBC_addressRead1 	<= SIG_address(5 DOWNTO 0);
					SIG_RBC_addressRead2 	<= (OTHERS => '0');
					SIG_RBC_bytes 				<= SIG_dataIn(2 DOWNTO 0);
					
					currentState <= state_REG_Debug_Wait1;
					
					
				WHEN state_REG_Debug_Wait1 =>	
				
					sig_Display8_DADO <= "0011";
					sig_Display7_DADO <= "0010";
					
					SIG_ready <= "00000";
			
					SIG_RBC_reset <= '0';
					
					currentState <= state_REG_Debug_Wait2;
			
			
				WHEN state_REG_Debug_Wait2 =>
				
					sig_Display8_DADO <= "0011";
					sig_Display7_DADO <= "0011";
					
					SIG_RBC_reset <= '0';
					
					IF SIG_RBC_ready = "001" THEN
					
						currentState <= state_REG_Debug_IDLE;
						
					ELSE
						
						currentState <= state_REG_Debug_Wait2;
					
					END IF;
					
					
				-- %%%%%%%%%%%%%%% FIM DA FSM DE DEBUG (DUMP) DO REGBANK %%%%%%%%%%%%%%%
				
				
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE LEITURA DE WORD DO REGBANK %%%%%%%%%%%%%%%
			
				WHEN state_REG_Read_Solicita =>
				
					sig_Display8_DADO <= "0100";
					sig_Display7_DADO <= "0001";
				
					SIG_ready <= "00000";
					
					SIG_RBC_opCode 	<= "001";
					SIG_RBC_reset 		<= '1';
					SIG_RBC_addressRead1 	<= VAR_addrRBRead1;
					SIG_RBC_addressRead2 	<= VAR_addrRBRead2;
					SIG_RBC_bytes <= "100";
					
					currentState <= state_REG_Read_Wait1;
					
					
				WHEN state_REG_Read_Wait1 =>	
				
					sig_Display8_DADO <= "0100";
					sig_Display7_DADO <= "0010";
					
					SIG_ready <= "00000";
			
					SIG_RBC_reset <= '0';
					
					currentState <= state_REG_Read_Wait2;
			
			
				WHEN state_REG_Read_Wait2 =>
				
					sig_Display8_DADO <= "0100";
					sig_Display7_DADO <= "0011";
					
					SIG_RBC_reset <= '0';
					
					IF SIG_RBC_ready = "001" THEN
					
						currentState <= stateEXFilter;
						
					ELSE
						
						currentState <= state_REG_Read_Wait2;
					
					END IF;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM DE LEITURA DE WORD DO REGBANK %%%%%%%%%%%%%%%
				
				
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE ESCRITA DE WORD DO REGBANK %%%%%%%%%%%%%%%
			
				WHEN state_REG_Write_Solicita =>
				
					sig_Display8_DADO <= "0101";
					sig_Display7_DADO <= "0001";
				
					SIG_ready <= "00000";
					
					SIG_RBC_opCode 			<= "010";
					SIG_RBC_reset 				<= '1';
					
					CASE SIG_INST_opCode IS
					
						-- LUI
						WHEN "011010" =>
							
							SIG_RBC_bytes				<= "010";
							
							SIG_RBC_addressWrite1 	<= VAR_addrRBWrite1;
							SIG_RBC_dataIn1			<= VAR_dataInRB1;
							
							SIG_RBC_addressWrite2 	<= VAR_addrRBWrite2;
							SIG_RBC_dataIn2			<= VAR_dataInRB2;
							
							currentState <= state_REG_Write_Wait1;

							
						WHEN OTHERS =>
						
							SIG_RBC_bytes				<= "000";
							
							SIG_RBC_addressWrite1 	<= VAR_addrRBWrite1;
							SIG_RBC_dataIn1			<= VAR_dataInRB1;
							
							SIG_RBC_addressWrite2 	<= VAR_addrRBWrite2;
							SIG_RBC_dataIn2			<= VAR_dataInRB2;
							
							currentState <= state_REG_Write_Wait1;
						
					END CASE;
					
					
				WHEN state_REG_Write_Wait1 =>	
				
					sig_Display8_DADO <= "0101";
					sig_Display7_DADO <= "0010";
					
					SIG_ready <= "00000";
			
					SIG_RBC_reset <= '0';
					
					currentState <= state_REG_Write_Wait2;
			
			
				WHEN state_REG_Write_Wait2 =>
				
					sig_Display8_DADO <= "0101";
					sig_Display7_DADO <= "0011";
					
					SIG_RBC_reset <= '0';
					
					IF SIG_RBC_ready = "010" THEN
					
						IF PC = PC_MAX THEN
					
							--VAR_contINSTLoad 	:= 0;
							--VAR_contINSTFetch := 0;
							PC 		:= (OTHERS => '0');
							PC_MAX 	:= (OTHERS => '0');
					
							currentState <= state_IDLE2;
						
						ELSE
						
							CASE SIG_INST_opCode IS
					
								WHEN "000000" =>
									
									CASE SIG_INST_funct IS
							
										-- JALR
										WHEN "001001" =>
										
											PC := SIG_RBC_dataOut1(7 DOWNTO 0);
										
										WHEN OTHERS =>
								
											PC := PC + 4;
								
									END CASE;

								WHEN OTHERS =>
								
									NULL;
								
							END CASE;
							
							currentState <= state_IF_Solicita;
							
						END IF;
						
					ELSE
						
						currentState <= state_REG_Write_Wait2;
					
					END IF;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM DE ESCRITA DE WORD DO REGBANK %%%%%%%%%%%%%%%
				
				
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE BUSCA DE INSTRUÇÃO %%%%%%%%%%%%%%%	
				
				WHEN state_IF_IDLE =>
				
					sig_Display8_DADO <= "0110";
					sig_Display7_DADO <= "0100";
					
					SIG_ready <= "01110";
					
					currentState <= state_IF_IDLE;
					
			
				WHEN state_IF_Solicita =>
			
					sig_Display8_DADO <= "0110";
					sig_Display7_DADO <= "0001";
					
					SIG_ready <= "00000";
					
					SIG_IRC_opCode 	<= "001";
					SIG_IRC_reset 		<= '1';
					SIG_IRC_address 	<= PC;
					
					currentState <= state_IF_Wait1;
			
			
				WHEN state_IF_Wait1 =>
				
					sig_Display8_DADO <= "0110";
					sig_Display7_DADO <= "0010";
			
					SIG_IRC_reset <= '0';
					
					currentState <= state_IF_Wait2;
			
			
				WHEN state_IF_Wait2 =>
				
					sig_Display8_DADO <= "0110";
					sig_Display7_DADO <= "0011";
					
					SIG_IRC_reset <= '0';
					
					IF SIG_IRC_ready = "001" THEN
					
						currentState <= stateDECLoad;
						
					ELSE
						
						currentState <= state_IF_Wait2;
					
					END IF;
					
					VAR_instrucaoAtual := SIG_IRC_instrucao;
				
				-- %%%%%%%%%%%%%%% FIM DA FSM DE BUSCA DE INSTRUÇÃO %%%%%%%%%%%%%%%	
				
				
				
				
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE DECODIFICAÇÃO %%%%%%%%%%%%%%%
				
				
				-- Estado onde o sinal de opCode é preenchido com parte dos dados contidos
				-- no sinal da instrução atual.
				WHEN stateDECLoad =>
			
					sig_Display8_DADO <= "0111";
					sig_Display7_DADO <= "0001";
					
					--VAR_contINSTFetch := VAR_contINSTFetch + 4;
					
					SIG_INST_opCode	<= VAR_instrucaoAtual(31 DOWNTO 26);
					
					SIG_INST_funct 	<= VAR_instrucaoAtual(5 DOWNTO 0);
					
					currentState <= stateDECFilter;
				
			
				WHEN stateDECFilter =>
				
					sig_Display8_DADO <= "0111";
					sig_Display7_DADO <= "0010";
					
					CASE SIG_INST_opCode IS
				
						-- INSTRUÇÕES DO TIPO R
						WHEN "000000" =>
						
							CASE SIG_INST_funct IS
							
								-------------------------------------------------------------
						
								-- ADD
								WHEN "100000" =>
									
									VAR_addrRBRead1 := "0" & VAR_instrucaoAtual(25 DOWNTO 21);
									VAR_addrRBRead2 := "0" & VAR_instrucaoAtual(20 DOWNTO 16);
									
									currentState <= state_REG_Read_Solicita;
									
								-------------------------------------------------------------
								
								-- ADDU
								WHEN "100001" =>
								
									VAR_addrRBRead1 := '0' & VAR_instrucaoAtual(25 DOWNTO 21);
									VAR_addrRBRead2 := '0' & VAR_instrucaoAtual(20 DOWNTO 16);
									
									currentState <= state_REG_Read_Solicita;
									
								-------------------------------------------------------------	
								
								-- AND
								WHEN "100100" =>
								
									VAR_addrRBRead1 := '0' & VAR_instrucaoAtual(25 DOWNTO 21);
									VAR_addrRBRead2 := '0' & VAR_instrucaoAtual(20 DOWNTO 16);
									
									currentState <= state_REG_Read_Solicita;
									
								-------------------------------------------------------------
								
								-- DIV, DIVU
								WHEN "011010" | "011011" =>
								
									VAR_addrRBRead1 := '0' & VAR_instrucaoAtual(25 DOWNTO 21);
									VAR_addrRBRead2 := '0' & VAR_instrucaoAtual(20 DOWNTO 16);
									
									currentState <= state_REG_Read_Solicita;
								
								-------------------------------------------------------------
							
								-- JALR
								WHEN "001001" =>
								
									VAR_addrRBRead1 := '0' & VAR_instrucaoAtual(25 DOWNTO 21);
									VAR_addrRBRead2 := (OTHERS => '0');
									
									currentState <= state_REG_Read_Solicita;
								
								-------------------------------------------------------------
							
								-- SUB
								WHEN "100010" =>
								
									VAR_addrRBRead1 := "0" & VAR_instrucaoAtual(25 DOWNTO 21);
									VAR_addrRBRead2 := "0" & VAR_instrucaoAtual(20 DOWNTO 16);
																		
									currentState <= state_REG_Read_Solicita;
																
								-------------------------------------------------------------
							
								-- SUBU
								WHEN "100011" =>
								
									VAR_addrRBRead1 := "0" & VAR_instrucaoAtual(25 DOWNTO 21);
									VAR_addrRBRead2 := "0" & VAR_instrucaoAtual(20 DOWNTO 16);
																		
									currentState <= state_REG_Read_Solicita;
								
								-------------------------------------------------------------
								
								WHEN OTHERS =>
								
									currentState <= state_IDLE2;
							
							END CASE;
							
							-- LUI
							WHEN "001111" =>
							
								currentState <= stateWBFilter;
							
							-- LB, LH, LW, LBU, LHU, SB, SH, SW
							WHEN "100000" | "100001" | "100011" | "100100" | "100101" | "101000" | "101001" | "101011" =>
							
								VAR_addrRBRead1 := "0" & VAR_instrucaoAtual(25 DOWNTO 21);
								VAR_addrRBRead2 := "0" & VAR_instrucaoAtual(20 DOWNTO 16);
																		
								currentState <= state_REG_Read_Solicita;
							
							
							WHEN OTHERS =>
								
								currentState <= state_IDLE2;
							
						END CASE;
				
			-- %%%%%%%%%%%%%%% FIM DA FSM DE DECODIFICAÇÃO %%%%%%%%%%%%%%%
			
			
			-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE EXECUÇÃO %%%%%%%%%%%%%%%
			
				WHEN stateEXFilter =>
				
					sig_Display8_DADO <= "1000";
					sig_Display7_DADO <= "0001";
					
					CASE SIG_INST_opCode IS
				
						-- INSTRUÇÕES DO TIPO R
						WHEN "000000" =>
						
							CASE SIG_INST_funct IS
							
								-------------------------------------------------------------
						
								-- ADD
								WHEN "100000" =>
									
									SIG_ready <= "00000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000000";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									currentState <= stateEXWait1;
									
								-------------------------------------------------------------
								
								-- ADDU
								WHEN "100001" =>
								
									SIG_ready <= "00000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000001";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									currentState <= stateEXWait1;
									
								-------------------------------------------------------------
								
								-- AND
								WHEN "100100" =>
								
									SIG_ready <= "00000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "010000";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									currentState <= stateEXWait1;
								
								-------------------------------------------------------------
								
								-- DIV
								WHEN "011010" =>
								
									SIG_ready <= "00000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000100";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									currentState <= stateEXWait1;
								
								-------------------------------------------------------------
								
								-- DIVU
								WHEN "011011" =>
								
									SIG_ready <= "00000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000101";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									currentState <= stateEXWait1;
								
								-------------------------------------------------------------
								
								-- JALR
								WHEN "001001" =>
								
									SIG_ready <= "00000";
									
									currentState <= stateWBFilter;
								
								-------------------------------------------------------------
							
								-- SUB
								WHEN "100010" =>
								
									SIG_ready <= "00000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "001110";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									currentState <= stateEXWait1;
								
								-------------------------------------------------------------
								
								-------------------------------------------------------------	
								
								-- SUBU
								WHEN "100011" =>
								
									SIG_ready <= "00000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "001111";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									currentState <= stateEXWait1;
									
								-------------------------------------------------------------	
								
									
								WHEN OTHERS =>
								
									NULL;
							
							END CASE;
							
							
							-- LB, LH, LW, LBU, LHU, SB, SH, SW
							WHEN "100000" | "100001" | "100011" | "100100" | "100101" | "101000" | "101001" | "101011" =>
					
								SIG_ready <= "00000";
									
								SIG_ALU_MIPS32_reset 	<= '1';		
								SIG_ALU_MIPS32_opCode 	<= "000001";
								SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
								SIG_ALU_MIPS32_in1 		<=  STD_LOGIC_VECTOR( RESIZE(SIGNED(VAR_instrucaoAtual(15 DOWNTO 0)), SIG_ALU_MIPS32_in1'LENGTH) );
								
								currentState <= stateEXWait1;
								
							WHEN OTHERS =>
								
								NULL;
							
						END CASE;
					
					
					
					
				WHEN stateEXWait1 =>
				
					sig_Display8_DADO <= "1000";
					sig_Display7_DADO <= "0010";
					
					SIG_ALU_MIPS32_reset <= '0';
					
					currentState <= stateEXWait2;
					
					
				WHEN stateExWait2 =>
				
					sig_Display8_DADO <= "1000";
					sig_Display7_DADO <= "0011";
					
					SIG_ALU_MIPS32_reset <= '0';
					
					IF SIG_ALU_MIPS32_ready = '1' THEN
					
						currentState <= stateWBFilter;
						
					ELSE
					
						currentState <= stateExWait2;
						
					END IF;
					
					VAR_ALUresult 	:= SIG_ALU_MIPS32_out0;
					VAR_ALUflags	:= SIG_ALU_MIPS32_outFlags;
					
				
				-- %%%%%%%%%%%%%%% TÉRMINO DA FSM DE EXECUÇÃO %%%%%%%%%%%%%%%
				
				
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE WRITEBACK %%%%%%%%%%%%%%%
		
			-- Estado onde, de acordo com o valor do sinal opCode, a instrução é filtrada e
			-- e as operações necessárias para no processo de writeback (memória ou registrador)
			-- são realizadas.
			WHEN stateWBFilter =>
			
				sig_Display8_DADO <= "1001";
				sig_Display7_DADO <= "0001";
			
				-- Filtra o valor do sinal de opCode.
				CASE SIG_INST_opCode IS
				
					-- INSTRUÇÕES DO TIPO R
					WHEN "000000" =>
					
						CASE SIG_INST_funct IS
								
							-------------------------------------------------------------
						
							-- ADD
							WHEN "100000" =>
										
								-- Verifica existência de overflow no cálculo, caso não haja,
								-- escreve o valor no registrador de destino.
								IF(VAR_ALUflags(4) /= '1') THEN
									
									VAR_addrRBWrite1 	:= '0' & VAR_instrucaoAtual(15 DOWNTO 11);
									VAR_dataInRB1 		:= VAR_ALUresult(31 DOWNTO 0);
								
								END IF;
								
								currentState <= state_REG_Write_Solicita;
								
							-------------------------------------------------------------
								
							-- ADDU
							WHEN "100001" =>
								
								VAR_addrRBWrite1 := '0' & VAR_instrucaoAtual(15 DOWNTO 11);
								VAR_dataInRB1	 := VAR_ALUresult(31 DOWNTO 0);
								
								currentState <= state_REG_Write_Solicita;
							
							-------------------------------------------------------------
							
							-- AND
							WHEN "100100" =>
								
								VAR_addrRBWrite1 := '0' & VAR_instrucaoAtual(15 DOWNTO 11);
								VAR_dataInRB1	 := VAR_ALUresult(31 DOWNTO 0);
								
								currentState <= state_REG_Write_Solicita;
							
							-------------------------------------------------------------	
							
							-- DIV, DIVU
							WHEN "011010" | "011011" =>
								
								VAR_addrRBWrite1	:= CONST_addrLO;
								VAR_dataInRB1	 	:= VAR_ALUresult(31 DOWNTO 0);
								
								VAR_addrRBWrite2	:= CONST_addrHI;
								VAR_dataInRB2	 	:= VAR_ALUresult(63 DOWNTO 32);
								
								currentState <= state_REG_Write_Solicita;
							
							-------------------------------------------------------------	
							
							-- JALR
							WHEN "001001" =>
								
								VAR_addrRBWrite1	:= '0' & VAR_instrucaoAtual(15 DOWNTO 11);
								VAR_dataInRB1	 	:= x"000000" & PC + 4;
								
								currentState <= state_REG_Write_Solicita;
							
							-------------------------------------------------------------
								
							-- SUB
							WHEN "100010" =>
							
								-- Verifica existência de overflow no cálculo, caso não haja,
								-- escreve o valor no registrador de destino.
								IF(VAR_ALUflags(4) /= '1') THEN
									
									VAR_addrRBWrite1 	:= '0' & VAR_instrucaoAtual(15 DOWNTO 11);
									VAR_dataInRB1		:= VAR_ALUresult(31 DOWNTO 0);
								
								END IF;
								
								currentState <= state_REG_Write_Solicita;
								
							-------------------------------------------------------------
								
							-- SUBU
							WHEN "100011" =>
							
								-- Salva o valor resultante da operação na ALU
								-- no registrador indicado em RD.
								VAR_addrRBWrite1 	:= '0' & VAR_instrucaoAtual(15 DOWNTO 11);
								VAR_dataInRB1 		:= VAR_ALUresult(31 DOWNTO 0);
								
								currentState <= state_REG_Write_Solicita;
								
							-------------------------------------------------------------
							
							
							WHEN OTHERS =>
								
								NULL;
							
						END CASE;
						
						
						-- LUI
						WHEN "001111" =>
						
							VAR_addrRBWrite1 	:= '0' & VAR_instrucaoAtual(20 DOWNTO 16);
							VAR_dataInRB1 		:= VAR_instrucaoAtual(15 DOWNTO 0) & x"0000";
							
							currentState <= state_REG_Write_Solicita;
							
						
						-- LB, LBU
						WHEN "100000" | "100100" =>
					
							VAR_addrDATARead := VAR_ALUresult(7 DOWNTO 0);
							SIG_DRC_bytes 		<= "00";
							
							currentState <= state_DATA_Read_Solicita;
						
						
						-- LH, LHU
						WHEN "100001" |"100101" =>
					
							VAR_addrDATARead := VAR_ALUresult(7 DOWNTO 0);
							SIG_DRC_bytes 		<= "01";
							
							currentState <= state_DATA_Read_Solicita;
						
						
						-- LW
						WHEN "100011" =>
					
							VAR_addrDATARead := VAR_ALUresult(7 DOWNTO 0);
							SIG_DRC_bytes 		<= "11";
							
							currentState <= state_DATA_Read_Solicita;			
						
						
						-- SB
						WHEN "101000" =>
					
							VAR_addrDATAWrite := VAR_ALUresult(7 DOWNTO 0);
							VAR_dataInDATA 	:= SIG_RBC_dataOut2;
							SIG_DRC_bytes 		<= "00";
							
							currentState <= state_DATA_Write_Solicita;
						
						
						-- SH
						WHEN "101001" =>
					
							VAR_addrDATAWrite := VAR_ALUresult(7 DOWNTO 0);
							VAR_dataInDATA 	:= SIG_RBC_dataOut2;
							SIG_DRC_bytes 		<= "01";
							
							currentState <= state_DATA_Write_Solicita;
							
						
						-- SW
						WHEN "101011" =>
					
							VAR_addrDATAWrite := VAR_ALUresult(7 DOWNTO 0);
							VAR_dataInDATA 	:= SIG_RBC_dataOut2;
							SIG_DRC_bytes 		<= "11";
							
							currentState <= state_DATA_Write_Solicita;
							
							
						WHEN OTHERS =>
								
							NULL;
							
					END CASE;
				
	
				-- Estado Inválido.
				WHEN OTHERS =>
				
					NULL;
					
			END CASE;
		
		END IF;
	
	END PROCESS;
			
END RTL;
-- Fim da declaração da arquitetura da entidade ROM.