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
 # Arquivo: About.cpp                                                     #
 #                                                                        #
 # Sobre: Esse arquivo contém a tela "About" convertida em hexadecimal.   #
 #                                                                        #
 # 05/01/16 - Formiga - MG                                                #
 #########################################################################*/

 
#include "About.h"
PROGMEM const unsigned char About[] = {
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
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x18,0x20,0xFF,0xFC,
0xFF,0xFF,0xFE,0xAF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFE,0x08,0x20,0xFF,0xFC,
0xFF,0xFF,0xF0,0x03,0xE0,0xFE,0x07,0xFF,0xFF,0xFF,0xFE,0x08,0x20,0xFF,0xFC,
0xFF,0xFF,0xC0,0x60,0xE0,0xF8,0x01,0xFF,0xFF,0xFF,0xFE,0x08,0x20,0xFF,0xFC,
0xFF,0xFF,0xC7,0x2C,0x60,0xF0,0x70,0xFD,0x2F,0xFF,0xFF,0x18,0x20,0xFF,0xFC,
0xFF,0xFF,0x18,0x02,0x20,0x71,0xFF,0x70,0x03,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0xFF,0xFF,0x21,0xB1,0x60,0xF3,0xFF,0xE0,0x03,0xFF,0xFE,0x08,0x3F,0xFF,0xFC,
0xFF,0xFE,0x66,0x1C,0xE0,0x71,0xFF,0xE0,0x03,0xFF,0xFE,0x08,0x3F,0xFF,0xFC,
0xFF,0xFE,0x4A,0xC7,0xE0,0xF0,0xFF,0xC0,0x07,0xFF,0xFE,0x08,0x3F,0xFF,0xFC,
0xFF,0xFC,0x50,0x09,0xE2,0xF8,0x7F,0x83,0xF7,0xFF,0xFE,0x08,0x3F,0xFF,0xFC,
0xFF,0xFC,0x9B,0x65,0xEE,0x78,0x3F,0x83,0xFF,0xFF,0xFE,0x08,0x3F,0xFF,0xFC,
0xFF,0xFC,0x95,0x13,0xE8,0xFE,0x07,0x03,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0xFF,0xFC,0x90,0x89,0xE8,0x7F,0x03,0xA7,0xFF,0xFF,0xFE,0x08,0x20,0xFF,0xFC,
0xFF,0xFC,0x9A,0xA3,0xCE,0xFF,0xD1,0x83,0xFF,0xFF,0xFE,0x08,0x20,0xFF,0xFC,
0xFF,0xFC,0xD2,0x99,0xEA,0x7F,0xF1,0x03,0xFF,0xFF,0xFE,0x08,0x20,0xFF,0xFC,
0xFF,0xFC,0x48,0x47,0xE0,0xFF,0xF4,0x83,0xF9,0xFF,0xFE,0x08,0x20,0xFF,0xFC,
0xFF,0xFE,0x4D,0x36,0xE0,0xFF,0xF9,0xC0,0xF0,0xFF,0xFE,0x08,0x20,0xFF,0xFC,
0xFF,0xFE,0x27,0x99,0xA0,0x7F,0xF9,0xC0,0x00,0x7F,0xFF,0xFF,0xFF,0xFF,0xFC,
0xFF,0xFF,0x10,0x02,0x20,0xDF,0xF8,0xE0,0x00,0xFF,0xFE,0x08,0x3F,0xFF,0xFC,
0xFF,0xFF,0x8C,0x44,0x60,0xC3,0xF5,0xC2,0x40,0xFF,0xFE,0x08,0x3F,0xFF,0xFC,
0xFF,0xFF,0xC3,0x70,0x60,0x78,0x43,0x88,0x03,0xFF,0xFE,0x08,0x3F,0xFF,0xFC,
0xFF,0xFF,0xE0,0x03,0xE0,0xFA,0x2F,0x0A,0x27,0xFF,0xFE,0x08,0x3F,0xFF,0xFC,
0xFF,0xFF,0xFC,0x27,0xE8,0xFF,0xFF,0xFF,0xFF,0xFF,0xFE,0x08,0x3F,0xFF,0xFC,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC,
0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFC
};
