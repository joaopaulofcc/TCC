 --#########################################################################
 --#	 Bacharelado em Ciência da Computação - IFMG campus Formiga - 2015	#
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
 --# Arquivo: RegBank.vhd										                     #
 --#                                                                      	#
 --# 12/08/15 - Formiga - MG                                              	#
 --#########################################################################

 
-- Importa as bibliotecas de sistema
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


-- Importa as bibliotecas de usuário
LIBRARY WORK;
USE WORK.funcoes.ALL;


-- Início da declaração da entidade RegBank
ENTITY RegBank IS

	PORT 
	(
		clock			: IN 	STD_LOGIC;				-- Sinal de relógio.
		we				: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";		--	Sinal de Write Enable (1 - Habilitado | 0 - Desabilitado)
		regRead1		: IN 	t_RegSelect;			-- Endereço do 1º registrador a ser lido.
		regRead2		: IN 	t_RegSelect;			-- Endereço do 2º registrador a ser lido.
		regWrite1	: IN 	t_RegSelect;			-- Endereço do registrador a ser escrito.
		regWrite2	: IN 	t_RegSelect;			-- Endereço do registrador a ser escrito.
		dataWrite1	: IN 	t_Word;					-- Dado a ser escrito no registrador "regWrite".
		dataWrite2	: IN 	t_Word;					-- Dado a ser escrito no registrador "regWrite".
		dataRead1	: OUT t_Word := (OTHERS => '0');					-- Dado lido no registrador "regRead1".
		dataRead2	: OUT t_Word := (OTHERS => '0')					-- Dado lido no registrador "regRead2".
	);

END ENTITY;
-- Fim da declaração da entidade RegBank


-- Início da declaração da arquitetura da entidade RegBank
ARCHITECTURE RTL OF RegBank IS

	-- Função utiliza para inicializar a memória ROM, para isso escreve em
	-- seus endereços o próprio valor do endereço.
	FUNCTION init_reg
	RETURN t_RegBank IS
		VARIABLE tmp : t_RegBank := (OTHERS => (OTHERS => '0'));
	BEGIN 
	
		FOR addr_pos IN 0 TO QTD_GPRs - 1 LOOP
		
			tmp(addr_pos) := STD_LOGIC_VECTOR(TO_UNSIGNED(addr_pos, REGISTER_WIDTH));
			
		END LOOP;
		
		RETURN tmp;
		
	END init_reg;

	-- Banco de registadores do tipo t_RegBank
	SIGNAL registers : t_RegBank := init_reg;

BEGIN
	
	process(clock)
	begin
	
		if(rising_edge(clock)) then
		
			if(we = "00") then
			
				registers(TO_INTEGER(UNSIGNED(regWrite1))) <= dataWrite1;
			
			ELSIF(we = "01") THEN
			
				registers(TO_INTEGER(UNSIGNED(regWrite2))) <= dataWrite2;
				
			ELSIF(we = "10") THEN
			
				registers(TO_INTEGER(UNSIGNED(regWrite1))) <= dataWrite1;
				registers(TO_INTEGER(UNSIGNED(regWrite2))) <= dataWrite2;
		
			end if;
			
		end if;
		
	end process;
	
	-- Register the address for reading
	dataRead1 <= registers(TO_INTEGER(UNSIGNED(regRead1)));
	dataRead2 <= registers(TO_INTEGER(UNSIGNED(regRead2)));

END RTL;
-- Fim da declaração da arquitetura da entidade RegBank