/*  Pulsa enviar para obtener la tesela en formato ROM VHDL
*/

#include <SPI.h>
#include <TFT_eSPI.h>

TFT_eSPI tft = TFT_eSPI();    // Config setup 70b HSPI

uint16_t colorSelection = 0x867D;   // Azul por defecto
uint16_t bitmapMatrix [8][8] = {{0}};

void touch_calibrate() {
  uint16_t calData[5] = { 316, 3559, 218, 3510, 7 };
  tft.setTouch(calData);
}

void setup() {
  Serial.begin(115200);

  tft.begin();
  tft.setRotation(1);
  touch_calibrate();

  // Dibuja la cuadricula 8x8
  tft.fillScreen(TFT_BLACK);
  for (int row = 0; row < 8; row++) {
    for (int col = 0; col < 8; col++) {
      tft.drawRect(col * 20, row * 20, 20, 20, TFT_WHITE);
    }
  }

  tft.drawRect(270, 0, 50, 20, TFT_WHITE);
  tft.fillRect(270, 0, 48, 18, 0xFDA0);       // Naranja
  tft.drawRect(270, 20, 50, 20, TFT_WHITE);
  tft.fillRect(270, 20, 48, 18, 0x07E0);      // Verde

  tft.setTextColor(TFT_BLACK, 0xFDA0);  // Texto en negro sobre el rectangulo
  tft.setTextSize(1);                   // Tamaño del texto
  tft.setCursor(275, 5);                // Posicion del texto
  tft.print("Naranja");

  // Texto
  tft.setTextColor(TFT_BLACK, 0x07E0);
  tft.setTextSize(1);
  tft.setCursor(275, 25);
  tft.print("Verde");

  tft.drawRect(180, 0, 60, 20, TFT_WHITE);
  tft.fillRect(182, 2, 56, 16, 0x0000);
  tft.drawRect(180, 25, 60, 20, TFT_WHITE);
  tft.fillRect(182, 27, 56, 16, 0x0000);

  tft.setTextColor(TFT_WHITE, 0x0000);
  tft.setTextSize(1);
  tft.setCursor(185, 5);
  tft.print("Enviar");

  tft.setTextColor(0xFFFF, 0x0000);
  tft.setTextSize(1);
  tft.setCursor(185, 30);
  tft.print("Reiniciar");

  // Texto generico
  tft.setTextColor(TFT_WHITE, 0x0000);
  tft.setTextSize(1);
  tft.setCursor(0, 200);
  tft.print("Programa desarrollado para diseñar bitmaps desde una interfaz mas interactiva.\
 Capaz de diseñar bitmaps de hasta 8x8 cuadriculas, envia la informacion a la FPGA mediante SPI,\
 ofreciendo la posibilidad de diseñar tus propios bitmaps en tiempo real");

  tft.setTextColor(TFT_WHITE, 0x0000);
  tft.setTextSize(1);
  tft.setCursor(0, 170);
  tft.print("Dibuja aqui tu bitmap. Pulsa /enviar/ cuando termines");
}

void loop() {
  uint16_t x = 0, y = 0;

  bool pressed = tft.getTouch(&x, &y);

  if (pressed) {
    // Para calcular la columna y la fila de la celda tocada
    int col = x / 20;
    int row = y / 20;

    if (pressed && x > 270 && x < 320 && y > 0 && y < 20){
      if (colorSelection == 0xFDA0){
        colorSelection = 0x867D;    // Azul
      }
      else {
        colorSelection = 0xFDA0;    // Naranja
        Serial.println("Cambio a naranja");
      }
    }
    else if (pressed && x > 270 && x < 320 && y > 20 && y < 40){
      if (colorSelection == 0x07E0){
        colorSelection = 0x867D;    // Azul
      }
      else {
        colorSelection = 0x07E0;    // Verde
        Serial.println("Cambio a verde");
      }
    }
    
    else if (col < 8 && row < 8) { // Debug
      Serial.print("Zona valida: fila ");
      Serial.print(row);
      Serial.print(", columna ");
      Serial.println(col);
      
      // Actualiza la celda tocada (rellena del color seleccionado)
      tft.fillRect(col * 20, row * 20, 18, 18, colorSelection);
      switch (colorSelection) {
        case 0x867D:
          bitmapMatrix[row][col] = 0x867D;
          break;
        case 0xFDA0:
          bitmapMatrix[row][col] = 0xFDA0;
          break;
        case 0x07E0:
          bitmapMatrix[row][col] = 0x07E0;
          break;
      }
    }

    else if (pressed && x > 180 && x < 240 && y > 20 && y < 40){    // Reinicio
    tft.fillRect(0, 0, 160, 160, 0x0000);
    Serial.print("Tu bitmap esta preparado! Copia lo siguiente:\n\n");
    Serial.print("const uint16_t bitmapWidth = 8;\nconst uint16_t bitmapHeight = 8;\n");
    Serial.print("const unsigned short  bitmap[64] PROGMEM={\n");
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          tft.drawRect(col * 20, row * 20, 20, 20, TFT_WHITE);
          Serial.print(bitmapMatrix[row][col]);
          if (!(row == 7 && col == 7)) {
            Serial.print(",");
          }
          bitmapMatrix[row][col] = 0;
        }
      }
      Serial.print("};");
      Serial.println();
    }

    else if (pressed && x > 180 && x < 240 && y > 0 && y < 20){    // ROM monocromo
    Serial.print("Tu bitmap esta preparado! Copia lo siguiente:\n\n");
    Serial.print("library IEEE;\nuse IEEE.STD_LOGIC_1164.ALL;\nuse IEEE.NUMERIC_STD.ALL;\n\n\nentity ROMx is\n  port (\n    clk  : in  std_logic;   -- reloj\n    addr : in  std_logic_vector(8-1 downto 0);\n    dout : out std_logic_vector(16-1 downto 0));\nend ROMx;\n\n\n");
    Serial.print("architecture BEHAVIORAL of ROMx is\n  signal addr_int  : natural range 0 to 2**4-1;\n type memostruct is array (natural range<>) of std_logic_vector(8-1 downto 0);\n constant filaimg : memostruct := (\n");
      for (int row = 0; row < 8; row++) {
        Serial.print('"');
        for (int col = 0; col < 8; col++) {
          uint16_t temp_val = bitmapMatrix[row][col];
          switch (temp_val) {
            case 0x867D:
              Serial.print('1');
              break;
            default:
              Serial.print('0');
              break;
          }
        }
        if (row != 7) {
          Serial.print("\",\n");
        } else {
          Serial.print("\"");
        }
      }
      Serial.print(");\n\n\nbegin\n\n addr_int <= TO_INTEGER(unsigned(addr));\n\n P_ROM: process (clk)\n  begin\n   if clk'event and clk='1' then\n     dout <= filaimg(addr_int);\n    end if;\n end process;\n\nend BEHAVIORAL;");
      Serial.println();
    }


    else {
      Serial.println("Zona no valida");   // Debug
    }
  }

  delay(250);   // Para evitar demasiada velocidad en la escritura
}

