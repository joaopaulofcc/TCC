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
 --# Arquivo: funcoes.vhd																	#
 --#                                                                      	#
 --# 12/08/15 - Formiga - MG                                              	#
 --#########################################################################

 
-- Importa bibliotecas.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


-- Início das declarações do pacote "funcoes".
PACKAGE funcoes IS

	-- Define a largura de dados salvos na RAM.
	CONSTANT DATA_WIDTH			: INTEGER := 8;
	
	-- Define a quantidade de endereços disponíveis na RAM.
	CONSTANT ADDRESS_DATA_WIDTH: INTEGER := 8;
	
	-- Define a quantidade de endereços disponíveis na ROM.
	CONSTANT ADDRESS_INST_WIDTH: INTEGER := 8;
	
	-- Define o tamanho de um Byte.
	CONSTANT BYTE					: INTEGER := 8;
	
	-- Define o tamanho de uma Word.
	CONSTANT WORD					: INTEGER := 32;
	
	-- Define o tamanho de uma DWord.
	CONSTANT DWORD					: INTEGER := 64;
	
	-- Define a largura de um registrador no sistema.
	CONSTANT REGISTER_WIDTH		: INTEGER := 32;
	
	-- Define a quantidade "n" de registradores presentes no sistema
	-- onde, qtde = (2 ^ n) - 1
	CONSTANT REGISTER_SELECT	: INTEGER := 6;
	
	-- Define a quantidade de registradores do sistema.
	CONSTANT QTD_GPRs				: INTEGER := 34;
	

	CONSTANT zero_DWord			: STD_LOGIC_VECTOR(DWORD - 1 DOWNTO 0) := x"0000000000000000";
	
	CONSTANT zero_Word			: STD_LOGIC_VECTOR(WORD  - 1 DOWNTO 0) := x"00000000";
	
	
	-- Define o Fator de divisão do clock utilizado no MIPS.
	CONSTANT fatorClock			: NATURAL := 6250;--1000000;--700000;--2500000;


	
	-- Define tipos de dados básicos
	SUBTYPE t_Word		IS STD_LOGIC_VECTOR((WORD  - 1) DOWNTO 0);
	SUBTYPE t_DWord	IS STD_LOGIC_VECTOR((DWORD - 1) DOWNTO 0);
	SUBTYPE t_Byte 	IS STD_LOGIC_VECTOR((BYTE  - 1) DOWNTO 0);
	
	-- Tipo de dados que representa um Opcode.
	SUBTYPE t_opCode	IS STD_LOGIC_VECTOR(5 DOWNTO 0);
	
	-- Tipo de dados para endereçamento de um GPRs.
	SUBTYPE t_RegSelect	IS STD_LOGIC_VECTOR (REGISTER_SELECT - 1 DOWNTO 0);
	
	-- Tipo de dados que representa um Registrador do uProc.
	SUBTYPE t_Register IS STD_LOGIC_VECTOR(REGISTER_WIDTH  - 1 DOWNTO 0);
	
	-- Tipo de dados que representa um barramento de endereços na RAM.
	SUBTYPE t_AddressDATA	IS STD_LOGIC_VECTOR((ADDRESS_DATA_WIDTH - 1) DOWNTO 0);
	
	-- Tipo de dados que representa um barramento de endereços na ROM.
	SUBTYPE t_AddressINST	IS STD_LOGIC_VECTOR((ADDRESS_INST_WIDTH - 1) DOWNTO 0);
	
	-- Tipo de dados que representa um vetor de registradores.
	TYPE t_RegBank		IS ARRAY (0 to QTD_GPRs - 1) OF t_Word;
	
	-- Tipo de dados que representa uma memória RAM.
	TYPE t_RAM_DATA	IS ARRAY (0 to (2 ** ADDRESS_DATA_WIDTH) - 1) OF t_Byte;
	
	-- Tipo de dados que representa uma memória ROM.
	TYPE t_RAM_INST	IS ARRAY (0 to (2 ** ADDRESS_INST_WIDTH) - 1) OF t_Byte;
	
END funcoes;
	
PACKAGE BODY funcoes IS

END funcoes;
-- Fim das declarações do pacote "funcoes".