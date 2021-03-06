/*------------------------------------------------------------------------------------//


            Prática Simples com Entradas e Saídas do PIC

            Descrição: se apertar os botões do PORTD, inverterá o estado das saídas
            correspondentes do PORTC

            Código elaborado por: Pedro Beltran

            Esta obra está licenciada com uma licença GNU AGPL-3.0


//-------------------------------------------------------------------------------------*/

unsigned short i;

void main()
{
  INTCON = 0x00;
  CMCON |= 7;
  ADCON1 = 0x0F;
  ADON_bit = 0;
  TRISD = 0xFF;
  LATD = 0x00;
  
  TRISB = 0x00;
  LATB = 0x00;

  TRISC = 0x00;                                  // Configure PORTC as output
  LATC = 0x00;                                   // Initial PORTC value

  while (1)
  {
      for(i = 0; i < 8; i++)
      {
        if(Button(&PORTD, i, 10, 1))
        {
            while(!Button(&PORTD,i,10,0))
            {
                Delay_ms(10);
            }
            switch(i)
            {
                case 0: LATC0_bit = ~LATC0_bit; break;
                case 1: LATB6_bit = ~LATB6_bit; break;
                case 2: LATB7_bit = ~LATB7_bit; break;
                case 3: LATC3_bit = ~LATC3_bit; break;
                case 4: LATC4_bit = ~LATC4_bit; break;
                case 5: LATC5_bit = ~LATC5_bit; break;
                case 6: LATC6_bit = ~LATC6_bit; break;
                case 7: LATC7_bit = ~LATC7_bit; break;
            }
            Delay_ms(200);
        }
      }
  }
}