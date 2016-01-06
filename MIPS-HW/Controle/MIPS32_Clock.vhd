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
 --# Arquivo: MIPS32_Clock.vhd	 														#
 --#                                                                      	#
 --# Sobre: Esse arquivo descreve a estrutura e comportamento da unidade 	#
 --# 			divisora	de frequencia para o sinal de clock de entrada do FPGA#
 --#                                                                      	#
 --# Retirado de:																				#
 --#                                                                      	#
 --# 			<http://www.pcs.usp.br/~labdig/material/divfreq_gen.vhd>       #
 --#                                                                      	#
 --# Observaçoes:                                                        	#
 --#                                                                      	#
 --#   		* Fator de divisao deve ser maior que 1 (fator > 1),				#
 --#   		  se fator for impar, a saida nao sera quadrada.           		#
 --#                                                                      	#
 --# 05/01/16 - Formiga - MG                                              	#
 --#########################################################################

 
 -- Importa as bibliotecas de sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Importa as bibliotecas de usuário.
USE WORK.MIPS32_Funcoes.ALL;

-- Início da declaração da entidade MIPS32_Clock.
ENTITY MIPS32_Clock IS
	
	PORT
	(
		SIGNAL clockIN    : IN STD_LOGIC;	-- Sinal de clock de entrada.
		SIGNAL clockOUT   : OUT STD_LOGIC	-- Sinal de clock de saída, i.e. pós processamento.
	);
	
END MIPS32_Clock;
-- Fim da declaração da entidade MIPS32_Clock.


-- Início da declaração da arquitetura da entidade MIPS32_Clock.
ARCHITECTURE BEHAVIOR OF MIPS32_Clock IS

	-- Sinal para conexão com barramento externos do circuito, evitando assim que flutuaçoes na entrada propaguem no circuito.
	SIGNAL SIG_clockOUT : STD_LOGIC := '0';

BEGIN

	-- Direciona os sinal do barramento externo para os respectivo sinal interno.
	clockOUT <= SIG_clockOUT;

	-- Process que permite que o circuito seja síncrono, é ativado por alteraçao de valores no sinal "clockIN", vindo do pino externo da FPGA.
	PROCESS(clockIN)
	
		VARIABLE contagem: NATURAL RANGE 0 TO fatorClock-1; --
		
	BEGIN
	
		-- Caso seja borda de subida do sinal "clockIN". Realiza a contagem, incrementando o contador até
		-- atingir o valor especificado em "fatorClock", aí então gera um pulso de clock para a saída.
		IF RISING_EDGE(clockIN) THEN
		
			IF contagem = fatorClock / 2 - 1 THEN
			
				SIG_clockOUT <= NOT(SIG_clockOUT);
				contagem := contagem+1;
				
			ELSIF contagem = fatorClock - 1 THEN
			
				SIG_clockOUT <= NOT(SIG_clockOUT);
				contagem := 0;
				
			ELSE
			
				contagem := contagem+1;
				
			END IF;
			
		END IF;
		
	END PROCESS; 

END BEHAVIOR;
-- Fim da declaração da arquitetura da entidade MIPS32_Clock.