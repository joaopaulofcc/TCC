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
 --# Arquivo: ALU_MIPS32.vhd									                     #
 --#                                                                      	#
 --# 09/07/15 - Formiga - MG                                              	#
 --#########################################################################

 
--Importa Bibliotecas 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Importa arquivos com constantes e funções do autor
USE WORK.funcoes.ALL;

-- Início das declarações do bloco ALU_MIPS32.
ENTITY ALU_MIPS32 IS
	
	PORT 
	(
		clock			: IN 	STD_LOGIC;	-- Sinal de sincronismo.
		reset			: IN 	STD_LOGIC;	-- Sinal de reset do circuito.
		opCode		: IN 	t_opCode;	-- Código da operação de ALU a ser exeutada.
		in0			: IN 	t_Word;		-- Primeiro operador (32 bits).
		in1			: IN 	t_Word;		-- Segundo operador (32 bits).
		out0			: OUT t_DWord;		-- Resultado da operação (64 bits).
		outFlags		: OUT t_Byte;		-- Vetor de flags.
		ready			: OUT STD_LOGIC	-- (1) Ready | (0) - Busy.
	);
	
END ALU_MIPS32;


-- Início da arquitetura do bloco ALU_MIPS32.
ARCHITECTURE RTL OF ALU_MIPS32 IS


	-- Márquina de estados da ALU.
	
		-- stateReset		= estado onde o circuito é resetado e seus pinos de saída preenchidos com valor '0'.
		-- stateIDLE		= estado dummy onde o circuito não realiza nenhuma operação.
		-- stateLoad		= estado de carregamento dos sinais externos para os pinos internos do circuito.
		-- stateExecute	= estado onde a operação lógica ou aritmética será executada de acordo com o valor do pino de opCode.
		-- stateFinish		= estado em que os resultados das operações calculadas no estado Execute são direcionados aos pinos de saída da ALU.
		
	TYPE aluState IS (stateReset, stateIDLE, stateLoad, stateExecute, stateFinish);
	SIGNAL currentState	: aluState := stateIDLE;
	
	-- Sinais internos do componente para conexão com os pinos externos.
	SIGNAL SIG_opCode		: t_opCode;
	SIGNAL SIG_in0			: t_Word;
	SIGNAL SIG_in1			: t_Word;
	SIGNAL SIG_out0		: t_DWord;
	SIGNAL SIG_outFlags	: t_Byte;
	SIGNAL SIG_ready		: STD_LOGIC;
	
