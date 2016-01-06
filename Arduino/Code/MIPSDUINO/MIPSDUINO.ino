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
 # Arquivo: MIPSDUINO.ino                                                 #
 #                                                                        #
 # Sobre: Esse arquivo contém o código da unidade de interação MIPSDUINO. #
 #                                                                        #
 # 05/01/16 - Formiga - MG                                                #
 #########################################################################*/

/*
 * Inclui biblioteca para escrita e leitura em pinos digitais de forma otimizada e mais rápida.
 * vide: <http://www.codeproject.com/Articles/732646/Fast-digital-I-O-for-Arduino>
 */
#include "arduino2.h"


/*
 * Inclui biblioteca e variáveis para controle do SD.
 */
#include <SPI.h>
#include <SD.h>
File root;                // Arquivo utilizado para mapear todos os arquivos na raiz do SD.
File arquivoSD;           // Arquivo utilizado para mapear o arquivo a ser exibido na tela e enviado para a FPGA.
bool sdInserido = false;  // Flag para controle se o SD está ou não inserido.



/*
 * Inclui biblioteca e variáveis para controle do RTC.
 */
#include <DS1307.h>
DS1307 rtc(20, 21);
uint8_t diaRTC;   // Armazena o dia.
uint8_t mesRTC;   // Armazena o mes.
uint16_t anoRTC;  // Armazena o ano.

uint8_t diaSemRTC;// Armazena o dia da semana.

uint8_t horaRTC;  // Armazena a hora.
uint8_t minRTC;   // Armazena os minutos.
uint8_t segRTC;   // Armazena os segundos.

// Instancia objeto da classe Time para coleta dos dados atuais do RTC.
Time dadosRTC;


/*
 * Inclui biblioteca e variáveis para controle da TV.
 */
#include <TVout.h>
#include <fontALL.h>
#include "baseContorno.h"   // Base para telas (contorno)
#include "logoMIPSDUINO.h"  // Logo do projeto
#include "openFILE.h"       // Base para tela de gerencia de Arquivos.
#include "showFILE.h"       // Base para tela de exibição de Arquivo.
#include "REG.h"            // Base para tela de registradores
#include "MEM.h"            // Base para tela de memória.
#include "About.h"          // Base para tela de informações.
#include "logoC2ISC.h"      // Logo do C2ISC
#include "logoIF.h"         // Logo do IFMG.
TVout TV;


/**
 * Biblioteca para controle do teclado matricial.
 */
#include <Keypad.h>
const byte numRows=4; // Numero de linhas
const byte numCols=4; // Numero de colunas

// Mapa das teclas.
char keymap[numRows][numCols]=
{
 {'1','2','3','A'},
 {'4','5','6','B'},
 {'7','8','9','C'},
 {'F','0','E','D'},
};

// Pinos onde estão conectados as linhas do teclado.
byte rowPins[numRows] = {A3,A4,A5,A6};

// Pinos onde estão conectados as colunas do teclado.
byte colPins[numCols] = {A7,A8,A9,A10};

// Instancia objeto do telado matricial.
Keypad myKeypad = Keypad(makeKeymap(keymap), rowPins, colPins, numRows, numCols);


/**
 * --------------- CONSTANTES ---------------
 */

// Constante para definição do número máximo de linhas exibidas em um arquivo.
#define MAX_QTD_LINES 255

// Constante para definição do número máximo de arquivos presentes no SD que serão exibidos.
#define MAX_QTD_FILES 8

// Constante para definição do número máximo de linhas presentes em um arquivo do cartão SD que serão exibidas e processadas.
#define MAX_LINES_SD 64

// Tempo em microssegundos utilizado para sincronização com o clock da FPGA.
const int delayFPGA = 1;

/**
 * --------------- VARIAVEIS ---------------
 */

// Item escolhido do Menu Principal.
byte itemMenuPrincipal = 1;

// Item escolhido do Menu de Registradores.
byte itemMenuReg = 1;

// Item escolhido do Menu de Memória.
byte itemMenuMem = 0;

// Item escolhido da tela de exibição de arquivos.
byte itemMenuShow = 1;

// Item escolhido da tela de listagem de arquivos.
byte itemOpen = 0;

// Item escolhido no ajuste de horas.
byte itemRTC = 0;

// Marcador de tela atual.
byte telaAtual = 1;

// Marcador de menu atual.
byte menuAtual = 1;

// Variável que controla qual tela de Registradores está sendo exibida;
byte telaReg = 1;

// Variável que controla qual tela de Memória RAM está sendo exibida;
byte telaMem = 1;



// Contador de arquivos presentes no cartão SD.
byte qtdArqSD = 0;

// Variáveis utilizadas no controle da exibição de linhas do arquivo selecionado.
byte marcPrimeiraLinhaSD = 0;  // Primeira linha a ser exibida.
byte marcUltimaLinhaSD = 8;    // Ultima linha a ser exibida.

// Contador de linhas do arquivo selecionado.
byte contLinhasSD = 0;

// Vetor para armazenagem das linhas lidas do arquivo presente no SD.
String linhasSD[MAX_QTD_LINES];

// Vetor para armazenagem dos nomes dos arquivos presentes no SD.
String filesSD[MAX_QTD_FILES];



// Flag que habilita (true) ou não (false) a reimpressão da tela exibida no momento.
bool printTelaAtual = true;

// Flags que indicam se é a primeira vez que o joystick é pressionado para baixo ou para cima.
bool primeiraVezBaixo = true;
bool primeiraVezCima = false;

// Variáveis marcadoras de posição do cursor na tela.
int posY;
int posX;

// Pinos do joytick.
const byte pinRy = A2;  // Eixo Y
const byte pinRx = A1;  // Eixo X
const byte pinSw = A0;  // Pino Switch

// Variáveis para controle do tempo mínimo para reconhecimento de mudanças no joystick.
long lastDebounceTime = 0;
long debounceDelay = 100;

// Pinos dos LEDs
const byte pinLedPOWER = 14;  // LED indicador de ON/OFF
const byte pinLedSD = 15;     // LED indicador de acesso ao cartão SD
const byte pinLedFPGA = 16;   // LED indicador de acessoa ao FPGA

// Flag que controla a impressão da tela de aviso caso o FPGA esteja desconectado.
bool printAviso = true;

// Pino que identifica se o FPGA está ou não conectado.
const byte pinFPGAPower = 12;


/**
 * Pinos GPIO (IDE)
 */

//Pinos de saída do Endereço para a FPGA.
const byte addr0 = 44; //LSB
const byte addr1 = 45;
const byte addr2 = 46;
const byte addr3 = 47;
const byte addr4 = 48;
const byte addr5 = 49;
const byte addr6 = A12;
const byte addr7 = A14;//MSB


//Pinos de saída de Dados para a FPGA.
const byte dout0 = 36; //LSB
const byte dout1 = 2;
const byte dout2 = 38;
const byte dout3 = 39;
const byte dout4 = 40;
const byte dout5 = 41;
const byte dout6 = 42;
const byte dout7 = 43; //MSB


//Pinos de entrada de Dados da a FPGA para o Arduino.
const byte din0 = 28; //LSB 
const byte din1 = 6;
const byte din2 = 30;
const byte din3 = 5;
const byte din4 = 32;
const byte din5 = 4;
const byte din6 = 34;
const byte din7 = 3; //MSB


//Pinos de controle da FPGA.

const byte pinClock = 23; // Clock gerado no FPGA.

//Pinos de status (ready).
const byte ready0 = 22; //LSB
const byte ready1 = 9;
const byte ready2 = 24;

//Pinos de erro.
const byte error0 = 37;
const byte error1 = 33; //MSB

//Pinos de escolha de operação (opCode).
const byte opCode0 = 8; //LSB
const byte opCode1 = 26;
const byte opCode2 = 7; //MSB

// Pino de reset do processador.
const byte reset = 35;

// Vetor com os pinos de endereçamento (utilizado para iterar ao ler/escrever dados nesses pinos).
const int pinosAddress[] = {addr0, addr1, addr2, addr3, addr4, addr5, addr6, addr7};

// Vetor com os pinos de dados de saída (utilizado para iterar ao ler/escrever dados nesses pinos).
const int pinosDataOUT[] = {dout0, dout1, dout2, dout3, dout4, dout5, dout6, dout7};

// Vetor com os pinos de dados de entrada (utilizado para iterar ao ler/escrever dados nesses pinos).
const int pinosDataIN[] = {din0, din1, din2, din3, din4, din5, din6, din7};

// Dado lido do banco de registradores no FPGA e convertido em hexadecimal para exibição na tela.
char hexDataREG[9];

// Armazena os dados lidos de um registrador do banco de registradores, em formato binário (Lidos por meio de digitalRead2).
byte binByteREG[32];

// Armazena os dados lidos de uma posição da memória RAM de dados, em formato binário (Lidos por meio de digitalRead2).
byte binByteRAM[8];

// Armazena os dados da variável "binCharREG" convertidos para caractere para impressão na tela.
char binCharREG[32];

// Armazena os dados da variável "binByteRAM" convertidos para caractere para impressão na tela.
char binCharRAM[8];

// Armazena o endereço do registrador a ser lido em formato binário (Escritos por meior de digitalWrite2).
byte binaryAddressREG[8];

// Armazena o endereço da posição de memória de dados a ser lida em formato binário (Escritos por meior de digitalWrite2).
byte binaryAddressRAM[8];

// Matriz que armazena o valor de todos os registradores lidos do FPGA.
char matrizRegsChar[34][9];

// Posição de memória de dados a ser lida, informada no keypad pelo usuário.
char hexaAddressRAM[3];

// Contador de caracteres digitados no textbox da RAM.
byte contAddrRAM = 0;

// Vetor de bytes utilizado para armazenar a instrução atual em formato binário.
byte instrucaoBytes[32];

// Vetor de string utilizado para armazenar cada campo da instrução lida como linha do cartão SD, após processamento de texto.
String stringsInstrucao[6];




/*
 * Procedimento que informado um vetor de 4 caracteres (nibble), retorna o valor em hexadecimal correspondente.
 */
char converteNibbleHex(char *binario)
{  
  // Armazena o valor do nibble convertido em inteiro.
  int convertidaDEC;

  // Converte o valor em inteiro.
  convertidaDEC = atoi(binario);

  // De acordo com o valor convertido, retorna o hexadecimal correspondente.
  switch(convertidaDEC)
  {
    case 0:

      return('0');

      break;

    case 1:

      return('1');

      break;

    case 10:

      return('2');

      break;

    case 11:

      return('3');

      break;

    case 100:

      return('4');

      break;

    case 101:

      return('5');

      break;

    case 110:

      return('6');

      break;

    case 111:

      return('7');

      break;

    case 1000:

      return('8');

      break;

    case 1001:

      return('9');

      break;

    case 1010:

      return('A');

      break;

    case 1011:

      return('B');

      break;

    case 1100:

      return('C');

      break;

    case 1101:

      return('D');

      break;

    case 1110:

      return('E');

      break;

    case 1111:

      return('F');

      break;
    
  }  
}


/**
 * Método onde informados um vetor de caracteres e a quantidade de nibbles que ele contém, gerencia a conversão de cada nibble,
 * chamando para isso o método "converteNibbleHex".
 */
void converteBinarioHexa(char *binario, byte qtdNibbles)
{
  // Vetor de 4 posições de caractere que é utilizado para armazenar o nibble atual a ser convertido.
  char nibble[4];

  // Controles de limite inferior e superior do laço.
  byte inf = 0;
  byte sup = 4;

  // Conta a qtde de caracteres que foi copiados para a variável "nibble".
  byte cont = 0;
  
  // Realiza o processo para a quantidade de nibbles informada.
  for(int i = 0; i < qtdNibbles; i++)
  {
    
    cont = 0;
  
    // Percorre o vetor de caracteres e armazena, o nibble que deverá ser convertido.
    for(int j = inf; j < sup; j++)
    {
      nibble[cont] = binario[j];
      cont++;
    }

    // Chama método para conversão de nibble em hexa, e armazena o resultado na posição "i" do vetor "hexaDataREG".
    hexDataREG[i] = converteNibbleHex(nibble);

    // Atualiza índices do laço.
    inf += 4;
    sup += 4;
    
  }
}


/**
 * Método responsável por preencher um vetor de caracteres, a partir de uma posição também informada, com o valor de um nibble, ambos informados como parâmetro.
 */
void preencheNibble(byte base, byte *nibble, char *destino)
{
  for(int i = 0; i < 4; i++)
  {
    destino[base + i] = nibble[i];
  }
}


/**
 * Método onde, informado um vetor de caracteres representando um número hexadecimal, um vetor de caracteres representando um número em formato binário,
 * e uma variável indicadora do tamanho desse vetor hexa, converte o vetor hexadecimal para o formato binário, e armazena o resultado no vetor binário.
 */
void converteHexaBinario(char *hexa, char *binario, int tam)
{
  char charAtual;
  byte nibble[4];

  // Itera "tam" vezes".
  for(int i = 0; i < tam; i++)
  {

    // Copia o valor do caractere hexadecimal atual (começa invertido para manter o endian).
    charAtual = hexa[1 - i];

    // De acordo com o valor hexa lido, armazena no vetor "nibble" o valor em binário correspondente, e em seguida
    // chama método para copiar tais valores para a posição correta no vetor "binario".
    switch(charAtual)
    {
      case '0':

        // Armazena dados em binário, no vetor "nibble".
        nibble[3] = 0;
        nibble[2] = 0;
        nibble[1] = 0;
        nibble[0] = 0;

        // Chama método para preencher o vetor "binario", com o valor convertido, armazenado em "nibble".
        preencheNibble(i * 4, nibble, binario);

        break;

      case '1':

        nibble[3] = 0;
        nibble[2] = 0;
        nibble[1] = 0;
        nibble[0] = 1;

        preencheNibble(i * 4, nibble, binario);

        break;

      case '2':

        nibble[3] = 0;
        nibble[2] = 0;
        nibble[1] = 1;
        nibble[0] = 0;

        preencheNibble(i * 4, nibble, binario);

        break;

      case '3':

        nibble[3] = 0;
        nibble[2] = 0;
        nibble[1] = 1;
        nibble[0] = 1;

        preencheNibble(i * 4, nibble, binario);

        break;

      case '4':

        nibble[3] = 0;
        nibble[2] = 1;
        nibble[1] = 0;
        nibble[0] = 0;

        preencheNibble(i * 4, nibble, binario);

        break;

      case '5':

        nibble[3] = 0;
        nibble[2] = 1;
        nibble[1] = 0;
        nibble[0] = 1;

        preencheNibble(i * 4, nibble, binario);

        break;

      case '6':

        nibble[3] = 0;
        nibble[2] = 1;
        nibble[1] = 1;
        nibble[0] = 0;

        preencheNibble(i * 4, nibble, binario);

        break;

      case '7':

        nibble[3] = 0;
        nibble[2] = 1;
        nibble[1] = 1;
        nibble[0] = 1;

        preencheNibble(i * 4, nibble, binario);

        break;

      case '8':

        nibble[3] = 1;
        nibble[2] = 0;
        nibble[1] = 0;
        nibble[0] = 0;

        preencheNibble(i * 4, nibble, binario);

        break;

      case '9':

        nibble[3] = 1;
        nibble[2] = 0;
        nibble[1] = 0;
        nibble[0] = 1;

        preencheNibble(i * 4, nibble, binario);

        break;

      case 'A':

        nibble[3] = 1;
        nibble[2] = 0;
        nibble[1] = 1;
        nibble[0] = 0;

        preencheNibble(i * 4, nibble, binario);

        break;

      case 'B':

        nibble[3] = 1;
        nibble[2] = 0;
        nibble[1] = 1;
        nibble[0] = 1;

        preencheNibble(i * 4, nibble, binario);

        break;

      case 'C':

        nibble[3] = 1;
        nibble[2] = 1;
        nibble[1] = 0;
        nibble[0] = 0;

        preencheNibble(i * 4, nibble, binario);

        break;

      case 'D':

        nibble[3] = 1;
        nibble[2] = 1;
        nibble[1] = 0;
        nibble[0] = 1;

        preencheNibble(i * 4, nibble, binario);

        break;

      case 'E':

        nibble[3] = 1;
        nibble[2] = 1;
        nibble[1] = 1;
        nibble[0] = 0;

        preencheNibble(i * 4, nibble, binario);

        break;

      case 'F':

        nibble[3] = 1;
        nibble[2] = 1;
        nibble[1] = 1;
        nibble[0] = 1;

        preencheNibble(i * 4, nibble, binario);

        break;
    }
  }
}


/**
 * Método que dado um número decimal e um vetor de bytes, converte o número decimal
 * para binário, armazenando os bits nas posições do vetor.
 */
