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
 --# Arquivo: MIPS32_7Seg.vhd		 														#
 --#                                                                      	#
 --# Sobre: Esse arquivo descreve a estrutura e comportamento de um 			#
 --#			decodificador para display de 7 segmentos tipo anôdo comum.		#
 --#                                                                      	#
 --# 05/01/16 - Formiga - MG                                              	#
 --#########################################################################

 
 -- Importa as bibliotecas de sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


-- Início da declaração da entidade MIPS32_Control.
ENTITY MIPS32_7Seg IS

	PORT
	(
		DADO : in  STD_LOGIC_VECTOR(3 DOWNTO 0);	-- Barramento de 4 bits para especificaçao do valor em hexadecimal (0 - F) a ser exeibido.
		A, B, C, D, E, F, G : OUT STD_LOGIC			-- Segmentos do display.
	);
END MIPS32_7Seg;
-- Fim da declaração da entidade MIPS32_7Seg.


-- Início da declaração da arquitetura da entidade MIPS32_7Seg.
ARCHITECTURE BEHAVIOR OF MIPS32_7Seg IS

	SIGNAL S : STD_LOGIC_VECTOR(0 to 6); -- Sinal onde será armazenado o mapeamento de quais segmentos serão acessos ou apagados, i.e. armazena o resultado da conversão de DADO.
	
BEGIN

	-- De acordo com o valor informado no barramento "DADO", mapeia quais segmentos
	-- deverão ser acessos ou apagados, salvando esse dado no Sinal "S".
	WITH DADO SELECT
	
	S <=  "0000001"  WHEN "0000",	-- '0'
			"1001111"  WHEN "0001",	-- '1'
			"0010010"  WHEN "0010",	-- '2'
			"0000110"  WHEN "0011",	-- '3'
			"1001100"  WHEN "0100",	-- '4'
			"0100100"  WHEN "0101",	-- '5'
			"0100000"  WHEN "0110",	-- '6'
			"0001111"  WHEN "0111",	-- '7'
			"0000000"  WHEN "1000",	-- '8'
			"0000100"  WHEN "1001",	-- '9'
			"0001000"  WHEN "1010",	-- 'A'
			"1100000"  WHEN "1011",	-- 'B'
			"0110001"  WHEN "1100",	-- 'C'
			"1000010"  WHEN "1101",	-- 'D'	
			"0110000"  WHEN "1110",	-- 'E'
			"0111000"  WHEN "1111",	-- 'F'
			"1111111"  WHEN OTHERS; 
		
	-- Após o mapeamento, direciona cada posiçao do Sinal S para a respectiva saída do circuito,
	-- correspondente ao segmento.
    A <= S(0);
    B <= S(1);
    C <= S(2);
    D <= S(3);
    E <= S(4);
    F <= S(5);
    G <= S(6);
	 
END BEHAVIOR;
-- Fim da declaração da arquitetura da entidade MIPS32_7Seg.