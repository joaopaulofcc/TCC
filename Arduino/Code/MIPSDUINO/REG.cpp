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
 # Arquivo: MEM.cpp                                                       #
 #                                                                        #
 # Sobre: Esse arquivo contém o tela REG convertida em hexadecimal.       #
 #                                                                        #
 # 05/01/16 - Formiga - MG                                                #
 #########################################################################*/


#include "REG.h"
PROGMEM const unsigned char REG[] = {
118,94,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0xFF,0xBF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xF7,0xFC,
0xFE,0x3F,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xF1,0xFC,
0xFC,0x3F,0xFF,0xFF,0xFF,0xFF,0xBE,0x1C,0xC3,0xFF,0xFF,0xFF,0xFF,0xF0,0xFC,
0xF0,0x00,0x7F,0xFF,0xFF,0xFF,0xBC,0xCB,0x5D,0xFF,0xFF,0xFF,0xF8,0x00,0x3C,
0xE0,0x00,0x7F,0xFF,0xFF,0xFF,0xBD,0xEB,0x5D,0xFF,0xFF,0xFF,0xF8,0x00,0x1C,
0xE0,0x00,0x7F,0xFF,0xFF,0xFF,0xBD,0xE8,0x5D,0xFF,0xFF,0xFF,0xF8,0x00,0x1C,
0xF0,0x00,0x7F,0xFF,0xFF,0xFF,0xBC,0xCB,0x5D,0xFF,0xFF,0xFF,0xF8,0x00,0x3C,
0xFC,0x3F,0xFF,0xFF,0xFF,0xFF,0x86,0x1B,0x43,0xFF,0xFF,0xFF,0xFF,0xF0,0xFC,
0xFE,0x3F,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xF1,0xFC,
0xFF,0xBF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xF7,0xFC,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0x80,0x0C,0x00,0x00,0x00,0x00,0x00,0x30,0x01,0x80,0x00,0x00,0x00,0x00,0x04,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC
};