/*------------------------------------------------------------------------------------//


            Muda o modo de operação das saídas pressionando repetidas vezes
            o botão RA0 em um curto período de tempo

            Descrição: 
            Entradas (botões) -> PORTA
            Saídas -> PORTB
            Há 3 modos de operação:
            MODO 1: o PORTB se comportando como saídas biestáveis
            MODO 2: o PORTB se comportando como saídas monoestáveis
            MODO 3: metade do PORTB (RB0 - RB3) se comporta como saídas biestáveis
                    e a outra se comporta como saídas monoestáveis

            Código elaborado por: Pedro Beltran

            Esta obra está licenciada com uma licença GNU AGPL-3.0


//-------------------------------------------------------------------------------------*/

unsigned short i, modo = 1, contador = 0, temp = 0;

void botao(), saidas_biestaveis(), saidas_monoestaveis(), saidas_mistas(), interrupt();

void main()
{
    CMCON |= 7;
    TRISA = 0xFF;
    PORTA = 0x00;

    TRISB = 0x00;
    PORTB = 0x00;

    INTCON = 0xC0;

    T1CON = 0b00000000;

    TMR1L = 0;
    TMR1H = 0;

    TMR1IF_bit = 0;
    TMR1IE_bit = 1;

    while(1)
    {
        switch (modo)
        {
            case 1: saidas_biestaveis(); break;
            case 2: saidas_monoestaveis(); break;
            case 3: saidas_mistas(); break;
        }

        if(contador == 4)
        {
            contador = 0;
            if(modo < 4)
            {
                PORTB = 0xFF;
                Delay_ms(500);
                PORTB = 0x00;
                Delay_ms(500);
                PORTB = 0xFF;
                Delay_ms(500);
                PORTB = 0x00;

                modo++;
            }
            else
                modo = 1;
        }

        botao();
        delay_ms(100);
    }
}

void botao()
{
    if(Button(&PORTA,0,10,1))
    {
        while(!Button(&PORTA,0,10,0));

        if(modo == 2)
        {
            RB0_bit = 1; Delay_ms(500); RB0_bit = 0;
        }
        else
            RB0_bit = ~RB0_bit;

        if (contador == 0)
        {
            TMR1ON_bit = 1;
        }

        contador++;
    }
}

void saidas_biestaveis()
{
    for(i = 1; i < 8; i++)
    {
        if(Button(&PORTA, i, 10, 1))
        {
            while(!Button(&PORTA,i,10,0));

            switch(i)
            {
                case 1: RB1_bit = ~RB1_bit; break;
                case 2: RB2_bit = ~RB2_bit; break;
                case 3: RB3_bit = ~RB3_bit; break;
                case 4: RB4_bit = ~RB4_bit; break;
                case 5: RB5_bit = ~RB5_bit; break;
                case 6: RB6_bit = ~RB6_bit; break;
                case 7: RB7_bit = ~RB7_bit; break;
            }
        }
    }
}

void saidas_monoestaveis()
{
    for(i = 1; i < 8; i++)
    {
        if(Button(&PORTA,i,10,1))
        {
            while(!Button(&PORTA,i,10,0));

            switch(i)
            {
                case 1: RB1_bit = 1; Delay_ms(500); RB1_bit = 0; break;
                case 2: RB2_bit = 1; Delay_ms(500); RB2_bit = 0; break;
                case 3: RB3_bit = 1; Delay_ms(500); RB3_bit = 0; break;
                case 4: RB4_bit = 1; Delay_ms(500); RB4_bit = 0; break;
                case 5: RB5_bit = 1; Delay_ms(500); RB5_bit = 0; break;
                case 6: RB6_bit = 1; Delay_ms(500); RB6_bit = 0; break;
                case 7: RB7_bit = 1; Delay_ms(500); RB7_bit = 0; break;
            }
        }
    }
}

void saidas_mistas()
{
    for(i = 1; i < 8; i++)
    {
        if(Button(&PORTA,i,10,1))
        {
            while(!Button(&PORTA,i,10,0));

            switch(i)
            {
                case 1: RB1_bit = ~RB1_bit; break;
                case 2: RB2_bit = ~RB2_bit; break;
                case 3: RB3_bit = ~RB3_bit; break;
                case 4: RB4_bit = 1; Delay_ms(500); RB4_bit = 0; break;
                case 5: RB5_bit = 1; Delay_ms(500); RB5_bit = 0; break;
                case 6: RB6_bit = 1; Delay_ms(500); RB6_bit = 0; break;
                case 7: RB7_bit = 1; Delay_ms(500); RB7_bit = 0; break;
            }
        }
    }
}

void interrupt()
{
    if(TMR1IF_bit == 1)
    {
        if(temp == 19 && modo != 2)
        {
            temp = 0;

            TMR1L = 0;
            TMR1H = 0;
            TMR1IF_bit = 0;
            contador = 0;
        }
        else if(temp == 59 && modo == 2)
        {
            temp = 0;

            TMR1L = 0;
            TMR1H = 0;
            TMR1IF_bit = 0;
            contador = 0;
        }
        else
        {
            temp++;

            TMR1L = 0;
            TMR1H = 0;
            TMR1IF_bit = 0;
        }
    }
}