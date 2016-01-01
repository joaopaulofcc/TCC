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
 --# Arquivo: ROM.vhd																		#
 --#                                                                      	#
 --# 12/08/15 - Formiga - MG                                              	#
 --#########################################################################

 
-- Importa as bibliotecas de sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Importa as bibliotecas de usuário.
LIBRARY WORK;
USE WORK.funcoes.ALL;


-- Início da declaração da entidade ROM.
ENTITY ROM IS

	PORT 
	(
		clock		: IN 	STD_LOGIC;			-- Sinal de relógio.
		address	: IN 	t_AddressROM;			-- Endereço da posição de memória a ser Lida/Escrita.
		dataOut	: OUT t_Byte				-- Dado lido da RAM.
	);

END ENTITY;
-- Fim da declaração da entidade ROM.


-- Início da declaração da arquitetura da entidade ROM.
ARCHITECTURE RTL OF ROM IS

	-- Função utiliza para inicializar a memória ROM, para isso escreve em
	-- seus endereços o próprio valor do endereço.
	FUNCTION init_rom
	RETURN t_ROM IS
		VARIABLE tmp : t_ROM := (OTHERS => (OTHERS => '0'));
	BEGIN 
	
		FOR addr_pos IN 0 TO 2 ** ROM_WIDTH - 1 LOOP
		
			tmp(addr_pos) := STD_LOGIC_VECTOR(TO_UNSIGNED(addr_pos, DATA_WIDTH));
			
		END LOOP;
		
		RETURN tmp;
		
	END init_rom;	 

	-- Vetor de dados do tipo t_ROM, inicializando seus valores por meio da função init_rom.
	SIGNAL rom 				: t_ROM 		:= ("00100000", "00011000", "01000010", "00000001",    "00000000", "00000000", "01001011", "10001100", OTHERS => x"00"); --init_rom;
	
BEGIN
		
	-- Process para controle de operações da máquina de estado.
	PROCESS(clock)
	BEGIN
	
		IF(RISING_EDGE(clock)) THEN
	
			-- Lê os dados.
			dataOut <= rom(TO_INTEGER(UNSIGNED(address)));
		
		END IF;
		
	END PROCESS;
		
END RTL;
-- Fim da declaração da arquitetura da entidade ROM.