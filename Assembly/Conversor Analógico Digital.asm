	title "Código Base - Conversor Analógico Digital"
	subtitle "Equivalente ao código em C cedido pela mikroElektronika"

CONFIG WDTEN = OFF
CONFIG FOSC = INTIO67
CONFIG PBADEN = OFF
CONFIG PLLCFG = OFF
CONFIG IESO = ON
CONFIG HFOFST = OFF
		
#include "p18f45k22.inc"
	
org 0

call Init_Osc
call Init_Ports
call Init_CAD

Laco:
    btfsc ADCON0,GO
    goto Laco

    movff ADRESL, PORTC
    movff ADRESH, PORTD
    bsf ADCON0,GO
    goto Laco

Init_Osc:
; Oscilador interno configurado para 4MHz
	movlw b'01010111'
	movwf OSCCON
	return

Init_Ports:
    clrf PORTB
    clrf LATB
    movlw b'00000010'
    movwf TRISB
    movwf ANSELB

    clrf PORTC
    clrf LATC
    clrf TRISC
    clrf ANSELC

    clrf PORTD
    clrf LATD
    clrf TRISD
    clrf ANSELD
    return

Init_CAD:
    movlw b'00000111'
    movwf ADCON0
    clrf ADCON1
    movlw b'10101111' ; 12 TAD e Frc - Clock derivado de um oscilador interno dedicado de 600kHz
    movwf ADCON2
    return

end