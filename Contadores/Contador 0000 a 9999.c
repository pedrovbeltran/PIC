/*----------------------------------------------------------------------------------//
                

                Contador de 0000 a 9999

                Código elaborado por: Pedro Beltran
                
                Esta obra está licenciada com uma licença GNU AGPL-3.0


//---------------------------------------------------------------------------------*/

short int numeros[10] = {0b00111111,0b00000110,0b01011011,0b01001111,0b01100110,0b01101101,0b01111101,0b00000111,0b01111111,0b01101111};

unsigned int unidade,dezena,centena,milhar,vezes;

void Timer0_Interrupt();

void main()
{

           ANSELA = 0;                    // Configure PORTA pins as digital
          ANSELD = 0;                    // Configure PORTD pins as digital

          TRISA = 0;                     // Configure PORTA as output
          LATA = 0;

          TRISD = 0;                     // Configure PORTD as output
          LATD  = 0;                     // Clear PORTD

          //Configurando timer usando os bits do INTCON (Interrupt Control Register)
          GIE_bit = 1;    //Global Interrupt Enable
          TMR0IE_bit = 1; //Timer 0 Interrupt Enable
          T0CON = 0xC7;   //Timer 0 Control Register
                          //C7 = 11000111, consultar datasheet para mais informações
                          //Timer no modo de 8 bits
          TMR0L = 0;

          unidade = 0;
          dezena = 0;
          centena = 0;
          milhar = 0;
          vezes = 30;

          while(1)
          {
            RA0_bit = 1;
            RA1_bit = 0;
            RA2_bit = 0;
            RA3_bit = 0;
            LATD = numeros[unidade];
            Delay_ms(3);
            RA0_bit = 0;
            RA1_bit = 1;
            RA2_bit = 0;
            RA3_bit = 0;
            LATD = numeros[dezena];
            Delay_ms(3);
            RA0_bit = 0;
            RA1_bit = 0;
            RA2_bit = 1;
            RA3_bit = 0;
            LATD = numeros[centena];
            Delay_ms(3);
            RA0_bit = 0;
            RA1_bit = 0;
            RA2_bit = 0;
            RA3_bit = 1;
            LATD = numeros[milhar];
            Delay_ms(3);
          }
}

void Timer0_Interrupt() iv 0x000008 ics ICS_OFF
{

                TMR0IF_bit = 0;
                TMR0L = 0;
                if (vezes == 0)
                {
                   vezes = 30;
                   if (unidade < 9)
                    {
                       unidade++;
                    }
                    else
                    {
                            unidade = 0;
                            if (dezena < 9)
                            {
                                    dezena++;
                            }
                            else
                            {
                                    dezena = 0;
                                    if (centena < 9)
                                    {
                                            centena++;
                                    }
                                    else
                                    {
                                            centena = 0;
                                            if (milhar < 9)
                                            {
                                                    milhar++;
                                            }
                                            else
                                                    milhar = 0;
                                }

                            }
                    }
                }
                else
                    vezes--;

}