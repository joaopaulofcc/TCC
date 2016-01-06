 /*########################################################################
 #   Bacharelado em Ciência da Computação - IFMG campus Formiga - 2016    #
 #                                                                        #
 #                  Trabalho de Conclusão de Curso                        #
 #                                                                        #
 #      Implementação de processador baseado no MIPS32 utilizando         #
 #                      hardware reconfigurável                           #
 #                                                                        #
 # ALUNO                                                                  #
 #                                                                        #
 # João Paulo Fernanades de Cerqueira César                               #
 #                                                                        #
 # ORIENTADOR                                                             #
 #                                                                        #
 # Otávio de Souza Martins Gomes                                          #
 #                                                                        #
 # Arquivo: logoSomON.cpp                                                 #
 #                                                                        #
 # Sobre: Esse arquivo contém o logo de som Ligado convertido em 	 	  #
 #		  hexadecimal. 												      #
 #                                                                        #
 # 05/01/16 - Formiga - MG                                                #
 #########################################################################*/
 
#include "logoSomON.h"
PROGMEM const unsigned char logoSomON[] = {
10,10,
0x08,0x00,
0x18,0x80,
0xEA,0x40,
0x89,0x40,
0x89,0x40,
0x89,0x40,
0x89,0x40,
0xEA,0x40,
0x18,0x80,
0x08,0x00
};