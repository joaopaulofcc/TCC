-----------------------------------------------------------------------
--
--	Projeto:  bin_7seg (Decodificador de bin�rio para 7 segmentos)
--
--		
--	Este c�digo implementa um decodificador de c�digo bin�rio de
--  quatro bits para sete segmentos de um display de anodo comum.
--
--  Por: Prof. �dson M�lo, em Maio de 2007
--
-----------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- A entidade define o bloco para o sistema:
entity bin_7seg is

	port
	(
		-- Sinais de entrada
		DADO : in  STD_LOGIC_VECTOR(3 DOWNTO 0);
		
		-- Sinais de sa�da
		A, B, C, D, E, F, G : out STD_LOGIC
	);
end bin_7seg;


architecture decodificador of bin_7seg is
	signal S : STD_LOGIC_VECTOR(0 to 6);
begin
	with DADO select
	S <=  "0000001"  when "0000",	-- '0'
		"1001111"  when "0001",	-- '1'
		"0010010"  when "0010",	-- '2'
		"0000110"  when "0011",	-- '3'
		"1001100"  when "0100",	-- '4'
		"0100100"  when "0101",	-- '5'
		"0100000"  when "0110",	-- '6'
		"0001111"  when "0111",	-- '7'
		"0000000"  when "1000",	-- '8'
		"0000100"  when "1001",	-- '9'
		"0001000"  when "1010",	-- 'A'
		"1100000"  when "1011",	-- 'B'
		"0110001"  when "1100",	-- 'C'
	  	"1000010"  when "1101",	-- 'D'	
		"0110000"  when "1110",	-- 'E'
		"0111000"  when "1111",	-- 'F'
     	"1111111"  when others; 
    A <= S(0);
    B <= S(1);
    C <= S(2);
    D <= S(3);
    E <= S(4);
    F <= S(5);
    G <= S(6);
end architecture;

