-- Test Bench para Controle

-- Importa bibliotecas do sistema
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

-- Importa as bibliotecas de usuário
LIBRARY WORK;
USE WORK.funcoes.ALL;
USE STD.TEXTIO.ALL;

-- Início da declaração da entidade TestBench
ENTITY TestBench IS
END ENTITY TestBench;
-- Fim da declaração da entidade TestBench


-- Início da declaração da arquitetura da entidade TestBench
ARCHITECTURE sinais OF TestBench IS
	
	-- Sinais internos
	SIGNAL SIG_address	: 	t_AddressDATA;
	SIGNAL SIG_dataOUT	: 	t_Byte;
	SIGNAL SIG_dataIN		:	t_Byte;
	SIGNAL SIG_clockOUT	: 	STD_LOGIC;
	SIGNAL SIG_clockIN	: 	STD_LOGIC;
	SIGNAL SIG_opCode		: 	STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL SIG_ready		: 	STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL SIG_reset		:	STD_LOGIC;
  
  
	-- Início da declaração da entidade MIPS32_Control.
	COMPONENT MIPS32_Control

		PORT 
		(
			address			: IN t_AddressDATA;
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

	END COMPONENT;
	-- Fim da declaração da entidade MIPS32_Control.	
  
  
	-- function to convert string of character to vector
	FUNCTION str2vec(str : string) RETURN std_logic_vector IS
		VARIABLE vtmp: std_logic_vector(str'RANGE);
	BEGIN
	
		FOR i IN str'RANGE LOOP
		
			IF str(i) = '1' THEN
			
				vtmp(i) := '1';
				
			ELSIF str(i) = '0' THEN
			
				vtmp(i) := '0';
				
			ELSE
			
				vtmp(i) := 'X';
				
			END IF;
			
		END LOOP;
		
		RETURN vtmp;
		
	END str2vec;
	
	
	-- function to convert vector to string
	-- for use in assert statements
	FUNCTION vec2str(vec : std_logic_vector) RETURN string IS
		VARIABLE stmp : string(vec'LEFT+1 DOWNTO 1);
	BEGIN
	
		FOR i IN vec'REVERSE_RANGE LOOP
		
			IF vec(i) = '1' THEN
			
				stmp(i+1) := '1';
				
			ELSIF vec(i) = '0' THEN
			
				stmp(i+1) := '0';
				
			ELSE
			
				stmp(i+1) := 'X';
				
			END IF;
			
		END LOOP;
		
		RETURN stmp;
		
	END vec2str;
  

BEGIN

	-- Mapeamento de portas do componente MIPS32_Control com sinais do Test Bench
	UUT_MIPS32_Control: MIPS32_Control PORT MAP                                          			    
	(
		address			=> SIG_address,
		dataOUT			=> SIG_dataOUT,
		dataIN			=> SIG_dataIN,
		PIN_clockOut	=> SIG_clockOUT,
		PIN_clockIN		=> SIG_clockIN,
		opCode			=> SIG_opCode,
		ready				=> SIG_ready,
		reset				=> SIG_reset
	);	
	
	
	-- Início do controle de clock	
	P_clockGen: PROCESS IS  
	BEGIN
		 	
		SIG_clockIN <= '0';   -- Clock em nível baixo por 10 ns
		
		WAIT FOR 10 ns; 
		
		SIG_clockIN <= '1';   -- Clock em nível alto por 10 ns
		
		WAIT FOR 10 ns;
		
	END PROCESS P_clockGen;
	-- Fim do controle de clock
	
	
	
	P_LeREGS: PROCESS IS
		-- declare and open file (1987 style)
		FILE vector_file: text IS in "test.vec";
		VARIABLE file_line : line; -- text line buffer
		VARIABLE str_stimulus_in: string(32 DOWNTO 1);
		VARIABLE stimulus_in : std_logic_vector(31 DOWNTO 0);
		
		VARIABLE indexByteDataINF : INTEGER;
		VARIABLE indexByteDataSUP : INTEGER;
	BEGIN
		
		-- Lê os dados dos Registradores.
		
		FOR i IN 0 TO 31 LOOP
		
			SIG_opCode <= "011";
		
			SIG_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, SIG_dataIN'LENGTH));
		
			-- Aguarda primeira borda de subida do clock.
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);
				
			-- Reseta circuito.
			SIG_reset 		<= '1';
			
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);			 					

			SIG_reset 		<= '0';
			
			WAIT UNTIL SIG_ready = "00011";
			
			
			SIG_opCode <= "100";
		
			SIG_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, SIG_dataIN'LENGTH));
		
			-- Aguarda primeira borda de subida do clock.
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);
				
			-- Reseta circuito.
			SIG_reset 		<= '1';
			
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);			 					

			SIG_reset 		<= '0';
			
			WAIT UNTIL SIG_ready = "00100";
			
			
			SIG_opCode <= "101";
		
			SIG_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, SIG_dataIN'LENGTH));
		
			-- Aguarda primeira borda de subida do clock.
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);
				
			-- Reseta circuito.
			SIG_reset 		<= '1';
			
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);			 					

			SIG_reset 		<= '0';
			
			WAIT UNTIL SIG_ready = "00101";
			
			
			SIG_opCode <= "110";
		
			SIG_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, SIG_dataIN'LENGTH));
		
			-- Aguarda primeira borda de subida do clock.
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);
				
			-- Reseta circuito.
			SIG_reset 		<= '1';
			
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);			 					

			SIG_reset 		<= '0';
			
			WAIT UNTIL SIG_ready = "00110";
			
		END LOOP;
		
		
		-- Carrega as instruçoes a serem executadas, carregadas em um arquivo texto.
		
		-- read one complete line into file_line
		--readline(vector_file, file_line);
		-- extract the first field from file_line
		--read(file_line, str_stimulus_in);
		-- convert string to vector
		--stimulus_in := str2vec(str_stimulus_in);
		
			
		--indexByteDataINF := 0;
		--indexByteDataSUP := 7;
		--	
		--FOR i IN 0 TO 3 LOOP
		--
		--	SIG_opCode <= "001";
		--
		--	SIG_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, SIG_dataIN'LENGTH));
		--	
		--	SIG_dataIN <= stimulus_in(indexByteDataSUP DOWNTO indexByteDataINF);
		--	
		--	-- Aguarda primeira borda de subida do clock.
		--	WAIT UNTIL RISING_EDGE(SIG_clockOUT);
		--		
		--	-- Reseta circuito.
		--	SIG_reset 		<= '1';
		--	
		--	WAIT UNTIL RISING_EDGE(SIG_clockOUT);			 					
		--
		--	SIG_reset 		<= '0';
		--	
		--	WAIT UNTIL SIG_ready = "00001";
		--	
		--	indexByteDataINF := indexByteDataINF + 8;
		--	indexByteDataSUP := indexByteDataSUP + 8;
		--
		--END LOOP;
			
		
		-- Executa instruçoes carregadas na memória de instruçoes.
		
		SIG_opCode <= "111";
		
		-- Aguarda primeira borda de subida do clock.
		WAIT UNTIL RISING_EDGE(SIG_clockOUT);
			
		-- Reseta circuito.
		SIG_reset 		<= '1';
		
		WAIT UNTIL RISING_EDGE(SIG_clockOUT);			 					

		SIG_reset 		<= '0';
		
		WAIT UNTIL SIG_ready = "01110";
		
			
		-- Lê os dados dos Registradores.
		
		SIG_opCode <= "010";
		
		FOR i IN 2 TO 2 LOOP
		
			SIG_opCode <= "011";
		
			SIG_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, SIG_dataIN'LENGTH));
		
			-- Aguarda primeira borda de subida do clock.
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);
				
			-- Reseta circuito.
			SIG_reset 		<= '1';
			
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);			 					

			SIG_reset 		<= '0';
			
			WAIT UNTIL SIG_ready = "00011";
			
			
			SIG_opCode <= "100";
		
			SIG_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, SIG_dataIN'LENGTH));
		
			-- Aguarda primeira borda de subida do clock.
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);
				
			-- Reseta circuito.
			SIG_reset 		<= '1';
			
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);			 					

			SIG_reset 		<= '0';
			
			WAIT UNTIL SIG_ready = "00100";
			
			
			SIG_opCode <= "101";
		
			SIG_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, SIG_dataIN'LENGTH));
		
			-- Aguarda primeira borda de subida do clock.
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);
				
			-- Reseta circuito.
			SIG_reset 		<= '1';
			
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);			 					

			SIG_reset 		<= '0';
			
			WAIT UNTIL SIG_ready = "00101";
			
			
			SIG_opCode <= "110";
		
			SIG_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, SIG_dataIN'LENGTH));
		
			-- Aguarda primeira borda de subida do clock.
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);
				
			-- Reseta circuito.
			SIG_reset 		<= '1';
			
			WAIT UNTIL RISING_EDGE(SIG_clockOUT);			 					

			SIG_reset 		<= '0';
			
			WAIT UNTIL SIG_ready = "00110";
			
		END LOOP;
		
		WAIT FOR 1 sec;
			
	END PROCESS P_LeREGS;
	
	
	
END ARCHITECTURE sinais;
-- Fim da declaração da arquitetura da entidade TestBench