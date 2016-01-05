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
 --# Arquivo: MIPS32_Control.vhd 														#
 --#                                                                      	#
 --# Esse arquivo descreve a estrutura e comportamento da unidade de      	#
 --# controle do processador MIPS32, é com esse circuito também que o     	#
 --# Arqduino irá se comunicar.                                           	#
 --#                                                                      	#
 --# 04/01/16 - Formiga - MG                                              	#
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
		address			: IN t_AddressINST;							-- Barramento de endereçamento    (8 bits)
		dataOUT			: OUT t_Byte;									-- Barramento de saída de dados 	 (8 bits)
		dataIN			: IN t_Byte;									-- Barramento de entrada de dados (8 bits)
		
		PIN_clockOUT	: OUT STD_LOGIC;								-- Pino de saída do sinal de clock já processado (divido), utilizado para sincronia com Arduino.
		PIN_clockIN		: IN STD_LOGIC;								-- Pino de entrada do sinal de clock vindo da FPGA(50MHz)
		
		opCode			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);		-- Barramento de opCode para seleção das operaçoes executadas pela unidade de controle.
		
		reset				: IN STD_LOGIC;								-- Sinal de reset para reiniciar o circuito.
		
		ready				: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);		-- Barramento de status do circuito (ready) para indicação de cada operação executada pelo circuito.
																				
																				-- "000": Circuito ocupado.
																				-- "001": Fim do processo de escrita de instruçao.
																				-- "010": Fim do processo de Debug de instruçao.
																				-- "011": Fim do processo de Debug de registradores.
																				-- "100": Fim do processo de Debug de dados.
																				-- "101": Fim da execuçao as instruçoes.
																		
		error				: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);		-- Barramento de status de erro do circuito.
		
		A1			: OUT STD_LOGIC;										-- Display de 7 segmentos 1 (HEX0)
		B1			: OUT STD_LOGIC;
		C1			: OUT STD_LOGIC;
		D1			: OUT STD_LOGIC;
		E1			: OUT STD_LOGIC;
		F1			: OUT STD_LOGIC;
		G1			: OUT STD_LOGIC;
		
		A2			: OUT STD_LOGIC;										-- Display de 7 segmentos 2 (HEX1)
		B2			: OUT STD_LOGIC;
		C2			: OUT STD_LOGIC;
		D2			: OUT STD_LOGIC;
		E2			: OUT STD_LOGIC;
		F2			: OUT STD_LOGIC;
		G2			: OUT STD_LOGIC;
		
		A3			: OUT STD_LOGIC;										-- Display de 7 segmentos 3 (HEX2)
		B3			: OUT STD_LOGIC;
		C3			: OUT STD_LOGIC;
		D3			: OUT STD_LOGIC;
		E3			: OUT STD_LOGIC;
		F3			: OUT STD_LOGIC;
		G3			: OUT STD_LOGIC;
		
		A4			: OUT STD_LOGIC;										-- Display de 7 segmentos 4 (HEX3)
		B4			: OUT STD_LOGIC;
		C4			: OUT STD_LOGIC;
		D4			: OUT STD_LOGIC;
		E4			: OUT STD_LOGIC;
		F4			: OUT STD_LOGIC;
		G4			: OUT STD_LOGIC;
		
		A5			: OUT STD_LOGIC;										-- Display de 7 segmentos 5 (HEX4)
		B5			: OUT STD_LOGIC;
		C5			: OUT STD_LOGIC;
		D5			: OUT STD_LOGIC;
		E5			: OUT STD_LOGIC;
		F5			: OUT STD_LOGIC;
		G5			: OUT STD_LOGIC;
		
		A6			: OUT STD_LOGIC;										-- Display de 7 segmentos 6 (HEX5)
		B6			: OUT STD_LOGIC;
		C6			: OUT STD_LOGIC;
		D6			: OUT STD_LOGIC;
		E6			: OUT STD_LOGIC;
		F6			: OUT STD_LOGIC;
		G6			: OUT STD_LOGIC;
		
		A7			: OUT STD_LOGIC;										-- Display de 7 segmentos 7 (HEX6)
		B7			: OUT STD_LOGIC;
		C7			: OUT STD_LOGIC;
		D7			: OUT STD_LOGIC;
		E7			: OUT STD_LOGIC;
		F7			: OUT STD_LOGIC;
		G7			: OUT STD_LOGIC;
		
		A8			: OUT STD_LOGIC;										-- Display de 7 segmentos 8 (HEX7)
		B8			: OUT STD_LOGIC;
		C8			: OUT STD_LOGIC;
		D8			: OUT STD_LOGIC;
		E8			: OUT STD_LOGIC;
		F8			: OUT STD_LOGIC;
		G8			: OUT STD_LOGIC
		
	);

END ENTITY;
-- Fim da declaração da entidade MIPS32_Control.


