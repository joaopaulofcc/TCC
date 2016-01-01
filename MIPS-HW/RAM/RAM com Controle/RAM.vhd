 -- Importa as bibliotecas de sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Importa as bibliotecas de usuário.
LIBRARY WORK;
USE WORK.funcoes.ALL;


-- Início da declaração da entidade RAM.
ENTITY RAM IS

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

END ENTITY;
-- Fim da declaração da entidade RAM.


-- Início da declaração da arquitetura da entidade RAM.
ARCHITECTURE RTL OF RAM IS

	-- Máquina de estado para escita e leitura de dados na memória RAM.
		
		-- stateReset	: Estado referente ao reset do circuito.
		-- stateLoad	: Estado para carregamento de sinais.
		-- stateIDLE	: Estado que não realiza nehuma operação.
		-- stateFinish	: Estado onde o processamento foi concluido.
		-- stateWrite1	: Estado para escrita do primeiro byte.
		-- stateWrite2	: Estado para escrita do segundo byte.
		-- stateWrite3	: Estado para escrita do terceiro byte.
		-- stateWrite4	: Estado para escrita do quarto byte.
		-- stateRead1	: Estado para leitura do primeiro byte.
		-- stateRead2	: Estado para leitura do segundo byte.
		-- stateRead3	: Estado para leitura do terceiro byte.
		-- stateRead4	: Estado para leitura do quarto byte.
		
	TYPE ramState IS (stateReset, stateLoad, stateIDLE, stateFinish, stateWrite1, stateWrite2, stateWrite3, stateWrite4, stateRead1, stateRead2, stateRead3, stateRead4);
	SIGNAL currentState	: ramState := stateIDLE;
	SIGNAL nextState		: ramState := stateIDLE;

	-- Vetor de dados do tipo t_Ram.
	SIGNAL ram : t_RAM;
	
	-- Sinais para utilização interna do componente.
	SIGNAL sig_address	: t_Address;
	SIGNAL sig_dataIn		: t_Word;
	SIGNAL sig_dataOut	: t_Word;
	
	
