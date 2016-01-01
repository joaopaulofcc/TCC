-- Importa as bibliotecas de sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Importa as bibliotecas de usuário.
LIBRARY WORK;
USE WORK.funcoes.ALL;


-- Início da declaração da entidade somador32.
ENTITY somador32 IS

	PORT 
	(
		clock		: IN 	STD_LOGIC;	-- Sinal de relógio.
		dataIn0	: IN 	t_Word;		-- Primeiro operador.
		dataIn1	: IN 	t_Word;		--	Srimeiro operador.
		dataOut	: OUT t_Word		-- Dado resultante da soma dos dois operadores.
	);

END ENTITY;
-- Fim da declaração da entidade somador32.


-- Início da declaração da arquitetura da entidade somador32.
ARCHITECTURE RTL OF somador32 IS
BEGIN
	
	-- Process para soma dos dados de entrada.
	PROCESS(clock)
	BEGIN
	
		dataOut <= dataIn0 + dataIn1;
				
	END PROCESS;
		
END RTL;
-- Fim da declaração da arquitetura da entidade somador32.