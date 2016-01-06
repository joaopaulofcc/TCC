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
 --# Arquivo: MIPS32_ALU.vhd		 														#
 --#                                                                      	#
 --# Sobre: Esse arquivo descreve a estrutura e comportamento da unidade	#
 --# 			lógica e aritmética a ser utilizada pelo MIPS.						#
 --#                                                                      	#
 --# 05/01/16 - Formiga - MG                                              	#
 --#########################################################################

 
--Importa Bibliotecas 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Importa arquivos com constantes e funções do autor
USE WORK.MIPS32_Funcoes.ALL;

-- Início das declarações da entidade MIPS32_ALU.
ENTITY MIPS32_ALU IS
	
	PORT 
	(
		clock			: IN 	STD_LOGIC;	-- Sinal de clock.
		reset			: IN 	STD_LOGIC;	-- Sinal de reset do circuito.
		opCode		: IN 	t_opCode;	-- Código da operação de ALU a ser executada.
		in0			: IN 	t_Word;		-- Primeiro operador (32 bits).
		in1			: IN 	t_Word;		-- Segundo operador  (32 bits).
		out0			: OUT t_DWord;		-- Resultado da operação (64 bits).
		outFlags		: OUT t_Byte;		-- Vetor de flags.
		ready			: OUT STD_LOGIC	-- (1) Ready | (0) - Busy.
	);
	
END MIPS32_ALU;
-- Fim da declaração da entidade MIPS32_ALU.


-- Início da declaração da arquitetura da entidade MIPS32_ALU.
ARCHITECTURE BEHAVIOR OF MIPS32_ALU IS

	-- Márquina de estados da ALU.
	
		-- stateReset		: estado onde o circuito é resetado e seus pinos de saída preenchidos com valor '0'.
		-- stateIDLE		: estado IDLE onde o circuito não realiza nenhuma operação.
		-- stateLoad		: estado de carregamento dos sinais externos para os pinos internos do circuito.
		-- stateExecute	: estado onde a operação lógica ou aritmética será executada de acordo com o valor do pino de opCode.
		-- stateFinish		: estado em que os resultados das operações calculadas no estado Execute são direcionados aos pinos de saída da ALU.
		
	TYPE aluState IS (stateReset, stateIDLE, stateLoad, stateExecute, stateFinish);
	SIGNAL nextState	: aluState := stateIDLE; -- Define o estado inicial da máquina como sendo o "stateIDLE".
	
	-- Sinais para conexão com barramentos externos do circuito, evitando assim que flutuaçoes na entrada propaguem no circuito.
	SIGNAL SIG_opCode		: t_opCode;
	SIGNAL SIG_in0			: t_Word;
	SIGNAL SIG_in1			: t_Word;
	SIGNAL SIG_out0		: t_DWord;
	SIGNAL SIG_outFlags	: t_Byte;
	SIGNAL SIG_ready		: STD_LOGIC;
	
	-- Vetor de Word totalmente preenchido com '0's utilizado em determinados cálculos na ALU.
	CONSTANT vectorZero	:	t_Word := x"00000000";
	