-- Início da declaração da arquitetura da entidade MIPS32_Control.
ARCHITECTURE BEHAVIOR OF MIPS32_Control IS

	
	-- Sinais para conexao com o componente "ALU_MIPS32".
	SIGNAL SIG_ALU_MIPS32_clock 		:  STD_LOGIC;
	SIGNAL SIG_ALU_MIPS32_reset		:  STD_LOGIC;
	SIGNAL SIG_ALU_MIPS32_opCode 		:  t_opCode;
	SIGNAL SIG_ALU_MIPS32_in0 			: 	t_Word;
	SIGNAL SIG_ALU_MIPS32_in1 			: 	t_Word;
	SIGNAL SIG_ALU_MIPS32_out0 		:  t_DWord;
	SIGNAL SIG_ALU_MIPS32_outFlags 	:  t_Byte;
	SIGNAL SIG_ALU_MIPS32_ready 		:  STD_LOGIC;
	
	-- Sinais para conexão com o componente "ClockMIPS".
	SIGNAL SIG_ClockMIPS_clockIN	: STD_LOGIC;
	SIGNAL SIG_ClockMIPS_clockOUT	: STD_LOGIC;
	
	-- Sinais para conexão com o componente "MIPS32_InstRAMCore".
	SIGNAL SIG_IRC_clock			: STD_LOGIC;
	SIGNAL SIG_IRC_reset			: STD_LOGIC := '0';
	SIGNAL SIG_IRC_opCode		: STD_LOGIC_VECTOR(2 DOWNTO 0); 
	SIGNAL SIG_IRC_address		: t_AddressINST; 
	SIGNAL SIG_IRC_dataIn		: t_Byte; 
	SIGNAL SIG_IRC_dataOut		: t_Byte; 
	SIGNAL SIG_IRC_instrucao	: t_Word;
	SIGNAL SIG_IRC_ready			: STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	-- Sinais para conexão com o componente "MIPS32_DataRAMCore".
	SIGNAL SIG_DRC_clock			: STD_LOGIC;
	SIGNAL SIG_DRC_reset			: STD_LOGIC := '0';
	SIGNAL SIG_DRC_opCode		: STD_LOGIC_VECTOR(2 DOWNTO 0); 
	SIGNAL SIG_DRC_address		: t_AddressINST; 
	SIGNAL SIG_DRC_dataIn		: t_Word; 
	SIGNAL SIG_DRC_dataOut		: t_Word; 
	SIGNAL SIG_DRC_bytes			: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL SIG_DRC_ready			: STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	-- Sinais para conexão com o componente "MIPS32_RegBankCore".
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
	
	-- Sinais para conexão com o componente 'bin_7seg" para o display de 7 segmentos 1 (HEX0).
	SIGNAL SIG_Display1_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display1_A		:  STD_LOGIC;
	SIGNAL SIG_Display1_B		:  STD_LOGIC;
	SIGNAL SIG_Display1_C		:  STD_LOGIC;
	SIGNAL SIG_Display1_D		:  STD_LOGIC;
	SIGNAL SIG_Display1_E		:  STD_LOGIC;
	SIGNAL SIG_Display1_F		:  STD_LOGIC;
	SIGNAL SIG_Display1_G		:  STD_LOGIC;
	
	-- Sinais para conexão com o componente 'bin_7seg" para o display de 7 segmentos 2 (HEX1).
	SIGNAL SIG_Display2_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display2_A		:  STD_LOGIC;
	SIGNAL SIG_Display2_B		:  STD_LOGIC;
	SIGNAL SIG_Display2_C		:  STD_LOGIC;
	SIGNAL SIG_Display2_D		:  STD_LOGIC;
	SIGNAL SIG_Display2_E		:  STD_LOGIC;
	SIGNAL SIG_Display2_F		:  STD_LOGIC;
	SIGNAL SIG_Display2_G		:  STD_LOGIC;
	
	-- Sinais para conexão com o componente 'bin_7seg" para o display de 7 segmentos 3 (HEX2).
	SIGNAL SIG_Display3_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display3_A		:  STD_LOGIC;
	SIGNAL SIG_Display3_B		:  STD_LOGIC;
	SIGNAL SIG_Display3_C		:  STD_LOGIC;
	SIGNAL SIG_Display3_D		:  STD_LOGIC;
	SIGNAL SIG_Display3_E		:  STD_LOGIC;
	SIGNAL SIG_Display3_F		:  STD_LOGIC;
	SIGNAL SIG_Display3_G		:  STD_LOGIC;
	
	-- Sinais para conexão com o componente 'bin_7seg" para o display de 7 segmentos 4 (HEX3).
	SIGNAL SIG_Display4_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display4_A		:  STD_LOGIC;
	SIGNAL SIG_Display4_B		:  STD_LOGIC;
	SIGNAL SIG_Display4_C		:  STD_LOGIC;
	SIGNAL SIG_Display4_D		:  STD_LOGIC;
	SIGNAL SIG_Display4_E		:  STD_LOGIC;
	SIGNAL SIG_Display4_F		:  STD_LOGIC;
	SIGNAL SIG_Display4_G		:  STD_LOGIC;
	
	-- Sinais para conexão com o componente 'bin_7seg" para o display de 7 segmentos 5 (HEX4).
	SIGNAL SIG_Display5_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display5_A		:  STD_LOGIC;
	SIGNAL SIG_Display5_B		:  STD_LOGIC;
	SIGNAL SIG_Display5_C		:  STD_LOGIC;
	SIGNAL SIG_Display5_D		:  STD_LOGIC;
	SIGNAL SIG_Display5_E		:  STD_LOGIC;
	SIGNAL SIG_Display5_F		:  STD_LOGIC;
	SIGNAL SIG_Display5_G		:  STD_LOGIC;
	
	-- Sinais para conexão com o componente 'bin_7seg" para o display de 7 segmentos 6 (HEX5).
	SIGNAL SIG_Display6_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display6_A		:  STD_LOGIC;
	SIGNAL SIG_Display6_B		:  STD_LOGIC;
	SIGNAL SIG_Display6_C		:  STD_LOGIC;
	SIGNAL SIG_Display6_D		:  STD_LOGIC;
	SIGNAL SIG_Display6_E		:  STD_LOGIC;
	SIGNAL SIG_Display6_F		:  STD_LOGIC;
	SIGNAL SIG_Display6_G		:  STD_LOGIC;
	
	-- Sinais para conexão com o componente 'bin_7seg" para o display de 7 segmentos 7 (HEX6).
	SIGNAL SIG_Display7_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display7_A		:  STD_LOGIC;
	SIGNAL SIG_Display7_B		:  STD_LOGIC;
	SIGNAL SIG_Display7_C		:  STD_LOGIC;
	SIGNAL SIG_Display7_D		:  STD_LOGIC;
	SIGNAL SIG_Display7_E		:  STD_LOGIC;
	SIGNAL SIG_Display7_F		:  STD_LOGIC;
	SIGNAL SIG_Display7_G		:  STD_LOGIC;
	
	-- Sinais para conexão com o componente 'bin_7seg" para o display de 7 segmentos 8 (HEX7).
	SIGNAL SIG_Display8_DADO 	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SIG_Display8_A		:  STD_LOGIC;
	SIGNAL SIG_Display8_B		:  STD_LOGIC;
	SIGNAL SIG_Display8_C		:  STD_LOGIC;
	SIGNAL SIG_Display8_D		:  STD_LOGIC;
	SIGNAL SIG_Display8_E		:  STD_LOGIC;
	SIGNAL SIG_Display8_F		:  STD_LOGIC;
	SIGNAL SIG_Display8_G		:  STD_LOGIC;
	
	
	-- Declaraçao da máquina de estados do circuito de controle.
	
	--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
	
	-- state_IDLE						: Estado onde a máquina permanece inativa, ou seja, não faz nenhuma operaçao útil.
	-- state_IDLE_Fim					: Estado IDLE executado após o processador executar todas as instruçoes carregadas na RAM de instruçoes.
	
	-- stateMIPS_Reset				: Estado de reset do circuito de controle, i.e. reset de todas as variáveis.
	
	
	--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
	
	
	-- %%%%%% FSM de controle da memória RAM de Instruçoes %%%%%%
	-- state_INST_Write_IDLE		: Estado IDLE da FSM dos estados de escrita na RAM de instruçoes.
	
	-- state_INST_Write_Solicita	: Estado onde é solicitada a escrita de um determinado byte na posiçao especificada pelo barramento externo.
	
	-- state_INST_Write_Wait1		: Estado utilizado para ativar a operaçao correspondente no circuito controlador da RAM de instruçoes, ou seja, 
	--										  após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
	
	-- state_INST_Write_Wait2		: Estado onde aguarda-se que a controladora da RAM de Instruçoes execute a gravaçao dos dados
	--										  e informe por meio do sinal "ready" que essa operaçao foi executada.
	
	
	-- state_INST_Debug_IDLE		: Estado IDLE da FSM dos estados de de Debug da RAM de instruçoes.
	
	-- state_INST_Debug_Solicita	: Estado onde é solicitada a leitura de um determinado byte na posiçao especificada pelo barramento externo.
	
	-- state_INST_Debug_Wait1		: Estado utilizado para ativar a operaçao correspondente no circuito controlador da RAM de instruçoes,
	-- 									  ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
	
	-- state_INST_Debug_Wait2		: Estado onde aguarda-se que a controladora da RAM de Instruçoes execute a leitura dos dados
	-- 									  e informe por meio do sinal "ready" que essa operaçao foi executada.
	
	
	--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
	
	
	-- %%%%%%   FSM de controle da memória RAM de Dados   %%%%%% 
	-- state_DATA_Write_Solicita	: Estado onde é solicitada a escrita de um determinado byte na posiçao especificada pelo barramento externo.
	
	-- state_DATA_Write_Wait1		: Estado utilizado para ativar a operaçao correspondente no circuito controlador da RAM de dados,
	-- 									  ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
	
	-- state_DATA_Write_Wait2		: Estado onde aguarda-se que a controladora da RAM de Dados execute a escrita dos dados
	-- 									  e informe por meio do sinal "ready" que essa operaçao foi executada.	
	
	
	-- state_DATA_Read_Solicita	: Estado onde é solicitada a leitura de um determinado byte na posiçao especificada pelo barramento externo.
	
	-- state_DATA_Read_Wait1		: Estado utilizado para ativar a operaçao correspondente no circuito controlador da RAM de dados,
	-- 									  ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
	
	-- state_DATA_Read_Wait2		: Estado onde aguarda-se que a controladora da RAM de Dados execute a leitura dos dados
	-- 									  e informe por meio do sinal "ready" que essa operaçao foi executada.
	
	
	-- state_DATA_Debug_IDLE		: Estado IDLE da FSM dos estados de de Debug da RAM de dados.
	
	-- state_DATA_Debug_Solicita	: Estado onde é solicitada a leitura de um determinado byte na posiçao especificada pelo barramento externo.
	
	-- state_DATA_Debug_Wait1		: Estado utilizado para ativar a operaçao correspondente no circuito controlador da RAM de dados,
	-- 									  ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
	
	-- state_DATA_Debug_Wait2		: Estado onde aguarda-se que a controladora da RAM de Dados execute a leitura dos dados
	-- 									  e informe por meio do sinal "ready" que essa operaçao foi executada.
	
	
	--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
	
	
	-- %%%%%%  FSM de controle do Banco de Registradores  %%%%%%
	-- state_REG_Read_Solicita		: Estado onde é solicitada a leitura de um determinado byte na posiçao especificada pelo barramento externo.
	
	-- state_REG_Read_Wait1			: Estado utilizado para ativar a operaçao correspondente no circuito controlador do Banco de Registradores,
	-- 									  ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
	
	-- state_REG_Read_Wait2			: Estado onde aguarda-se que a controladora do Banco de Registradores execute a leitura dos dados
	--										  e informe por meio do sinal "ready" que essa operaçao foi executada.
	
	
	-- state_REG_Write_Solicita	: Estado onde é solicitada a escrita de um determinado byte na posiçao especificada pelo barramento externo.
	
	-- state_REG_Write_Wait1		: Estado utilizado para ativar a operaçao correspondente no circuito controlador do Banco de Registradores,
	-- 									  ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
	
	-- state_REG_Write_Wait2		: Estado onde aguarda-se que a controladora do Banco de Registradores execute a escrita dos dados
	-- 								     e informe por meio do sinal "ready" que essa operaçao foi executada.
	
	
	-- state_REG_Debug_IDLE			: Estado IDLE da FSM dos estados de Debug do Banco de Registradores.
	
	-- state_REG_Debug_Solicita	: Estado onde é solicitada a leitura de um determinado byte na posiçao especificada pelo barramento externo.
	
	-- state_REG_Debug_Wait1		: Estado utilizado para ativar a operaçao correspondente no circuito controlador do Banco de Registradores,
	--										  ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
	
	-- state_REG_Debug_Wait2		: Estado onde aguarda-se que a controladora do Banco de Registradores execute a leitura dos dados
	-- 									  e informe por meio do sinal "ready" que essa operaçao foi executada.
	
	
	--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
	
	
	-- %%%%%%     FSM de controle do estágio de Busca de Instruçao     %%%%%% 	
	-- state_IF_Solicita				: Estado onde é solicitado ao controlador da RAM de instruçoes a leitura da próxima instruçao. Envia o valor base do contador de programa (PC),
	--										  e o controlador é responsável por ler todos os 4 bytes da RAM de instruçoes.
	
   -- state_IF_Wait1					: Estado utilizado para ativar a operaçao correspondente no circuito controlador da RAM de instruçoes,
	-- 									  ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
	
	-- state_IF_Wait2					: Estado onde aguarda-se que a controladora da RAM de instruçoes execute a leitura da próxima instruçao
	-- 									  e informe por meio do sinal "ready" que essa operaçao foi executada.
	
	
	--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
	
	
	-- %%%%%% FSM de controle do estágio de Decodificação da Instruçao %%%%%% 
	-- state_DEC_Load					: Estado onde o sinal de opCode é preenchido com parte dos dados contidos na  variável de instrução atual.
	
	-- state_DEC_Filter				: Estado onde ocorre a decodificação da instruçao atual, de acordo com os campos opCode, funct e funct2 armazenados nas variáveis
	-- 									  correspondentes anteriormente. No estágio de decodificaçao são armazenados nas variaveis adequadas os endereços dos registradores
	-- 									  que devem ser lidos para a correta execução das instruçoes. Tais registradores são descritos em campos especiais das instruçoes dos tipos
	-- 									  R e I do MIPS, assim, em instruçoes desses tipos, após salvar os endereços, direciona-se a FSM para os estados de leitura de registradores.
	-- 									  Nas instruçoes do tipo J ou aquelas onde não é necessário a leitura de registradores para sua correta execuçao, a FSM é encaminhada para
	--										  outros estados, não aquele de leitura de registradores.
	
	
	--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
	
	
	-- %%%%%%    FSM de controle do estágio de Execuçao da Instruçao   %%%%%% 
	-- state_EX_Filter				: Estado de filtro da fase de Execução da instruçao. Nesse estado são realizadas as solicitaçoes de calculos na ALU e espera pelo resultado calculado.
	
	-- state_EX_Wait1					: Estado utilizado para ativar a operaçao requisitada na ALU no estado anterior ou seja, após o sinal de reset ser 
	-- 									  colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
	
	-- state_EX_Wait2					: Estado onde aguarda-se que a ALU execute a operação requisitada e informe por meio do sinal "ready" que essa operaçao foi executada.
	
	
	--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
	
	
	-- %%%%%%    FSM de controle do estágio de Writeback da Instruçao  %%%%%% 
	-- state_WB_Filter				: Estado onde a instruçao atual é filtrada e de acordo com o tipo de instruçao dados resultantes da execuçao
	-- 									  dessa instruçao no estado de execuçao podem ser salvos no Banco de Registradores ou na memória RAM de dados.
	
	
	--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
	
	
	-- state_Finaliza					: Estado após a execuçao da instruçao atual, nesse estado é decidido se deve-se buscar uma nova instruçao ou não.
	-- 									  Caso PC seja igual a PC_MAX o processador já executou todas as instruçoes, caso contrário torna-se necessario iniciar novamente
	-- 									  o ciclo de "Busca - Decodificação - Execuçao e Writeback".
	
	TYPE controlFSM IS (	state_IDLE,                state_IDLE_Fim,
	
								stateMIPS_Reset,
							  
								state_INST_Write_IDLE,     state_INST_Write_Solicita, state_INST_Write_Wait1, state_INST_Write_Wait2,
							  
								state_INST_Debug_IDLE,     state_INST_Debug_Solicita, state_INST_Debug_Wait1, state_INST_Debug_Wait2,
							  
								state_DATA_Write_Solicita, state_DATA_Write_Wait1,    state_DATA_Write_Wait2,
								
								state_DATA_Read_Solicita,  state_DATA_Read_Wait1,     state_DATA_Read_Wait2,
							  
								state_DATA_Debug_IDLE,     state_DATA_Debug_Solicita, state_DATA_Debug_Wait1, state_DATA_Debug_Wait2,
							  
								state_REG_Read_Solicita,   state_REG_Read_Wait1,      state_REG_Read_Wait2,
							  
								state_REG_Write_Solicita,  state_REG_Write_Wait1,     state_REG_Write_Wait2,
							  
								state_REG_Debug_IDLE,      state_REG_Debug_Solicita,  state_REG_Debug_Wait1,  state_REG_Debug_Wait2,
							  
								state_IF_Solicita,         state_IF_Wait1,            state_IF_Wait2,
							  
								state_DEC_Load,            state_DEC_Filter,
							  
								state_EX_Filter,           state_EX_Wait1,            state_EX_Wait2,
							  
								state_WB_Filter,
	
								state_Finaliza	
							  );
							  
	SIGNAL nextState	: controlFSM := state_IDLE; -- Define o estado inicial da máquina como sendo o "state_IDLE".
		
	
	-- Sinais para conexão com barramentos externos do circuito, evitando assim que flutuaçoes na entrada propaguem no circuito.
	SIGNAL SIG_address 	: t_AddressINST;
	SIGNAL SIG_dataIn		: t_Byte;
	SIGNAL SIG_dataOut	: t_Byte;
	SIGNAL SIG_opCode		: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL SIG_ready		: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL SIG_error		: STD_LOGIC_VECTOR(1 DOWNTO 0);
		
		
	-- Define constante para os endereços no Banco de Registradores dos registradores "HI" e "LO".	
	CONSTANT CONST_addrHI : t_RegSelect := "100000";
	CONSTANT CONST_addrLO : t_RegSelect := "100001";
	