void converteDecimalBinario(int decimal, byte *binario, byte sizeVetor)
{
  int k, c;

  for (c = sizeVetor - 1; c >= 0; c--)
  {
    k = decimal >> c;
 
    if (k & 1)
    {
      binario[c] = 1;
    }
    else
    {
      binario[c] = 0;
    }
  }
}


/**
 * Método para leitura de dados presentes em uma determinada posição de memória de Instruções do MIPS.
 */
void leMEMInst()
{
  // Armazena o endereço a ser lido da memória em forma decimal.
  int addrInt = 0;

  // Liga o LED de acesso ao FPGA.
  digitalWrite2(pinLedFPGA, HIGH);  

  // Converte o endereço hexadecimal digitado no keypad para um valor inteiro.
  sscanf(hexaAddressRAM,"%x", &addrInt);

  // Solicita, a partir do endereço base salvo em "addrInt", a leitura de 4 bytes da memória.
  for(int i = 0; i < 4; i++)
  {    
    // Converte para binário o endereço salvo em "addrInt".
    converteDecimalBinario(addrInt, binaryAddressRAM, 8);

    // Escreve nos pinos de endereço o valor correspondente.
    for(int j = 0; j < 8; j++)
    {
      digitalWrite2(pinosAddress[j], binaryAddressRAM[j]);
    }

    // Escreve o valor do opCode "010" nos pinos correspondentes, solicitando que o MIPS entre 
    // em modo de debug da RAM de instruções.
    digitalWrite2(opCode2, LOW);
    digitalWrite2(opCode1, HIGH);
    digitalWrite2(opCode0, LOW);
  
    // Aguarda borda de subida do clock.
    while(digitalRead2(pinClock) != 1){}
  
    // Reseta circuito do FPGA.
    digitalWrite2(reset, HIGH);
  
    // Aguarda borda de subida do clock.
    while(digitalRead2(pinClock) != 1){}
  
    // Desliga o pino de reset (i.e. '0').
    digitalWrite2(reset, LOW);
  
    // Aguarda resposta "ready = 010" do FPGA, sinalizando que o byte solicitado foi lido da memória.
    while(! ((digitalRead2(ready2) == LOW) && (digitalRead2(ready1) == HIGH) && (digitalRead2(ready0) == LOW)) ) {}
    
    // Lê dados do byte dos pinos de entrada no Arduino e armazena no vetor de bytes "binByteRAM".
    binByteRAM[0] = digitalRead2(din0);
    binByteRAM[1] = digitalRead2(din1);
    binByteRAM[2] = digitalRead2(din2);
    binByteRAM[3] = digitalRead2(din3);
    binByteRAM[4] = digitalRead2(din4);
    binByteRAM[5] = digitalRead2(din5);
    binByteRAM[6] = digitalRead2(din6);
    binByteRAM[7] = digitalRead2(din7);
  
    // Converte bytes lidos para string e armazena o resultado no vetor de caracteres "binCharRAM", para ser impresso na tela.
    sprintf(binCharRAM, "%i%i%i%i%i%i%i%i", binByteRAM[7], binByteRAM[6], binByteRAM[5], binByteRAM[4], binByteRAM[3], binByteRAM[2], binByteRAM[1], binByteRAM[0]);

    // Imprime o dado na posição correta da tela, de acordo com o indice do byte lido.
    switch(i)
    {
      // 1º byte.
      case 0:

        // Escreve layout da memória na tela.
        TV.print(25, 54, "MSB");
        TV.print(75, 54, "LSB");
      
        TV.draw_line(38, 52, 38, 90, 1);
        TV.draw_line(72, 52, 72, 90, 1);
        TV.draw_line(38, 52, 73, 52, 1);
        TV.draw_line(38, 90, 73, 90, 1);
      
        TV.draw_line(38, 81, 73, 81, 1);
        TV.draw_line(38, 71, 73, 71, 1);
        TV.draw_line(38, 61, 73, 61, 1);
        TV.draw_line(38, 51, 73, 51, 1);
      
        // Escreve na TV o byte lido da memória.
        TV.print(40,84, binCharRAM);
      
        // Escreve endereço bas, informado para leitura na RAM.
        TV.print(76,84, 'x');
        TV.print(80,84, hexaAddressRAM[0]);
        TV.print(84,84, hexaAddressRAM[1]);

        break;

      // 2º byte;
      case 1:

        // Escreve na TV o byte lido da memória.
        TV.print(40,74, binCharRAM);

        break;

      // 3º byte.
      case 2:

        // Escreve na TV o byte lido da memória.
        TV.print(40,64, binCharRAM);

        break;

      // 4º byte
      case 3:

        // Escreve na TV o byte lido da memória.
        TV.print(40,54, binCharRAM);

        break;
    }

    // Incrementa o endereço base a ser lido, para assim, na próxima iteração poder ler o próximo byte.
    addrInt++;

    // Solicita ao MIPS que entre em estado IDLE e em seguida aguarda "delayFPGA" microssegundos antes da próxima iteração.
    solicitaIDLE();

    delayMicroseconds(delayFPGA);
  }

  // Desliga o LED de acesso ao FPGA.
  digitalWrite2(pinLedFPGA, LOW);
}



/**
 * Método para leitura de dados presentes em uma determinada posição de memória de Dados do MIPS.
 */
void leMEMData()
{
  // Armazena o endereço a ser lido da memória em forma decimal.
  int addrInt = 0;

  // Liga o LED de acesso ao FPGA.
  digitalWrite2(pinLedFPGA, HIGH);  

  // Converte o endereço hexadecimal digitado no keypad para um valor inteiro.
  sscanf(hexaAddressRAM,"%x", &addrInt);

  // Solicita, a partir do endereço base salvo em "addrInt", a leitura de 4 bytes da memória.
  for(int i = 0; i < 4; i++)
  { 
    // Converte para binário o endereço salvo em "addrInt".
    converteDecimalBinario(addrInt, binaryAddressRAM, 8);

    // Escreve nos pinos de endereço o valor correspondente.
    for(int j = 0; j < 8; j++)
    {
      digitalWrite2(pinosAddress[j], binaryAddressRAM[j]);
    }

    // Escreve o valor do opCode "100" nos pinos correspondentes, solicitando que o MIPS entre 
    // em modo de debug da RAM de dados.
    digitalWrite2(opCode2, HIGH);
    digitalWrite2(opCode1, LOW);
    digitalWrite2(opCode0, LOW);
  
    // Aguarda borda de subida do clock.
    while(digitalRead2(pinClock) != 1){}
  
    // Reseta circuito do FPGA.
    digitalWrite2(reset, HIGH);
  
    // Aguarda borda de subida do clock.
    while(digitalRead2(pinClock) != 1){}
  
    // Desliga o pino de reset (i.e. '0').
    digitalWrite2(reset, LOW);
  
    // Aguarda resposta "ready = 100" do FPGA, sinalizando que o byte solicitado foi lido da memória.
    while(! ((digitalRead2(ready2) == HIGH) && (digitalRead2(ready1) == LOW) && (digitalRead2(ready0) == LOW)) ) {}
  
    // Lê dados do byte dos pinos de entrada no Arduino e armazena no vetor de bytes "binByteRAM".
    binByteRAM[0] = digitalRead2(din0);
    binByteRAM[1] = digitalRead2(din1);
    binByteRAM[2] = digitalRead2(din2);
    binByteRAM[3] = digitalRead2(din3);
    binByteRAM[4] = digitalRead2(din4);
    binByteRAM[5] = digitalRead2(din5);
    binByteRAM[6] = digitalRead2(din6);
    binByteRAM[7] = digitalRead2(din7);
  
    // Converte bytes lidos para string e armazena o resultado no vetor de caracteres "binCharRAM", para ser impresso na tela.
    sprintf(binCharRAM, "%i%i%i%i%i%i%i%i", binByteRAM[7], binByteRAM[6], binByteRAM[5], binByteRAM[4], binByteRAM[3], binByteRAM[2], binByteRAM[1], binByteRAM[0]);

    // Imprime o dado na posição correta da tela, de acordo com o indice do byte lido.
    switch(i)
    {
      // 1º byte.
      case 0:

        // Escreve layout da memória na tela.
        TV.print(25, 54, "MSB");
        TV.print(75, 54, "LSB");
      
        TV.draw_line(38, 52, 38, 90, 1);
        TV.draw_line(72, 52, 72, 90, 1);
        TV.draw_line(38, 52, 73, 52, 1);
        TV.draw_line(38, 90, 73, 90, 1);
      
        TV.draw_line(38, 81, 73, 81, 1);
        TV.draw_line(38, 71, 73, 71, 1);
        TV.draw_line(38, 61, 73, 61, 1);
        TV.draw_line(38, 51, 73, 51, 1);
      
        // Escreve na TV o byte lido da memória.
        TV.print(40,84, binCharRAM);
      
        // Escreve endereço bas, informado para leitura na RAM.
        TV.print(76,84, 'x');
        TV.print(80,84, hexaAddressRAM[0]);
        TV.print(84,84, hexaAddressRAM[1]);

        break;

      // 2º byte.
      case 1:

        // Escreve na TV o byte lido da memória.
        TV.print(40,74, binCharRAM);

        break;

      // 3º byte.
      case 2:

        // Escreve na TV o byte lido da memória.
        TV.print(40,64, binCharRAM);

        break;

      // 4º byte.
      case 3:

        // Escreve na TV o byte lido da memória.
        TV.print(40,54, binCharRAM);

        break;
    }

    // Incrementa o endereço base a ser lido, para assim, na próxima iteração poder ler o próximo byte.
    addrInt++;

    // Solicita ao MIPS que entre em estado IDLE e em seguida aguarda "delayFPGA" microssegundos antes da próxima iteração.
    solicitaIDLE();

    delayMicroseconds(delayFPGA);
  }

  // Desliga o LED de acesso ao FPGA.
  digitalWrite2(pinLedFPGA, LOW);
}



/**
 * Método para leitura de dados presentes nas posições do banco de registradores.
 */
void leREGS()
{
    // Variável auxiliar ao realizar a leitura dos dados do registrador selecionado e salvá-los no vetor "binByteREG".
    byte base;
  
    // Liga LED de acesso ao FPGA.
    digitalWrite2(pinLedFPGA, HIGH);

    // Percorre todos os Registradores de propósito geral, ou seja, do endereço 00 ao endereço 33.
    for(int i = 0; i < 34; i++)
    {
      // Zera variável "base".
      base = 0;

      // Solicita a leitura byte a byte do registrador em questão.
      for(int j = 0; j < 4; j++)
      {
        // Escreve o valor do opCode "011" nos pinos correspondentes, solicitando que o MIPS entre 
        // em modo de debug do Banco de Registradores.
        digitalWrite2(opCode2, LOW);
        digitalWrite2(opCode1, HIGH);
        digitalWrite2(opCode0, HIGH);

        // Converte o valor j, pois esse será utilizado para informar ao MIPS qual byte está sendo solicitado daquele registrador.
        converteDecimalBinario(j, binaryAddressREG, 8);

        // Escreve o valor j convertido no barramento de dados.
        for(int k = 0; k < 8; k++)
        {
          digitalWrite2(pinosDataOUT[k], binaryAddressREG[k]);
        } 

        // Converte endereço do i-ésimo registrador a ser lido para notação binária.
        converteDecimalBinario(i, binaryAddressREG, 8);
  
        // Após a conversão, percorre o vetor onde está salvo o endereço convertido e escreve seus valores (digitalWrite2) nos pinos de endereço correspondente.
        for(int k = 0; k < 8; k++)
        {
          digitalWrite2(pinosAddress[k], binaryAddressREG[k]);
        } 
        
        // Aguarda borda de subida do clock.
        while(digitalRead2(pinClock) != 1){}
      
        // Reseta circuito do FPGA.
        digitalWrite2(reset, HIGH);
      
        // Aguarda borda de subida do clock.
        while(digitalRead2(pinClock) != 1){}
  
        // Desliga o pino de reset (i.e. '0').
        digitalWrite2(reset, LOW);
  
        // Aguarda resposta "ready = 011" do FPGA, sinalizando que o dado do j-ésimo byte do dado do registrador endereçado está pronto nos pinos correspondentes.
        while(! ((digitalRead2(ready2) == LOW) && (digitalRead2(ready1) == HIGH) && (digitalRead2(ready0) == HIGH)) ) {}
          
        // Lê dados do j-ésimo byte dos pinos de entrada no Arduino e armazena nas posições corretas (k + base) do vetor de bytes "binByteREG".
        for(int k = 0; k < 8; k++)
        {
          binByteREG[k + base] = digitalRead2(pinosDataIN[k]);
        }

        // Incrementa o índice de base;
        base += 8;

        // Solicita ao MIPS que entre em estado IDLE e em seguida aguarda "delayFPGA" microssegundos antes da próxima iteração.
        solicitaIDLE();
  
        delayMicroseconds(delayFPGA);

      }

      // Converte bytes lidos para string e armazena o resultado no vetor de caracteres "binCharREG", para ser impresso na tela.
      sprintf(binCharREG, "%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i", binByteREG[31], binByteREG[30], binByteREG[29], binByteREG[28], binByteREG[27], binByteREG[26], binByteREG[25],binByteREG[24], binByteREG[23], binByteREG[22], binByteREG[21], binByteREG[20], binByteREG[19], binByteREG[18], binByteREG[17], binByteREG[16], binByteREG[15], binByteREG[14], binByteREG[13], binByteREG[12], binByteREG[11], binByteREG[10], binByteREG[9], binByteREG[8], binByteREG[7], binByteREG[6], binByteREG[5], binByteREG[4], binByteREG[3], binByteREG[2], binByteREG[1], binByteREG[0]);

      // Converte os dados armazenados na string para a base hexadecimal, salvando o resultado na variável "hexDataREG".
      converteBinarioHexa(binCharREG, 8);

      // Armazena na devida posição da matriz de dados do banco de registradores, o valor do lido do registrador atual.
      strcpy(matrizRegsChar[i], hexDataREG);

      // Solicita ao MIPS que entre em estado IDLE e em seguida aguarda "delayFPGA" microssegundos antes da próxima iteração.
      solicitaIDLE();

      delayMicroseconds(delayFPGA);
    }

    // Desliga o LED de acesso ao FPGA.
    digitalWrite2(pinLedFPGA, LOW);
}




/**
 * Procedimento que dada a instrução presente na variável global "instrucao"
 * retira os espaços em branco no início e final, separa e armazena em um posição de vetor,
 * cada item separado por espaço na instrução.
 */
void splitInstrucao(String instrucao)
{
  int i = 0;

  String instrucaoAtual = instrucao;

  // Percorre a instrução enquanto ela conter um caractere.
  while(instrucaoAtual != "")
  {
    // Retira espaços em branco do início e fim da string.
    instrucaoAtual.trim();

    // Armazena na posição "i" a primeira palavra antes de um espaço na string.
    stringsInstrucao[i] = instrucaoAtual.substring(0, instrucaoAtual.indexOf(' '));    

    // Retira a palavra anteriormente adicionada ao vetor da string.
    instrucaoAtual = instrucaoAtual.substring(instrucaoAtual.indexOf(' '), instrucaoAtual.length());

    // Atualiza contador.
    i++;
  }
}


/**
 * Método onde informados limites superiores e inferiores, copia os dados
 * presentes no vetor "data" para "instrucaoBytes". Utilizado para preencher
 * a instrução atual binária com os dados de cada um dos campos (RS, RT, RD)
 * convertidos da instrução lida do cartão SD.
 */
void preencheInstrucao(int sup, int inf,int size, byte *data)
{
  for(int i = sup; i >= inf; i--)
  {
    instrucaoBytes[i] = data[size - 1];
    size--;
  }
}


/**
 * Método principal para conversão da instrução lida do cartão SD e já separada
 * em segmentos pelo método "splitInstrucao".
 */
