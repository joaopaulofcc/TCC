-- Test Bench para ALU

-- Importa bibliotecas do sistema
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;


-- Importa as bibliotecas de usuário
LIBRARY WORK;
USE WORK.funcoes.ALL;

-- Início da declaração da entidade TestBench
ENTITY TestBench IS
END ENTITY TestBench;
-- Fim da declaração da entidade TestBench


-- Início da declaração da arquitetura da entidade TestBench
ARCHITECTURE sinais OF TestBench IS
	
	-- Sinais internos
	SIGNAL sig_clock 		: 	STD_LOGIC;
	SIGNAL sig_reset		:	STD_LOGIC;
	SIGNAL sig_opCode		: 	t_opCode;
	SIGNAL sig_in0			:	t_Word;
	SIGNAL sig_in1			:	t_Word;
	SIGNAL sig_out0		:	t_DWord;
	SIGNAL SIG_outFlags	:	t_Byte;
	SIGNAL sig_ready		:	STD_LOGIC;
  
  
   -- Importação do componente RAM já construido  
	COMPONENT ALU_MIPS32
	
		PORT 
		(
			clock			: IN 	STD_LOGIC;
			reset			: IN 	STD_LOGIC;
			opCode		: IN 	t_opCode;
			in0			: IN 	t_Word;
			in1			: IN 	t_Word;
			out0			: OUT t_DWord;
			outFlags		: OUT t_Byte;
			ready			: OUT STD_LOGIC
		);
		
	END COMPONENT;	
  

BEGIN

	-- Mapeamento de portas do componente ALU_MIPS32 com sinais do Test Bench
	UUT_ALU_MIPS32: ALU_MIPS32 PORT MAP                                          			    
	(
		clock		=> sig_clock,
		reset		=> sig_reset,
		opCode	=> sig_opCode,
		in0		=> sig_in0,
		in1		=> sig_in1,
		out0		=> sig_out0,
		outFlags	=> sig_outFlags,
		ready		=> sig_ready
	);
   
	
	-- Início do controle de clock	
	P_clockGen: PROCESS IS  
	BEGIN
		 	
		sig_clock <= '0';   -- Clock em nível baixo por 10 ns
		
		WAIT FOR 10 ns; 
		
		sig_clock <= '1';   -- Clock em nível alto por 10 ns
		
		WAIT FOR 10 ns;
		
	END PROCESS P_clockGen;
	-- Fim do controle de clock

	
	
	-- Início do Processo de Escrita (WRITE) e Leitura (READ) de dados presentes nmemória RAM.
	P_WriteRead: PROCESS IS                                               				 
	BEGIN
		
		sig_in0	<= x"0000F000";
		
		sig_in1	<= x"00000002";
		
		
		--ADD
		
			sig_opCode	<= "001011";
			
			-- Aguarda alteração do clock.
			WAIT UNTIL sig_clock'EVENT;
		
			sig_reset 	<= '1'; 
		
			-- Aguarda alteração do clock.
			WAIT UNTIL sig_clock'EVENT;
			
			sig_reset	<= '0';
			
			WAIT UNTIL sig_ready = '1';
			
			WAIT FOR 80 ns;
		
	END PROCESS P_WriteRead;
	-- Fim do Processo de Escrita (WRITE) e Leitura (READ) de dados presentes na memória RAM.
	
END ARCHITECTURE sinais;
-- Fim da declaração da arquitetura da entidade TestBench