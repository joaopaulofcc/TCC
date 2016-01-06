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
 # Arquivo: logoSomOFF.cpp                                                #
 #                                                                        #
 # Sobre: Esse arquivo contém o logo de som desligado convertido em 	  #
 #		  hexadecimal. 												      #
 #                                                                        #
 # 05/01/16 - Formiga - MG                                                #
 #########################################################################*/
 
#include "logoSomOFF.h"
PROGMEM const unsigned char logoSomOFF[] = {
10,10,
0x08,0x00,
0x18,0x00,
0xE8,0x00,
0x88,0x00,
0x88,0x00,
0x88,0x00,
0x88,0x00,
0xE8,0x00,
0x18,0x00,
0x08,0x00
};