BEGIN

	-- Direciona os sinais dos barramentos externos para os respectivos sinais internos.
	SIG_opCode 	<= opCode;
	SIG_in0		<= in0;
	SIG_in1		<= in1;
	out0 			<= SIG_out0;
	outFlags		<= SIG_outFlags;
	ready			<= SIG_ready;


	-- Process de controle de toda a FSM do circuito.
	-- Esse process é ativado com alteraçao de valores nos sinais: "clock" e "reset".
	PROCESS(clock, reset) 
		VARIABLE a				:	STD_LOGIC_VECTOR(32 DOWNTO 0);	-- Armazena o valor de SIG_in0 com 33 bits - '0' + SIG_in0.
		VARIABLE b				:	STD_LOGIC_VECTOR(32 DOWNTO 0);	-- Armazena o valor de SIG_in1 com 33 bits - '0' + SIG_in1.
		VARIABLE c				:	STD_LOGIC_VECTOR(32 DOWNTO 0);	-- Aramzena o resultado de operaçoes envolvendo as variáveis a e b.
		VARIABLE temp			: 	INTEGER;									-- Utilizado para manter contadores em laços de repetiçao.
		
	BEGIN
		
		-- Reset do circuito.
		IF (reset = '1') THEN
			
			-- Solicita mudança para estado de IDLE do circuito, utilizado para inicialização.
			nextState 	<= stateReset;
			
			
		-- Caso o sinal de reset não esteja ativo (alto) e seja borda de subida do clock, executa os comandos da FSM.
		ELSIF (RISING_EDGE(clock)) THEN
		
			-- Filtra de acordo com o estado atual.
			CASE nextState IS
			
				-- Estado IDLE, não realiza nenhuma operação,
				-- para mudar de estado deve resetar o circuito.
				WHEN stateIDLE 		=>
				
					-- Sinaliza que nenhuma operaçao foi concluida.
					SIG_ready		<= '0';
				
					-- Encaminha a FSM para o mesmo estado atual.
					nextState <= stateIDLE;
				
				
				-- %%
			
				
				-- Estado de reset do circuito.
				WHEN stateReset 		=>
					
					-- Zera sinais de resultado(SIG_out0)
					-- e vetor de flags (SIG_outFlags).
					SIG_out0			<= (OTHERS => '0');
					SIG_outFlags	<= (OTHERS => '0');
					
					-- Circuito está ocupado.
					SIG_ready		<= '0';
		
					-- Direciona a FSM para o estado de execuçao de instruçoes.
					nextState	<= stateExecute;
				
				
				-- %%
			
				
				-- Estado de execução das operações determinadas pelo
				-- valor presente em opCode.
				WHEN stateExecute		=>
				
					-- Filtra qual operação deverá ser executada de acordo
					-- com o valor do barramento opCode.
					CASE SIG_opCode IS
					
					-- CPU Arithmetic Instructions
					
						-- ADD | ADDI
						WHEN "000000" 	=>
						
							a	:= SIG_in0(31) & SIG_in0;
							b	:= SIG_in1(31) & SIG_in1;
							
							c := a + b;
							
							-- Seta flag de overflow.
							IF ( c(32) /= c(31) ) THEN
							
								SIG_outFlags(4) <= '1';
							
							END IF;
							
							-- Seta flag de zero.
							IF(c = x"00000000") THEN
							
								SIG_outFlags(2) <= '1';
								
							END IF;
						
							SIG_out0		<=  vectorZero & c(31 DOWNTO 0);
					
							-- Direciona a FSM para o estado de finalizaçao.
							nextState	<= stateFinish;
						
						-------------------------------------------------------------
						
						-- ADDU |ADDIU
						WHEN "000001" 	=>
						
							SIG_out0 		<= vectorZero & (SIG_in0 + SIG_in1);
														
							IF(SIG_out0 = x"0000000000000000") THEN
							
								SIG_outFlags(2) <= '1';
								
							END IF;
							
							-- Direciona a FSM para o estado de finalizaçao.
							nextState	<= stateFinish;
						
						-------------------------------------------------------------
						
						-- CLO
						WHEN "000010" 	=>
						
							temp := 32;
								
							loopCLO: FOR i IN 31 DOWNTO 0 LOOP
							
											IF (SIG_in0(i) = '0') THEN
												
												temp := 31 - i;
												
												EXIT loopCLO;
												
											END IF;
											
										END LOOP;
										
							SIG_out0	<= STD_LOGIC_VECTOR(TO_UNSIGNED(temp, SIG_out0'LENGTH));
							
							-- Direciona a FSM para o estado de finalizaçao.
							nextState <= stateFinish;
							
						-------------------------------------------------------------
						
						-- CLZ
						WHEN "000011" 	=>
							
							temp := 32;
								
							loopCLZ: FOR i IN 31 DOWNTO 0 LOOP
							
											IF (SIG_in0(i) = '1') THEN
												
												temp := 31 - i;
												
												EXIT loopCLZ;
												
											END IF;
											
										END LOOP;
										
							SIG_out0	<= STD_LOGIC_VECTOR(TO_UNSIGNED(temp, SIG_out0'LENGTH));
							
							-- Direciona a FSM para o estado de finalizaçao.
							nextState <= stateFinish;
						
						-------------------------------------------------------------
						
						-- DIV
						WHEN "000100" 	=>
			
							SIG_out0(63 DOWNTO 32)	<= STD_LOGIC_VECTOR(SIGNED(SIG_in0) MOD SIGNED(SIG_in1));
							SIG_out0(31 DOWNTO 0)	<= STD_LOGIC_VECTOR(SIGNED(SIG_in0) / SIGNED(SIG_in1));
						
							-- Direciona a FSM para o estado de finalizaçao.
							nextState <= stateFinish;
						
						-------------------------------------------------------------
						
						-- DIVU
						WHEN "000101" 	=>
						
							SIG_out0(63 DOWNTO 32)	<= STD_LOGIC_VECTOR(UNSIGNED(SIG_in0) MOD UNSIGNED(SIG_in1));
							SIG_out0(31 DOWNTO 0)	<= STD_LOGIC_VECTOR(UNSIGNED(SIG_in0) / UNSIGNED(SIG_in1));
						
							-- Direciona a FSM para o estado de finalizaçao.
							nextState <= stateFinish;
					
						--------------------------------------------------------------------
						
						-- MUL / MULT
						WHEN "001010" 	=>
						
							SIG_out0			<= STD_LOGIC_VECTOR(SIGNED(SIG_in0) * SIGNED(SIG_in1));
						
							-- Direciona a FSM para o estado de finalizaçao.
							nextState 		<= stateFinish;
						
						-------------------------------------------------------------
						
						-- MULTU
						WHEN "001011" 	=>
						
							SIG_out0			<= STD_LOGIC_VECTOR(UNSIGNED(SIG_in0) * UNSIGNED(SIG_in1));
						
							-- Direciona a FSM para o estado de finalizaçao.
							nextState 		<= stateFinish;
						
						-------------------------------------------------------------
						
						-- SLT / SLTI
						WHEN "001100" 	=>
						
							IF(SIGNED(SIG_in0) < SIGNED(SIG_in1)) THEN
								
								SIG_out0 <= (0 => '1', OTHERS => '0');
							
							ELSE
								
								SIG_out0 <= (OTHERS => '0');
							
							END IF;
							
							-- Direciona a FSM para o estado de finalizaçao.
							nextState <= stateFinish;
						
						-------------------------------------------------------------
						
						-- SLTIU / SLTU
						WHEN "001101" 	=>
						
							IF(UNSIGNED(SIG_in0) < UNSIGNED(SIG_in1)) THEN
								
								SIG_out0 <= (0 => '1', OTHERS => '0');
							
							ELSE
								
								SIG_out0 <= (0 => '0', OTHERS => '0');
							
							END IF;
							
							-- Direciona a FSM para o estado de finalizaçao.
							nextState <= stateFinish;
						
						-------------------------------------------------------------
						
						-- SUB
						WHEN "001110" 	=>
						
							a	:= SIG_in0(31) & SIG_in0;
							b	:= SIG_in1(31) & SIG_in1;
							
							c := a - b;
							
							-- Seta flag de overflow.
							IF ( SIG_out0(32) /= SIG_out0(31) ) THEN
							
								SIG_outFlags(4) <= '1';
							
							END IF;
							
							-- Seta flag de zero.
							IF(c = x"00000000") THEN
							
								SIG_outFlags(2) <= '1';
								
							END IF;
						
							SIG_out0 	<=  vectorZero & c(31 DOWNTO 0);
					
							-- Direciona a FSM para o estado de finalizaçao.
							nextState	<= stateFinish;
						
						-------------------------------------------------------------
						
						-- SUBU
						WHEN "001111" 	=>
							
							SIG_out0 		<= vectorZero & (SIG_in0 - SIG_in1);
							
							-- Seta flag de zero.
							IF(SIG_out0 = x"0000000000000000") THEN
							
								SIG_outFlags(2) <= '1';
								
							END IF;
							
							nextState		<= stateFinish;
						
					--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
					
					-- CPU Logical Instructions	
					
						-- AND / ANDI
						WHEN "010000" 	=>
					
							SIG_out0 <= vectorZero & (SIG_in0 AND SIG_in1);
							
							-- Direciona a FSM para o estado de finalizaçao.
							nextState <= stateFinish;
					
						-------------------------------------------------------------
					
						-- NOR
						WHEN "010001" 	=>
						
							SIG_out0 <= vectorZero & (SIG_in0 NOR SIG_in1);
							
							-- Direciona a FSM para o estado de finalizaçao.
							nextState <= stateFinish;
						
						-------------------------------------------------------------
						
						-- OR / ORI
						WHEN "010010" 	=>
							
							SIG_out0 <= vectorZero & (SIG_in0 OR SIG_in1);
							
							-- Direciona a FSM para o estado de finalizaçao.
							nextState <= stateFinish;
						
						-------------------------------------------------------------
						
						-- XOR / XORI
						WHEN "010011" 	=>
						
							SIG_out0 <= vectorZero & (SIG_in0 XOR SIG_in1);
							
							-- Direciona a FSM para o estado de finalizaçao.
							nextState <= stateFinish;
						
					--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
					
					-- CPU Shift Instructions	
					
						-- Todas as instruções desse bloco foram tiveram suas implementaçoes adaptadas de:
						-- <http://stackoverflow.com/questions/4174473/universal-shift-arithmetic-right-in-vhdl>
					
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
							
							-- Direciona a FSM para o estado de finalizaçao.
							nextState	<= stateFinish;
							
						-------------------------------------------------------------
						
						-- SRA / SRAV
						WHEN "010101" 	=>
						
							temp := TO_INTEGER(UNSIGNED(SIG_in1(4 DOWNTO 0)));
						
							FOR I IN 0 TO 31 LOOP
							
								IF I + temp < 32 THEN
								
								  SIG_out0(I) <= SIG_in0(I + temp);
								  
								ELSE
								
								  SIG_out0(I) <= SIG_in0(31);
								  
								END IF;
								
							 END LOOP;
						
							-- Direciona a FSM para o estado de finalizaçao.
							nextState	<= stateFinish;
						
						-------------------------------------------------------------
						
						-- SRL / SRLV
						WHEN "010110" 	=>
							
							temp := TO_INTEGER(UNSIGNED(SIG_in1(4 DOWNTO 0)));
						
							FOR I IN 0 TO 31 LOOP
							
								IF I + temp < 32 THEN
								
								  SIG_out0(I) <= SIG_in0(I + temp);
								  
								ELSE
								
								  SIG_out0(I) <= '0';
								  
								END IF;
								
							 END LOOP;
						
							-- Direciona a FSM para o estado de finalizaçao.
							nextState	<= stateFinish;
							
						
						-- Estados inválidos
						WHEN OTHERS		=>
						
							NULL;
				
				
					END CASE;
					
				
				-- %%
			
				
				-- Estado onde o resultado das operações realizadas no estado Execute são direcionados para os pinos externos da ALU.
				WHEN stateFinish		=>
		
					-- Sinaliza que a operaçao requerida foi finalizada.
					SIG_ready		<= '1';
					
					-- Encaminha a FSM para o estado IDLE.
					nextState 	<= stateIDLE;
		
				-- Estados inválidos.
				WHEN OTHERS	=>
				
					NULL;
		
			END CASE;
		
		END IF;
		
	END PROCESS;
	
END BEHAVIOR;
-- Fim da declaração da arquitetura da entidade MIPS32_ALU.