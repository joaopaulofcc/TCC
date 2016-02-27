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
 --# Arquivo: MIPS32_ALU.vhd		 														#
 --#                                                                      	#
 --# Sobre: Esse arquivo descreve contantes, subtipos e tipos utilizados 	#
 --#			no MIPS																			#
 --#                                                                      	#
 --# 05/01/16 - Formiga - MG                                              	#
 --#########################################################################

 
-- Importa as bibliotecas de sistema.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


-- Início das declarações do pacote "MIPS32_Funcoes".
PACKAGE MIPS32_Funcoes IS

	--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||

	-- DEFINIÇAO DE CONSTANTES

	-- Define a largura do barramento de dados.
	CONSTANT DATA_WIDTH			: INTEGER := 8;
	
	-- Define a largura do barramento de endereços disponíveis na RAM de Dados.
	CONSTANT ADDRESS_DATA_WIDTH: INTEGER := 8;
	
	-- Define a largura do barramento de endereços disponíveis na RAM de Instruçoes.
	CONSTANT ADDRESS_INST_WIDTH: INTEGER := 8;
	
	-- Define o tamanho de um Byte.
	CONSTANT BYTE					: INTEGER := 8;
	
	-- Define o tamanho de uma Word.
	CONSTANT WORD					: INTEGER := 32;
	
	-- Define o tamanho de uma Double Word.
	CONSTANT DWORD					: INTEGER := 64;
	
	-- Define a largura (bits) de um registrador no sistema.
	CONSTANT REGISTER_WIDTH		: INTEGER := 32;
	
	-- Define a quantidade "n" de registradores presentes no sistema
	-- onde, qtde = (2 ^ n) - 1, utilizado para endereçamento.
	CONSTANT REGISTER_SELECT	: INTEGER := 6;
	
	-- Define a quantidade de registradores do sistema.
	CONSTANT QTD_GPRs				: INTEGER := 34;
	
	-- Define o Fator de divisão do clock utilizado no MIPS.
	-- Onde, fatorClock = 50000000/clockDesejado(Hz).
	
		-- OBS:  para testbench 		-> fatorClock = 1
		--			execuçao com Arduino -> fatorClock = 6250
		
	-- <http://www.estadofinito.com/divisor-frecuencia-vhdl/>
		
	CONSTANT fatorClock			: NATURAL := 6250;


	--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
	
	-- DEFINIÇAO DE SUBTIPOS DE DADOS
	
	-- Define tipos de dados básicos
	SUBTYPE t_Word		IS STD_LOGIC_VECTOR((WORD  - 1) DOWNTO 0);
	SUBTYPE t_DWord	IS STD_LOGIC_VECTOR((DWORD - 1) DOWNTO 0);
	SUBTYPE t_Byte 	IS STD_LOGIC_VECTOR((BYTE  - 1) DOWNTO 0);
	
	-- Tipo de dados que representa o campo opCode e funct de uma instruçao.
	SUBTYPE t_opCode	IS STD_LOGIC_VECTOR(5 DOWNTO 0);
	
	-- Tipo de dados que representa o campo funct2 de uma instruçao.
	SUBTYPE t_Funct2	IS STD_LOGIC_VECTOR(4 DOWNTO 0);
	
	-- Tipo de dados para endereçamento de um GPRs.
	SUBTYPE t_RegSelect	IS STD_LOGIC_VECTOR (REGISTER_SELECT - 1 DOWNTO 0);
	
	-- Tipo de dados que representa um Registrador do uProc.
	SUBTYPE t_Register IS STD_LOGIC_VECTOR(REGISTER_WIDTH  - 1 DOWNTO 0);
	
	-- Tipo de dados que representa um barramento de endereços na RAM de Dados.
	SUBTYPE t_AddressDATA	IS STD_LOGIC_VECTOR((ADDRESS_DATA_WIDTH - 1) DOWNTO 0);
	
	-- Tipo de dados que representa um barramento de endereços na RAM de Instruçoes.
	SUBTYPE t_AddressINST	IS STD_LOGIC_VECTOR((ADDRESS_INST_WIDTH - 1) DOWNTO 0);
	
	
	--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||--||
	
	-- DEFINIÇÃO DE TIPOS DE DADOS.
	
	-- Tipo de dados que representa um vetor de registradores.
	TYPE t_RegBank		IS ARRAY (0 to QTD_GPRs - 1) OF t_Word;
	
	-- Tipo de dados que representa uma memória RAM de Dados
	TYPE t_RAM_DATA	IS ARRAY (0 to (2 ** ADDRESS_DATA_WIDTH) - 1) OF t_Byte;
	
	-- Tipo de dados que representa uma memória RAM de Instruçoes
	TYPE t_RAM_INST	IS ARRAY (0 to (2 ** ADDRESS_INST_WIDTH) - 1) OF t_Byte;
	
END MIPS32_Funcoes;
-- Fim das declarações do pacote "MIPS32_Funcoes".