BEGIN

	-- Conexão dos barramentos externos dos Displays de 7 segmentos com os respectivos sinais internos.
	
	A1 <= SIG_Display1_A;	-- Display de 7 segmentos 1 (HEX0)
	B1 <= SIG_Display1_B;
	C1 <= SIG_Display1_C;
	D1 <= SIG_Display1_D;
	E1 <= SIG_Display1_E;
	F1 <= SIG_Display1_F;
	G1 <= SIG_Display1_G;
	
	A2 <= SIG_Display2_A;	-- Display de 7 segmentos 2 (HEX1)
	B2 <= SIG_Display2_B;
	C2 <= SIG_Display2_C;
	D2 <= SIG_Display2_D;
	E2 <= SIG_Display2_E;
	F2 <= SIG_Display2_F;
	G2 <= SIG_Display2_G;
	
	A3 <= SIG_Display3_A;	-- Display de 7 segmentos 3 (HEX2)
	B3 <= SIG_Display3_B;
	C3 <= SIG_Display3_C;
	D3 <= SIG_Display3_D;
	E3 <= SIG_Display3_E;
	F3 <= SIG_Display3_F;
	G3 <= SIG_Display3_G;
	
	A4 <= SIG_Display4_A;	-- Display de 7 segmentos 4 (HEX3)
	B4 <= SIG_Display4_B;
	C4 <= SIG_Display4_C;
	D4 <= SIG_Display4_D;
	E4 <= SIG_Display4_E;
	F4 <= SIG_Display4_F;
	G4 <= SIG_Display4_G;
	
	A5 <= SIG_Display5_A;	-- Display de 7 segmentos 5 (HEX4)
	B5 <= SIG_Display5_B;
	C5 <= SIG_Display5_C;
	D5 <= SIG_Display5_D;
	E5 <= SIG_Display5_E;
	F5 <= SIG_Display5_F;
	G5 <= SIG_Display5_G;
	
	A6 <= SIG_Display6_A;	-- Display de 7 segmentos 6 (HEX5)
	B6 <= SIG_Display6_B;
	C6 <= SIG_Display6_C;
	D6 <= SIG_Display6_D;
	E6 <= SIG_Display6_E;
	F6 <= SIG_Display6_F;
	G6 <= SIG_Display6_G;
	
	A7 <= SIG_Display7_A;	-- Display de 7 segmentos 7 (HEX6)
	B7 <= SIG_Display7_B;
	C7 <= SIG_Display7_C;
	D7 <= SIG_Display7_D;
	E7 <= SIG_Display7_E;
	F7 <= SIG_Display7_F;
	G7 <= SIG_Display7_G;
	
	A8 <= SIG_Display8_A;	-- Display de 7 segmentos 8 (HEX7)
	B8 <= SIG_Display8_B;
	C8 <= SIG_Display8_C;
	D8 <= SIG_Display8_D;
	E8 <= SIG_Display8_E;
	F8 <= SIG_Display8_F;
	G8 <= SIG_Display8_G;
	
	
	-- Importaçao do compoente e mapeamento de portas do display de 7 segmentos 1 (HEX0).
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
		
	-- Importaçao do compoente e mapeamento de portas do display de 7 segmentos 2 (HEX1).
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
		
	-- Importaçao do compoente e mapeamento de portas do display de 7 segmentos 3 (HEX2).
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
		
	
	-- Importaçao do compoente e mapeamento de portas do display de 7 segmentos 4 (HEX3).
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
		
		
	-- Importaçao do compoente e mapeamento de portas do display de 7 segmentos 5 (HEX4).
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
	
	
	-- Importaçao do compoente e mapeamento de portas do display de 7 segmentos 6 (HEX5).
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
		

	-- Importaçao do compoente e mapeamento de portas do display de 7 segmentos 7 (HEX6).
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
		
	-- Importaçao do compoente e mapeamento de portas do display de 7 segmentos 8 (HEX7).
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
		
		
		
	-- Importaçao e mapeamento de portas do componente ALU_MIPS32.
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
		
	-- Importaçao e mapeamento de portas do componente ClockMIPS.
	mapClockMIPS: ENTITY WORK.ClockMIPS
		PORT MAP
		(
			clockIN	=> SIG_ClockMIPS_clockIN,
			clockOUT	=> SIG_ClockMIPS_clockOUT
		);
		
	
	-- Importação e mapeamento de portas do componente mapMIPS32_InstRAMCore.
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
		);	
		
		
	-- Importação e mapeamento de portas do componente MIPS32_DataRAMCore.
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
		);		
	
		
	-- Importaçao e mapeamento de portas do componente MIPS32_RegBankCore.
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
	
	
	-- Direciona o sinal externo do clock (50 MHz) para a entrada do componente divisor de frequencia "ClockMIPS".
	SIG_ClockMIPS_clockIN <= PIN_clockIN;
	
	
	-- Sincroniza o clock dos componentes com o sinal de saída do divisor de frequencia "ClockMIPS" (ambos componentes recebem o mesmo sinal de clock).
	SIG_ALU_MIPS32_clock <= SIG_ClockMIPS_clockOUT;
	SIG_IRC_clock			<= SIG_ClockMIPS_clockOUT;
	SIG_DRC_clock			<= SIG_ClockMIPS_clockOUT;
	SIG_RBC_clock			<= SIG_ClockMIPS_clockOUT;
	PIN_clockOUT			<= SIG_ClockMIPS_clockOUT;
	
	
	-- Direciona os sinais dos barramentos externos para os respectivos sinais internos.
	SIG_address <= address;
	SIG_dataIn 	<= dataIN;
	SIG_opCode 	<= opCode;
	dataOUT 		<= SIG_dataOut;
	ready			<= SIG_ready;
	error			<= SIG_error;
	
	
	-- Process de controle de toda a FSM do circuito.
	-- Esse process é ativado com alteraçao de valores nos sinais: "SIG_ClockMIPS_clockOUT" e "reset".
	PROCESS(SIG_ClockMIPS_clockOUT, reset) 
		VARIABLE VAR_addrRBRead1 		: t_RegSelect;		-- Armazenamento do 1º endereço a ser lido do banco de registradores.
		VARIABLE VAR_addrRBRead2 		: t_RegSelect;		-- Armazenamento do 2º endereço a ser lido do banco de registradores.
		VARIABLE VAR_addrRBWrite1 		: t_RegSelect;		-- Armazenamento do 1º endereço a ser escrito no banco de registradores.
		VARIABLE VAR_dataInRB1			: t_Word;			-- Armazenamento do dado a ser escrito em "VAR_addrRBWrite1".
		VARIABLE VAR_addrRBWrite2 		: t_RegSelect;		-- Armazenamento do 2º endereço a ser escrito no banco de registradores.
		VARIABLE VAR_dataInRB2			: t_Word;			-- Armazenamento do dado a ser escrito em "VAR_addrRBWrite2".
		VARIABLE VAR_addrDATAWrite		: t_addressDATA;	-- Armazenamento do endereço a ser escrito na memória RAM de dados.
		VARIABLE VAR_addrDATARead		: t_addressDATA;	-- Armazenamento do endereço a ser lido da memória RAM de dados.
		VARIABLE VAR_dataInDATA			: t_Word;			-- Armazenamento do dado a ser escrito em "VAR_addrDATAWrite".
		VARIABLE VAR_instrucaoAtual	: t_Word;			-- Armazenamento da instruçao atual (32 bits) lida da memória RAM de Instruçoes.
		VARIABLE VAR_ALUresult			: t_DWord;			-- Armazenamento do resultado da última operaçao calculada pela ALU.
		VARIABLE VAR_ALUflags			: t_Byte;			-- Armazenamento do vetor de flags da última operaçao calculada pela ALU.
		VARIABLE PC							: t_addressINST;	-- Armazenamento do contador de programas atual.
		VARIABLE PC_MAX					: t_addressINST;	-- Armazenamento do contador de programas máximo pertido, i.e. quantidade de instruçoes carregadas * 4 (bits)
		VARIABLE VAR_INST_opCode		: t_opCode;			-- Armazenamento do campo opCode da instruçao atual 	- instrucaoAtual(31 DOWNTO 26).
		VARIABLE VAR_INST_funct			: t_opCode;			-- Armazenamento do campo funct da instruçao atual 	- instrucaoAtual(5 DOWNTO 0).
		VARIABLE VAR_INST_funct2		: t_Funct2;			-- Armazenamento do campo funct2 da instruçao atual 	- instrucaoAtual(20 DOWNTO 16).
	BEGIN
		
		-- Reset do circuito.
		IF (reset = '1') THEN
			
			-- Após o sinal de reset, de acordo com o valor presente no barramento de opCode (carregado em SIG_opCode), desvia a FSM para o estado correto.
			CASE SIG_opCode IS
			
				-- Solicita mudança para estado de IDLE do circuito, utilizado para inicialização.
				WHEN "000" =>
				
					nextState	<= state_IDLE;
				
				-- Solicita mudança para estado de escrita de bytes na memória RAM de instruçoes.
				WHEN "001" =>
				
					nextState	<= state_INST_Write_Solicita;
				
				-- Solicita mudança para estado de leitura de bytes da memória RAM de instruçoes.
				WHEN "010" =>
				
					nextState	<= state_INST_Debug_Solicita;
					
				-- Solicita mudança para estado de debug do Banco de Registradores.
				WHEN "011" =>
				
					nextState	<= state_REG_Debug_Solicita;
								
				-- Solicita mudança para estado de debug da memória RAM de dados.
				WHEN "100" =>
				
					nextState	<= state_DATA_Debug_Solicita;
				
				-- Solicita mudança para estado de reset do circuito de controle.
				WHEN "101" =>
				
					nextState	<= stateMIPS_Reset;
				
				-- Solicita mudança para estado de execuçao das intruçoes carregadas na RAM de instruçoes, 
				-- ou seja inicia o ciclo "Busca - Decodifica - Executa - Writeback".
				WHEN "111" =>
				
					nextState	<= state_IF_Solicita;	
					
				-- Estados inválidos.
				WHEN OTHERS =>
				
					SIG_error <= "11";
					
					nextState <= state_IDLE_Fim;
				
			END CASE;			
				
				
				
		-- Caso o sinal de reset não esteja ativo (alto) e seja borda de subida do clock, executa os comandos da FSM.
		ELSIF (RISING_EDGE(SIG_ClockMIPS_clockOUT)) THEN
			
			-- Filtra de acordo com o estado atual.
			CASE nextState IS
			
				-- Estado onde a máquina permanece inativa, ou seja, não faz nenhuma operaçao útil.
				WHEN state_IDLE	=>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "1110";
					sig_Display7_DADO <= "1110";
					
					-- Informa que o circuito não tem nenhuma operaçao pronta.
					SIG_ready <= "000";
					
					-- Atualiza o próximo estado, apontando esse para o próprio estado atual.
					nextState <= state_IDLE;
					
				
				-- Estado IDLE executado após o processador executar todas as instruçoes carregadas na RAM de instruçoes.
				WHEN state_IDLE_Fim	=>
				
					--sig_Display8_DADO <= "1111";
					--sig_Display7_DADO <= "1111";
					
					sig_Display8_DADO <= "00" & SIG_error;
					--sig_Display7_DADO <= VAR_INST_opCode(3 DOWNTO 0);
					
					--sig_Display6_DADO <= "00" & VAR_INST_funct(5 DOWNTO 4);
					--sig_Display5_DADO <= VAR_INST_funct(3 DOWNTO 0);
					
					--sig_Display4_DADO <= PC(3 DOWNTO 0);
					
					--sig_Display3_DADO <= VAR_ALUresult(3 DOWNTO 0);
					
					--sig_Display3_DADO <= std_logic_vector(to_unsigned(VAR_contINSTFetch, 4));
					
					--sig_Display2_DADO <= SIG_RBC_dataOut1(3 DOWNTO 0);
					
					--sig_Display1_DADO <= SIG_RBC_dataOut2(3 DOWNTO 0);
					
					
					SIG_ready <= "101";
					
					
					-- Atualiza o próximo estado, apontando esse para o próprio estado atual.
					nextState <= state_IDLE_Fim;
					
					
				-- Estado de reset do circuito de controle, i.e. reset de todas as variáveis.
				WHEN stateMIPS_Reset =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "1101";
					sig_Display7_DADO <= "1101";
					
					-- Zera variáveis.
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
					PC						:= (OTHERS => '0');
					PC_MAX				:= (OTHERS => '0');
					VAR_INST_opCode	:= (OTHERS => '0');
					VAR_INST_funct		:= (OTHERS => '0');
					VAR_INST_funct2	:= (OTHERS => '0');
					
					SIG_error 			<= "00";
				
					-- Encaminha a FSM para estado de IDLE.
					nextState <= state_IDLE;
					
					
					
					
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE ESCRITA DE BYTES NA RAM DE INSTRUÇÕES %%%%%%%%%%%%%%%
				
				-- Estado IDLE da FSM dos estados de escrita na RAM de instruçoes.
				WHEN state_INST_Write_IDLE =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0101";
					
					-- Garante que o circuito controlador da RAM de instruçoes não está recebendo sinal de reset.
					SIG_IRC_reset <= '0';
					
					-- Sinaliza no barramento "ready" que a operaçao dessa parte da FSM foi concluída.
					SIG_ready <= "001";
				
					-- Encaminha a FSM para o estado atual.
					nextState <= state_INST_Write_IDLE;
				
				
				-- %%
				
				
				-- Estado onde é solicitada a escrita de um determinado byte na posiçao especificada pelo barramento externo.
				WHEN state_INST_Write_Solicita =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0001";
					
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais do circuito controlador da RAM de instruçoes.
					SIG_IRC_opCode 	<= "010";			-- Informa a controladora que a operaçao a ser executada é a de escrita de dados - "state_IRC_Write_Solicita".
					SIG_IRC_reset 		<= '1';				-- Coloca o sinal de reset em nível alto, fazendo assim com que a controladora entre em reset e desvie para o opcode informado.
					SIG_IRC_address 	<= SIG_address;	-- Envia o valor presente no barramento "address" desse circuito para a controladora informando o endereço que será escrito.
					SIG_IRC_dataIn 	<= SIG_dataIn;		-- Envia o valor presente no barramento "dataIn" desse circuito para a controladora com o dado a ser escito na RAM.
					
					-- Encaminha a FSM para o estado de espera "Wait1".
					nextState <= state_INST_Write_Wait1;
			
				
				-- %%	
					
				
				-- Estado utilizado para ativar a operaçao correspondente no circuito controlador da RAM de instruçoes,
				-- ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
				WHEN state_INST_Write_Wait1 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0010";
					
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
			
					-- Coloca o sinal de reset da controladora em nivel baixo, fazendo com que essa saia do estado de reset e execute.
					SIG_IRC_reset <= '0';
					
					-- Encaminha a FSM para o estado de espera "Wait2".
					nextState <= state_INST_Write_Wait2;
					
				
				-- %%
			
				
				-- Estado onde aguarda-se que a controladora da RAM de Instruçoes execute a gravaçao dos dados
				-- e informe por meio do sinal "ready" que essa operaçao foi executada.
				WHEN state_INST_Write_Wait2 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0011";
					
					-- Garante o sinal baixo no barramento de reset da controladora.
					SIG_IRC_reset <= '0';
					
					-- Verifica se o sinal "ready" da controladora é igual a "010", caso seja a operaçao foi concluída,
					-- caso contrario e necessario aguardar por mais um ciclo.
					IF SIG_IRC_ready = "010" THEN
					
						-- Caso a operação tenha sido conclcuída, i.e. o byte de instruçao salvo na RAM, incrementa o contador PC_MAX em 1 unidade.
						PC_MAX := PC_MAX + 1;
					
						-- Encaminha a FSM para o estado IDLE da FSM de escrita de instruçoes.
						nextState <= state_INST_Write_IDLE;
						
					-- Caso contrário,
					ELSE
						
						-- Encaminha a FSM para o mesmo estado atual.
						nextState <= state_INST_Write_Wait2;
					
					END IF;
						
			-- %%%%%%%%%%%%%%% FIM DA FSM DE ESCRITA DE BYTES NA RAM DE INSTRUÇÕES %%%%%%%%%%%%%%%
			
			
			
			
			
			
			-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE DEBUG (DUMP) DA MEMÓRIA DE INSTRUÇÕES %%%%%%%%%%%%%%%
			
			
				-- Estado IDLE da FSM dos estados de de Debug da RAM de instruçoes.
				WHEN state_INST_Debug_IDLE =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0101";
					
					-- Garante que o circuito controlador da RAM de instruçoes não está recebendo sinal de reset.
					SIG_IRC_reset <= '0';
					
					-- Encaminha o valor do barramento "dataOut" da controladora para o barramento "dataOut" desse circuito.
					SIG_dataOut <= SIG_IRC_dataOut;
					
					-- Sinaliza no barramento "ready" que a operaçao dessa parte da FSM foi concluída.
					SIG_ready <= "010";
					
					-- Encaminha a FSM para o estado atual.
					nextState <= state_INST_Debug_IDLE;
				
				
				-- %%
			
								
				-- Estado onde é solicitada a leitura de um determinado byte na posiçao especificada pelo barramento externo.
				WHEN state_INST_Debug_Solicita =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0001";
					
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais do circuito controlador da RAM de instruçoes.
					SIG_IRC_opCode 	<= "011";			-- Informa a controladora que a operaçao a ser executada é a de leitura de dados - "state_IRC_Read_Solicita".
					SIG_IRC_reset 		<= '1';				-- Coloca o sinal de reset em nível alto, fazendo assim com que a controladora entre em reset e desvie para o opcode informado.
					SIG_IRC_address 	<= SIG_address;	-- Envia o valor presente no barramento "address" desse circuito para a controladora informando o endereço que será lido.
					
					-- Encaminha a FSM para o estado de espera "Wait1".
					nextState <= state_INST_Debug_Wait1;
			
				
				-- %%
			
					
				-- Estado utilizado para ativar a operaçao correspondente no circuito controlador da RAM de instruçoes,
				-- ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
				WHEN state_INST_Debug_Wait1 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0010";
					
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
			
					-- Coloca o sinal de reset da controladora em nivel baixo, fazendo com que essa saia do estado de reset e execute.
					SIG_IRC_reset <= '0';
					
					-- Encaminha a FSM para o estado de espera "Wait2".
					nextState <= state_INST_Debug_Wait2;
			
				
				-- %%
			
					
				-- Estado onde aguarda-se que a controladora da RAM de Instruçoes execute a leitura dos dados
				-- e informe por meio do sinal "ready" que essa operaçao foi executada.
				WHEN state_INST_Debug_Wait2 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0011";
					
					-- Garante que o circuito controlador da RAM de instruçoes não está recebendo sinal de reset.
					SIG_IRC_reset <= '0';
					
					-- Verifica se o sinal "ready" da controladora é igual a "011", caso seja a operaçao foi concluída,
					-- caso contrario e necessario aguardar por mais um ciclo.
					IF SIG_IRC_ready = "011" THEN
					
						-- Encaminha a FSM para o estado IDLE da FSM de debug de instruçoes.
						nextState <= state_INST_Debug_IDLE;
						
					-- Caso contrário,
					ELSE
					
						-- Encaminha a FSM para o mesmo estado atual.
						nextState <= state_INST_Debug_Wait2;
					
					END IF;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM DE DEBUG (DUMP) DA MEMÓRIA DE INSTRUÇOES %%%%%%%%%%%%%%%
				
			
			
			
			
			
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE ESCRITA DE BYTES NA RAM DE DADOS %%%%%%%%%%%%%%%				
				
				-- Estado onde é solicitada a escrita de um determinado byte na posiçao especificada pelo barramento externo.
				WHEN state_DATA_Write_Solicita =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0001";
					
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais do circuito controlador da RAM de dados.
					SIG_DRC_opCode 	<= "010";					-- Informa a controladora que a operaçao a ser executada é a de escrita de dados - "state_DRC_Write_Solicita1".
					SIG_DRC_reset 		<= '1';						-- Coloca o sinal de reset em nível alto, fazendo assim com que a controladora entre em reset e desvie para o opcode informado.
					SIG_DRC_address 	<= VAR_addrDATAWrite;	-- Envia o valor presente na variável "VAR_addrDATAWrite" para a controladora informando o endereço que será escrito.
					SIG_DRC_dataIn 	<= VAR_dataInDATA;		-- Envia o valor presente na variável "VAR_dataInDATA" para a controladora com o dado a ser escito na RAM.
					
					-- Encaminha a FSM para o estado "Wait1".
					nextState <= state_DATA_Write_Wait1;
			
				
				-- %%
			
					
				-- Estado utilizado para ativar a operaçao correspondente no circuito controlador da RAM de dados,
				-- ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
				WHEN state_DATA_Write_Wait1 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0010";
					
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
			
					-- Coloca o sinal de reset da controladora em nivel baixo, fazendo com que essa saia do estado de reset e execute.
					SIG_DRC_reset <= '0';
					
					-- Encaminha a FSM para o estado "Wait2".
					nextState <= state_DATA_Write_Wait2;
						
				
				-- %%
			
				
				-- Estado onde aguarda-se que a controladora da RAM de Dados execute a escrita dos dados
				-- e informe por meio do sinal "ready" que essa operaçao foi executada.	
				WHEN state_DATA_Write_Wait2 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0011";
					
					-- Verifica se o sinal "ready" da controladora é igual a "010", caso seja a operaçao foi concluída,
					-- caso contrario e necessario aguardar por mais um ciclo.
					IF SIG_DRC_ready = "010" THEN
					
						-- Encaminha a FSM para o estado de finalizaçao da execuçao de instruçoes.
						nextState <= state_Finaliza;
						
					-- Caso contrário,
					ELSE
						
						-- Encaminha a FSM para o mesmo estado atual.
						nextState <= state_DATA_Write_Wait2;
					
					END IF;
						
				-- %%%%%%%%%%%%%%% FIM DA FSM DE ESCRITA DE BYTES NA RAM DE DADOS %%%%%%%%%%%%%%%
				
			
			
			
			
			
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE LEITURA DE BYTES NA RAM DE DADOS %%%%%%%%%%%%%%%
				
				-- Estado onde é solicitada a leitura de um determinado byte na posiçao especificada pelo barramento externo.
				WHEN state_DATA_Read_Solicita =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0001";
					
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais do circuito controlador da RAM de dados.
					SIG_DRC_opCode 	<= "001";				-- Informa a controladora que a operaçao a ser executada é a de leitura de dados - "state_DRC_Read_Solicita1".
					SIG_DRC_reset 		<= '1';					-- Coloca o sinal de reset em nível alto, fazendo assim com que a controladora entre em reset e desvie para o opcode informado.
					SIG_DRC_address 	<= VAR_addrDATARead;	-- Envia o valor presente na variável "VAR_addrDATARead" para a controladora informando o endereço que será lido.
					
					-- OBS: o valor de "SIG_DRC_bytes" é informado no estado solicitante da leitura.
					
					-- Encaminha a FSM para o estado "Wait1".
					nextState <= state_DATA_Read_Wait1;
				
				
				-- %%
			
				
				-- Estado utilizado para ativar a operaçao correspondente no circuito controlador da RAM de dados,
				-- ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
				WHEN state_DATA_Read_Wait1 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0010";
					
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Coloca o sinal de reset da controladora em nivel baixo, fazendo com que essa saia do estado de reset e execute.
					SIG_DRC_reset <= '0';
					
					-- Encaminha a FSM para o estado "Wait2".
					nextState <= state_DATA_Read_Wait2;
			
				
				-- %%
			
				
				-- Estado onde aguarda-se que a controladora da RAM de Dados execute a leitura dos dados
				-- e informe por meio do sinal "ready" que essa operaçao foi executada.
				WHEN state_DATA_Read_Wait2 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0001";
					sig_Display7_DADO <= "0011";
					
					-- Verifica se o sinal "ready" da controladora é igual a "001", caso seja a operaçao foi concluída,
					-- caso contrario e necessario aguardar por mais um ciclo.
					IF SIG_DRC_ready = "001" THEN
					
						-- Filtra de acordo com o valor presente no campo opCode da instruçao atual. Apos a leitura dos dados
						-- da RAM de dados, prossegue-se com a escrita desse dado no Banco de Registradores, pois a leitura de
						-- dados da RAM somente é executada em instruçoes do tipo LOAD. A leitura dos dados dessa RAM sem ser por
						-- motivo de execuçao de instruçoes LOAD é feita na FSM de Debug da Ram de instruçoes.
						CASE VAR_INST_opCode IS
						
							-- LB
							WHEN "100000" =>
							
								-- Realiza Extensão de Sinal no valor lido da RAM de dados e 
								-- direciona para variável de armazenamento do dado 1 a ser escrito no Banco de Registradores.
								VAR_dataInRB1 		:= STD_LOGIC_VECTOR( RESIZE(SIGNED(SIG_DRC_dataOut(7 DOWNTO 0)), VAR_dataInRB1'LENGTH) );
								VAR_addrRBWrite1 	:= "0" & VAR_instrucaoAtual(20 DOWNTO 16);
						
								-- Encaminha a FSM para o estado de escrita no Banco de Registradores.
								nextState <= state_REG_Write_Solicita;
								
							-- LH
							WHEN "100001" =>
							
								-- Realiza Extensão de Sinal no valor lido da RAM de dados e 
								-- direciona para variável de armazenamento do dado 1 a ser escrito no Banco de Registradores.
								VAR_dataInRB1 		:= STD_LOGIC_VECTOR( RESIZE(SIGNED(SIG_DRC_dataOut(15 DOWNTO 0)), VAR_dataInRB1'LENGTH) );
								VAR_addrRBWrite1 	:= "0" & VAR_instrucaoAtual(20 DOWNTO 16);
						
								-- Encaminha a FSM para o estado de escrita no Banco de Registradores.
								nextState <= state_REG_Write_Solicita;
								
							-- LW, LBU, LHU
							WHEN "100011" | "100100" | "100101" =>
							
								-- Direciona para variável de armazenamento do dado 1 a ser escrito no Banco de Registradores o valor lido da RAM de dados.
								VAR_dataInRB1 		:= SIG_DRC_dataOut;
								VAR_addrRBWrite1 	:= "0" & VAR_instrucaoAtual(20 DOWNTO 16);
						
								-- Encaminha a FSM para o estado de escrita no Banco de Registradores.
								nextState <= state_REG_Write_Solicita;
							
							-- Estados inválidos.
							WHEN OTHERS =>
							
								SIG_error <= "11";
							
								nextState <= state_IDLE_Fim;
						
						END CASE;
					
					-- Caso contrário,
					ELSE
						
						-- Encaminha a FSM para o mesmo estado atual.
						nextState <= state_DATA_Read_Wait2;
					
					END IF;
						
				-- %%%%%%%%%%%%%%% FIM DA FSM DE LEITURA DE BYTES NA RAM DE DADOS %%%%%%%%%%%%%%%
				
			
			
			
			
			
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE DEBUG (DUMP) DA MEMÓRIA DE DADOS %%%%%%%%%%%%%%%
			
				-- Estado IDLE da FSM dos estados de de Debug da RAM de dados.
				WHEN state_DATA_Debug_IDLE =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0101";
					
					-- Garante que o circuito controlador da RAM de dados não está recebendo sinal de reset.
					SIG_DRC_reset <= '0';
					
					-- Encaminha o valor do barramento "dataOut" da controladora para o barramento "dataOut" desse circuito.
					SIG_dataOut <= SIG_DRC_dataOut(7 DOWNTO 0);
					
					-- Sinaliza no barramento "ready" que a operaçao dessa parte da FSM foi concluída.
					SIG_ready <= "100";
					
					-- Encaminha a FSM para o mesmo estado atual.
					nextState <= state_DATA_Debug_IDLE;
			
				
				-- %%
			
				
				-- Estado onde é solicitada a leitura de um determinado byte na posiçao especificada pelo barramento externo.
				WHEN state_DATA_Debug_Solicita =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0001";
					
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais do circuito controlador da RAM de dados.
					SIG_DRC_opCode 	<= "001";			-- Informa a controladora que a operaçao a ser executada é a de leitura de dados - "state_DRC_Read_Solicita1".
					SIG_DRC_reset 		<= '1';				-- Coloca o sinal de reset em nível alto, fazendo assim com que a controladora entre em reset e desvie para o opcode informado.
					SIG_DRC_address 	<= SIG_address;	-- Envia o valor presente no barramento "address" desse circuito para a controladora informando o endereço que será lido.
					SIG_DRC_bytes		<= "00";				-- Informa para a controladora que deve ser lido apenas um byte da RAM.
					
					-- Encaminha a FSM para o estado "Wait1".
					nextState <= state_DATA_Debug_Wait1;
					
				
				-- %%
			
				
				-- Estado utilizado para ativar a operaçao correspondente no circuito controlador da RAM de dados,
				-- ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
				WHEN state_DATA_Debug_Wait1 =>	
					
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0010";
					
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
			
					-- Coloca o sinal de reset da controladora em nivel baixo, fazendo com que essa saia do estado de reset e execute.
					SIG_DRC_reset <= '0';
					
					-- Encaminha a FSM para o estado "Wait2".
					nextState <= state_DATA_Debug_Wait2;
			
				
				-- %%
			
			
				-- Estado onde aguarda-se que a controladora da RAM de Dados execute a leitura dos dados
				-- e informe por meio do sinal "ready" que essa operaçao foi executada.
				WHEN state_DATA_Debug_Wait2 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0010";
					sig_Display7_DADO <= "0011";
					
					-- Garante que o circuito controlador da RAM de instruçoes não está recebendo sinal de reset.
					SIG_DRC_reset <= '0';
					
					-- Verifica se o sinal "ready" da controladora é igual a "001", caso seja a operaçao foi concluída,
					-- caso contrario e necessario aguardar por mais um ciclo.
					IF SIG_DRC_ready = "001" THEN
					
						-- Encaminha a FSM para o estado IDLE da FSM de debug de dados.
						nextState <= state_DATA_Debug_IDLE;
						
					-- Caso contrário,
					ELSE
						
						-- Encaminha a FSM para o mesmo estado atual.
						nextState <= state_DATA_Debug_Wait2;
					
					END IF;
					
					
				-- %%%%%%%%%%%%%%% FIM DA FSM DE DEBUG (DUMP) DA MEMÓRIA DE DADOS %%%%%%%%%%%%%%%
				
			
			
			
			
			
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE DEBUG (DUMP) DO REGBANK %%%%%%%%%%%%%%%
			
				-- Estado IDLE da FSM dos estados de Debug do Banco de Registradores.
				WHEN state_REG_Debug_IDLE =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0011";
					sig_Display7_DADO <= "0101";
					
					-- Garante que o circuito controlador do Banco de Registradores não está recebendo sinal de reset.
					SIG_RBC_reset <= '0';
					
					-- Encaminha o valor do barramento "dataOut" da controladora (1 Byte) para o barramento "dataOut" desse circuito.
					SIG_dataOut <= SIG_RBC_dataOut1(7 DOWNTO 0);
					
					-- Sinaliza no barramento "ready" que a operaçao dessa parte da FSM foi concluída.
					SIG_ready <= "011";
				
					-- Encaminha a FSM para o mesmo estado atual.
					nextState <= state_REG_Debug_IDLE;
			
				
				-- %%
			
			
				-- Estado onde é solicitada a leitura de um determinado byte na posiçao especificada pelo barramento externo.
				WHEN state_REG_Debug_Solicita =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0011";
					sig_Display7_DADO <= "0001";
				
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais do circuito controlador do Banco de Registradores.
					SIG_RBC_opCode 			<= "001";							-- Informa a controladora que a operaçao a ser executada é a de leitura de dados - "state_RBC_Read_Solicita".
					SIG_RBC_reset 				<= '1';								-- Coloca o sinal de reset em nível alto, fazendo assim com que a controladora entre em reset e desvie para o opcode informado.
					SIG_RBC_addressRead1 	<= SIG_address(5 DOWNTO 0);	-- Envia o valor presente no barramento "address" desse circuito (6 bytes) para a controladora informando o endereço 1 que será lido.
					SIG_RBC_addressRead2 	<= (OTHERS => '0');				-- Envia o valor "0" para o sinal de leitura 2 da controladora.
					SIG_RBC_bytes 				<= SIG_dataIn(2 DOWNTO 0);		-- Informa para a controladora qual o byte da word presente na posiçao especificada no Banco de Registradores deve ser lido.
					
					-- Encaminha a FSM para o estado "Wait1".
					nextState <= state_REG_Debug_Wait1;
					
				
				-- %%
			
				
				-- Estado utilizado para ativar a operaçao correspondente no circuito controlador do Banco de Registradores,
				-- ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
				WHEN state_REG_Debug_Wait1 =>	
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0011";
					sig_Display7_DADO <= "0010";
					
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
			
					-- Coloca o sinal de reset da controladora em nivel baixo, fazendo com que essa saia do estado de reset e execute.
					SIG_RBC_reset <= '0';
					
					-- Encaminha a FSM para o estado "Wait2".
					nextState <= state_REG_Debug_Wait2;
			
				
				-- %%
			
				
				-- Estado onde aguarda-se que a controladora do Banco de Registradores execute a leitura dos dados
				-- e informe por meio do sinal "ready" que essa operaçao foi executada.
				WHEN state_REG_Debug_Wait2 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0011";
					sig_Display7_DADO <= "0011";
					
					-- Garante que o circuito controlador do Banco de Registradores não está recebendo sinal de reset.
					SIG_RBC_reset <= '0';
					
					-- Verifica se o sinal "ready" da controladora é igual a "001", caso seja a operaçao foi concluída,
					-- caso contrario e necessario aguardar por mais um ciclo.
					IF SIG_RBC_ready = "001" THEN
					
						-- Encaminha a FSM para o estado IDLE da FSM de debug de dados.
						nextState <= state_REG_Debug_IDLE;
						
					-- Caso contrário,
					ELSE
						
						-- Encaminha a FSM para o mesmo estado atual.
						nextState <= state_REG_Debug_Wait2;
					
					END IF;
					
					
				-- %%%%%%%%%%%%%%% FIM DA FSM DE DEBUG (DUMP) DO REGBANK %%%%%%%%%%%%%%%
				
			
			
			
			
			
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE LEITURA DE WORD DO REGBANK %%%%%%%%%%%%%%%
			
				-- Estado onde é solicitada a leitura de um determinado byte na posiçao especificada pelo barramento externo.
				WHEN state_REG_Read_Solicita =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0100";
					sig_Display7_DADO <= "0001";
				
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais do circuito controlador do Banco de Registradores.
					SIG_RBC_opCode 	<= "001";						-- Informa a controladora que a operaçao a ser executada é a de leitura de dados - "state_RBC_Read_Solicita".
					SIG_RBC_reset 		<= '1';							-- Coloca o sinal de reset em nível alto, fazendo assim com que a controladora entre em reset e desvie para o opcode informado.
					SIG_RBC_addressRead1 	<= VAR_addrRBRead1;	-- Envia o valor presente na variável "VAR_addrRBRead1" para a controladora informando o endereço 1 que será lido.
					SIG_RBC_addressRead2 	<= VAR_addrRBRead2;	-- Envia o valor presente na variável "VAR_addrRBRead2" para a controladora informando o endereço 2 que será lido.
					SIG_RBC_bytes <= "100";								-- Informa que devem ser lidos 4 bytes (1 Word) do Banco de Registradores.
					
					-- Encaminha a FSM para o estado "Wait1".
					nextState <= state_REG_Read_Wait1;
					
				
				-- %%
			
				
				-- Estado utilizado para ativar a operaçao correspondente no circuito controlador do Banco de Registradores,
				-- ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
				WHEN state_REG_Read_Wait1 =>	
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0100";
					sig_Display7_DADO <= "0010";
					
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
			
					-- Coloca o sinal de reset da controladora em nivel baixo, fazendo com que essa saia do estado de reset e execute.
					SIG_RBC_reset <= '0';
					
					-- Encaminha a FSM para o estado "Wait2".
					nextState <= state_REG_Read_Wait2;
			
				
				-- %%
			
				
				-- Estado onde aguarda-se que a controladora do Banco de Registradores execute a leitura dos dados
				-- e informe por meio do sinal "ready" que essa operaçao foi executada.
				WHEN state_REG_Read_Wait2 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0100";
					sig_Display7_DADO <= "0011";
					
					-- Garante que o circuito controlador do Banco de Registradores não está recebendo sinal de reset.
					SIG_RBC_reset <= '0';
					
					-- Verifica se o sinal "ready" da controladora é igual a "001", caso seja a operaçao foi concluída,
					-- caso contrario e necessario aguardar por mais um ciclo.
					IF SIG_RBC_ready = "001" THEN
					
						-- Encaminha a FSM para o estado de filtro do processo de Execução da instruçao atual.
						-- Essa FSM de leitura somente é executada para capturar os dados contidos nos registradores
						-- especificados na Instruçao atual (ex: RT, RS, ...).
						nextState <= state_EX_Filter;
						
					-- Caso contrário,
					ELSE
						
						-- Encaminha a FSM para o mesmo estado atual.
						nextState <= state_REG_Read_Wait2;
					
					END IF;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM DE LEITURA DE WORD DO REGBANK %%%%%%%%%%%%%%%
				
			
			
			
			
			
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE ESCRITA DE WORD DO REGBANK %%%%%%%%%%%%%%%
			
				-- Estado onde é solicitada a escrita de um determinado byte na posiçao especificada pelo barramento externo.
				WHEN state_REG_Write_Solicita =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0101";
					sig_Display7_DADO <= "0001";
				
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Preenche os sinais do circuito controlador do Banco de Registradores.
					SIG_RBC_opCode 	<= "010";	-- Informa a controladora que a operaçao a ser executada é a de escrita de dados - "state_RBC_Write_Solicita".
					SIG_RBC_reset 		<= '1';		-- Coloca o sinal de reset em nível alto, fazendo assim com que a controladora entre em reset e desvie para o opcode informado.
					
					-- Filtra de acordo com o campo "opCode" da instruçao atual.
					CASE VAR_INST_opCode IS
					
						WHEN "000000" =>
						
							-- Filtra de acordo com o campo "funct" da instruçao atual.
							-- Instruçoes MULT, MULTU, DIV e DIVU utiliza da gravaçao simultanea de dados nos dois barramentos de endereço
							-- do Banco de Registradores, pois os resultados são salvos em HI e LO.
							CASE VAR_INST_funct IS
							
								-- MULT, MULTU, DIV, DIVU
								WHEN "011000" | "011001" | "011010" | "011011" =>
								
									SIG_RBC_bytes				<= "010";				-- Informa que devem ser escritos dados no Banco de Registradores nas duas posiçoes de endereço.
							
									SIG_RBC_addressWrite1 	<= VAR_addrRBWrite1;	-- Envia o valor presente na variável "VAR_addrRBRead1" para a controladora informando o endereço 1 onde o dado "VAR_dataInRB1" será escrito.
									SIG_RBC_dataIn1			<= VAR_dataInRB1;		-- Envia o valor presente na variável "VAR_dataInRB1" para a controladora informando o dado a ser escrito na posiçao "VAR_addrRBWrite1".
									
									SIG_RBC_addressWrite2 	<= VAR_addrRBWrite2;	-- Envia o valor presente na variável "VAR_addrRBRead1" para a controladora informando o endereço 1 onde o dado "VAR_dataInRB2" será escrito.
									SIG_RBC_dataIn2			<= VAR_dataInRB2;		-- Envia o valor presente na variável "VAR_dataInRB2" para a controladora informando o dado a ser escrito na posiçao "VAR_addrRBWrite2".
									
									-- Encaminha a FSM para o estado "Wait1".
									nextState <= state_REG_Write_Wait1;
								
								-- Caso não sejam as operaçoes de MULT e MULTU.
								WHEN OTHERS =>
									
									SIG_RBC_bytes				<= "000";				-- Informa que devem ser escritos dados no Banco de Registradores apenas na 1º posiçao de endereço.
							
									SIG_RBC_addressWrite1 	<= VAR_addrRBWrite1;
									SIG_RBC_dataIn1			<= VAR_dataInRB1;
									
									SIG_RBC_addressWrite2 	<= (OTHERS => '0');
									SIG_RBC_dataIn2			<= (OTHERS => '0');
									
									-- Encaminha a FSM para o estado "Wait1".
									nextState <= state_REG_Write_Wait1;
							
							END CASE;
					
						
						-- Caso o "opCode" não seja "000000" .
						WHEN OTHERS =>
						
							SIG_RBC_bytes				<= "000";
							
							SIG_RBC_addressWrite1 	<= VAR_addrRBWrite1;
							SIG_RBC_dataIn1			<= VAR_dataInRB1;
							
							SIG_RBC_addressWrite2 	<= (OTHERS => '0');
							SIG_RBC_dataIn2			<= (OTHERS => '0');
							
							-- Encaminha a FSM para o estado "Wait1".
							nextState <= state_REG_Write_Wait1;
				
					END CASE;
					
				
				-- %%
			
				
				-- Estado utilizado para ativar a operaçao correspondente no circuito controlador do Banco de Registradores,
				-- ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
				WHEN state_REG_Write_Wait1 =>	
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0101";
					sig_Display7_DADO <= "0010";
					
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
			
					-- Coloca o sinal de reset da controladora em nivel baixo, fazendo com que essa saia do estado de reset e execute.
					SIG_RBC_reset <= '0';
					
					-- Encaminha a FSM para o estado "Wait2".
					nextState <= state_REG_Write_Wait2;
			
				
				-- %%
			
				
				-- Estado onde aguarda-se que a controladora do Banco de Registradores execute a escrita dos dados
				-- e informe por meio do sinal "ready" que essa operaçao foi executada.
				WHEN state_REG_Write_Wait2 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0101";
					sig_Display7_DADO <= "0011";
					
					-- Garante que o circuito controlador do Banco de Registradores não está recebendo sinal de reset.
					SIG_RBC_reset <= '0';
					
					-- Verifica se o sinal "ready" da controladora é igual a "010", caso seja a operaçao foi concluída,
					-- caso contrario e necessario aguardar por mais um ciclo.
					IF SIG_RBC_ready = "010" THEN
					
						-- Encaminha a FSM para o estado de finalizaçao da execuçao da instruçao atual, isso ocorre, pois os dados somente,
						-- são escritos no Banco de Registradores no estado de Writeback, que é o estado anterior ao de finalizaçao.
						nextState <= state_Finaliza;
						
					-- Caso contrário,
					ELSE
						
						-- Encaminha a FSM para o mesmo estado atual.
						nextState <= state_REG_Write_Wait2;
					
					END IF;
					
				-- %%%%%%%%%%%%%%% FIM DA FSM DE ESCRITA DE WORD DO REGBANK %%%%%%%%%%%%%%%
				
			
			
			
			
			
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE BUSCA DE INSTRUÇÃO %%%%%%%%%%%%%%%	
				
				-- Estado onde é solicitado ao controlador da RAM de instruçoes a leitura da próxima instruçao. Envia o valor base do contador de programa (PC),
				-- e o controlador é responsável por ler todos os 4 bytes da RAM de instruçoes.
				WHEN state_IF_Solicita =>
			
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0110";
					sig_Display7_DADO <= "0001";
					
					-- Sinaliza no barramento "ready" que não operaçoes concluidas, i.e. o circuito está ocupado.
					SIG_ready <= "000";
					
					-- Escreve dados nos barramentos do controlador da RAM de instruçoes
					SIG_IRC_opCode 	<= "001";	-- Informa a controladora que a operaçao a ser executada é a de leitura de instruçao - "state_IRC_IF_Solicita1".
					SIG_IRC_reset 		<= '1';		-- Coloca o sinal de reset em nível alto, fazendo assim com que a controladora entre em reset e desvie para o opcode informado.
					SIG_IRC_address 	<= PC;		-- Envia o valor presente na variável "PC" para a controladora informando o endereço que será lido.
					
					-- Encaminha a FSM para o estado "Wait1".
					nextState <= state_IF_Wait1;
			
				
				-- %%
			
				
				-- Estado utilizado para ativar a operaçao correspondente no circuito controlador da RAM de instruçoes,
				-- ou seja, após o sinal de reset ser colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
				WHEN state_IF_Wait1 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0110";
					sig_Display7_DADO <= "0010";
			
					-- Coloca o sinal de reset da controladora em nivel baixo, fazendo com que essa saia do estado de reset e execute.
					SIG_IRC_reset <= '0';
					
					-- Encaminha a FSM para o estado "Wait2".
					nextState <= state_IF_Wait2;
			
				
				-- %%
			
				
				-- Estado onde aguarda-se que a controladora da RAM de instruçoes execute a leitura da próxima instruçao
				-- e informe por meio do sinal "ready" que essa operaçao foi executada.
				WHEN state_IF_Wait2 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0110";
					sig_Display7_DADO <= "0011";
					
					-- Garante que o circuito controlador da RAM de instruçoes não está recebendo sinal de reset.
					SIG_IRC_reset <= '0';
					
					-- Verifica se o sinal "ready" da controladora é igual a "001", caso seja a operaçao foi concluída,
					-- caso contrario e necessario aguardar por mais um ciclo.
					IF SIG_IRC_ready = "001" THEN
					
						-- Encaminha a FSM para o estado de Decodificaçao da instrução carregada.
						nextState <= state_DEC_Load;
						
					-- Caso contrário,
					ELSE
						
						-- Encaminha a FSM para o mesmo estado atual.
						nextState <= state_IF_Wait2;
					
					END IF;
					
					-- Armazena a instruçao lida, presente no barramento de instruçao da controladora, na variável correspondente.
					VAR_instrucaoAtual := SIG_IRC_instrucao;
				
				-- %%%%%%%%%%%%%%% FIM DA FSM DE BUSCA DE INSTRUÇÃO %%%%%%%%%%%%%%%	
				
			
			
			
			
			
				-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE DECODIFICAÇÃO %%%%%%%%%%%%%%%
				
				
				-- Estado onde o sinal de opCode é preenchido com parte dos dados contidos
				-- na  variável de instrução atual.
				WHEN state_DEC_Load =>
			
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0111";
					sig_Display7_DADO <= "0001";
					
					-- Armazena o valor do campo opCode.
					VAR_INST_opCode	:= VAR_instrucaoAtual(31 DOWNTO 26);
					
					-- Armazena o valor do campo funct.
					VAR_INST_funct 	:= VAR_instrucaoAtual(5 DOWNTO 0);
					
					-- Armazena o valor do campo funct2.
					VAR_INST_funct2 	:= VAR_instrucaoAtual(20 DOWNTO 16);
					
					-- Encaminha a FSM para o estado de filtro da decodificaçao.
					nextState <= state_DEC_Filter;
				
				
				-- %%
			
				
				-- Estado onde ocorre a decodificação da instruçao atual, de acordo com os campos opCode, funct e funct2 armazenados nas variáveis
				-- correspondentes anteriormente. No estágio de decodificaçao são armazenados nas variaveis adequadas os endereços dos registradores
				-- que devem ser lidos para a correta execução das instruçoes. Tais registradores são descritos em campos especiais das instruçoes dos tipos
				-- R e I do MIPS, assim, em instruçoes desses tipos, após salvar os endereços, direciona-se a FSM para os estados de leitura de registradores.
				-- Nas instruçoes do tipo J ou aquelas onde não é necessário a leitura de registradores para sua correta execuçao, a FSM é encaminhada para
				-- outros estados, não aquele de leitura de registradores.
				WHEN state_DEC_Filter =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "0111";
					sig_Display7_DADO <= "0010";
					
					-- Filtra de acordo com o campo "opCode".
					CASE VAR_INST_opCode IS
				
						-- INÍCIO DO OPCODE "000000"
						WHEN "000000" =>
						
							-- Filtra de acordo com o campo "funct".
							CASE VAR_INST_funct IS
							
								-- ADD, 	ADDU, AND, 	 DIV,  DIV, 
								-- JALR, JR, 	MOVN,  MOVZ, MTHI, 
								-- MTLO, MULT, MULTU, NOR,  OR, 
								-- SLLV, SLT,  SLTU,  SRA,  SRAV,
								-- SRL,  SRLV, SUB,  SUBU,  XOR
								WHEN "100000" | "100001" | "100100" | "011010" | "011011" | 
									  "001001" | "001000" | "001011" | "001010" | "010001" |
									  "010011" | "011000" | "011001" | "100111" | "100101" | 
									  "000100" | "101010" | "101011" | "000011" | "000111" |
									  "000010" | "000110" | "100010" | "100011" | "100110" =>
									
									VAR_addrRBRead1 := "0" & VAR_instrucaoAtual(25 DOWNTO 21);
									VAR_addrRBRead2 := "0" & VAR_instrucaoAtual(20 DOWNTO 16);
									
									nextState <= state_REG_Read_Solicita;
									
								-------------------------------------------------------------
								
								-- NOP
								WHEN "000000" =>
								
									IF VAR_instrucaoAtual = x"00000000" THEN
									
										nextState <= state_Finaliza;
								
									-- SLL
									ELSE
									
										VAR_addrRBRead1 := (OTHERS => '0');
										VAR_addrRBRead2 := "0" & VAR_instrucaoAtual(20 DOWNTO 16);
										
										nextState <= state_REG_Read_Solicita;
									
									END IF;
									
								-------------------------------------------------------------
								
								-- MFHI
								WHEN "010000" =>
								
									VAR_addrRBRead1 := CONST_addrHI;
									VAR_addrRBRead2 := (OTHERS => '0');
								
									nextState <= state_REG_Read_Solicita;
									
								-------------------------------------------------------------
								
								-- MFLO
								WHEN "010010" =>
								
									VAR_addrRBRead1 := CONST_addrLO;
									VAR_addrRBRead2 := (OTHERS => '0');
								
									nextState <= state_REG_Read_Solicita;
									
									
								-- Estados inválidos.
								WHEN OTHERS =>
								
									SIG_error <= "11";
								
									nextState <= state_IDLE_Fim;
							
							END CASE;
							-- FIM DO OPCODE "000000"
							
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
							
							-- INÍCIO DO OPCODE "000001"
							WHEN "000001" =>
							
								-- Filtra de acordo com o campo "funct2".
								CASE VAR_INST_funct2 IS
									
									-- BAL, BGEZ, BGEZAL, BLTZ, BLTZAL
									WHEN "00001" | "10001" | "00000" | "10000" =>
									
										VAR_addrRBRead1 := "0" & VAR_instrucaoAtual(25 DOWNTO 21);
										VAR_addrRBRead2 := "0" & VAR_instrucaoAtual(20 DOWNTO 16);
										
										nextState <= state_REG_Read_Solicita;

									-- Estados inválidos.
									WHEN OTHERS =>
									
										SIG_error <= "11";
									
										nextState <= state_IDLE_Fim;
							
							END CASE;
							-- FIM DO OPCODE "000001"
								
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
								
							-- LUI, JAL
							WHEN "001111" | "000011" =>
							
								nextState <= state_WB_Filter;
							
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
								
							-- J
							WHEN "000010" =>
							
								nextState <= state_Finaliza;
							
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
							
							-- B,  BEQ, BNE, BLEZ, BGTZ, LB, 
							-- LH, LW,  LBU, LHU,  SB,   
							-- SH, SW, ADDI, ADDIU, SLTI
							-- SLTIU, ANDI, ORI, XORI
							WHEN "000100" | "000101" | "000110" | "000111" | "100000" |
								  "100001" | "100011" | "100100" | "100101" | "101000" |
								  "101001" | "101011" | "001000" | "001001" | "001010" |
								  "001011" | "001100" | "001101" | "001110" =>
							
								VAR_addrRBRead1 := "0" & VAR_instrucaoAtual(25 DOWNTO 21);
								VAR_addrRBRead2 := "0" & VAR_instrucaoAtual(20 DOWNTO 16);
																		
								nextState <= state_REG_Read_Solicita;
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
								
							-- INÍCIO DO OPCODE "011100"	
							WHEN "011100" =>
							
								CASE VAR_INST_funct IS
								
									-- CLO, CLZ, MUL
									WHEN "100001" | "100000" | "000010" =>
								
										VAR_addrRBRead1 := "0" & VAR_instrucaoAtual(25 DOWNTO 21);
										VAR_addrRBRead2 := "0" & VAR_instrucaoAtual(20 DOWNTO 16);
										
										nextState <= state_REG_Read_Solicita;
								
									-- Estados inválidos.
									WHEN OTHERS =>
									
										SIG_error <= "11";
									
										nextState <= state_IDLE_Fim;
							
								END CASE;
								
							-- FIM DO OPCODE "011100"
							
								
							-- Estados inválidos.
							WHEN OTHERS =>
								
								SIG_error <= "11";
								
								nextState <= state_IDLE_Fim;
							
						END CASE;
				
			-- %%%%%%%%%%%%%%% FIM DA FSM DE DECODIFICAÇÃO %%%%%%%%%%%%%%%
			
			
			
			
			
			
			-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE EXECUÇÃO %%%%%%%%%%%%%%%
			
				-- Estado de filtro da fase de Execução da instruçao. Nesse estado são realizadas as solicitaçoes de calculos na ALU e espera pelo resultado calculado.
				WHEN state_EX_Filter =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "1000";
					sig_Display7_DADO <= "0001";
					
					-- Filtra de acordo com o campo "opCode".
					CASE VAR_INST_opCode IS
				
						-- INÍCIO DO OPCODE "000000"
						WHEN "000000" =>
						
							-- Filtra de acordo com o campo "funct".
							CASE VAR_INST_funct IS
						
								-- ADD
								WHEN "100000" =>
									
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000000";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									nextState <= state_EX_Wait1;
									
								-------------------------------------------------------------
								
								-- ADDU
								WHEN "100001" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000001";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									nextState <= state_EX_Wait1;
									
								-------------------------------------------------------------
								
								-- AND
								WHEN "100100" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "010000";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									nextState <= state_EX_Wait1;
								
								-------------------------------------------------------------
								
								-- DIV
								WHEN "011010" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000100";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									nextState <= state_EX_Wait1;
								
								-------------------------------------------------------------
								
								-- DIVU
								WHEN "011011" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000101";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									nextState <= state_EX_Wait1;
								
								-------------------------------------------------------------
								
								-- JALR, MFHI, MFLO, MTHI, MTLO
								WHEN "001001" | "010000" | "010010" | "010001" | "010011" =>
								
									SIG_ready <= "000";
									
									nextState <= state_WB_Filter;
								
								--------	-----------------------------------------------------
								
								-- JR
								WHEN "001000" =>
								
									SIG_ready <= "000";
									
									nextState <= state_Finaliza;
								
								-------------------------------------------------------------
								
								-- MOVN, MOVZ
								WHEN "001011" | "001010" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "010111";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut2;
									SIG_ALU_MIPS32_in1 		<= (OTHERS => '0');
									
									nextState <= state_EX_Wait1;
								
								-------------------------------------------------------------
								
								-- MULT
								WHEN "011000" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "001010";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									nextState <= state_EX_Wait1;
								
								-------------------------------------------------------------
								
								-- MULTU
								WHEN "011001" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "001011";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									nextState <= state_EX_Wait1;
								
								-------------------------------------------------------------
								
								-- NOR
								WHEN "100111" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "010001";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									nextState <= state_EX_Wait1;
								
								-------------------------------------------------------------
								
								-- OR
								WHEN "100101" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "010010";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									nextState <= state_EX_Wait1;
								
								-------------------------------------------------------------
								
								-- SLL
								WHEN "000000" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "010100";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut2;
									SIG_ALU_MIPS32_in1 		<= x"000000" & "000" & VAR_instrucaoAtual(10 DOWNTO 6);
									
									nextState <= state_EX_Wait1;
									
								-------------------------------------------------------------
								
								-- SLLV
								WHEN "000100" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "010100";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut2;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut1;
									
									nextState <= state_EX_Wait1;
									
								-------------------------------------------------------------
								
								-- SLT
								WHEN "101010" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "001100";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									nextState <= state_EX_Wait1;
									
								-------------------------------------------------------------
								
								-- SLTU
								WHEN "101011" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "001101";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									nextState <= state_EX_Wait1;
									
								-------------------------------------------------------------
								
								-- SRA
								WHEN "000011" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "010101";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut2;
									SIG_ALU_MIPS32_in1 		<= x"000000" & "000" & VAR_instrucaoAtual(10 DOWNTO 6);
									
									nextState <= state_EX_Wait1;
									
								-------------------------------------------------------------
								
								-- SRAV
								WHEN "000111" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "010101";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut2;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut1;
									
									nextState <= state_EX_Wait1;
									
								-------------------------------------------------------------
								
								-- SRL
								WHEN "000010" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "010110";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut2;
									SIG_ALU_MIPS32_in1 		<= x"000000" & "000" & VAR_instrucaoAtual(10 DOWNTO 6);
									
									nextState <= state_EX_Wait1;
									
								-------------------------------------------------------------
								
								-- SRLV
								WHEN "000110" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "010110";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut2;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut1;
									
									nextState <= state_EX_Wait1;
									
								-------------------------------------------------------------
								
								-- SUB
								WHEN "100010" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "001110";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									nextState <= state_EX_Wait1;
								
								-------------------------------------------------------------
								
								-- SUBU
								WHEN "100011" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "001111";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									nextState <= state_EX_Wait1;
									
								-------------------------------------------------------------	
								
								-- XOR
								WHEN "100110" =>
								
									SIG_ready <= "000";
									
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "010011";
									SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
									SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
									
									nextState <= state_EX_Wait1;
								
								
								-- Estados inválidos
								WHEN OTHERS =>
								
									nextState <= state_IDLE_Fim;
							
							END CASE;
							-- FIM DO OPCODE "000000"
							
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
							
							-- FIM DO OPCODE "000001"
							WHEN "000001" =>
							
								-- Filtra de acordo com o campo "funct2".
								CASE VAR_INST_funct2 IS
									
									-- BAL, BGEZ, BGEZAL
									WHEN "00001" | "10001" =>
									
										IF SIG_RBC_dataOut1 >= x"00000000" THEN
									
											SIG_ready <= "000";
											SIG_ALU_MIPS32_reset 	<= '1';		
											SIG_ALU_MIPS32_opCode 	<= "000001";
											SIG_ALU_MIPS32_in0 		<= x"000000" & PC;
											SIG_ALU_MIPS32_in1 		<= x"0000" & VAR_instrucaoAtual(15 DOWNTO 0);
											
											nextState <= state_EX_Wait1;
										
										ELSE
										
											SIG_ready <= "000";
											SIG_ALU_MIPS32_reset 	<= '1';		
											SIG_ALU_MIPS32_opCode 	<= "000001";
											SIG_ALU_MIPS32_in0 		<= x"000000" & PC;
											SIG_ALU_MIPS32_in1 		<= x"00000004";
											
											nextState <= state_EX_Wait1;
										
										END IF;
										
									-------------------------------------------------------------	
										
									-- BLTZ | BLTZAL
									WHEN "00000" | "10000" =>
									
										IF SIG_RBC_dataOut1(31) = '1' THEN
									
											SIG_ready <= "000";
											SIG_ALU_MIPS32_reset 	<= '1';		
											SIG_ALU_MIPS32_opCode 	<= "000001";
											SIG_ALU_MIPS32_in0 		<= x"000000" & PC;
											SIG_ALU_MIPS32_in1 		<= x"0000" & VAR_instrucaoAtual(15 DOWNTO 0);
											
											nextState <= state_EX_Wait1;
										
										ELSE
										
											SIG_ready <= "000";
											SIG_ALU_MIPS32_reset 	<= '1';		
											SIG_ALU_MIPS32_opCode 	<= "000001";
											SIG_ALU_MIPS32_in0 		<= x"000000" & PC;
											SIG_ALU_MIPS32_in1 		<= x"00000004";
											
											nextState <= state_EX_Wait1;
										
										END IF;
										
									-- Estados inválidos
									WHEN OTHERS =>
									
										nextState <= state_IDLE_Fim;
										
									-- FIM DO OPCODE "000001"
								
								END CASE;
															
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
								
							-- B, BEQ
							WHEN "000100" =>
							
								IF SIG_RBC_dataOut1 = SIG_RBC_dataOut2 THEN
									
									SIG_ready <= "000";
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000001";
									SIG_ALU_MIPS32_in0 		<= x"000000" & PC;
									SIG_ALU_MIPS32_in1 		<= x"0000" & VAR_instrucaoAtual(15 DOWNTO 0);
									
									nextState <= state_EX_Wait1;
								
								ELSE
								
									SIG_ready <= "000";
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000001";
									SIG_ALU_MIPS32_in0 		<= x"000000" & PC;
									SIG_ALU_MIPS32_in1 		<= x"00000004";
									
									nextState <= state_EX_Wait1;
								
								END IF;
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
								
							-- BNE
							WHEN "000101" =>
							
								IF SIG_RBC_dataOut1 /= SIG_RBC_dataOut2 THEN
									
									SIG_ready <= "000";
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000001";
									SIG_ALU_MIPS32_in0 		<= x"000000" & PC;
									SIG_ALU_MIPS32_in1 		<= x"0000" & VAR_instrucaoAtual(15 DOWNTO 0);
									
									nextState <= state_EX_Wait1;
								
								ELSE
								
									SIG_ready <= "000";
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000001";
									SIG_ALU_MIPS32_in0 		<= x"000000" & PC;
									SIG_ALU_MIPS32_in1 		<= x"00000004";
									
									nextState <= state_EX_Wait1;
								
								END IF;
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
								
							-- BLEZ
							WHEN "000110" =>
							
								IF (SIG_RBC_dataOut1(31) = '1') OR (SIG_RBC_dataOut1 = x"00000000") THEN
									
									SIG_ready <= "000";
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000001";
									SIG_ALU_MIPS32_in0 		<= x"000000" & PC;
									SIG_ALU_MIPS32_in1 		<= x"0000" & VAR_instrucaoAtual(15 DOWNTO 0);
									
									nextState <= state_EX_Wait1;
								
								ELSE
								
									SIG_ready <= "000";
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000001";
									SIG_ALU_MIPS32_in0 		<= x"000000" & PC;
									SIG_ALU_MIPS32_in1 		<= x"00000004";
									
									nextState <= state_EX_Wait1;
								
								END IF;
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
								
							-- BGTZ
							WHEN "000111" =>
							
								IF (SIG_RBC_dataOut1(31) = '0') AND (SIG_RBC_dataOut1 /= x"00000000") THEN
									
									SIG_ready <= "000";
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000001";
									SIG_ALU_MIPS32_in0 		<= x"000000" & PC;
									SIG_ALU_MIPS32_in1 		<= x"0000" & VAR_instrucaoAtual(15 DOWNTO 0);
									
									nextState <= state_EX_Wait1;
								
								ELSE
								
									SIG_ready <= "000";
									SIG_ALU_MIPS32_reset 	<= '1';		
									SIG_ALU_MIPS32_opCode 	<= "000001";
									SIG_ALU_MIPS32_in0 		<= x"000000" & PC;
									SIG_ALU_MIPS32_in1 		<= x"00000004";
									
									nextState <= state_EX_Wait1;
								
								END IF;
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||	
								
							-- ADDI
							WHEN "001000" =>
							
								SIG_ready <= "000";
									
								SIG_ALU_MIPS32_reset 	<= '1';		
								SIG_ALU_MIPS32_opCode 	<= "000000";
								SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
								SIG_ALU_MIPS32_in1 		<= x"0000" & VAR_instrucaoAtual(15 DOWNTO 0);
								
								nextState <= state_EX_Wait1;
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||	
							
							-- ADDIU
							WHEN "001001" =>
							
								SIG_ready <= "000";
									
								SIG_ALU_MIPS32_reset 	<= '1';		
								SIG_ALU_MIPS32_opCode 	<= "000001";
								SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
								SIG_ALU_MIPS32_in1 		<= x"0000" & VAR_instrucaoAtual(15 DOWNTO 0);
								
								nextState <= state_EX_Wait1;
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
								
							-- ANDI
							WHEN "001100" =>
								
								SIG_ready <= "000";
								
								SIG_ALU_MIPS32_reset 	<= '1';		
								SIG_ALU_MIPS32_opCode 	<= "010000";
								SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
								SIG_ALU_MIPS32_in1 		<= x"0000" & VAR_instrucaoAtual(15 DOWNTO 0);
								
								nextState <= state_EX_Wait1;
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||	
								
							-- ORI
							WHEN "001101" =>
							
								SIG_ready <= "000";
								
								SIG_ALU_MIPS32_reset 	<= '1';		
								SIG_ALU_MIPS32_opCode 	<= "010010";
								SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
								SIG_ALU_MIPS32_in1 		<= x"0000" & VAR_instrucaoAtual(15 DOWNTO 0);
								
								nextState <= state_EX_Wait1;
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
							
							-- XORI
							WHEN "001110" =>
							
								SIG_ready <= "000";
								
								SIG_ALU_MIPS32_reset 	<= '1';		
								SIG_ALU_MIPS32_opCode 	<= "010011";
								SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
								SIG_ALU_MIPS32_in1 		<= x"0000" & VAR_instrucaoAtual(15 DOWNTO 0);
								
								nextState <= state_EX_Wait1;
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
							
							-- SLTI
							WHEN "001010" =>
								
								SIG_ready <= "000";
								
								SIG_ALU_MIPS32_reset 	<= '1';		
								SIG_ALU_MIPS32_opCode 	<= "001100";
								SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
								SIG_ALU_MIPS32_in1 		<= x"0000" & VAR_instrucaoAtual(15 DOWNTO 0);
								
								nextState <= state_EX_Wait1;
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
								
							-- SLTIU
							WHEN "001011" =>
								
								SIG_ready <= "000";
								
								SIG_ALU_MIPS32_reset 	<= '1';		
								SIG_ALU_MIPS32_opCode 	<= "001101";
								SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
								SIG_ALU_MIPS32_in1 		<= x"0000" & VAR_instrucaoAtual(15 DOWNTO 0);
								
								nextState <= state_EX_Wait1;
							
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
							
							-- LB, LH, LW, LBU, LHU, SB, SH, SW
							WHEN "100000" | "100001" | "100011" | "100100" | "100101" | "101000" | "101001" | "101011" =>
					
								SIG_ready <= "000";
									
								SIG_ALU_MIPS32_reset 	<= '1';		
								SIG_ALU_MIPS32_opCode 	<= "000001";
								SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
								SIG_ALU_MIPS32_in1 		<=  STD_LOGIC_VECTOR( RESIZE(SIGNED(VAR_instrucaoAtual(15 DOWNTO 0)), SIG_ALU_MIPS32_in1'LENGTH) );
								
								nextState <= state_EX_Wait1;
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
								
							-- INÍCIO DO OPCODE "011100"		
							WHEN "011100" =>
							
								-- Filtra de acordo com o campo "funct".
								CASE VAR_INST_funct IS
								
									-- CLO
									WHEN "100001" =>
								
										SIG_ready <= "000";
									
										SIG_ALU_MIPS32_reset 	<= '1';		
										SIG_ALU_MIPS32_opCode 	<= "000010";
										SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
										SIG_ALU_MIPS32_in1 		<= (OTHERS => '0');
										
										nextState <= state_EX_Wait1;
										
									-------------------------------------------------------------
										
									-- CLZ
									WHEN "100000" =>
								
										SIG_ready <= "000";
									
										SIG_ALU_MIPS32_reset 	<= '1';		
										SIG_ALU_MIPS32_opCode 	<= "000011";
										SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
										SIG_ALU_MIPS32_in1 		<= (OTHERS => '0');
										
										nextState <= state_EX_Wait1;
								
									-------------------------------------------------------------
								
									-- MUL
									WHEN "000010" =>
								
										SIG_ready <= "000";
									
										SIG_ALU_MIPS32_reset 	<= '1';		
										SIG_ALU_MIPS32_opCode 	<= "001010";
										SIG_ALU_MIPS32_in0 		<= SIG_RBC_dataOut1;
										SIG_ALU_MIPS32_in1 		<= SIG_RBC_dataOut2;
										
										nextState <= state_EX_Wait1;
								
									-- Estados inválidos.
									WHEN OTHERS =>
									
										SIG_error <= "11";
									
										nextState <= state_IDLE_Fim;
							
								END CASE;
								-- FIM DO OPCODE "011100"	
								
							-- Estados inválidos.
							WHEN OTHERS =>
								
								SIG_error <= "11";
								
								nextState <= state_IDLE_Fim;
							
						END CASE;
					
				
				-- %%
			
				
				-- Estado utilizado para ativar a operaçao requisitada na ALU no estado anterior ou seja, após o sinal de reset ser 
				-- colocado em nível alto no estado anterior, agora ele será colocado em nível baixo.
				WHEN state_EX_Wait1 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "1000";
					sig_Display7_DADO <= "0010";
					
					-- Coloca o sinal de reset da ALU, fazendo com que essa saia do estado de reset e execute.
					SIG_ALU_MIPS32_reset <= '0';
					
					-- Encaminha a FSM para o estado "Wait2".
					nextState <= state_EX_Wait2;
					
				
				-- %%
			
				
				-- Estado onde aguarda-se que a ALU execute a operação requisitada
				-- e informe por meio do sinal "ready" que essa operaçao foi executada.
				WHEN state_EX_Wait2 =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "1000";
					sig_Display7_DADO <= "0011";
					
					-- Garante que o circuito da ALU não está recebendo sinal de reset.
					SIG_ALU_MIPS32_reset <= '0';
					
					-- Verifica se o sinal "ready" da ALU é igual a '1', caso seja a operaçao foi concluída,
					-- caso contrario e necessario aguardar por mais um ciclo.
					IF SIG_ALU_MIPS32_ready = '1' THEN
					
						-- Encaminha a FSM para o estado de Writeback.
						nextState <= state_WB_Filter;
						
					-- Caso contrário,
					ELSE
					
						-- Encaminha a FSM para o mesmo estado atual.
						nextState <= state_EX_Wait2;
						
					END IF;
					
					-- Armazena nas variáveis de ALU os dados resultantes dos sinais de resultado(out0) e flags(outFlags) calculados na ALU.
					VAR_ALUresult 	:= SIG_ALU_MIPS32_out0;
					VAR_ALUflags	:= SIG_ALU_MIPS32_outFlags;
					
					
			-- %%%%%%%%%%%%%%% TÉRMINO DA FSM DE EXECUÇÃO %%%%%%%%%%%%%%%
				
			
			
			
			
			
			-- %%%%%%%%%%%%%%% INÍCIO DA FSM DE WRITEBACK %%%%%%%%%%%%%%%
		
			-- Estado onde a instruçao atual é filtrada e de acordo com o tipo de instruçao dados resultantes da execuçao
			-- dessa instruçao no estado de execuçao podem ser salvos no Banco de Registradores ou na memória RAM de dados.
			WHEN state_WB_Filter =>
			
				-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
				sig_Display8_DADO <= "1001";
				sig_Display7_DADO <= "0001";
			
				-- Filtra o valor do sinal de opCode.
				CASE VAR_INST_opCode IS
				
					-- INÍCIO DO OPCODE "000000"
					WHEN "000000" =>
					
						-- Filtra de acordo com o campo "opCode".
						CASE VAR_INST_funct IS
						
							-- ADD
							WHEN "100000" =>
										
								-- Verifica existência de overflow no cálculo, caso não haja,
								-- escreve o valor no registrador de destino.
								IF(VAR_ALUflags(4) /= '1') THEN
									
									VAR_addrRBWrite1 	:= '0' & VAR_instrucaoAtual(15 DOWNTO 11);
									VAR_dataInRB1 		:= VAR_ALUresult(31 DOWNTO 0);
								
								END IF;
								
								nextState <= state_REG_Write_Solicita;
								
							-------------------------------------------------------------
							
							-- DIV, DIVU
							WHEN "011010" | "011011" =>
								
								VAR_addrRBWrite1	:= CONST_addrLO;
								VAR_dataInRB1	 	:= VAR_ALUresult(31 DOWNTO 0);
								
								VAR_addrRBWrite2	:= CONST_addrHI;
								VAR_dataInRB2	 	:= VAR_ALUresult(63 DOWNTO 32);
								
								nextState <= state_REG_Write_Solicita;
							
							-------------------------------------------------------------	
							
							-- JALR
							WHEN "001001" =>
								
								VAR_addrRBWrite1	:= '0' & VAR_instrucaoAtual(15 DOWNTO 11);
								VAR_dataInRB1	 	:= x"000000" & PC + 4;
								
								nextState <= state_REG_Write_Solicita;
							
							-------------------------------------------------------------
							
							-- MFHI, MFLO
							WHEN "010000" | "010010" =>
								
								VAR_addrRBWrite1	:= '0' & VAR_instrucaoAtual(15 DOWNTO 11);
								VAR_dataInRB1	 	:= SIG_RBC_dataOut1;
								
								nextState <= state_REG_Write_Solicita;
							
							-------------------------------------------------------------
								
							-- MOVN
							WHEN "001011" =>
							
								IF(VAR_ALUresult(1 DOWNTO 0) /= "11") THEN
									
									VAR_addrRBWrite1 	:= '0' & VAR_instrucaoAtual(15 DOWNTO 11);
									VAR_dataInRB1		:= SIG_RBC_dataOut1;
								
								END IF;
								
								nextState <= state_REG_Write_Solicita;
								
							-------------------------------------------------------------
								
							-- MOVZ
							WHEN "001010" =>
							
								IF(VAR_ALUresult(1 DOWNTO 0) = "11") THEN
									
									VAR_addrRBWrite1 	:= '0' & VAR_instrucaoAtual(15 DOWNTO 11);
									VAR_dataInRB1		:= SIG_RBC_dataOut1;
								
								END IF;
								
								nextState <= state_REG_Write_Solicita;
								
							-------------------------------------------------------------
							
							-- MTHI
							WHEN "010001" =>
								
								VAR_addrRBWrite1	:= CONST_addrHI;
								VAR_dataInRB1	 	:= SIG_RBC_dataOut1;
								
								nextState <= state_REG_Write_Solicita;
							
							-------------------------------------------------------------
							
							-- MTLO
							WHEN "010011" =>
								
								VAR_addrRBWrite1	:= CONST_addrLO;
								VAR_dataInRB1	 	:= SIG_RBC_dataOut1;
								
								nextState <= state_REG_Write_Solicita;
							
							-------------------------------------------------------------
							
							-- MULT, MULTU
							WHEN "011000" | "011001" =>
								
								VAR_addrRBWrite1	:= CONST_addrLO;
								VAR_dataInRB1	 	:= VAR_ALUresult(31 DOWNTO 0);
								
								VAR_addrRBWrite2	:= CONST_addrHI;
								VAR_dataInRB2	 	:= VAR_ALUresult(63 DOWNTO 32);
								
								nextState <= state_REG_Write_Solicita;
							
							-------------------------------------------------------------
							
							-- ADDU, AND,  NOR,  OR,  SLL,  
							-- SLLV, SLT,  SLTU, SRA, SRAV, 
							-- SRL,  SRLV, XOR,  SUBU
							WHEN "100001" | "100100" | "100111" | "100101" | "000000" | 
								  "000100" | "101010" | "101011" | "000011" | "000111" |
								  "000010" | "000110" | "100110" | "100011" =>
							
								-- Salva o valor resultante da operação na ALU
								-- no registrador indicado em RD.
								VAR_addrRBWrite1 	:= '0' & VAR_instrucaoAtual(15 DOWNTO 11);
								VAR_dataInRB1 		:= VAR_ALUresult(31 DOWNTO 0);
								
								nextState <= state_REG_Write_Solicita;
								
							-------------------------------------------------------------
								
							-- SUB
							WHEN "100010" =>
							
								-- Verifica existência de overflow no cálculo, caso não haja,
								-- escreve o valor no registrador de destino.
								IF(VAR_ALUflags(4) /= '1') THEN
									
									VAR_addrRBWrite1 	:= '0' & VAR_instrucaoAtual(15 DOWNTO 11);
									VAR_dataInRB1		:= VAR_ALUresult(31 DOWNTO 0);
								
								END IF;
								
								nextState <= state_REG_Write_Solicita;
								
							-------------------------------------------------------------
							
							-- Estados inválidos.
							WHEN OTHERS =>
								
								SIG_error <= "11";
								
								nextState <= state_IDLE_Fim;
							
						END CASE;
						-- FIM DO OPCODE "000000"
						
						--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
						
						-- INÍCIO DO OPCODE "000001"
						WHEN "000001" =>
							
							-- Filtra de acordo com o campo "funct2".
							CASE VAR_INST_funct2 IS
							
								-- BAL, BGEZAL, BLTZAL
								WHEN "10001" | "10000" =>
								
									VAR_addrRBWrite1	:= "011111";
									VAR_dataInRB1	 	:= x"000000" & PC + 4;
									
									nextState <= state_REG_Write_Solicita;
									
								-------------------------------------------------------------
								
								-- BGEZ, BLTZ
								WHEN "00001" | "00000" =>
								
									nextState <= state_Finaliza;
									
								-- Estados inválidos.
								WHEN OTHERS =>
								
									SIG_error <= "11";
								
									nextState <= state_IDLE_Fim;
							
							END CASE;
							-- FIM DO OPCODE "000001"
							
						--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
						
						-- J, B, BEQ, BNE, BLEZ, BGTZ
						WHEN "000010" | "000100" | "000101" | "000110" | "000111" =>
						
							nextState <= state_Finaliza;
							
						--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
							
						-- ADDI
						WHEN "001000" =>
										
							-- Verifica existência de overflow no cálculo, caso não haja,
							-- escreve o valor no registrador de destino.
							IF(VAR_ALUflags(4) /= '1') THEN
								
								VAR_addrRBWrite1 	:= '0' & VAR_instrucaoAtual(20 DOWNTO 16);
								VAR_dataInRB1 		:= VAR_ALUresult(31 DOWNTO 0);
							
							END IF;
							
							nextState <= state_REG_Write_Solicita;
							
						--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
							
						-- ADDIU, SLTI, SLTIU, ANDI, ORI, XORI
						WHEN "001001" | "001010" | "001011" | "001100" | "001101" | "001110" =>
						
							-- Salva o valor resultante da operação na ALU
							-- no registrador indicado em RD.
							VAR_addrRBWrite1 	:= '0' & VAR_instrucaoAtual(20 DOWNTO 16);
							VAR_dataInRB1 		:= VAR_ALUresult(31 DOWNTO 0);
							
							nextState <= state_REG_Write_Solicita;
						
						--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
							
						-- JAL
						WHEN "000011" =>
						
							VAR_addrRBWrite1	:= "011111";
							VAR_dataInRB1	 	:= x"000000" & PC + 4;
							
							nextState <= state_REG_Write_Solicita;
						
						--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
						
						-- LUI
						WHEN "001111" =>
						
							VAR_addrRBWrite1 	:= '0' & VAR_instrucaoAtual(20 DOWNTO 16);
							VAR_dataInRB1 		:= VAR_instrucaoAtual(15 DOWNTO 0) & x"0000";
							
							nextState <= state_REG_Write_Solicita;
						
						--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
						
						-- LB, LBU
						WHEN "100000" | "100100" =>
					
							VAR_addrDATARead := VAR_ALUresult(7 DOWNTO 0);
							SIG_DRC_bytes 		<= "00";
							
							nextState <= state_DATA_Read_Solicita;
						
						--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
						
						-- LH, LHU
						WHEN "100001" |"100101" =>
					
							VAR_addrDATARead := VAR_ALUresult(7 DOWNTO 0);
							SIG_DRC_bytes 		<= "01";
							
							nextState <= state_DATA_Read_Solicita;
						
						--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
						
						-- LW
						WHEN "100011" =>
					
							VAR_addrDATARead := VAR_ALUresult(7 DOWNTO 0);
							SIG_DRC_bytes 		<= "11";
							
							nextState <= state_DATA_Read_Solicita;			
						
						--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
						
						-- SB
						WHEN "101000" =>
					
							VAR_addrDATAWrite := VAR_ALUresult(7 DOWNTO 0);
							VAR_dataInDATA 	:= SIG_RBC_dataOut2;
							SIG_DRC_bytes 		<= "00";
							
							nextState <= state_DATA_Write_Solicita;
						
						--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
						
						-- SH
						WHEN "101001" =>
					
							VAR_addrDATAWrite := VAR_ALUresult(7 DOWNTO 0);
							VAR_dataInDATA 	:= SIG_RBC_dataOut2;
							SIG_DRC_bytes 		<= "01";
							
							nextState <= state_DATA_Write_Solicita;
						
						--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||	
						
						-- SW
						WHEN "101011" =>
					
							VAR_addrDATAWrite := VAR_ALUresult(7 DOWNTO 0);
							VAR_dataInDATA 	:= SIG_RBC_dataOut2;
							SIG_DRC_bytes 		<= "11";
							
							nextState <= state_DATA_Write_Solicita;
							
						--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
							
						-- FIM DO OPCODE "011100"
						WHEN "011100" =>
							
							-- Filtra de acordo com o campo "funct".
							CASE VAR_INST_funct IS
							
								-- CLO, CLZ, MUL
								WHEN "100001" | "100000" | "000010" =>
							
									VAR_addrRBWrite1 	:= '0' & VAR_instrucaoAtual(15 DOWNTO 11);
									VAR_dataInRB1 		:= VAR_ALUresult(31 DOWNTO 0);
									
									nextState <= state_REG_Write_Solicita;
							
								-- Estados inválidos.
								WHEN OTHERS =>
								
									SIG_error <= "11";
								
									nextState <= state_IDLE_Fim;
						
							END CASE;
							-- FIM DO OPCODE "011100"
							
						-- Estados inválidos.
						WHEN OTHERS =>
								
							SIG_error <= "11";
								
							nextState <= state_IDLE_Fim;
							
					END CASE;
					
			
			
			
			
				-- Estado após a execuçao da instruçao atual, nesse estado é decidido se deve-se buscar uma nova instruçao ou não.
				-- Caso PC seja igual a PC_MAX o processador já executou todas as instruçoes, caso contrário torna-se necessario iniciar novamente
				-- o ciclo de "Busca - Decodificação - Execuçao e Writeback".
				WHEN state_Finaliza =>
				
					-- Sinaliza nos display de 7 segmentos o estado atual da FSM.
					sig_Display8_DADO <= "1010";
					sig_Display7_DADO <= "0001";
				
					-- Caso todas as instruçoes ja tenham sido executadas.
					IF PC = PC_MAX THEN
					
						SIG_error <= "00";
					
						-- Encaminha a FSM para o estado IDLE de finalizaçao.
						nextState <= state_IDLE_Fim;
					
					-- Caso ainda tenham instruçoes a serem executadas, é necessario atualizar o valor de PC,
					-- isso pode ser realizado de duas maneiras, caso alguma instruçao de desvio tenha sido tomada
					-- utiliza-se o valor valvulado na instruçao, ou caso contrário, não seja instruçao de desvio,
					-- simplesmente incrementa PC em 4 unidades.
					ELSE
					
						-- Filtra de acordo com o campo "opCode".
						CASE VAR_INST_opCode IS
				
							-- INÍCIO DO OPCODE "000000"
							WHEN "000000" =>
								
								-- Filtra de acordo com o campo "funct".
								CASE VAR_INST_funct IS
						
									-- JALR, JR
									WHEN "001001" | "001000" =>
									
										PC := SIG_RBC_dataOut1(7 DOWNTO 0);
										
									WHEN OTHERS =>
							
										PC := PC + 4;
							
								END CASE;
								-- FIM DO OPCODE "000000"
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
								
							-- INÍCIO DO OPCODE "000001"
							WHEN "000001" =>
						
								-- Filtra de acordo com o campo "funct2".
								CASE VAR_INST_funct2 IS
								
									-- BAL, BGEZ, BLTZ, BLTZAL
									WHEN "10001" | "00001" | "00000" | "10000" =>
									
										PC := VAR_ALUresult(7 DOWNTO 0);
								
									WHEN OTHERS =>
									
										PC := PC + 4;
								
								END CASE;
								-- FIM DO OPCODE "000001"
								
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
							
							-- J, JAL, 
							WHEN "000010" | "000011" =>	
							
								PC := VAR_instrucaoAtual(7 DOWNTO 0);
							
							--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
							
							-- B, BEQ, 
							-- BNE, BLEZ, BGTZ
							WHEN "000100" | 
								  "000101" | "000110" | "000111" =>
							
								PC := VAR_ALUresult(7 DOWNTO 0);

							WHEN OTHERS =>
							
								PC := PC + 4;
							
						END CASE;
						
						nextState <= state_IF_Solicita;
						
					END IF;
				
	
				-- Estado Inválido.
				WHEN OTHERS =>
				
					SIG_error <= "11";
				
					nextState <= state_IDLE_Fim;
					
			END CASE;
		
		END IF;
	
	END PROCESS;
			
END BEHAVIOR;
-- Fim da declaração da arquitetura da entidade MIPS32_Control.