BEGIN
	
	
	-- Process de controle de reset e de currentState.
	PROCESS(clock, reset) 
	BEGIN
		
		-- Reset do circuito.
		IF (reset = '1') THEN
			
			-- Direciona a máquina para o estado de reset.
			currentState	<= stateReset;
				
		-- Caso reset = 0 e clock = 1.
		ELSIF (RISING_EDGE(clock)) THEN
		
			-- Atualiza o estado atual da máquina de estados.
			currentState 	<= nextState;
			
		END IF;
			
	END PROCESS;
	
	
	
	-- Process para controle de operações da máquina de estado.
	PROCESS(currentState)
	BEGIN
	
		-- Verifica o estado atual da FSM.
		CASE currentState IS
		
			-- Estado de reset do circuito.
			WHEN stateReset =>
				
				-- Coloca um sinal de alta impedância no pino de saida.
				dataOut			<= (OTHERS => 'Z');
				
				-- Sinaliza que a máquina está ocupada.
				ready				<= '0';
				
				-- altera o estado da máquina para "inicializa".
				nextState 		<= stateLoad;
			
			
			
			-- Estado de carregamento dos valores presentes no pino de entrada,
			-- evita que flutuações nesse interfira no comportamento e resultado do componente.
			-- Estado é responsável também por encaminhar a FMS para estado de escrita ou leitura.
			WHEN stateLoad =>
			
				-- Carrega sinais.
				sig_address	<= address;
				sig_dataIn	<= dataIn;
			
				-- De acordo com o valor do pino "we" encaminha para o estado de escrita ou leitura na FSM.
				IF(we = '1') THEN
				
					-- altera o estado da máquina para "stateWrite1".
					nextState	<= stateWrite1;
				
				ELSIF (we = '0') THEN
				
					-- altera o estado da máquina para "stateRead1".
					nextState	<= stateRead1;
				
				END IF;
				
			
			
			-- Estado em que a máquina não realiza nenhuma operação.
			WHEN stateIDLE	=>	
			
			
			
			-- Estado onde o processo de escrita ou leitura foi concluído.
			WHEN stateFinish =>
				
				IF(we = '0') THEN
					
					dataOut <= sig_dataOut;					
				
				END IF;
				
				ready	<= '1';
			
			
			
			-- Estado que realiza a escrita do primeiro byte na endereço 1 de 4.
			WHEN stateWrite1 =>
			
				-- Salva os dados.
				ram(TO_INTEGER(UNSIGNED(sig_address))) <= dataIn(7 DOWNTO 0);
				
				-- Incrementa em uma posição o endereço.
				sig_address <= STD_LOGIC_VECTOR(UNSIGNED(sig_address) + 1);
				
				-- altera o estado da máquina para "stateWrite2".
				nextState <= stateWrite2;
				
			
			
			-- Estado que realiza a escrita do segundo byte na endereço 2 de 4.
			WHEN stateWrite2 =>
			
				-- Salva os dados.
				ram(TO_INTEGER(UNSIGNED(sig_address))) <= dataIn(15 DOWNTO 8);
				
				-- Incrementa em uma posição o endereço.
				sig_address <= STD_LOGIC_VECTOR(UNSIGNED(sig_address) + 1);
				
				-- altera o estado da máquina para "stateWrite3".
				nextState <= stateWrite3;
				
			
			
			-- Estado que realiza a escrita do terceiro byte na endereço 3 de 4.
			WHEN stateWrite3 =>
			
				-- Salva os dados.
				ram(TO_INTEGER(UNSIGNED(sig_address))) <= dataIn(23 DOWNTO 16);
				
				-- Incrementa em uma posição o endereço.
				sig_address <= STD_LOGIC_VECTOR(UNSIGNED(sig_address) + 1);
				
				-- altera o estado da máquina para "stateWrite4".
				nextState <= stateWrite4;
			
		
			
			-- Estado que realiza a escrita do quarto byte na endereço 4 de 4.
			WHEN stateWrite4 =>

				-- Salva os dados.
				ram(TO_INTEGER(UNSIGNED(sig_address))) <= dataIn(31 DOWNTO 24);
				
				-- altera o estado da máquina para "stateFinish".
				nextState <= stateFinish;
				
				
			
			-- Estado que realiza a leitura do primeiro byte na endereço 1 de 4.
			WHEN stateRead1 =>
			
				-- Lê os dados.
				sig_dataOut(7 DOWNTO 0) <= ram(TO_INTEGER(UNSIGNED(sig_address)));
				
				-- Incrementa em uma posição o endereço.
				sig_address <= STD_LOGIC_VECTOR(UNSIGNED(sig_address) + 1);
				
				-- altera o estado da máquina para "stateRead2".
				nextState	<= stateRead2;
			
	
	
			-- Estado que realiza a leitura do segundo byte na endereço 2 de 4.
			WHEN stateRead2 =>
			
				-- Lê os dados.
				sig_dataOut(15 DOWNTO 8) <= ram(TO_INTEGER(UNSIGNED(sig_address)));
				
				-- Incrementa em uma posição o endereço.
				sig_address <= STD_LOGIC_VECTOR(UNSIGNED(sig_address) + 1);
				
				-- altera o estado da máquina para "stateRead3".
				nextState	<= stateRead3;
			
		
		
			-- Estado que realiza a leitura do terceiro byte na endereço 3 de 4.
			WHEN stateRead3 =>
			
				-- Lê os dados.
				sig_dataOut(23 DOWNTO 16) <= ram(TO_INTEGER(UNSIGNED(sig_address)));
				
				-- Incrementa em uma posição o endereço.
				sig_address <= STD_LOGIC_VECTOR(UNSIGNED(sig_address) + 1);
				
				-- altera o estado da máquina para "stateRead4".
				nextState	<= stateRead4;
				

				
			-- Estado que realiza a leitura do quarto byte na endereço 4 de 4.
			WHEN stateRead4 =>
			
				-- Incrementa em uma posição o endereço.
				sig_dataOut(31 DOWNTO 24) <= ram(TO_INTEGER(UNSIGNED(sig_address)));
				
				-- altera o estado da máquina para "stateFinish".
				nextState	<= stateFinish;

				
			
			-- Estado Inválido.
			WHEN OTHERS =>
			
		
		END CASE;
		
	END PROCESS;
		
END RTL;
-- Fim da declaração da arquitetura da entidade RAM.