void converteInstrucao()
{
    String opCode_String;
    String funct_Sring;
    String rs_String;
    String rt_String;
    String rd_String;
    String shamt_String;
    String imm_String;
    String off_String;
    String addr_String;
  
    // Instancia um vetor para armazenar o valor do campo "opCode" em binário, após conversão.
    byte opCode_Binary[6];

    // Instancia um vetor para armazenar o valor do campo "rs" em binário, após conversão.
    byte rs_Binary[5];

    // Instancia um vetor para armazenar o valor do campo "rt" em binário, após conversão.
    byte rt_Binary[5];

    // Instancia um vetor para armazenar o valor do campo "rd" em binário, após conversão.
    byte rd_Binary[5];

    // Instancia um vetor para armazenar o valor do campo "shamt" em binário, após conversão.
    byte shamt_Binary[5];

    // Instancia um vetor para armazenar o valor do campo "imm" em binário, após conversão.
    byte imm_Binary[16];

    // Instancia um vetor para armazenar o valor do campo "offset" em binário, após conversão.
    byte off_Binary[16];

    // Instancia um vetor para armazenar o valor do campo "addr" em binário, após conversão.
    byte addr_Binary[26];


// Filtra instruções por opCode ASCII.

    /*|-----------------------------------------|
     *|                                         |
     *| Início das instruções com opCode 000000 |
     *|                                         | 
     *|-----------------------------------------|*/

    // Instrução ADD (Add Word).
    if(stringsInstrucao[0].equals("ADD"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[2];
      rt_String = stringsInstrucao[3];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 1;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 0;
    }


    // Instrução ADDU (Add Unsigned Word).
    else if(stringsInstrucao[0].equals("ADDU"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[2];
      rt_String = stringsInstrucao[3];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 1;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 1;
    }


    // Instrução AND.
    else if(stringsInstrucao[0].equals("AND"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[2];
      rt_String = stringsInstrucao[3];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 1;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 1;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 0;
    }


    // Instrução DIV (Divide Word).
    else if(stringsInstrucao[0].equals("DIV"))
    {
      // Carrega valores de RS e RT.
      rs_String = stringsInstrucao[1];
      rt_String = stringsInstrucao[2];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      instrucaoBytes[15] = 0;
      instrucaoBytes[14] = 0;
      instrucaoBytes[13] = 0;
      instrucaoBytes[12] = 0;
      instrucaoBytes[11] = 0;
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 1;
      instrucaoBytes[3] = 1;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 0;
    }


    // Instrução DIVU (Divide Unsigned Word).
    else if(stringsInstrucao[0].equals("DIVU"))
    {
      // Carrega valores de RS e RT.
      rs_String = stringsInstrucao[1];
      rt_String = stringsInstrucao[2];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      instrucaoBytes[15] = 0;
      instrucaoBytes[14] = 0;
      instrucaoBytes[13] = 0;
      instrucaoBytes[12] = 0;
      instrucaoBytes[11] = 0;
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 1;
      instrucaoBytes[3] = 1;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 1;
    }


    // Instrução JALR (Jump and Link Register).
    else if(stringsInstrucao[0].equals("JALR"))
    {
      // Carrega valores de RS e RD.
      rs_String = stringsInstrucao[2];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      instrucaoBytes[20] = 0;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 0;
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 1;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 1;
    }


    // Instrução JR (Jump Register).
    else if(stringsInstrucao[0].equals("JR"))
    {
      // Carrega valor de RS.
      rs_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      instrucaoBytes[20] = 0;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 0;
      
      //RD
      instrucaoBytes[15] = 0;
      instrucaoBytes[14] = 0;
      instrucaoBytes[13] = 0;
      instrucaoBytes[12] = 0;
      instrucaoBytes[11] = 0;
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 1;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 0;
    }


    // Instrução MFHI (Move From HI Register).
    else if(stringsInstrucao[0].equals("MFHI"))
    {
      // Carrega valor de RD.
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      instrucaoBytes[25] = 0;
      instrucaoBytes[24] = 0;
      instrucaoBytes[23] = 0;
      instrucaoBytes[22] = 0;
      instrucaoBytes[21] = 0;
      
      //RT
      instrucaoBytes[20] = 0;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 0;

      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 1;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 0;
    }


    // Instrução MFLO (Move From LO Register).
    else if(stringsInstrucao[0].equals("MFLO"))
    {
      // Carrega valor de RD.
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      instrucaoBytes[25] = 0;
      instrucaoBytes[24] = 0;
      instrucaoBytes[23] = 0;
      instrucaoBytes[22] = 0;
      instrucaoBytes[21] = 0;
      
      //RT
      instrucaoBytes[20] = 0;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 0;

      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 1;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 0;
    }


    // Instrução MOVN (Move Conditional on Not Zero).
    else if(stringsInstrucao[0].equals("MOVN"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[2];
      rt_String = stringsInstrucao[3];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 1;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 1;
    }


    // Instrução MOVZ (Move Conditional on Zero).
    else if(stringsInstrucao[0].equals("MOVZ"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[2];
      rt_String = stringsInstrucao[3];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 1;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 0;
    }


    // Instrução MTHI (Move to HI Register).
    else if(stringsInstrucao[0].equals("MTHI"))
    {
      // Carrega valor de RS.
      rs_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      instrucaoBytes[20] = 0;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 0;
      
      //RD
      instrucaoBytes[15] = 0;
      instrucaoBytes[14] = 0;
      instrucaoBytes[13] = 0;
      instrucaoBytes[12] = 0;
      instrucaoBytes[11] = 0;
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 1;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 1;
    }


    // Instrução MTLO (Move to LO Register).
    else if(stringsInstrucao[0].equals("MTLO"))
    {
      // Carrega valor de RS.
      rs_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      instrucaoBytes[20] = 0;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 0;
      
      //RD
      instrucaoBytes[15] = 0;
      instrucaoBytes[14] = 0;
      instrucaoBytes[13] = 0;
      instrucaoBytes[12] = 0;
      instrucaoBytes[11] = 0;
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 1;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 1;
    }


    // Instrução MULT (Multiply Word).
    else if(stringsInstrucao[0].equals("MULT"))
    {
      // Carrega valor de RS e RT.
      rs_String = stringsInstrucao[1];
      rt_String = stringsInstrucao[2];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rt_Binary), rt_Binary);
      
      //RD
      instrucaoBytes[15] = 0;
      instrucaoBytes[14] = 0;
      instrucaoBytes[13] = 0;
      instrucaoBytes[12] = 0;
      instrucaoBytes[11] = 0;
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 1;
      instrucaoBytes[3] = 1;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 0;
    }


    // Instrução MULTU (Multiply Unsigned Word).
    else if(stringsInstrucao[0].equals("MULTU"))
    {
      // Carrega valores de RS e RT.
      rs_String = stringsInstrucao[1];
      rt_String = stringsInstrucao[2];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rt_Binary), rt_Binary);
      
      //RD
      instrucaoBytes[15] = 0;
      instrucaoBytes[14] = 0;
      instrucaoBytes[13] = 0;
      instrucaoBytes[12] = 0;
      instrucaoBytes[11] = 0;
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 1;
      instrucaoBytes[3] = 1;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 1;
    }


    // Instrução NOP (No Operation).
    else if(stringsInstrucao[0].equals("NOP"))
    {
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      instrucaoBytes[25] = 0;
      instrucaoBytes[24] = 0;
      instrucaoBytes[23] = 0;
      instrucaoBytes[22] = 0;
      instrucaoBytes[21] = 0;

      //RT
      instrucaoBytes[20] = 0;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 0;
      
      //RD
      instrucaoBytes[15] = 0;
      instrucaoBytes[14] = 0;
      instrucaoBytes[13] = 0;
      instrucaoBytes[12] = 0;
      instrucaoBytes[11] = 0;
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 0;
    }


    // Instrução NOR (Not Or).
    else if(stringsInstrucao[0].equals("NOR"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[2];
      rt_String = stringsInstrucao[3];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 1;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 1;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 1;
    }


    // Instrução OR (Or).
    else if(stringsInstrucao[0].equals("OR"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[2];
      rt_String = stringsInstrucao[3];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 1;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 1;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 1;
    }


    // Instrução SLL (Shift Word Left Logical).
    else if(stringsInstrucao[0].equals("SLL"))
    {
      // Carrega valores de RT, RD e Shamt.
      rt_String = stringsInstrucao[2];
      rd_String = stringsInstrucao[1];
      shamt_String = stringsInstrucao[3];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      instrucaoBytes[25] = 0;
      instrucaoBytes[24] = 0;
      instrucaoBytes[23] = 0;
      instrucaoBytes[22] = 0;
      instrucaoBytes[21] = 0;

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      converteDecimalBinario(shamt_String.toInt(), shamt_Binary, 5);
      preencheInstrucao(10, 6, sizeof(shamt_Binary), shamt_Binary);

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 0;
    }


    // Instrução SLLV (Shift Word Left Logical Variable).
    else if(stringsInstrucao[0].equals("SLLV"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[3];
      rt_String = stringsInstrucao[2];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 1;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 0;
    }


    // Instrução SLT (Set on Less Than).
    else if(stringsInstrucao[0].equals("SLT"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[2];
      rt_String = stringsInstrucao[3];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 1;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 1;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 0;
    }


    // Instrução SLTU (Set on Less Than Unsigned).
    else if(stringsInstrucao[0].equals("SLTU"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[2];
      rt_String = stringsInstrucao[3];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 1;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 1;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 1;
    }


    // Instrução SRA (Shift Word Right Arithmetic).
    else if(stringsInstrucao[0].equals("SRA"))
    {
      // Carrega valores de Shamt, RT e RD.
      shamt_String = stringsInstrucao[3];
      rt_String = stringsInstrucao[2];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      instrucaoBytes[25] = 0;
      instrucaoBytes[24] = 0;
      instrucaoBytes[23] = 0;
      instrucaoBytes[22] = 0;
      instrucaoBytes[21] = 0;

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      converteDecimalBinario(shamt_String.toInt(), shamt_Binary, 5);
      preencheInstrucao(10, 6, sizeof(shamt_Binary), shamt_Binary);

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 1;
    }


    // Instrução SRAV (Shift Word Right Arithmetic Variable).
    else if(stringsInstrucao[0].equals("SRAV"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[3];
      rt_String = stringsInstrucao[2];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 1;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 1;
    }


    // Instrução SRL (Shift Word Right Logical).
    else if(stringsInstrucao[0].equals("SRL"))
    {
      // Carrega valores de RT, RD e Shamt.
      rt_String = stringsInstrucao[2];
      rd_String = stringsInstrucao[1];
      shamt_String = stringsInstrucao[3];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      instrucaoBytes[25] = 0;
      instrucaoBytes[24] = 0;
      instrucaoBytes[23] = 0;
      instrucaoBytes[22] = 0;
      instrucaoBytes[21] = 0;

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      converteDecimalBinario(shamt_String.toInt(), shamt_Binary, 5);
      preencheInstrucao(10, 6, sizeof(shamt_Binary), shamt_Binary);

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 0;
    }


    // Instrução SRLV (Shift Word Right Logical Variable).
    else if(stringsInstrucao[0].equals("SRLV"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[3];
      rt_String = stringsInstrucao[2];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 1;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 0;
    }


    // Instrução SUB (Subtract Word).
    else if(stringsInstrucao[0].equals("SUB"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[2];
      rt_String = stringsInstrucao[3];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 1;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 0;
    }


    // Instrução SUBU (Subtract Unsigned Word).
    else if(stringsInstrucao[0].equals("SUBU"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[2];
      rt_String = stringsInstrucao[3];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 1;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 1;
    }


    // Instrução XOR (Exclusive OR).
    else if(stringsInstrucao[0].equals("XOR"))
    {
      // Carrega valores de RS, RT e RD.
      rs_String = stringsInstrucao[2];
      rt_String = stringsInstrucao[3];
      rd_String = stringsInstrucao[1];

      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);
      
      //Shamt
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 1;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 1;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 0;
    } 
    
    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 000000   |
     *|                                         |
     *| Início das instruções com opCode 000001 |
     *|-----------------------------------------|*/

    // Instrução BAL (Branch and Link).
    else if(stringsInstrucao[0].equals("BAL"))
    {
      // Carrega valor de Addr (Offset).
      off_String = stringsInstrucao[1];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 1;

      //RS
      instrucaoBytes[25] = 0;
      instrucaoBytes[24] = 0;
      instrucaoBytes[23] = 0;
      instrucaoBytes[22] = 0;
      instrucaoBytes[21] = 0;

      //BGEZAL
      instrucaoBytes[20] = 1;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 1;

      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    } 


    // Instrução BGEZ (Branch on Greater Than or Equal to Zero).
    else if(stringsInstrucao[0].equals("BGEZ"))
    {
      // Carrega valores de RS e Addr (Offset).
      rs_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 1;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //BGEZ
      instrucaoBytes[20] = 0;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 1;

      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    } 


    // Instrução BGEZAL (Branch on Greater Than or Equal to Zero and Link).
    else if(stringsInstrucao[0].equals("BGEZAL"))
    {
      // Carrega valores de RS e Addr (Offset).
      rs_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 1;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //BGEZAL
      instrucaoBytes[20] = 1;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 1;

      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    } 


    // Instrução BLTZ (Branch on Less Than Zero).
    else if(stringsInstrucao[0].equals("BLTZ"))
    {
      // Carrega valores de RS e Addr (Offset).
      rs_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 1;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //BLTZ
      instrucaoBytes[20] = 0;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 0;

      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    } 


    // Instrução BLTZAL (Branch on Less Than Zero and Link).
    else if(stringsInstrucao[0].equals("BLTZAL"))
    {
      // Carrega valores de RS e Addr (Offset).
      rs_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 1;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //BLTZ
      instrucaoBytes[20] = 1;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 0;

      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    } 

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 000001   |
     *|                                         |
     *| Início das instruções com opCode 000010 |
     *|-----------------------------------------|*/

    // Instrução J (Jump).
    else if(stringsInstrucao[0].equals("J"))
    {
      // Carrega valor de Addr.
      addr_String = stringsInstrucao[1];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 1;
      instrucaoBytes[26] = 0;

      //Addr
      converteDecimalBinario(addr_String.toInt(), addr_Binary, 26);
      preencheInstrucao(25, 0, sizeof(addr_Binary), addr_Binary);
    } 

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 000010   |
     *|                                         |
     *| Início das instruções com opCode 000011 |
     *|-----------------------------------------|*/

    // Instrução JAL (Jump and Link).
    else if(stringsInstrucao[0].equals("JAL"))
    {
      // Carrega valor de Addr.
      addr_String = stringsInstrucao[1];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 1;
      instrucaoBytes[26] = 1;

      //Addr
      converteDecimalBinario(addr_String.toInt(), addr_Binary, 26);
      preencheInstrucao(25, 0, sizeof(addr_Binary), addr_Binary);
    } 

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 000011   |
     *|                                         |
     *| Início das instruções com opCode 000100 |
     *|-----------------------------------------|*/

    // Instrução B (Unconditional Branch).
    else if(stringsInstrucao[0].equals("B"))
    {
      // Carrega valor de Addr (Offset).
      off_String = stringsInstrucao[1];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      instrucaoBytes[25] = 0;
      instrucaoBytes[24] = 0;
      instrucaoBytes[23] = 0;
      instrucaoBytes[22] = 0;
      instrucaoBytes[21] = 0;

      //RT
      instrucaoBytes[20] = 0;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 0;

      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    } 


    // Instrução BEQ (Branch on Equal).
    else if(stringsInstrucao[0].equals("BEQ"))
    {
      // Carrega valores de RS, RT e Addr (Offset).
      rs_String   = stringsInstrucao[1];
      rt_String   = stringsInstrucao[2];
      off_String = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);

      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    } 

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 000100   |
     *|                                         |
     *| Início das instruções com opCode 000101 |
     *|-----------------------------------------|*/

    // Instrução BNE (Branch on Not Equal).
    else if(stringsInstrucao[0].equals("BNE"))
    {
      // Carrega valores de RS, RT e Addr (Offset).
      rs_String   = stringsInstrucao[1];
      rt_String   = stringsInstrucao[2];
      off_String = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 1;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);

      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 000101   |
     *|                                         |
     *| Início das instruções com opCode 000110 |
     *|-----------------------------------------|*/

    // Instrução BLEZ (Branch on Less Than or Equal to Zero).
    else if(stringsInstrucao[0].equals("BLEZ"))
    {
      // Carrega valores de RS e Addr (Offset).
      rs_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 1;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      instrucaoBytes[20] = 0;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 0;

      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 000110   |
     *|                                         |
     *| Início das instruções com opCode 000111 |
     *|-----------------------------------------|*/

    // Instrução BGTZ (Branch on Greater Than Zero).
    else if(stringsInstrucao[0].equals("BGTZ"))
    {
      // Carrega valores de RS e Addr (Offset).
      rs_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 1;
      instrucaoBytes[26] = 1;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      instrucaoBytes[20] = 0;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 0;

      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 000111   |
     *|                                         |
     *| Início das instruções com opCode 001000 |
     *|-----------------------------------------|*/

    // Instrução ADDI (Add Immediate Word).
    else if(stringsInstrucao[0].equals("ADDI"))
    {
      // Carrega valores de RT, RS e Addr (Immediate).
      rt_String   = stringsInstrucao[1];
      rs_String   = stringsInstrucao[2];
      imm_String = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);

      //Addr (Immediate)
      converteDecimalBinario(imm_String.toInt(), imm_Binary, 16);
      preencheInstrucao(15, 0, sizeof(imm_Binary), imm_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 001000   |
     *|                                         |
     *| Início das instruções com opCode 001001 |
     *|-----------------------------------------|*/

    // Instrução ADDIU (Add Immediate Unsigned Word).
    else if(stringsInstrucao[0].equals("ADDIU"))
    {
      // Carrega valores de RT, RS e Addr (Immediate).
      rt_String   = stringsInstrucao[1];
      rs_String   = stringsInstrucao[2];
      imm_String = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 1;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);

      //Addr (Immediate)
      converteDecimalBinario(imm_String.toInt(), imm_Binary, 16);
      preencheInstrucao(15, 0, sizeof(imm_Binary), imm_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 001001   |
     *|                                         |
     *| Início das instruções com opCode 001010 |
     *|-----------------------------------------|*/

    // Instrução SLTI (Set on Less Than Immediate).
    else if(stringsInstrucao[0].equals("SLTI"))
    {
      // Carrega valores de RT, RS e Addr (Immediate).
      rt_String   = stringsInstrucao[1];
      rs_String   = stringsInstrucao[2];
      imm_String = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 1;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);

      //Addr (Immediate)
      converteDecimalBinario(imm_String.toInt(), imm_Binary, 16);
      preencheInstrucao(15, 0, sizeof(imm_Binary), imm_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 001010   |
     *|                                         |
     *| Início das instruções com opCode 001011 |
     *|-----------------------------------------|*/

    // Instrução SLTIU (Set on Less Than Immediate Unsigned).
    else if(stringsInstrucao[0].equals("SLTIU"))
    {
      // Carrega valores de RT, RS e Addr (Immediate).
      rt_String   = stringsInstrucao[1];
      rs_String   = stringsInstrucao[2];
      imm_String = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 1;
      instrucaoBytes[26] = 1;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);

      //Addr (Immediate)
      converteDecimalBinario(imm_String.toInt(), imm_Binary, 16);
      preencheInstrucao(15, 0, sizeof(imm_Binary), imm_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 001011   |
     *|                                         |
     *| Início das instruções com opCode 001100 |
     *|-----------------------------------------|*/

    // Instrução ANDI (And Immediate).
    else if(stringsInstrucao[0].equals("ANDI"))
    {
      // Carrega valores de RT, RS e Addr (Immediate).
      rt_String   = stringsInstrucao[1];
      rs_String   = stringsInstrucao[2];
      imm_String = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);

      //Addr (Immediate)
      converteDecimalBinario(imm_String.toInt(), imm_Binary, 16);
      preencheInstrucao(15, 0, sizeof(imm_Binary), imm_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 001100   |
     *|                                         |
     *| Início das instruções com opCode 001101 |
     *|-----------------------------------------|*/

    // Instrução ORI (Or Immediate).
    else if(stringsInstrucao[0].equals("ORI"))
    {
      // Carrega valores de RT, RS e Addr (Immediate).
      rt_String   = stringsInstrucao[1];
      rs_String   = stringsInstrucao[2];
      imm_String = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 1;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);

      //Addr (Immediate)
      converteDecimalBinario(imm_String.toInt(), imm_Binary, 16);
      preencheInstrucao(15, 0, sizeof(imm_Binary), imm_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 001101   |
     *|                                         |
     *| Início das instruções com opCode 001110 |
     *|-----------------------------------------|*/

    // Instrução XORI (Exclusive Or Immediate).
    else if(stringsInstrucao[0].equals("XORI"))
    {
      // Carrega valores de RT, RS e Addr (Immediate).
      rt_String   = stringsInstrucao[1];
      rs_String   = stringsInstrucao[2];
      imm_String = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 1;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);

      //Addr (Immediate)
      converteDecimalBinario(imm_String.toInt(), imm_Binary, 16);
      preencheInstrucao(15, 0, sizeof(imm_Binary), imm_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 001110   |
     *|                                         |
     *| Início das instruções com opCode 001111 |
     *|-----------------------------------------|*/

    // Instrução LUI (Load Upper Immediate).
    else if(stringsInstrucao[0].equals("LUI"))
    {
      // Carrega valores de RT e Addr (Immediate).
      rt_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 1;
      instrucaoBytes[26] = 1;

      //RS
      instrucaoBytes[25] = 0;
      instrucaoBytes[24] = 0;
      instrucaoBytes[23] = 0;
      instrucaoBytes[22] = 0;
      instrucaoBytes[21] = 0;

      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);

      //Addr (Immediate)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 001111   |
     *|                                         |
     *| Início das instruções com opCode 011100 |
     *|-----------------------------------------|*/

    // Instrução CLO (Count Leading Ones in Word).
    else if(stringsInstrucao[0].equals("CLO"))
    {
      // Carrega valores de RD e RS.
      rd_String = stringsInstrucao[1];
      rs_String = stringsInstrucao[2];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 1;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      instrucaoBytes[20] = 0;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 0;

      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);

      //0
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 1;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 1;
    }


    // Instrução CLZ (Count Leading Zeros in Word).
    else if(stringsInstrucao[0].equals("CLZ"))
    {
      // Carrega valores de RD e RS.
      rd_String = stringsInstrucao[1];
      rs_String = stringsInstrucao[2];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 1;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      instrucaoBytes[20] = 0;
      instrucaoBytes[19] = 0;
      instrucaoBytes[18] = 0;
      instrucaoBytes[17] = 0;
      instrucaoBytes[16] = 0;

      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);

      //0
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 1;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 0;
    }


    // Instrução MADD (Multiply and Add Word to Hi,Lo).
    else if(stringsInstrucao[0].equals("MADD"))
    {
      // Carrega valores de RS e RT.
      rs_String = stringsInstrucao[1];
      rt_String = stringsInstrucao[2];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 1;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //0
      instrucaoBytes[15] = 0;
      instrucaoBytes[14] = 0;
      instrucaoBytes[13] = 0;
      instrucaoBytes[12] = 0;
      instrucaoBytes[11] = 0;
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 0;
    }


    // Instrução MADDU (Multiply and Add Unsigned Word to Hi,Lo).
    else if(stringsInstrucao[0].equals("MADDU"))
    {
      // Carrega valores de RS e RT.
      rs_String = stringsInstrucao[1];
      rt_String = stringsInstrucao[2];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 1;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //0
      instrucaoBytes[15] = 0;
      instrucaoBytes[14] = 0;
      instrucaoBytes[13] = 0;
      instrucaoBytes[12] = 0;
      instrucaoBytes[11] = 0;
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 1;
    }


    // Instrução MSUB (Multiply and Subtract Word to Hi,Lo).
    else if(stringsInstrucao[0].equals("MSUB"))
    {
      // Carrega valores de RS e RT.
      rs_String = stringsInstrucao[1];
      rt_String = stringsInstrucao[2];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 1;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //0
      instrucaoBytes[15] = 0;
      instrucaoBytes[14] = 0;
      instrucaoBytes[13] = 0;
      instrucaoBytes[12] = 0;
      instrucaoBytes[11] = 0;
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 1;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 0;
    }


    // Instrução MSUBU (Multiply and Subtract Word to Hi,Lo).
    else if(stringsInstrucao[0].equals("MSUBU"))
    {
      // Carrega valores de RS e RT.
      rs_String = stringsInstrucao[1];
      rt_String = stringsInstrucao[2];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 1;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //0
      instrucaoBytes[15] = 0;
      instrucaoBytes[14] = 0;
      instrucaoBytes[13] = 0;
      instrucaoBytes[12] = 0;
      instrucaoBytes[11] = 0;
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 1;
      instrucaoBytes[1] = 0;
      instrucaoBytes[0] = 1;
    }


    // Instrução MUL (Multiply Word to GPR).
    else if(stringsInstrucao[0].equals("MUL"))
    {
      // Carrega valores de RD, RS e RT.
      rd_String = stringsInstrucao[1];
      rs_String = stringsInstrucao[2];
      rt_String = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 0;
      instrucaoBytes[30] = 1;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //RD
      converteDecimalBinario(rd_String.toInt(), rd_Binary, 5);
      preencheInstrucao(15, 11, sizeof(rd_Binary), rd_Binary);

      //0
      instrucaoBytes[10] = 0;
      instrucaoBytes[9]  = 0;
      instrucaoBytes[8]  = 0;
      instrucaoBytes[7]  = 0;
      instrucaoBytes[6]  = 0;

      //Funct
      instrucaoBytes[5] = 0;
      instrucaoBytes[4] = 0;
      instrucaoBytes[3] = 0;
      instrucaoBytes[2] = 0;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 0;
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 011100   |
     *|                                         |
     *| Início das instruções com opCode 100000 |
     *|-----------------------------------------|*/
    
    // Instrução LB (Load Byte).
    else if(stringsInstrucao[0].equals("LB"))
    {
      // Carrega valores de RT, Addr (Offset) e RS (Base).
      rt_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      rs_String   = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 1;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS (Base)
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 100000   |
     *|                                         |
     *| Início das instruções com opCode 100001 |
     *|-----------------------------------------|*/
    
    // Instrução LH (Load Halfword).
    else if(stringsInstrucao[0].equals("LH"))
    {
      // Carrega valores de RT, Addr (Offset) e RS (Base).
      rt_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      rs_String   = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 1;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 1;

      //RS (Base)
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 100001   |
     *|                                         |
     *| Início das instruções com opCode 100011 |
     *|-----------------------------------------|*/
    
    // Instrução LW (Load Word).
    else if(stringsInstrucao[0].equals("LW"))
    {
      // Carrega valores de RT, Addr (Offset) e RS (Base).
      rt_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      rs_String   = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 1;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 1;
      instrucaoBytes[26] = 1;

      //RS (Base)
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 100011   |
     *|                                         |
     *| Início das instruções com opCode 100100 |
     *|-----------------------------------------|*/
    
    // Instrução LBU (Load Byte Unsigned).
    else if(stringsInstrucao[0].equals("LBU"))
    {
      // Carrega valores de RT, Addr (Offset) e RS (Base).
      rt_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      rs_String   = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 1;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS (Base)
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 100100   |
     *|                                         |
     *| Início das instruções com opCode 100101 |
     *|-----------------------------------------|*/
    
    // Instrução LHU (Load Halfword Unsigned).
    else if(stringsInstrucao[0].equals("LHU"))
    {
      // Carrega valores de RT, Addr (Offset) e RS (Base).
      rt_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      rs_String   = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 1;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 0;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 1;

      //RS (Base)
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 100101   |
     *|                                         |
     *| Início das instruções com opCode 101000 |
     *|-----------------------------------------|*/
    
    // Instrução SB (Store Byte).
    else if(stringsInstrucao[0].equals("SB"))
    {
      // Carrega valores de RT, Addr (Offset) e RS (Base).
      rt_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      rs_String   = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 1;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 0;

      //RS (Base)
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 101000   |
     *|                                         |
     *| Início das instruções com opCode 101001 |
     *|-----------------------------------------|*/
    
    // Instrução SH (Store Halfword).
    else if(stringsInstrucao[0].equals("SH"))
    {
      // Carrega valores de RT, Addr (Offset) e RS (Base).
      rt_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      rs_String   = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 1;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 0;
      instrucaoBytes[26] = 1;

      //RS (Base)
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    }

    /*|-----------------------------------------|
     *|  Fim das instruções com opCode 101001   |
     *|                                         |
     *| Início das instruções com opCode 101011 |
     *|-----------------------------------------|*/
    
    // Instrução SW (Store Word).
    else if(stringsInstrucao[0].equals("SW"))
    {
      // Carrega valores de RT, Addr (Offset) e RS (Base).
      rt_String   = stringsInstrucao[1];
      off_String = stringsInstrucao[2];
      rs_String   = stringsInstrucao[3];
      
      //OpCode
      instrucaoBytes[31] = 1;
      instrucaoBytes[30] = 0;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 0;
      instrucaoBytes[27] = 1;
      instrucaoBytes[26] = 1;

      //RS (Base)
      converteDecimalBinario(rs_String.toInt(), rs_Binary, 5);
      preencheInstrucao(25, 21, sizeof(rs_Binary), rs_Binary);
      
      //RT
      converteDecimalBinario(rt_String.toInt(), rt_Binary, 5);
      preencheInstrucao(20, 16, sizeof(rt_Binary), rt_Binary);
      
      //Addr (Offset)
      converteDecimalBinario(off_String.toInt(), off_Binary, 16);
      preencheInstrucao(15, 0, sizeof(off_Binary), off_Binary);
    }

    // Instrução inválida.
    else
    {
      instrucaoBytes[31] = 1;
      instrucaoBytes[30] = 1;
      instrucaoBytes[29] = 1;
      instrucaoBytes[28] = 1;
      instrucaoBytes[27] = 1;
      instrucaoBytes[26] = 1;
      instrucaoBytes[25] = 1;
      instrucaoBytes[24] = 1;
      instrucaoBytes[23] = 1;
      instrucaoBytes[22] = 1;
      instrucaoBytes[21] = 1;
      instrucaoBytes[20] = 1;
      instrucaoBytes[19] = 1;
      instrucaoBytes[18] = 1;
      instrucaoBytes[17] = 1;
      instrucaoBytes[16] = 1;
      instrucaoBytes[15] = 1;
      instrucaoBytes[14] = 1;
      instrucaoBytes[13] = 1;
      instrucaoBytes[12] = 1;
      instrucaoBytes[11] = 1;
      instrucaoBytes[10] = 1;
      instrucaoBytes[9] = 1;
      instrucaoBytes[8] = 1;
      instrucaoBytes[8] = 1;
      instrucaoBytes[7] = 1;
      instrucaoBytes[6] = 1;
      instrucaoBytes[5] = 1;
      instrucaoBytes[4] = 1;
      instrucaoBytes[3] = 1;
      instrucaoBytes[2] = 1;
      instrucaoBytes[1] = 1;
      instrucaoBytes[0] = 1;
    }
}
// ______________________________________________________________________________


/**
 * Procedimento responsável por imprimir a base do layout na tela da TV.
 */
void printBase()
{
  // Imprime contornos da tela.
  TV.bitmap(0,0,baseContorno);

  // Chama método para imprimir strings de itens do menu principal.
  imprimeItensMenuPrincipal();

  // Inverte faixa identificadora do item atual no menu principal (indica que o item está em foco).
  inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

  // Inverte a cor do item selecionado do menu principal.
  inverteItensMenuPrincipal(itemMenuPrincipal);
}


/**
 * Método responsável por imprimir os itens do menu principal.
 */
void imprimeItensMenuPrincipal()
{
  // Seleciona fonte.
  TV.select_font(font4x6);
  
  // Itens do Menu Principal.
  TV.print(2,2,"HOME");
  TV.print(27,2,"OPEN");
  TV.print(52,2,"REG");
  TV.print(74,2,"MEM");
  TV.print(97,2,"ABOUT");
}


/**
 * Imprime tela base para o menu de memória RAM de DADOS.
 */
void imprimeBaseMem1()
{
  TV.clear_screen();
  
  // Imprime tela.
  TV.bitmap(0,0,MEM);

  // Chama método para imprimir strings do menu principal.
  imprimeItensMenuPrincipal();

  // Inverte faixa identificadora do item atual no menu principal (indica que o item está em foco).
  inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

  // Inverte a cor do item selecionado do menu principal.
  inverteItensMenuPrincipal(itemMenuPrincipal);

  // Seleciona fonte.
  TV.select_font(font4x6);

  // Imprime strings presentes na tela.
  TV.print(3, 38, "ADDR:");
  TV.print(100, 30, "OK");
  TV.print(100, 44, "<-");
  TV.print(3, 69, "DATA:");
}


/**
 * Imprime tela base para o menu de memória RAM de Instruções.
 */
void imprimeBaseMem2()
{
  TV.clear_screen();
  
  // Imprime tela.
  TV.bitmap(0,0,MEM);

  // Chama método para imprimir strings do menu principal.
  imprimeItensMenuPrincipal();

  // Inverte faixa identificadora do item atual no menu principal (indica que o item está em foco).
  inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

  // Inverte a cor do item selecionado do menu principal.
  inverteItensMenuPrincipal(itemMenuPrincipal);

  // Seleciona fonte.
  TV.select_font(font4x6);

  // Imprime strings presentes na tela.
  TV.print(3, 38, "ADDR:");
  TV.print(100, 30, "OK");
  TV.print(100, 44, "<-");
  TV.print(3, 69, "INST:");
}


/**
 * Imprime tela base para o menu de informações.
 */
void imprimeBaseAbout()
{
  // Imprime tela.
  TV.bitmap(0,0,About);

  // Chama método para imprimir strings do menu principal.
  imprimeItensMenuPrincipal();

  // Inverte faixa identificadora do item atual no menu principal (indica que o item está em foco).
  inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

  //Inverte a cor do item selecionado do menu principal.
  inverteItensMenuPrincipal(itemMenuPrincipal);

  // Seleciona fonte.
  TV.select_font(font4x6);

  // Imprime strings presentes na tela.
  TV.print(36, 12, "MIPSDUINO 32");

  TV.print(4, 22, "TCC - Ciencia da Computacao");
  TV.print(2, 34, "> Joao Paulo F. C. Cesar");
  TV.print(2, 44, "> Otavio S. M. Gomes");
  TV.print(10, 56, "IFMG - 2016 - Formiga/MG");

  // Inverte Título.
  for(int i = 35; i < 84; i++)
  {
    for(int j = 11; j < 18; j++)
    {
      TV.set_pixel(i, j, 2);
    }
  }
}


/**
 * Imprime tela base para o menu de gerencia de arquivo, listagem de arquivos.
 */
void imprimeBaseOpen()
{
  // Imprime tela.
  TV.bitmap(0,0,openFILE);

  // Chama método para imprimir strings do menu principal.
  imprimeItensMenuPrincipal();

  // Inverte faixa identificadora do item atual no menu principal (indica que o item está em foco).
  inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

  //Inverte a cor do item selecionado do menu principal.
  inverteItensMenuPrincipal(itemMenuPrincipal);

  // Seleciona fonte.
  TV.select_font(font4x6);

  // Imprime strings presentes na tela.
  TV.print(35, 13, "NAME");
  TV.print(93, 13, "BYTES");

  // Inverte barra no topo.
  for(int i = 1; i < 117; i++)
  {
    for(int j = 10; j < 21; j++)
    {
      TV.set_pixel(i, j, 2);
    }
  }

  itemOpen = 0;

  // Caso o cartão esteja inserido, prepara para chamada do método de listagem dos arquivos
  // contidos no SD.
  if(sdInserido)
  {
    qtdArqSD = 0;
    posY = 15;
    root = SD.open("/");
    printDirectory(root);
    root.close();
  }
}


/**
 * Percorre o vetor que armazena as linhas de um arquivo e preenche com nulo cada uma das posições.
 */
void limpaVetorSD()
{
  for(int i = 0; i < MAX_QTD_LINES; i++)
  {
    linhasSD[i] = "";
  }
}


/**
 * Procedimento responsável por preencher o vetor com o conteúdo de cada linha de um determinado arquivo
 * presente no cartão SD. Cada linha será carregada em uma posição do vetor.
 */
void carregaVetorSD(String path)
{
  // Armazena o caractere lido do arquivo.
  char charLido;

  // Indica a posição do vetor atual.
  int posVetor = 0;

  // Inicializa o contador de linhas.
  contLinhasSD = 0;

  // Transforma parâmetro "path" em formato requerido pelo método SD.open().
  char pathChar[path.length()+1];
  path.toCharArray(pathChar, sizeof(pathChar));

  // Abre o arquivo.
  arquivoSD = SD.open(pathChar);  

  // Chama método para inicialização do vetor onde serão salvas as linhas.
  limpaVetorSD();

  // Caso haja caracteres a serem lidos no arquivo, i.e. não está vazio, inicializa o contador de linhas.
  if(arquivoSD.available())
  {
    contLinhasSD = 1;
  }
  
  // Enquanto existirem caracteres a serem lidos no arquivo.
  while (arquivoSD.available()) 
  {
    // Lê caractere e o armazena na variável adequada.
    charLido = arquivoSD.read();

    // Caso o caractere lido seja quebra de linha, incrementa o contador de linhas e o cabeçote do vetor.
    if(charLido == '\n')
    {
      posVetor++;
      contLinhasSD++;
    }
    // Caso contrário, concatena o caractere lido na string armazenada na posição atual do vetor.
    else
    {
      linhasSD[posVetor] += charLido;
    }

    if(contLinhasSD > MAX_LINES_SD)
    {
      contLinhasSD = MAX_LINES_SD;
    }
  }
  
  // Ao final da leitura fecha o arquivo.
  arquivoSD.close();
}


/**
 * Procedimento responsável pela impressão de cada linha presente no vetor de linhas, lidas previamente, do arquivo.
 */
void imprimeLinhasSD()
{
  // Marcador backup de ultima linha a ser impressa, utilizado para manter o correto funcionamento dos botões de próxima e página anterior.
  int marcBkp;

  // Posição X e Y onde os caracteres do arquivo serão impressos.
  int posY = 13;
  int posX = 20;

  // Posição X dos contadores de linha.
  int posXLine = 3;

  // Salva backup.
  marcBkp = marcUltimaLinhaSD;

  // Caso o marcador de ultima linha a ser impressa seja maior que o tamanho de linhas do arquivo, atualiza para o menor valor.
  if(marcUltimaLinhaSD > contLinhasSD)
  {
    marcUltimaLinhaSD = contLinhasSD;
  }

  // Imprime desde a linha armazenada no marcador de primeira linha até o valor do marcador de ultima linha.
  for(int i = marcPrimeiraLinhaSD; i < marcUltimaLinhaSD; i++)
  {
    // Posiciona o cursor.
    TV.set_cursor(posX, posY);

    // Imprime o conteúdo da linha "i" do arquivo lido, ou seja, a posição "i" do vetor de linhas".
    // Impressão feita caractere por caractere.
    for(int j = 0; j < linhasSD[i].length(); j++)
    {
      TV.print(linhasSD[i][j]);  

      // Avança o cursor em um caractere.
      posX += 4;
    }

    // Posicão no eixo X a ser escrito os contadores de linha na tela.
    posXLine = 3;

    // Imprime o contador da linha correspondente, sempre com 3 casas.
    for (int k = 100; i + 1 <= k - 1; k /= 10) 
    {
      TV.print(posXLine, posY, "0");
      posXLine += 4;      
    }
    TV.print(posXLine, posY, i + 1);

    // Atualiza posições X e Y para impressão da próxima linha.
    posY += 8;
    posX = 20;
  }  

  // Recupera o valor salvo no backup.
  marcUltimaLinhaSD = marcBkp;
}


/**
 * Procedimento responsável por imprimir a tela de visualização de arquivo do cartão SD.
 */
void imprimeShowFile()
{  
  // Imprime tela.
  TV.bitmap(0,0,showFILE);

  // Chama método para imprimir strings do menu principal.
  imprimeItensMenuPrincipal();

  // Inverte faixa identificadora do item atual no menu principal (indica que o item está em foco).
  inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

  //Inverte a cor do item selecionado do menu principal.
  inverteItensMenuPrincipal(itemMenuPrincipal);

  // Chama método para impressão do texto contido no arquivo.
  imprimeLinhasSD();

  // Imprime título do botão.
  TV.print(92, 83, "RUN");

  // Inverte cores da barra inferior.
  for(int i = 1; i < 19; i++)
  {
    for(int j = 11; j < 77; j++)
    {
      TV.set_pixel(i, j, 2);
    }
  }
}


/**
 * Procedimento responsável por imprimir a tela de registradores 1/2.
 */
void imprimeBaseRegs1()
{
  TV.clear_screen();
  
  // Imprime contornos da tela.
  TV.bitmap(0,0,REG);

  // Chama método para imprimir strings do menu principal.
  imprimeItensMenuPrincipal();

  //Inverte a cor do item selecionado do menu principal.
  inverteItensMenuPrincipal(itemMenuPrincipal);

  // Seleciona fonte.
  TV.select_font(font4x6);

  // Imprime strings presentes na tela.
  TV.print(3, 23, "00");
  TV.print(3, 32, "01");
  TV.print(3, 41, "02");
  TV.print(3, 50, "03");
  TV.print(3, 59, "04");
  TV.print(3, 68, "05");
  TV.print(3, 77, "06");
  TV.print(3, 86, "07");

  TV.print(62, 23, "08");
  TV.print(62, 32, "09");
  TV.print(62, 41, "10");
  TV.print(62, 50, "11");
  TV.print(62, 59, "12");
  TV.print(62, 68, "13");
  TV.print(62, 77, "14");
  TV.print(62, 86, "15");


  

  TV.print(20, 23, matrizRegsChar[0]);
  TV.print(20, 32, matrizRegsChar[1]);
  TV.print(20, 41, matrizRegsChar[2]);
  TV.print(20, 50, matrizRegsChar[3]);
  TV.print(20, 59, matrizRegsChar[4]);
  TV.print(20, 68, matrizRegsChar[5]);
  TV.print(20, 77, matrizRegsChar[6]);
  TV.print(20, 86, matrizRegsChar[7]);

  TV.print(79, 23, matrizRegsChar[8]);
  TV.print(79, 32, matrizRegsChar[9]);
  TV.print(79, 41, matrizRegsChar[10]);
  TV.print(79, 50, matrizRegsChar[11]);
  TV.print(79, 59, matrizRegsChar[12]);
  TV.print(79, 68, matrizRegsChar[13]);
  TV.print(79, 77, matrizRegsChar[14]);
  TV.print(79, 86, matrizRegsChar[15]);
}


/**
 * Procedimento responsável por imprimir a tela de registradores 2/2.
 */
void imprimeBaseRegs2()
{
  // Imprime contornos da tela.
  TV.bitmap(0,0,REG);

  // Chama método para imprimir strings do menu principal.
  imprimeItensMenuPrincipal();
  
  //Inverte a cor do item selecionado do menu principal.
  inverteItensMenuPrincipal(itemMenuPrincipal);

  // Seleciona fonte.
  TV.select_font(font4x6);

  // Imprime strings presentes na tela.
  TV.print(3, 23, "16");
  TV.print(3, 32, "17");
  TV.print(3, 41, "18");
  TV.print(3, 50, "19");
  TV.print(3, 59, "20");
  TV.print(3, 68, "21");
  TV.print(3, 77, "22");
  TV.print(3, 86, "23");

  TV.print(62, 23, "24");
  TV.print(62, 32, "25");
  TV.print(62, 41, "26");
  TV.print(62, 50, "27");
  TV.print(62, 59, "28");
  TV.print(62, 68, "29");
  TV.print(62, 77, "30");
  TV.print(62, 86, "31");

  TV.print(20, 23, matrizRegsChar[16]);
  TV.print(20, 32, matrizRegsChar[17]);
  TV.print(20, 41, matrizRegsChar[18]);
  TV.print(20, 50, matrizRegsChar[19]);
  TV.print(20, 59, matrizRegsChar[20]);
  TV.print(20, 68, matrizRegsChar[21]);
  TV.print(20, 77, matrizRegsChar[22]);
  TV.print(20, 86, matrizRegsChar[23]);

  TV.print(79, 23, matrizRegsChar[24]);
  TV.print(79, 32, matrizRegsChar[25]);
  TV.print(79, 41, matrizRegsChar[26]);
  TV.print(79, 50, matrizRegsChar[27]);
  TV.print(79, 59, matrizRegsChar[28]);
  TV.print(79, 68, matrizRegsChar[29]);
  TV.print(79, 77, matrizRegsChar[30]);
  TV.print(79, 86, matrizRegsChar[31]);
}


void imprimeBaseRegs3()
{
  // Imprime contornos da tela.
  TV.bitmap(0,0,REG);

  // Chama método para imprimir strings do menu principal.
  imprimeItensMenuPrincipal();

  //Inverte a cor do item selecionado do menu principal.
  inverteItensMenuPrincipal(itemMenuPrincipal);

  // Seleciona fonte.
  TV.select_font(font4x6);

  // Imprime strings presentes na tela.
  TV.print(3, 23, "HI");
  TV.print(3, 32, "LO");

  TV.print(20, 23, matrizRegsChar[32]);
  TV.print(20, 32, matrizRegsChar[33]);
}

/**
 * Procedimento que informado um item da área de atualização do RTC, inverte sua cor, 
 * fornecendo assim a aparência de que tal item está selecionado.
 */
void inverteItemRTC(int item)
{
  switch(item)
  {
    // Dia.
    case 1:
    
      for(int i = 2; i < 10; i++)
      {
        for(int j = 83; j < 93; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Mês.
    case 2:
    
      for(int i = 14; i < 22; i++)
      {
        for(int j = 83; j < 93; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Ano.
    case 3:
    
      for(int i = 25; i < 34; i++)
      {
        for(int j = 83; j < 93; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Dia da Semana.
    case 4:
    
      for(int i = 34; i < 84; i++)
      {
        for(int j = 83; j < 93; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Hora.
    case 5:
    
      for(int i = 84; i < 93; i++)
      {
        for(int j = 83; j < 93; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Minutos.
    case 6:
    
      for(int i = 96; i < 105; i++)
      {
        for(int j = 83; j < 93; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Segundos.
    case 7:
    
      for(int i = 108; i < 117; i++)
      {
        for(int j = 83; j < 93; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;
  }
}


/**
 * Procedimento que informado um item da tela de visualização de arquivos, inverte sua cor, 
 * fornecendo assim a aparência de que tal item está selecionado.
 */
void inverteItemShowFile(int item)
{
  switch(item)
  {
    // Seta para baixo.
    case 1:
    
      for(int i = 11; i < 29; i++)
      {
        for(int j = 79; j < 93; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Seta para cima. 
    case 2:
    
      for(int i = 37; i < 55; i++)
      {
        for(int j = 79; j < 93; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Seta de retorno.
    case 3:
    
      for(int i = 63; i < 81; i++)
      {
        for(int j = 79; j < 93; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Botão Run.
    case 4:
    
      for(int i = 89; i < 107; i++)
      {
        for(int j = 79; j < 93; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;
  }
}


/**
 * Procedimento que informado um item da tela de listagem de arquivos, inverte sua cor, 
 * fornecendo assim a aparência de que tal item está selecionado.
 */
void inverteItemOpen(int item)
{
  switch(item)
  {
    // Arquivo 1.
    case 1:
    
      for(int i = 0; i < 118; i++)
      {
        for(int j = 21; j < 32; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Arquivo 2.
    case 2:
    
      for(int i = 0; i < 118; i++)
      {
        for(int j = 32; j < 41; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Arquivo 3.
    case 3:
    
      for(int i = 0; i < 118; i++)
      {
        for(int j = 41; j < 50; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Arquivo 4.
    case 4:
    
      for(int i = 0; i < 118; i++)
      {
        for(int j = 50; j < 59; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Arquivo 5.
    case 5:
    
      for(int i = 0; i < 118; i++)
      {
        for(int j = 59; j < 68; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Arquivo 6.
    case 6:
    
      for(int i = 0; i < 118; i++)
      {
        for(int j = 68; j < 77; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Arquivo 7.
    case 7:
    
      for(int i = 0; i < 118; i++)
      {
        for(int j = 77; j < 86; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Arquivo 8.
    case 8:
    
      for(int i = 0; i < 118; i++)
      {
        for(int j = 86; j < 95; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;
     
  }
}

/**
 * Procedimento que informado um item do menu de memória RAM, inverte sua cor, 
 * fornecendo assim a aparência de que tal item está selecionado no menu.
 */
void inverteItemMenuMem(int item)
{
  switch(item)
  {
    // DATA.
    case 1:
    
      for(int i = 8; i < 29; i++)
      {
        for(int j = 11; j < 23; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

     // INST.
    case 2:
    
      for(int i = 90; i < 111; i++)
      {
        for(int j = 11; j < 23; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;
    
    // Textbox.
    case 3:
    
      for(int i = 23; i < 89; i++)
      {
        for(int j = 33; j < 46; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Botão OK.
    case 4:
    
      for(int i = 95; i < 113; i++)
      {
        for(int j = 26; j < 39; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Seta Backspace.
    case 5:
    
      for(int i = 95; i < 113; i++)
      {
        for(int j = 40; j < 53; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;
  }
}

/**
 * Procedimento que informado um item do menu de Memória, inverte a cor da faixa lateral 
 * do item, fornecendo assim a aparência de que tal item está selecionado no menu.
 */
void inverteItemMenuMemFaixa(int item)
{
  switch(item)
  {
    // DATA.
    case 1:
    
      for(int i = 11; i < 23; i++)
      {
        TV.set_pixel(6, i, 2);
        TV.set_pixel(30, i, 2);
      }

      break;

     // INST.
    case 2:
    
      for(int i = 11; i < 23; i++)
      {
        TV.set_pixel(88, i, 2);
        TV.set_pixel(112, i, 2);
      }

      break;
  }
}


/**
 * Procedimento que informado uma das setas do menu de Registradores, inverte sua cor, 
 * fornecendo assim a aparência de que tal item está selecionado no menu.
 */
void inverteItemRegs(int item)
{
  switch(item)
  {
    // Seta Esquerda.
    case 1:

      for(int i = 1; i < 19; i++)
      {
        for(int j = 10; j < 21; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // LOAD
    case 2:

      for(int i = 48; i < 72; i++)
      {
        for(int j = 12; j < 20; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Seta Direita.
    case 3:

      for(int i = 100; i < 117; i++)
      {
        for(int j = 10; j < 21; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;
  }
}


/**
 * Procedimento que informado um item do menu principal, inverte sua cor, 
 * fornecendo assim a aparência de que tal item está selecionado no menu.
 */
void inverteItensMenuPrincipal(int item)
{
  switch(item)
  {
    // Item "HOME".
    case 1:

      for(int i = 1; i < 18; i++)
      {
        for(int j = 1; j < 9; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Item "OPEN".
    case 2:

      for(int i = 26; i < 43; i++)
      {
        for(int j = 1; j < 9; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Item "REG".
    case 3:

      for(int i = 51; i < 64; i++)
      {
        for(int j = 1; j < 9; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Item "MEM".
    case 4:

      for(int i = 73; i < 86; i++)
      {
        for(int j = 1; j < 9; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break;

    // Item "ABOUT".
    case 5:

      for(int i = 96; i < 117; i++)
      {
        for(int j = 1; j < 9; j++)
        {
          TV.set_pixel(i, j, 2);
        }
      }

      break; 
  }
}


/**
 * Procedimento que informado um item do menu principal, inverte sua cor, 
 * fornecendo assim a aparência de que tal item está selecionado no menu.
 */
void inverteItensMenuPrincipalFaixa(int item)
{
  switch(item)
  {
    // Item "HOME".
    case 1:

      for(int i = 1; i < 18; i++)
      {
        TV.set_pixel(i, 0, 2);
      }

      break;

    // Item "OPEN".
    case 2:

      for(int i = 26; i < 43; i++)
      {
        TV.set_pixel(i, 0, 2);
      }

      break;

    // Item "REG".
    case 3:

      for(int i = 51; i < 64; i++)
      {
        TV.set_pixel(i, 0, 2);
      }

      break;

    // Item "MEM".
    case 4:

      for(int i = 73; i < 86; i++)
      {
        TV.set_pixel(i, 0, 2);
      }

      break;

    // Item "ABOUT".
    case 5:

      for(int i = 96; i < 117; i++)
      {
        TV.set_pixel(i, 0, 2);
      }

      break; 
  }
}


/**
 * Procedimento responsável por atualizar os dados do RTC de acordo com os valores
 * das respectivas variáveis globais.
 */
void atualizaRTC()
{
  // Atualiza Data.
  rtc.setDate(diaRTC, mesRTC, anoRTC);

  // Atualiza Dia da semana.
  rtc.setDOW(diaSemRTC);

  // Atualiza Hora.
  rtc.setTime(horaRTC, minRTC, segRTC);  
}


/**
 * Procedimento de configuração dos dispositivos conectados ao Arduino.
 */
void setup() 
{
  // Configura pinos para comunicação com FPGA.

  pinMode2(addr0,OUTPUT);
  pinMode2(addr1,OUTPUT);
  pinMode2(addr2,OUTPUT);
  pinMode2(addr3,OUTPUT);
  pinMode2(addr4,OUTPUT);
  pinMode2(addr5,OUTPUT);
  pinMode2(addr6,OUTPUT);
  pinMode2(addr7,OUTPUT);
  
  pinMode2(dout0,OUTPUT);
  pinMode2(dout1,OUTPUT);
  pinMode2(dout2,OUTPUT);
  pinMode2(dout3,OUTPUT);
  pinMode2(dout4,OUTPUT);
  pinMode2(dout5,OUTPUT);
  pinMode2(dout6,OUTPUT);
  pinMode2(dout7,OUTPUT);

  pinMode2(din0,INPUT);
  pinMode2(din1,INPUT);
  pinMode2(din2,INPUT);
  pinMode2(din3,INPUT);
  pinMode2(din4,INPUT);
  pinMode2(din5,INPUT);
  pinMode2(din6,INPUT);
  pinMode2(din7,INPUT);

  pinMode2(pinClock,INPUT);

  pinMode2(ready0,INPUT);
  pinMode2(ready1,INPUT);
  pinMode2(ready2,INPUT);
  
  pinMode2(error0,INPUT);
  pinMode2(error1,INPUT);

  pinMode2(opCode0,OUTPUT);
  pinMode2(opCode1,OUTPUT);
  pinMode2(opCode2,OUTPUT);

  pinMode2(reset,OUTPUT);

  // Solicita ao MIPS que execute o processo de reset do circuito.
  resetMIPS();
  
  //Serial.begin(9600);

  // _______________________________________________________________
  
  // Configura parâmetros da biblioteca TVOut.
  TV.begin(_NTSC, 120, 96); // Resolução da tela.d

  // Configuração do SD.
  pinMode2(53, OUTPUT);
  if (!SD.begin(53)) 
  {
    sdInserido = false;
  }
  else
  {
    sdInserido = true;
  }
  
  // Configuração do RTC.
  rtc.halt(false);
  rtc.setSQWRate(SQW_RATE_1);
  rtc.enableSQW(true);
  
  
  // Configura pinos do joystick.
  pinMode2(pinRx, INPUT);
  pinMode2(pinRy, INPUT);
  pinMode2(pinSw, INPUT);

  // Configura pinos dos LEDs
  pinMode2(pinLedPOWER, OUTPUT);
  pinMode2(pinLedSD, OUTPUT);
  pinMode2(pinLedFPGA, OUTPUT);

  pinMode2(pinFPGAPower, INPUT);

  digitalWrite2(pinLedPOWER, HIGH);

  // Imprime logotipos na tela.
  //TV.clear_screen();
  //TV.bitmap(30,0,logoIFGrande);

  //for(int i = 0; i < 15; i ++)
  //{
 //   TV.shift(1, 1);
  //  TV.delay(70);
  //}

  // Seleciona fonte.
  TV.select_font(font8x8);

  //TV.print(42, 0, "IFMG");
  //TV.print(2, 80, "campus Formiga");
  //TV.delay(5000);

  //TV.clear_screen();
  //TV.bitmap(4,20,C2Grande);
  //TV.delay(5000);

  // Imprime fundo base.
  printBase();
}


/**
 * Método utilizado para comunicar ao MIPS que esse deve ser colocado em modo IDLE.
 */
void solicitaIDLE()
{
  // Informa opCode para essa opção "000".
  digitalWrite2(opCode2, LOW);
  digitalWrite2(opCode1, LOW);
  digitalWrite2(opCode0, LOW);

  //Aguarda borda de subida do clock.
  while(digitalRead2(pinClock) != 1){}

  //Reseta circuito da FSM RAM de programa da FPGA.
  digitalWrite2(reset, HIGH);

  //Aguarda borda de subida do clock.
  while(digitalRead2(pinClock) != 1){}

  // Coloca o sinal de reset em nível baixo.
  digitalWrite2(reset, LOW);
}


/**
 * Método utilizado para comunicar ao MIPS que esse deve reiniciar seu circuito.
 */
void resetMIPS()
{
  // Informa opCode para essa opção "101".
  digitalWrite2(opCode2, HIGH);
  digitalWrite2(opCode1, LOW);
  digitalWrite2(opCode0, HIGH);

  //Aguarda borda de subida do clock.
  while(digitalRead2(pinClock) != 1){}

  //Reseta circuito da FSM RAM de programa da FPGA.
  digitalWrite2(reset, HIGH);

  //Aguarda borda de subida do clock.
  while(digitalRead2(pinClock) != 1){}

  // Coloca o sinal de reset em nível baixo.
  digitalWrite2(reset, LOW);
}


/**
 * Método responsável por deletar um caractere digitado pelo teclado, na tela de memória.
 */
void limpaUmMemKeypad()
{
  // Verifica se existe algo a ser apagado, ou seja, se o contador de caracteres digitados é maior que 0.
  if(contAddrRAM > 0)
  {
    // Apaga caractere do vetor de caracteres digitados.
    hexaAddressRAM[contAddrRAM] = ' ';

    // Decrementa contador.
    contAddrRAM--;

    // Decrementa posição do cursor.
    posX -= 6;

    // Apaga caractere da tela.
    TV.print(posX, 37, ' ');
  }
}


/**
 * Remove todos os caracteres do vetor. Não é necessário apagar da tela, pois esse método será chamado após reprint da tela.
 */
void limpaTodosMemKeypad()
{
  for(int i = 0; i < 2; i++)
  {
    hexaAddressRAM[i] = ' ';
  }
}


/**
 * Método responsável por capturar o endereço de memória RAM desejado para leitura na tela de RAM, do teclado matricial.
 */
void capturaMemKeypad()
{  
  // Flag que determina se o sistema continua ou não lendo caracteres do teclado.
  bool sair = false;

  // Lê dados do teclado enquanto não ler 2 caracteres ou o joystick for pressionado para cima.
  while( (contAddrRAM < 2) && (sair == false) )
  {
    // Salva o caractere lido.
    char keypressed = myKeypad.getKey();

    // Aguarda até que uma tecla seja pressionada ou o joystick pressionado para cima.
    while((keypressed == NO_KEY) && (analogRead(pinRy) > 200))
    {
      keypressed = myKeypad.getKey();
      delay(100);
    }

    // Caso o joystick tenha sido pressionado, ativa a flag de saída do laço.
    if((analogRead(pinRy) < 200))
    {
      sair = true;
    }
    // Caso contrário imprime o caractere digitado na posição correta, salva no vetorm incrementa contador e avança o cursor, 
    else
    {
      TV.print(posX, 37, keypressed);
      
      hexaAddressRAM[contAddrRAM] = keypressed;
      
      contAddrRAM++;
      posX += 6;
    }
  }
}


/**
 * Procedimento responsável por controlar a interação do usuário com os itens presentes nas telas, por meio do joystick.
 */
void operaJoystickMenu()
{
  // Verifica se já se passou o tempo de debouce, para evitar flutuações.
  if ((millis() - lastDebounceTime) > debounceDelay) 
  {
    
    // OPERAÇÃO QUANDO O JOYSTICK É PRESSIONADO PARA A DIREITA
    if(analogRead(pinRx) < 200)
    {
      // Caso o menu atual seja o principal.
      if(menuAtual == 1)
      {
        // Verifica se o item informado é menor que o máximo.
        if(itemMenuPrincipal < 5)
        {
          // Incrementa marcador de item desse menu.
          itemMenuPrincipal++;

          // Ativa impressao dessa tela no procedimento LOOP.
          printTelaAtual = true;

          // Atualiza o marcador de tela atual.
          telaAtual = itemMenuPrincipal;

          // Reseta demais marcadores de menus.
          itemMenuMem = 1;
          itemMenuReg = 1;
          itemMenuShow = 1;
          itemOpen = 0;
        }
      }
      else 
      {
        // Operações de acordo com a tela em exibição.
        switch (telaAtual)
        {
          // Tela HOME.
          case 1:

            // Verifica se o item informado é menor que o máximo.
            // Caso seja, incrementa o contador, e inverte os itens anterior e atual.
            if(itemRTC < 7)
            {
              itemRTC++;
              inverteItemRTC(itemRTC);
              inverteItemRTC(itemRTC - 1);
            }
          
            break;

          // Tela REG
          case 3:
          
            // Verifica se o item informado é menor que o máximo.
            // Caso seja, incrementa o contador, e inverte as setas.
            if(itemMenuReg < 3)
            {
              itemMenuReg++;
              inverteItemRegs(itemMenuReg);
              inverteItemRegs(itemMenuReg - 1);
            }
          
            break;

          // Tela MEM
          case 4:

            // Verifica se o item selecionado é o item DATA.
            // Caso seja, incrementa o contador, e inverte os itens anterior e atual e a faixa.
            if(itemMenuMem == 1)
            {
              itemMenuMem++;
              inverteItemMenuMem(itemMenuMem);
              inverteItemMenuMem(itemMenuMem - 1);
              inverteItemMenuMemFaixa(itemMenuMem);
              inverteItemMenuMemFaixa(itemMenuMem - 1);
            }
          
            // Verifica se o item selecionado é o textbox.
            // Caso seja, incrementa o contador, e inverte os itens anterior e atual.
            else if(itemMenuMem == 3)
            {
              itemMenuMem++;
              inverteItemMenuMem(itemMenuMem);
              inverteItemMenuMem(itemMenuMem - 1);
            }
              
            break;

          // Tela de visualização de arquivos.
          case 6:

            // Verifica se o item selecionado é menor que o máximo.
            // Caso seja, incrementa o contador, e inverte os itens anterior e atual.
            if(itemMenuShow < 4)
            {
              itemMenuShow++;
              inverteItemShowFile(itemMenuShow);
              inverteItemShowFile(itemMenuShow - 1);
            }
            
            break;
        }
      }

      // Atualiza o tempo de debounce.
      lastDebounceTime = millis();
    }
    

    // OPERAÇÃO QUANDO O JOYSTICK É PRESSIONADO PARA A ESQUERDA
    else if(analogRead(pinRx) > 1000)
    {
      // Caso o menu atual seja o principal.
      if(menuAtual == 1)
      {
        // Verifica se o item informado é maior que o mínimo.
        if(itemMenuPrincipal > 1)
        {
          // Decrementa marcador de item desse menu.
          itemMenuPrincipal--;

          // Ativa impressao dessa tela no procedimento LOOP.
          printTelaAtual = true;

          // Atualiza o marcador de tela atual.
          telaAtual = itemMenuPrincipal;

          // Reseta demais marcadores de menus.
          itemMenuMem = 1;
          itemMenuReg = 1;
          itemMenuShow = 1;
          itemOpen = 0;
        }
      }
      else 
      {
        // Operações de acordo com a tela em exibição.
        switch (telaAtual)
        {
          // Tela HOME.
          case 1:

            // Verifica se o item informado é maior que o mínimo.
            // Caso seja, decrementa o contador, e inverte os itens anterior e atual.
            if(itemRTC > 1)
            {
              itemRTC--;
              inverteItemRTC(itemRTC);
              inverteItemRTC(itemRTC + 1);
            }

            break;

          // Tela REG.
          case 3:
            
            // Verifica se o item informado é maior que o mínimo.
            // Caso seja, decrementa o contador, e inverte as setas.
            if(itemMenuReg > 1)
            {
              itemMenuReg--;
              inverteItemRegs(itemMenuReg);
              inverteItemRegs(itemMenuReg + 1);
            }

            break;

          // Tela MEM.
          case 4:
          
            // Verifica se o item selecionado é o item INST.
            // Caso seja, incrementa o contador, e inverte os itens anterior e atual e a faixa.
            if(itemMenuMem == 2)
            {
              itemMenuMem--;
              inverteItemMenuMem(itemMenuMem);
              inverteItemMenuMem(itemMenuMem + 1);
              inverteItemMenuMemFaixa(itemMenuMem);
              inverteItemMenuMemFaixa(itemMenuMem + 1);
            }
          
            // Verifica se o item selecionado é o botão OK.
            // Caso seja, incrementa o contador, e inverte os itens anterior e atual.
            else if(itemMenuMem == 4)
            {
              itemMenuMem--;
              inverteItemMenuMem(itemMenuMem);
              inverteItemMenuMem(itemMenuMem + 1);
            }

            break;

          // Tela de visualização de arquivos.
          case 6:

            // Verifica se o item selecionado é maior que o mínimo.
            // Caso seja, decrementa o contador, e inverte os itens anterior e atual.
            if(itemMenuShow > 1)
            {
              itemMenuShow--;
              inverteItemShowFile(itemMenuShow);
              inverteItemShowFile(itemMenuShow + 1);
            }

            break;
        }
      }

      // Atualiza o tempo de debounce.
      lastDebounceTime = millis();
    }

    // OPERAÇÃO QUANDO O JOYSTICK É PRESSIONADO PARA BAIXO
    else if(analogRead(pinRy) > 1000)
    {
      // Operações de acordo com a tela em exibição.
      switch (telaAtual)
      {
        // Tela OPEN.
        case 2:

          // Verifica se é a primeira vez que o usuário pressionou o joystick para baixo na tela atual.
          if(primeiraVezBaixo)
          {
            // Inverte flags.
            primeiraVezBaixo = false;
            primeiraVezCima = true;
            
            // Inverte faixa identificadora do item atual no menu principal (indica que o item não está em foco).
            inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

            // Atualiza menu atual.
            menuAtual = 2;
          }

          // Verifica se o item de listagem do arquivo é menor que a quantidade de arquivo presente no SD (máx 8).
          if(itemOpen < qtdArqSD)
          {
            // Incrementa o indicador de arquivo atual na listagem.
            itemOpen++;     

            // Inverte itens da tela de visualização, item atual e anterior.
            inverteItemOpen(itemOpen);
            inverteItemOpen(itemOpen - 1);
          }

          break;

        // Tela REG.
        case 3:

          // Verifica se é a primeira vez que o usuário pressionou o joystick para baixo na tela atual.
          if(primeiraVezBaixo)
          {
            // Inverte flags.
            primeiraVezBaixo = false;
            primeiraVezCima = true;

            // Inverte faixa identificadora do item atual no menu principal (indica que o item não está em foco).
            inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

            // Atualiza menu atual.
            menuAtual = 3;

            // Atualiza o item do menu de registradores.
            itemMenuReg = 2;

            // Inverte a seta atual do menu.
            inverteItemRegs(itemMenuReg);
          }
        
          break;

        // Tela MEM.
        case 4:

          // Verifica se é a primeira vez que o usuário pressionou o joystick para baixo na tela atual.
          if(primeiraVezBaixo)
          {
            // Inverte flags.
            primeiraVezBaixo = false;
            primeiraVezCima = true;

            itemMenuMem = 1;

            imprimeBaseMem1();

            // Inverte item atual.
            inverteItemMenuMem(itemMenuMem);

            inverteItemMenuMemFaixa(itemMenuMem);

            // Atualiza menu atual.
            menuAtual = 4;
          }
          // Caso não seja a primeira vez, o item selecionado seja o item DATA e a tela de memória seja a DATA.
          else if ( (itemMenuMem == 1) && (telaMem == 1) )
          {
            inverteItemMenuMemFaixa(itemMenuMem);

            // Indicador de item passa a apontar para o textbox.
            itemMenuMem = 3;

            // Inverte item atual.
            inverteItemMenuMem(itemMenuMem);
          }
          // Caso não seja a primeira vez, o item selecionado seja o item INST e a tela de memória seja a INST.
          else if ( (itemMenuMem == 2) && (telaMem == 2) )
          {
            inverteItemMenuMemFaixa(itemMenuMem);

            // Indicador de item passa a apontar para o textbox.
            itemMenuMem = 3;

            // Inverte item atual.
            inverteItemMenuMem(itemMenuMem);
          }
           // Caso não seja a primeira vez, e o item selecionado seja o botão OK.
          else if (itemMenuMem == 4)
          {
             // Indicador de item é incrementado.
            itemMenuMem++;
            
            // Inverte item anterior.
            inverteItemMenuMem(itemMenuMem - 1);

            // Inverte item atual.
            inverteItemMenuMem(itemMenuMem);
          }

          break;

        // Tela de visualização de arquivos.
        case 6:

          // Verifica se é a primeira vez que o usuário pressionou o joystick para baixo na tela autal.
          if(primeiraVezBaixo)
          {
            // Inverte flags.
            primeiraVezBaixo = false;
            primeiraVezCima = true;
            
            // Inverte faixa identificadora do item atual no menu principal (indica que o item não está em foco).
            inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

            // Atualiza menu atual.
            menuAtual = 6;

            // Inverte item atual.
            inverteItemShowFile(itemMenuShow);
          }

          break;

        // Tela de ajuste do DIA do RTC.
        case 7:

          // Caso o valor de DIA seja igual ao mínimo (1), retorna o valor para o máximo (31), 
          // caso contrário, decrementa e chama método para atualizar o RTC com os novos valores.
          if(diaRTC == 1)
          {
            diaRTC = 31;
          }
          else
          {
            diaRTC--;
          }
          atualizaRTC();

          break;

        // Tela de ajuste do MES do RTC.
        case 8:

          // Caso o valor de MES seja igual ao mínimo (1), retorna o valor para o máximo (12), 
          // caso contrário, decrementa e chama método para atualizar o RTC com os novos valores.
          if(mesRTC == 1)
          {
            mesRTC = 12;
          }
          else
          {
            mesRTC--;
          }
          atualizaRTC();

          break;

        // Tela de ajuste do ANO do RTC.
        case 9:

          // Caso o valor de ANO seja igual ao mínimo (2000), retorna o valor para o máximo (2099), 
          // caso contrário, decrementa e chama método para atualizar o RTC com os novos valores.
          if(anoRTC == 2000)
          {
            anoRTC = 2099;
          }
          else
          {
            anoRTC--;
          }
          atualizaRTC();

          break;

        // Tela de ajuste do DIA DA SEMANA do RTC.
        case 10:

          // Caso o valor de DIA DA SEMANA seja igual ao mínimo (SEGUNDA), retorna o valor para o máximo (DOMINGO), 
          // caso contrário, decrementa e chama método para atualizar o RTC com os novos valores.
          if(diaSemRTC == SEGUNDA)
          {
            diaSemRTC = DOMINGO;
          }
          else
          {
            diaSemRTC--;
          }
          atualizaRTC();

          break;

        // Tela de ajuste da HORA do RTC.
        case 11:

          // Caso o valor de HORA seja igual ao mínimo (0), retorna o valor para o máximo (23), 
          // caso contrário, decrementa e chama método para atualizar o RTC com os novos valores.
          if(horaRTC == 0)
          {
            horaRTC = 23;
          }
          else
          {
            horaRTC--;
          }
          atualizaRTC();

          break;

        // Tela de ajuste dos MINUTOS do RTC.
        case 12:

          // Caso o valor de MINUTO seja igual ao mínimo (0), retorna o valor para o máximo (59), 
          // caso contrário, decrementa e chama método para atualizar o RTC com os novos valores.
          if(minRTC == 0)
          {
            minRTC = 59;
          }
          else
          {
            minRTC--;
          }
          atualizaRTC();

          break;

        // Tela de ajuste dos SEGUNDOS do RTC.
        case 13:

          // Caso o valor de SEGUNDO seja igual ao mínimo (0), retorna o valor para o máximo (59), 
          // caso contrário, decrementa e chama método para atualizar o RTC com os novos valores.
          if(segRTC == 0)
          {
            segRTC = 59;
          }
          else
          {
            segRTC--;
          }
          atualizaRTC();

          break;
      }

      // Atualiza o tempo de debounce.
      lastDebounceTime = millis();
    }


    // OPERAÇÃO QUANDO O JOYSTICK É PRESSIONADO PARA CIMA
    else if(analogRead(pinRy) < 200)
    {
      // Operações de acordo com a tela em exibição.
      switch (telaAtual)
      {
        // Tela HOME.
        case 1:

          // Verifica se é a primeira vez que o usuário pressionou o joystick para cima na tela atual.
          if(primeiraVezCima)
          {
            // Inverte flags.
            primeiraVezCima = false;
            primeiraVezBaixo = true;

            // Inverte faixa identificadora do item atual no menu principal (indica que o item está em foco).
            inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

            // Atualiza menu atual, apontando para o principal.
            menuAtual = 1;

            // Reseta o apontador de item do menu principal para o primeiro item.
            itemMenuPrincipal = 1;

            // Inverte item selecionado previamente do RTC.
            inverteItemRTC(itemRTC);
          }

          break;

        // Tela OPEN.
        case 2:

          // Verifica se o item de listagem do arquivo é maior que a quantidade mínima de arquivos (0).
          if(itemOpen > 0)
          {
            // Decrementa o indicador de arquivo atual na listagem.
            itemOpen--;

            // Caso, após o decremento, aponte para o arquivo 0, retorna o controle para o menu principal.
            if(itemOpen == 0)
            {
              // Inverte faixa identificadora do item atual no menu principal (indica que o item está em foco).
              inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

              // Inverte flags.
              primeiraVezBaixo = true;
              primeiraVezCima = false;
              
              menuAtual = 1;

              // Inverte indicador de arquivo posterior.
              inverteItemOpen(itemOpen + 1);
            }
            // Senão, mantém o menu atual e inverte indicador de arquivo atual e posterior.
            else
            {            
              menuAtual = 5;
                      
              inverteItemOpen(itemOpen);
              inverteItemOpen(itemOpen + 1);
            }
          }

          break;

        // Tela REG.
        case 3:

          // Verifica se é a primeira vez que o usuário pressionou o joystick para cima na tela atual.
          if(primeiraVezCima)
          {
            // Inverte flags.
            primeiraVezCima = false;
            primeiraVezBaixo = true;

            // Inverte faixa identificadora do item atual no menu principal (indica que o item está em foco).
            inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

            // Retorna o controle para o menu principal.
            menuAtual = 1;

            // Atualiza o indicador de item do menu principal para o referente a tela REG.
            itemMenuPrincipal = 3;

            // Inverte a seta previamente selecionada.
            inverteItemRegs(itemMenuReg);
          }

          break;

        // Tela MEM.
        case 4:

          // Verifica se é a primeira vez que o usuário pressionou o joystick para cima na tela atual, e não é o botão de DATA ou INST.
          if( (primeiraVezCima) && (itemMenuMem < 3))
          {
            // Inverte flags.
            primeiraVezCima = false;
            primeiraVezBaixo = true;

            // Inverte faixa identificadora do item atual no menu principal (indica que o item está em foco).
            inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

            // Retorna o controle para o menu principal.
            menuAtual = 1;

            // Atualiza o indicador de item do menu principal para o referente a tela MEM.
            itemMenuPrincipal = 4;

            // Inverte item previamente selecionado na tela MEM.
            inverteItemMenuMem(itemMenuMem);

            inverteItemMenuMemFaixa(itemMenuMem);
          }
          // Caso seja o textbox.
          else if( (itemMenuMem == 3) || (itemMenuMem == 4) )
          { 
            if(telaMem == 1)
            {
              // Inverte item atual.
              inverteItemMenuMem(itemMenuMem);
  
              // Indicador de item passa a apontar para o item DATA.
              itemMenuMem = 1;
  
              inverteItemMenuMemFaixa(itemMenuMem); 
            }
            else
            {
              // Inverte item atual.
              inverteItemMenuMem(itemMenuMem);
  
              // Indicador de item passa a apontar para o item DATA.
              itemMenuMem = 2;
  
              inverteItemMenuMemFaixa(itemMenuMem); 
            }
          }
          // Caso seja demais botões.
          else if(itemMenuMem > 4)
          {  
            // Decrementa o indicador de item da tela atual.
            itemMenuMem--;

            // Inverte item atual e posterior (indicador passa para o botão OK).
            inverteItemMenuMem(itemMenuMem);
            inverteItemMenuMem(itemMenuMem + 1);
          }

          break;

        // Tela de ajuste do DIA do RTC.
        case 7:

          // Caso o valor de DIA seja igual ao máximo (31), retorna o valor para o minimo (1), 
          // caso contrário, incrementa e chama método para atualizar o RTC com os novos valores.
          if(diaRTC == 31)
          {
            diaRTC = 1;
          }
          else
          {
            diaRTC++;
          }
          atualizaRTC();
          
          break;

        // Tela de ajuste do MES do RTC.
        case 8:

          // Caso o valor de MES seja igual ao máximo (12), retorna o valor para o minimo (1), 
          // caso contrário, incrementa e chama método para atualizar o RTC com os novos valores.
          if(mesRTC == 12)
          {
            mesRTC = 1;
          }
          else
          {
            mesRTC++;
          }
          atualizaRTC();

          break;

        // Tela de ajuste do ANO do RTC.
        case 9:

          // Caso o valor de ANO seja igual ao máximo (2099), retorna o valor para o minimo (2000), 
          // caso contrário, incrementa e chama método para atualizar o RTC com os novos valores.
          if(anoRTC == 2099)
          {
            anoRTC = 2000;
          }
          else
          {
            anoRTC++;
          }
          atualizaRTC();

          break;

        // Tela de ajuste do DIA DA SEMANA do RTC.
        case 10:

          // Caso o valor de DIA DA SEMANA seja igual ao máximo (Domingo), retorna o valor para o minimo (Segunda), 
          // caso contrário, incrementa e chama método para atualizar o RTC com os novos valores.
          if(diaSemRTC == DOMINGO)
          {
            diaSemRTC = SEGUNDA;
          }
          else
          {
            diaSemRTC++;
          }
          atualizaRTC();

          break;

        // Tela de ajuste da HORA do RTC.
        case 11:

          // Caso o valor de HORA seja igual ao máximo (23), retorna o valor para o minimo (0), 
          // caso contrário, incrementa e chama método para atualizar o RTC com os novos valores.
          if(horaRTC == 23)
          {
            horaRTC = 0;
          }
          else
          {
            horaRTC++;
          }
          atualizaRTC();

          break;

        // Tela de ajuste dos MINUTOS do RTC.
        case 12:

          // Caso o valor de MINUTO seja igual ao máximo (59), retorna o valor para o minimo (0), 
          // caso contrário, incrementa e chama método para atualizar o RTC com os novos valores.
          if(minRTC == 59)
          {
            minRTC = 0;
          }
          else
          {
            minRTC++;
          }
          atualizaRTC();

          break;

        // Tela de ajuste dos SEGUNDOS do RTC.
        case 13:

          // Caso o valor de SEGUNDOS seja igual ao máximo (59), retorna o valor para o minimo (0), 
          // caso contrário, incrementa e chama método para atualizar o RTC com os novos valores.
          if(segRTC == 59)
          {
            segRTC = 0;
          }
          else
          {
            segRTC++;
          }
          atualizaRTC();

          break; 
      }

      // Atualiza o tempo de debounce.
      lastDebounceTime = millis();
    }

    // OPERAÇÃO QUANDO O JOYSTICK É PRESSIONADO PARA BAIXO (SWITCH)
    else if (analogRead(pinSw) < 100)
    {
      // Operações de acordo com a tela em exibição.
      switch (telaAtual)
      {
         // Tela HOME.
        case 1:

          // Verifica se é a primeira vez que o usuário pressionou o joystick para baixo na tela atual.
          if(primeiraVezBaixo)
          {
            // Inverte flags.
            primeiraVezBaixo = false;
            primeiraVezCima = true;

            // Inverte faixa identificadora do item atual no menu principal (indica que o item não está em foco).
            inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

            // Posiciona o indicador do item de ajuste do RTC para ajuste do dia.
            itemRTC = 1;

            // Inverte o item do RTC atual.
            inverteItemRTC(itemRTC);

            // Atualiza menu atual.
            menuAtual = 0;

            // Atualiza a tela atual.
            telaAtual = 7;
          }

          break;
          
        // Tela OPEN.
        case 2:

          // Inverte flags.
          primeiraVezBaixo = true;
          primeiraVezCima = false;

          // Indica que a primeira linha a ser impressa do arquivo é a linha 0.
          marcPrimeiraLinhaSD = 0;

          // Indica que a última linha a ser impressa do arquivo é a linha 7 ( < 8).
          marcUltimaLinhaSD = 8;

          // Chama método para preencher vetor com as linhas contidas no arquivo lido.
          carregaVetorSD(filesSD[itemOpen - 1]);

          // Chama método responsável por imprimir a tela de visualização.
          imprimeShowFile();

          // Já seleciona o item nº 1 da tela de exibição.
          itemMenuShow = 1;
          inverteItemShowFile(itemMenuShow);
          primeiraVezBaixo = false;
          primeiraVezCima = true;

          // Atualiza a tela atual, modificando ela para a tela de visualização.
          telaAtual = 6;

          break;

        // Tela REG.
        case 3:

          // Filtra por item selecionado na tela REG.
          switch(itemMenuReg)
          {
            // Seta para a esquerda.
            case 1:

              // Filtra de acordo com a tela atualmente exibida.
              switch(telaReg)
              {
                // Retorna a tela 1.
                case 2:

                  telaReg--;
                
                  // Imprime tela com primeiro conjunto de registradores.
                  imprimeBaseRegs1();

                  // Inverte seta atual , continuando invertida assim, a seta selecionada na tela anterior.
                  inverteItemRegs(itemMenuReg);
      
                  break;

                // Retorna a tela 2.
                case 3:

                  telaReg--;

                  // Imprime tela com segundo conjunto de registradores.
                  imprimeBaseRegs2();

                  // Inverte seta atual , continuando invertida assim, a seta selecionada na tela anterior.
                  inverteItemRegs(itemMenuReg);

                  break;

              }
              
              break;

            // LOAD
            case 2:

              // Chama método para leitura dos registradores do MIPS.
              leREGS();

              // Chama método para solicitar que o MIPS entre em estado IDLE.
              solicitaIDLE();

              // Imprime tela de registradores 1.
              imprimeBaseRegs1();

              // Mantém o item atual como o item LOAD.
              itemMenuReg = 2;

              //Inverte seta atual , continuando invertida assim, a seta selecionada na tela anterior.
              inverteItemRegs(itemMenuReg);

              // Retorna a tela 1 de visualização dos registradores.
              telaReg = 1;

              break;


            // Seta para a direita.
            case 3:

              // Filtra por item selecionado na tela REG.
              switch(telaReg)
              {
                 // Avança para a tela 2.
                case 1:

                    telaReg++;

                    // Imprime tela com segundo conjunto de registradores.
                    imprimeBaseRegs2();

                    // Inverte seta atual , continuando invertida assim, a seta selecionada na tela anterior.
                    inverteItemRegs(itemMenuReg);
                    
                  break;

                // Avança para a tela 3.
                case 2:

                    telaReg++;
  
                    // Imprime tela com terceiro conjunto de registradores.
                    imprimeBaseRegs3();

                    // Inverte seta atual , continuando invertida assim, a seta selecionada na tela anterior.
                    inverteItemRegs(itemMenuReg);

                  break;
              }

              break;
          }

          break;

        // Tela MEM.
        case 4:

          // Filtra por item selecionado na tela MEM.
          switch(itemMenuMem)
          {
            // DATA
            case 1:

              // Caso a tela exibida seja a de RAM de instruções, exibe a tela de RAM de dados.
              if(telaMem == 2)
              {
                telaMem--;

                imprimeBaseMem1();
  
                // Posição inicial do cursor no eixo X para textbox.
                posX = 26;
  
                contAddrRAM = 0;
  
                itemMenuMem = 1;
  
                inverteItemMenuMem(itemMenuMem);
  
                inverteItemMenuMemFaixa(itemMenuMem);
              }
        
              break;

            // INST
            case 2:

              // Caso a tela exibida seja a de RAM de dados, exibe a tela de RAM de instruções.
              if(telaMem == 1)
              {
                telaMem++;

                imprimeBaseMem2();

                // Posição inicial do cursor no eixo X para textbox.
                posX = 26;
  
                contAddrRAM = 0;
  
                itemMenuMem = 2;
  
                inverteItemMenuMem(itemMenuMem);
                
                inverteItemMenuMemFaixa(itemMenuMem);
              }

              break;
            
            // Textbox.
            case 3:

              // Inverte item atual (deixa preto).
              inverteItemMenuMem(3);

              // Chama método de captura de dados do keypad.
              capturaMemKeypad();

              // Inverte item atual (deixa branco).
              inverteItemMenuMem(3);
              
              break;

            // Botão OK.
            case 4:

              if(telaMem == 1)
              {
                leMEMData();
              }

              else if(telaMem == 2)
              {
                leMEMInst();
              }

              solicitaIDLE();
              
              break;

            // Backspace.
            case 5:

              // Inverte item atual (deixa preto).
              inverteItemMenuMem(5);

              // Chama método para deletar um caractere do Textobox.
              limpaUmMemKeypad();

              // Inverte item atual (deixa branco).
              inverteItemMenuMem(5);

              break;
          }

          break;

        // Tela de visualização de arquivos.
        case 6:

          // Filtra por item selecionado na tela de visualização.
          switch(itemMenuShow)
          {
            // Seta para baixo.
            case 1:

              // Se ainda existem linhas abaixo a serem exibidas no arquivo.
              if(marcUltimaLinhaSD < contLinhasSD)
              {
                // Atualiza os marcadores de linha, adicionando 8 (valor máximo de linhas exibidas) a eles.
                marcPrimeiraLinhaSD += 8;
                marcUltimaLinhaSD += 8;

                // Chama método para impressão das linhas do arquivo na tela.
                imprimeShowFile();

                // Inverte item atual (deixa preto).
                inverteItemShowFile(itemMenuShow);
              }

              break;

            // Seta para cima.
            case 2:

              // Se existem linhas acima, para serem exibidas, ou seja, marcador de primeira linha for maior que 0.
              if(marcPrimeiraLinhaSD > 0)
              {
                marcPrimeiraLinhaSD -= 8;
                marcUltimaLinhaSD -= 8;

                // Chama método para impressão das linhas do arquivo na tela.
                imprimeShowFile();

                // Inverte item atual (deixa preto).
                inverteItemShowFile(itemMenuShow);
              }

              break;

            // Seta de retorno.
            case 3:

              // Atualiza o menu principal para item da tela OPEN.
              itemMenuPrincipal = 2;

              // Retorna o controle para o menu principal.
              menuAtual = 1;

              // Atualiza o item do menu de listagem de arquivos (OPEN) para o valor 0 (inexistente).
              itemMenuShow = 0;

              // Atualiza Flags de controle, comunicando que o usuário ainda não movimentou o joystick para baixo.
              primeiraVezBaixo = true;
              primeiraVezCima = false;

              // Retorna os indicadores de itens das demais telas para valores default.
              itemMenuMem = 1;
              itemMenuReg = 1;
              itemMenuShow = 1; 
              itemOpen = 0;

              // Atualiza a tela atual como sendo a tela OPEN.
              telaAtual = 2;

              // Chama método para imprimir a tela OPEN.
              imprimeBaseOpen();

              break;
              
            // RUN
            case 4:

              // Chama método para carregar instruções para o MIPS.
              enviaInstrucao();

              // Chama método para execução no MIPS das instruções anteriormente carregadas.
              executa();
              
              break;
          }
  
          break;

        // Telas de ajuste do RTC, com exceção da ultima, SEGUNDOS.
        case 7:
        case 8:
        case 9:
        case 10:
        case 11:
        case 12:

          // Atualiza indicador de item RTC para próximo.
          itemRTC++;

          // Inverte item atual e anterior.
          inverteItemRTC(itemRTC);
          inverteItemRTC(itemRTC - 1);

          // Incrementa a tela atual.
          telaAtual += 1;
          
          break;

        // Tela de ajuste de SEGUNDOS do RTC.
        case 13:

          // Inverte flags.
          primeiraVezBaixo = true;
          primeiraVezCima = false;

          // Inverte faixa identificadora do item atual no menu principal (indica que o item está em foco).
          inverteItensMenuPrincipalFaixa(itemMenuPrincipal);

          // Inverte item atual do RTC.
          inverteItemRTC(itemRTC);

          // Altera o indicador de item do RTC para inexistente (não selecionado)
          itemRTC = 0;
          
          // Devolve o controle ao menu principal.
          menuAtual = 1;

          // Indica que o item do menu principal atual é o HOME.
          telaAtual = 1;

          break;
      }

      // Atualiza o tempo de debounce.
      lastDebounceTime = millis();
    }
  }
}


/**
 * Método responsável por imprimir na tela, valores do RTC.
 */
void imprimeRTC()
{
  // Seleciona fonte.
  TV.select_font(font4x6);

  // Imprime data em formato simplficado (2015 = 15).
  TV.print(2, 85, rtc.getDateStr(FORMAT_SHORT));

  // Imprime dia da semana.
  TV.print(45, 85, rtc.getDOWStr());

  // Imprime horário.
  TV.print(85, 85, rtc.getTimeStr());
}


/**
 * Procedimento responsável por buscar e imprimir na tela os 8 primeiros arquivos presentes no cartão SD.
 * Além disso salva no vetor adequado, os nomes de cada um dos aquivos, um em cada posição.
 */
void printDirectory(File dir) 
{
  // Seleciona fonte.
  TV.select_font(font4x6);

  dir.seek(0);
  
  while(true)
  {
    posY += 9;

    // Aponta para o próximo arquivo.
    File entry =  dir.openNextFile();

    // Caso não exista próximo arquivo, ou o contador de arquivos chegou em 8, para execução do método.
    if ((! entry) || (qtdArqSD == 8)) 
    {
       // no more files
       break;
    }

    // Adiciona na posição adequada o nome do arquivo atual.
    filesSD[qtdArqSD] = entry.name();

    // Imprime na tela o nome do arquivo atual.
    TV.print(2, posY, entry.name());

    // Incrementa o contador de arquivo.
    qtdArqSD++;

    // Caso o arquivo apontado atualmente seja uma pasta, chama método recursivamente para essa pasta.
    if (entry.isDirectory()) 
    {
      printDirectory(entry);
    }
    // Caso contrário, imprime o tamanho de tal arquivo na tela.
    else
    {
     TV.print(90, posY, entry.size(), DEC);
    }

    // Fecha arquivo atual.
    entry.close();
  }
}


/*
 * Método responsável por carregar as instruções lidas do SD e convertidas, para a memória de instruções do MIPS.
 */
void enviaInstrucao()
{
  byte contAddress = 0;
  byte base = 0;
  
  resetMIPS();
 
  // Liga LED de acesso ao FPGA.
  digitalWrite2(pinLedFPGA, HIGH);

  // Percorre todas as linhas do arquivo selecionado.
  for(int i = 0; i < contLinhasSD; i++)
  {
    // Separa a instrução em partes.
    splitInstrucao(linhasSD[i]);

    // Chama método para conversão da instrução para o binário do MIPS.
    converteInstrucao(); 

    base = 0;

    // Envia byte a byte a instrução convertida.
    for(int j = 0; j < 4; j++)
    {    
      // Converte o endereço da posição onde será carregada o byte da instrução.
      converteDecimalBinario(contAddress, binaryAddressREG, 8);

      // Escreve nos pinos correspondentes, o opCode dessa operação - load de instrução (i.e. "001").
      digitalWrite2(opCode2, LOW);
      digitalWrite2(opCode1, LOW);
      digitalWrite2(opCode0, HIGH);
  
      // Após a conversão, percorre o vetor onde está salvo o endereço convertido e escreve seus valores (digitalWrite2) nos pinos de endereço correspondente.
      for(int k = 0; k < 8; k++)
      {
        digitalWrite2(pinosAddress[k], binaryAddressREG[k]);
      }  

      // Escreve j-ésimo byte da instrução convetida
      for(int k = 0; k < 8; k++)
      {
        digitalWrite2(pinosDataOUT[k], instrucaoBytes[base + k]);
      }

      // Aguarda borda de subida do clock.
      while(digitalRead2(pinClock) != 1){}
      
      // Reseta circuito do FPGA.
      digitalWrite2(reset, HIGH);
    
      // Aguarda borda de subida do clock.
      while(digitalRead2(pinClock) != 1){}
  
      // Desliga o pino de reset (i.e. '0').
      digitalWrite2(reset, LOW);
  
      // Aguarda resposta "ready = 001" do FPGA, sinalizando que o dado do j-ésimo byte foi salvo.
      while(! ((digitalRead2(ready2) == LOW) && (digitalRead2(ready1) == LOW) && (digitalRead2(ready0) == HIGH)) ){}

      // Incrementa endereço para próxima iteração.
      contAddress++;

      // Incrementa variável auxiliar.
      base += 8;

      // Solicita ao MIPS que entre em estado IDLE e em seguida aguarda "delayFPGA" microssegundos antes da próxima iteração.
      solicitaIDLE();

      delayMicroseconds(delayFPGA);

    }
  }  

  // Liga LED de acesso ao FPGA.
  digitalWrite2(pinLedFPGA, LOW);
}


/*
 * Método utilizado para comunicar ao MIPS que esse deve inicar a execução das instruções que foram carregadas em sua memória.
 */
void executa()
{
  // Liga LED de acesso ao FPGA.
  digitalWrite2(pinLedFPGA, HIGH);
  
  // Escreve nos pinos correspondentes, o opCode dessa operação - execução de instruções (i.e. "111").
  digitalWrite2(opCode2, HIGH);
  digitalWrite2(opCode1, HIGH);
  digitalWrite2(opCode0, HIGH);

  // Aguarda borda de subida do clock.
  while(digitalRead2(pinClock) != 1){}
  
  // Reseta circuito do FPGA.
  digitalWrite2(reset, HIGH);
  
  // Aguarda borda de subida do clock.
  while(digitalRead2(pinClock) != 1){}
  
  // Desliga o pino de reset (i.e. '0').
  digitalWrite2(reset, LOW);

  // Aguarda resposta "ready = 101" do FPGA, sinalizando que as instruções foram executadas.
  while( !((digitalRead2(ready2) == HIGH) && (digitalRead2(ready1) == LOW) && (digitalRead2(ready0) == HIGH)) ){}

  // Verifica se ocorreu algum erro na execução, caso sim exibe mensagem de erro, caso contrário exibe mensagem de sucesso.
  if ((digitalRead2(error1) == HIGH) && (digitalRead2(error0) == HIGH))
  {
    TV.clear_screen();
    TV.print(25, 40, "EXECUTION ERROR!");
    TV.print(10, 60, "PLEASE, CHECK THE FILE!");

    delay(4000);
  }
  else
  {
    TV.clear_screen();
    TV.print(20, 40, "EXECUTION SUCESSFUL!");

    delay(4000);
  }

  // Imprime novamente a tela anterior a mensagem, ou seja a visualização do arquivo.
  itemMenuShow = 4;
  imprimeShowFile();
  inverteItemShowFile(itemMenuShow);
  inverteItensMenuPrincipalFaixa(itemMenuPrincipal);
  telaAtual = 6;

  // Desliga LED de acesso ao FPGA.
  digitalWrite2(pinLedFPGA, LOW);
}


/**
 * Procedimento principal.
 */
void loop() 
{
  // Caso a FPGA seja desligada, bloqueia controle e exibe mensagem ao usuário.
  if((digitalRead2(pinFPGAPower) == 0) && (printAviso == true))
  {
    printAviso = false;
    TV.clear_screen();
    TV.print(43, 40, "FPGA OFF!");
    TV.print(20, 60, "Turn ON to Continue!");

    printTelaAtual = true;
  }

  // Caso contrário
  else if(digitalRead2(pinFPGAPower) == 1)
  {
    printAviso = true;
    
    // Atualiza dados do RTC e os salva nas respectivas variáveis.
    dadosRTC = rtc.getTime();
    
    // Salva os dados atuais do RTC nas respectivas variáveis, assim, as mantém atualizadas.
    diaRTC    = dadosRTC.date;
    mesRTC    = dadosRTC.mon;
    anoRTC    = dadosRTC.year;
    diaSemRTC = dadosRTC.dow;
    horaRTC   = dadosRTC.hour;
    minRTC    = dadosRTC.min;
    segRTC    = dadosRTC.sec;
    
    // Chama método para operar o joystick.
    operaJoystickMenu();
  
    // Opera de acordo com o valor do item atual do menu principal.
    switch(itemMenuPrincipal)
    {
      // Item HOME.
      case 1:
  
        // Caso a tela atual seja HOME e ela não tenha sido impressa ainda.
        if((telaAtual == 1) && (printTelaAtual == true))
        {
          // Deasativa futuras impressões, até que o usuário mova o joystick para outra tela.
          printTelaAtual = false;

          TV.clear_screen();
  
          // Imprime base da tela.
          printBase();
  
          // Imprime o logo do MIPSDUINO
          TV.bitmap(3,20,logoMIPSDUINO);
  
          // Imprime reta para divisão dos dados do RTC na tela.
          TV.draw_line(0, 82, 118, 82, 1);
        }
  
        // Chama método para imprimir dados do RTC (essa chamada repete, diferentemente dos comandos no IF anterior).
        // Ou seja, a base da tela é impressa somente uma vez, porém os dados do RTC a cada execução do LOOP, caso a tela atual seja a HOME.
        imprimeRTC();
        
        break;
  
  
      // Item OPEN.
      case 2:
  
        // Caso a tela atual seja OPEN e ela não tenha sido impressa ainda.      
        if((telaAtual == 2) && (printTelaAtual == true))
        {
          // Chama método para impressão da tela OPEN.
          imprimeBaseOpen();
          
          // Deasativa futuras impressões, até que o usuário mova o joystick para outra tela.
          printTelaAtual = false;
        }
  
        break;
  
  
      // Item REG.
      case 3:
  
        // Caso a tela atual seja REG e ela não tenha sido impressa ainda.
        if((telaAtual == 3) && (printTelaAtual == true))
        {
          // Chama método para impressão da tela REG para primeiros registradores.
          imprimeBaseRegs1();

          // Inverte faixa identificadora do item atual no menu principal (indica que o item está em foco).
          inverteItensMenuPrincipalFaixa(itemMenuPrincipal);
  
          // Deasativa futuras impressões, até que o usuário mova o joystick para outra tela.
          printTelaAtual = false;
        }
        break;
  
  
      // Item MEM.
      case 4:
  
        // Caso a tela atual seja MEM e ela não tenha sido impressa ainda.
        if((telaAtual == 4) && (printTelaAtual == true))
        {
          // Posição inicial do cursor no eixo X para textbox.
          posX = 26;
          
          contAddrRAM = 0;

          // Limpa vetor de caracteres digitados no keypad.
          limpaTodosMemKeypad();
          
          // Chama método para impressão da tela MEM.
          imprimeBaseMem1();
  
          // Deasativa futuras impressões, até que o usuário mova o joystick para outra tela.
          printTelaAtual = false;
        }
        break;
  
  
      // Item ABOUT.
      case 5:
  
        // Caso a tela atual seja ABOUT e ela não tenha sido impressa ainda.
        if((telaAtual == 5) && (printTelaAtual == true))
        {
          // Chama método para impressão da tela ABOUT.
          imprimeBaseAbout();
  
          // Deasativa futuras impressões, até que o usuário mova o joystick para outra tela.
          printTelaAtual = false;
        }
        break;
    }
  }
}
