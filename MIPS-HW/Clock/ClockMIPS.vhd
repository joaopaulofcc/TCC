-- http://www.pcs.usp.br/~labdig/material/divfreq_gen.vhd
-- divfreq_gen.vhd
-- divisor de frequÃªncia em VHDL com generic
--   => fator de divisÃ£o deve ser maior que 1 (fator>1)
--   => se fator for impar, a saÃ­da nÃ£o serÃ¡ quadrada
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Importa arquivos com constantes e funções do autor
USE WORK.funcoes.ALL;

ENTITY ClockMIPS IS
	
	PORT
	(
		SIGNAL clockIN    : IN STD_LOGIC;
		SIGNAL clockOUT   : OUT STD_LOGIC
	);
	
END ClockMIPS;

ARCHITECTURE RTL OF ClockMIPS IS

	SIGNAL SIG_clockOUT : STD_LOGIC := '0';

BEGIN

	PROCESS(clockIN)
	
		VARIABLE contagem: NATURAL RANGE 0 TO fatorClock-1;
		
	BEGIN
		IF Rising_Edge(clockIN) THEN
		
			IF contagem = fatorClock/2-1 THEN
			
				SIG_clockOUT <= NOT(SIG_clockOUT);
				contagem := contagem+1;
				
			ELSIF contagem = fatorClock-1 THEN
			
				SIG_clockOUT <= NOT(SIG_clockOUT);
				contagem := 0;
				
			ELSE
			
				contagem := contagem+1;
				
			END IF;
			
		END IF;
		
	END PROCESS; 

	clockOUT <= SIG_clockOUT;

END RTL;