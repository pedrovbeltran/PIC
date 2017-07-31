/*------------------------------------------------------------------------------------//


            Prática Simples com Entradas e Saídas do PIC

            Descrição: se apertar o botão RE2 ou RE3, gerará um pulso nas saídas RE0 ou RE1
            que durará 500 milissegundos

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

  TRISE0_bit = 0;
  TRISE1_bit = 0;
  TRISE2_bit = 1;
  MCLR_bit = 0;
  LATE = 0x02;

  while (1)
  {
      for(i = 2; i < 4; i++)
      {
        if(Button(&PORTE,i,10,1))
        {
            while(!Button(&PORTE,i,10,0))
            {
                Delay_ms(10);
            }
            switch(i)
            {
                case 2: LATE0_bit = 1; Delay_ms(500); LATE0_bit = 0; break;
                case 3: LATE1_bit = 0; Delay_ms(500); LATE1_bit = 1; break;
            }
        }
      }
  }
}