BEGIN

	SIG_opCode 	<= opCode;
	SIG_in0		<= in0;
	SIG_in1		<= in1;
	out0 			<= SIG_out0;
	outFlags		<= SIG_outFlags;
	ready			<= SIG_ready;


	-- Process de controle de reset e de currentState.
	PROCESS(clock, reset) 
	
		-- Variáveis auxiliares nas operações da ALU.
		VARIABLE a				:	STD_LOGIC_VECTOR(32 DOWNTO 0);
		VARIABLE b				:	STD_LOGIC_VECTOR(32 DOWNTO 0);
		VARIABLE c				:	STD_LOGIC_VECTOR(32 DOWNTO 0);
		VARIABLE vectorZero	:	t_Word := x"00000000";
		VARIABLE temp			: 	INTEGER;
		
	BEGIN
		
		-- Reset do circuito
		IF (reset = '1') THEN
			
			-- Direciona a máquina de estado para stateReset.
			currentState 	<= stateReset;
			
		-- Caso reset = 0 e clock = 1, encaminha a FSM para o próximo estado.
		ELSIF (RISING_EDGE(clock)) THEN
		
			-- Verifica o estado atual da FSM
			CASE currentState IS
			
				-- Estado IDLE, não realiza nenhuma operação,
				-- para mudar de estado deve resetar o circuito.
				WHEN stateIDLE 		=>
				
					SIG_ready		<= '0';
				
					currentState <= stateIDLE;
				
			
				-- Estado de reset do circuito.
				WHEN stateReset 		=>
					
					-- Zera sinais de resultado(SIG_out0)
					-- e vetor de flags (SIG_outFlags).
					SIG_out0			<= (OTHERS => '0');
					SIG_outFlags	<= (OTHERS => '0');
					
					-- Circuito está ocupado.
					SIG_ready		<= '0';
		
					-- Direciona a FSM para stateLoad.
					currentState	<= stateExecute;
				
				
					
				-- Estado de execução das operações determinadas pelo
				-- valor presente em opCode.
				WHEN stateExecute		=>
				
					-- Filtra qual operação deverá ser executada de acordo
					-- com o valor de opCode.
					CASE SIG_opCode IS
					
					-------------------------------------------------------------
					
					-- CPU Arithmetic Instructions
					
						-- ADD | ADDI
						WHEN "000000" 	=>
						
							a	:= SIG_in0(31) & SIG_in0;
							b	:= SIG_in1(31) & SIG_in1;
							
							c := a + b;
							
							SIG_outFlags	<= (OTHERS => '0');
							
							IF ( c(32) /= c(31) ) THEN
							
								SIG_outFlags(4) <= '1';
							
							END IF;
							
							IF(c = x"00000000") THEN
							
								SIG_outFlags(2) <= '1';
								
							END IF;
						
							SIG_out0		<=  vectorZero & c(31 DOWNTO 0);
					
							currentState	<= stateFinish;
						
						-------------------------------------------------------------
						
						-- ADDU |ADDIU
						WHEN "000001" 	=>
						
							SIG_out0 		<= vectorZero & (SIG_in0 + SIG_in1);
							
							SIG_outFlags	<= (OTHERS => '0');
							
							IF(SIG_out0 = x"0000000000000000") THEN
							
								SIG_outFlags(2) <= '1';
								
							END IF;
							
							currentState	<= stateFinish;
						
						-------------------------------------------------------------
						
						-- CLO
						WHEN "000010" 	=>
						
							SIG_outFlags	<= (OTHERS => '0');
						
							temp := 32;
								
							loopCLO: FOR i IN 31 DOWNTO 0 LOOP
							
											IF (SIG_in0(i) = '0') THEN
												
												temp := 31 - i;
												
												EXIT loopCLO;
												
											END IF;
											
										END LOOP;
										
							SIG_out0	<= STD_LOGIC_VECTOR(TO_UNSIGNED(temp, SIG_out0'LENGTH));
							
							currentState <= stateFinish;
							
						-------------------------------------------------------------
						
						-- CLZ
						WHEN "000011" 	=>
							
							SIG_outFlags	<= (OTHERS => '0');
							
							temp := 32;
								
							loopCLZ: FOR i IN 31 DOWNTO 0 LOOP
							
											IF (SIG_in0(i) = '1') THEN
												
												temp := 31 - i;
												
												EXIT loopCLZ;
												
											END IF;
											
										END LOOP;
										
							SIG_out0	<= STD_LOGIC_VECTOR(TO_UNSIGNED(temp, SIG_out0'LENGTH));
							
							currentState <= stateFinish;
						
						-------------------------------------------------------------
						
						-- DIV
						WHEN "000100" 	=>
			
							SIG_outFlags	<= (OTHERS => '0');
			
							SIG_out0(63 DOWNTO 32)	<= STD_LOGIC_VECTOR(SIGNED(SIG_in0) MOD SIGNED(SIG_in1));
							SIG_out0(31 DOWNTO 0)	<= STD_LOGIC_VECTOR(SIGNED(SIG_in0) / SIGNED(SIG_in1));
						
							currentState <= stateFinish;
						
						-------------------------------------------------------------
						
						-- DIVU
						WHEN "000101" 	=>
						
							SIG_outFlags	<= (OTHERS => '0');
						
							SIG_out0(63 DOWNTO 32)	<= STD_LOGIC_VECTOR(UNSIGNED(SIG_in0) MOD UNSIGNED(SIG_in1));
							SIG_out0(31 DOWNTO 0)	<= STD_LOGIC_VECTOR(UNSIGNED(SIG_in0) / UNSIGNED(SIG_in1));
						
							currentState <= stateFinish;
						
						
						
						-- TODO
						--------------------------------------------------------------------
						
						-- MADD
						--WHEN "000110" 	=>
						
						
						-- MADDU
						--WHEN "000111" 	=>
						
						
						-- MSUB
						--WHEN "001000" 	=>
						
						
						-- MSUBU
						--WHEN "001001" 	=>
						
						--------------------------------------------------------------------
						
						
						
						-- MUL / MULT
						WHEN "001010" 	=>
							
							SIG_outFlags	<= (OTHERS => '0');
							
							SIG_out0			<= STD_LOGIC_VECTOR(SIGNED(SIG_in0) * SIGNED(SIG_in1));
						
							currentState 		<= stateFinish;
						
						-------------------------------------------------------------
						
						-- MULTU
						WHEN "001011" 	=>
						
							SIG_outFlags	<= (OTHERS => '0');
						
							SIG_out0			<= STD_LOGIC_VECTOR(UNSIGNED(SIG_in0) * UNSIGNED(SIG_in1));
						
							currentState 		<= stateFinish;
						
						-------------------------------------------------------------
						
						-- SLT / SLTI
						WHEN "001100" 	=>
						
							SIG_outFlags	<= (OTHERS => '0');
						
							IF(SIGNED(SIG_in0) < SIGNED(SIG_in1)) THEN
								
								SIG_out0 <= (0 => '1', OTHERS => '0');
							
							ELSE
								
								SIG_out0 <= (OTHERS => '0');
							
							END IF;
							
							currentState <= stateFinish;
						
						-------------------------------------------------------------
						
						-- SLTIU / SLTU
						WHEN "001101" 	=>
						
							SIG_outFlags	<= (OTHERS => '0');
						
							IF(UNSIGNED(SIG_in0) < UNSIGNED(SIG_in1)) THEN
								
								SIG_out0 <= (0 => '1', OTHERS => '0');
							
							ELSE
								
								SIG_out0 <= (0 => '0', OTHERS => '0');
							
							END IF;
							
							currentState <= stateFinish;
						
						-------------------------------------------------------------
						
						-- SUB
						WHEN "001110" 	=>
						
							SIG_outFlags	<= (OTHERS => '0');
						
							a	:= SIG_in0(31) & SIG_in0;
							b	:= SIG_in1(31) & SIG_in1;
							
							c := a - b;
							
							IF ( SIG_out0(32) /= SIG_out0(31) ) THEN
							
								SIG_outFlags(4) <= '1';
							
							END IF;
							
							IF(c = x"00000000") THEN
							
								SIG_outFlags(2) <= '1';
								
							END IF;
						
							SIG_out0 	<=  vectorZero & c(31 DOWNTO 0);
					
							currentState	<= stateFinish;
						
						-------------------------------------------------------------
						
						-- SUBU
						WHEN "001111" 	=>
							
							SIG_outFlags	<= (OTHERS => '0');
							
							SIG_out0 		<= vectorZero & (SIG_in0 - SIG_in1);
							
							IF(SIG_out0 = x"0000000000000000") THEN
							
								SIG_outFlags(2) <= '1';
								
							END IF;
							
							currentState		<= stateFinish;
						
					-------------------------------------------------------------
					
					-- CPU Logical Instructions	
					
						-- AND / ANDI
						WHEN "010000" 	=>
					
							SIG_out0 <= vectorZero & (SIG_in0 AND SIG_in1);
							
							currentState <= stateFinish;
					
						-------------------------------------------------------------
					
						-- NOR
						WHEN "010001" 	=>
						
							SIG_out0 <= vectorZero & (SIG_in0 NOR SIG_in1);
							
							currentState <= stateFinish;
						
						-------------------------------------------------------------
						
						-- OR / ORI
						WHEN "010010" 	=>
							
							SIG_out0 <= vectorZero & (SIG_in0 OR SIG_in1);
							
							currentState <= stateFinish;
						
						-------------------------------------------------------------
						
						-- XOR / XORI
						WHEN "010011" 	=>
						
							SIG_out0 <= vectorZero & (SIG_in0 XOR SIG_in1);
							
							currentState <= stateFinish;
						
					-------------------------------------------------------------
					
					-- CPU Shift Instructions	
					
						-- SLL / SLLV
						WHEN "010100" 	=>
							
							temp := TO_INTEGER(UNSIGNED(SIG_in1(4 DOWNTO 0)));
							
							FOR I IN 0 TO 31 LOOP 
							
								IF I < temp THEN
								
								  SIG_out0(I) <= '0';
								  
								ELSE
								
								  SIG_out0(I) <= SIG_in0(I - temp);
								  
								END IF;
								
							 END LOOP;
							
							currentState	<= stateFinish;
							
						-------------------------------------------------------------
						
						-- SRA / SRAV
						WHEN "010101" 	=>
						
							--http://stackoverflow.com/questions/4174473/universal-shift-arithmetic-right-in-vhdl
						
							temp := TO_INTEGER(UNSIGNED(SIG_in1(4 DOWNTO 0)));
						
							FOR I IN 0 TO 31 LOOP
							
								IF I + temp < 32 THEN
								
								  SIG_out0(I) <= SIG_in0(I + temp);
								  
								ELSE
								
								  SIG_out0(I) <= SIG_in0(31);
								  
								END IF;
								
							 END LOOP;
						
							currentState	<= stateFinish;
						
						-------------------------------------------------------------
						
						-- SRL / SRLV
						WHEN "010110" 	=>
						
							--SIG_out0 <= vectorZero & STD_LOGIC_VECTOR( SHIFT_RIGHT( UNSIGNED(SIG_in0), TO_INTEGER( UNSIGNED(SIG_in1(4 DOWNTO 0)) ) ) );
							
							temp := TO_INTEGER(UNSIGNED(SIG_in1(4 DOWNTO 0)));
						
							FOR I IN 0 TO 31 LOOP
							
								IF I + temp < 32 THEN
								
								  SIG_out0(I) <= SIG_in0(I + temp);
								  
								ELSE
								
								  SIG_out0(I) <= '0';
								  
								END IF;
								
							 END LOOP;
						
							currentState	<= stateFinish;
							
							
						-- CMP
						WHEN "010111" 	=>
						
							IF SIG_in0 = SIG_in1 THEN
							
								SIG_out0 <= x"000000000000000" & "00" & "11";
							
							ELSIF SIG_in0 > SIG_in1 THEN
							
								SIG_out0 <= x"000000000000000" & "00" & "01";
							
							ELSIF SIG_in1 > SIG_in0 THEN
							
								SIG_out0 <= x"000000000000000" & "00" & "10";
							
							END IF;
							
							currentState	<= stateFinish;
							
						
						WHEN OTHERS		=>
						
							NULL;
				
				
					END CASE;
					
				
				-- Estado onde o resultado das operações realizadas no estado Execute são direcionados para os pinos externos da ALU.
				WHEN stateFinish		=>
		
					SIG_ready		<= '1';
					
					currentState 	<= stateIDLE;
		
				WHEN OTHERS	=>
				
					NULL;
		
			END CASE;
			-- Fim do processamento referente à decifragem.
		
		END IF;
		
	END PROCESS;
	
END RTL;