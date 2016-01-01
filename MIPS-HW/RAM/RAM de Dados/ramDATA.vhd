 -- Importa as bibliotecas de sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Importa as bibliotecas de usuário.
LIBRARY WORK;
USE WORK.funcoes.ALL;


-- Início da declaração da entidade RAM.
ENTITY ramDATA IS

	PORT 
	(
		clock		: IN 	STD_LOGIC;			-- Sinal de relógio.
		we			: IN 	STD_LOGIC := '1';	--	Sinal de Write Enable (1 - Habilitado | 0 - Desabilitado), default = habilitado.
		address	: IN 	t_AddressDATA;		-- Endereço da posição de memória a ser Escrita/Lida.
		dataIn	: IN 	t_Byte;				-- Dado a ser escrito na RAM.
		dataOut	: OUT t_Byte				-- Dado lido da RAM.
	);

END ENTITY;
-- Fim da declaração da entidade RAM.


-- Início da declaração da arquitetura da entidade RAM.
ARCHITECTURE RTL OF ramDATA IS

	-- Função utiliza para inicializar a memória ROM, para isso escreve em
	-- seus endereços o próprio valor do endereço.
	FUNCTION init_ram
	RETURN t_RAM_DATA IS
		VARIABLE tmp : t_RAM_DATA := (OTHERS => (OTHERS => '0'));
	BEGIN 
	
		FOR addr_pos IN 0 TO 2 ** ADDRESS_DATA_WIDTH - 1 LOOP
		
			tmp(addr_pos) := STD_LOGIC_VECTOR(TO_UNSIGNED(addr_pos, DATA_WIDTH));
			
		END LOOP;
		
		RETURN tmp;
		
	END init_ram;

	-- Vetor de dados do tipo t_Ram.
	SIGNAL ram : t_RAM_DATA := init_ram;
		
	--SIGNAL addr_reg : t_addressDATA;
		
BEGIN
	
	process(clock)
	begin
	
		if(rising_edge(clock)) then
		
			if(we = '0') then
			
				ram(TO_INTEGER(UNSIGNED(address))) <= dataIn;
				
			end if;
			
			--addr_reg <= address;
			
		end if;	
		
	end process;
	
	dataOut <= ram(TO_INTEGER(UNSIGNED(address)));
			
END RTL;
-- Fim da declaração da arquitetura da entidade RAM.