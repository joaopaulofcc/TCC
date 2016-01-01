-- Test Bench para RAM

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
	SIGNAL sig_we			: 	STD_LOGIC;
	SIGNAL sig_address	:	t_Address;
	SIGNAL sig_dataIn		:	t_Word;
	SIGNAL sig_dataOut	:	t_Word;
	SIGNAL sig_ready		:	STD_LOGIC;
  
  
   -- Importação do componente RAM já construido  
	COMPONENT RAM
		PORT 
		(
			clock		: IN 	STD_LOGIC;			-- Sinal de relógio.
			reset		: IN 	STD_LOGIC;			-- Sinal de reset.
			we			: IN 	STD_LOGIC := '1';	--	Sinal de Write Enable (1 - Habilitado | 0 - Desabilitado).
			address	: IN 	t_Address;			-- Endereço da posição de memória a ser Lida/Escrita.
			dataIn	: IN 	t_Word;				-- Dado a ser escrito na RAM.
			dataOut	: OUT t_Word;				-- Dado lido da RAM.
			ready		: OUT STD_LOGIC			-- Sinal de Write Enable (1 - Pronto | 0 - Ocupado).
		);
	END COMPONENT;	
  

BEGIN

	-- Mapeamento de portas do componente RAM com sinais do Test Bench
	UUT_RAM: RAM PORT MAP                                          			    
	(
		clock		=> sig_clock,
		reset		=> sig_reset,
		we			=> sig_we,
		address	=> sig_address,
		dataIn	=> sig_dataIn,
		dataOut	=> sig_dataOut,
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
		
		-- Aguarda primeira borda de subida do clock.
		WAIT UNTIL RISING_EDGE(sig_clock);
	
		-- Ativa o sinal Write Enabled.
		sig_we 			<= '1'; 
	
		-- Zera sinal de endereço.
		sig_address		<= STD_LOGIC_VECTOR(TO_UNSIGNED(0, sig_address'LENGTH));
			
		-- Seta o sinal de dado a ser inserido com o valor máximo.
		sig_dataIn  	<= (OTHERS => '1');
	
		-- Salva dados em 8 posições de memória.
		WHILE UNSIGNED(sig_address) /= 32 LOOP	
		
			-- Aguarda borda de subida do clock.
			WAIT UNTIL RISING_EDGE(sig_clock);
			
			-- Reseta circuito.
			sig_reset 		<= '1';
			
			WAIT UNTIL RISING_EDGE(sig_clock);			 					

			sig_reset 		<= '0';
			
			-- Aguarda até o dado presente em "sig_dataIn" ser escrito na memória.
			WAIT UNTIL sig_ready = '1';
			
			-- Aguarda por 80 ns até salvar o próximo dado.
			WAIT FOR 80 ns;
			
			-- Altera o valor do sinal de endereço para o próximo endereço na memória.
			sig_address		<= STD_LOGIC_VECTOR(UNSIGNED(sig_address) + 4);
			
			-- Altera o valor a ser salvo no próximo ciclo.
			sig_dataIn  	<= STD_LOGIC_VECTOR(UNSIGNED(sig_dataIn) - 100000);
		
		END LOOP;
		
		
		-- Aguarda primeira borda de subida do clock.
		WAIT UNTIL RISING_EDGE(sig_clock);
		
		-- Desativa o sinal Write Enabled, ou seja irá ler dados da memória.
		sig_we 			<= '0'; 
	
		-- Zera sinal de endereço.
		sig_address		<= STD_LOGIC_VECTOR(TO_UNSIGNED(0, sig_address'LENGTH));
			
		-- Lê dados em 8 posições de memória.
		WHILE UNSIGNED(sig_address) /= 32 LOOP	
		
			-- Aguarda primeira borda de subida do clock.
			WAIT UNTIL RISING_EDGE(sig_clock);
			
			-- Reseta circuito.
			sig_reset 		<= '1';
			
			WAIT UNTIL RISING_EDGE(sig_clock);			 					

			sig_reset <= '0';
			
			-- Aguarda a té o dado presente em "sig_dataIn" ser lido da memória.
			WAIT UNTIL sig_ready = '1';
			
			-- Aguarda por 80 ns até ler o próximo dado.
			WAIT FOR 80 ns;
		
			-- Altera o valor do sinal de endereço para o próximo endereço na memória.
			sig_address		<= STD_LOGIC_VECTOR(UNSIGNED(sig_address) + 4);
			
		END LOOP;
		
	END PROCESS P_WriteRead;
	-- Fim do Processo de Escrita (WRITE) e Leitura (READ) de dados presentes na memória RAM.
	
END ARCHITECTURE sinais;
-- Fim da declaração da arquitetura da entidade TestBench