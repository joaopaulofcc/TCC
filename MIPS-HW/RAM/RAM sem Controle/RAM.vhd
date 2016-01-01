 -- Importa as bibliotecas de sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Importa as bibliotecas de usuário.
LIBRARY WORK;
USE WORK.funcoes.ALL;


-- Início da declaração da entidade RAM.
ENTITY RAM IS

	PORT 
	(
		clock		: IN 	STD_LOGIC;			-- Sinal de relógio.
		we			: IN 	STD_LOGIC := '1';	--	Sinal de Write Enable (1 - Habilitado | 0 - Desabilitado), default = habilitado.
		address	: IN 	t_Address;			-- Endereço da posição de memória a ser Lida/Escrita.
		dataIn	: IN 	t_Byte;				-- Dado a ser escrito na RAM.
		dataOut	: OUT t_Byte				-- Dado lido da RAM.
	);

END ENTITY;
-- Fim da declaração da entidade RAM.


-- Início da declaração da arquitetura da entidade RAM.
ARCHITECTURE RTL OF RAM IS

	-- Vetor de dados do tipo t_Ram.
	SIGNAL ram : t_RAM;
	
	-- Sinais para utilização interna do componente.
	SIGNAL sig_address	: t_Address;
	
BEGIN
	
	-- Process para controle de escrita e leitura na RAM.
	PROCESS(clock)
	BEGIN
	
		-- Ativado em borda de subida do clock.
		IF(RISING_EDGE(clock)) THEN
		
			-- Escrita de dados.
			IF(we = '1') THEN
			
				ram(TO_INTEGER(UNSIGNED(address))) <= dataIn;
				
			END IF;

			-- Armazena o endereço no sinal correspondente
			sig_address <= address;
			
		END IF;
	
	END PROCESS;
	
	-- Sempre retorna o valor contido no endereço especificado, ou seja,
	-- sempre ocorrerá a operação de leitura.
	dataOut <= ram(TO_INTEGER(UNSIGNED(sig_address)));
		
END RTL;
-- Fim da declaração da arquitetura da entidade RAM.