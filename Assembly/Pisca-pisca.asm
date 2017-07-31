	title "Pisca-pisca com o Timer"
	subtitle "Olá mundo para microcontroladores"
		
CONFIG WDTEN = OFF
CONFIG FOSC = INTIO67
CONFIG PBADEN = OFF
CONFIG PLLCFG = OFF
CONFIG IESO = ON
CONFIG HFOFST = OFF
		
#include "p18f45k22.inc"

;(65535-50000) = 15535 = 00111100 10101111	
HIGH_BYTE   equ b'00111100' ; Esses dois valores são carregados no Timer1
LOW_BYTE    equ b'10101111' ; Que neste caso está contando microssegundos
LED	    equ 0
	   
Delay res 1
 
; Programa
org 0			    ; começa no endereço 0

movlw d'20'
movwf Delay		    ; Número de vezes que o atraso de meio segundo vai se repetir

Start_Program:
	call Init_Osc	    ; Inicializa o Oscilador Interno
	call Init_Ports	    ; Inicializa os ports do PIC
	call Init_Timer	    ; Inicializa o timer
	call Init_Intr	    ; Inicializa as interrupções

Main:
	call Delay_50ms
	call Toggle_LED
	GOTO Main
				
Init_Osc:
; Oscilador interno configurado para 4MHz
	movlw b'01010111'
	movwf OSCCON
	return

Init_Ports:
	clrf PORTB
	clrf ANSELB	    ; Faz o Port B ser digital
	clrf TRISB	    ; Faz o Port B ser saída	
	return

Init_Timer:
; Registradores do Timer1 
; Prescaler=1:1; Ciclo de máquina: 1us
	movlw b'00000010'
	movwf T1CON
	return
Init_Intr:
	bsf PIE1, TMR1IE    ; Habilita a interrupção do timer 1
	bcf PIR1, TMR1IF    ; Zera a "flag" que sinaliza o estouro do timer 1
	return
	
Delay_50ms:
	bcf T1CON, TMR1ON   ; Desliga o timer 1
	bcf PIR1, TMR1IF    ; Zera a "flag" que sinaliza o estouro do timer 1
	
	movlw LOW_BYTE	    ; Configura o byte mais baixo
	movwf TMR1L
	movlw HIGH_BYTE	    ; Configura o byte mais alto
	movwf TMR1H	

	bsf T1CON, TMR1ON   ; Liga o timer 1

teste:	btfss PIR1, TMR1IF  ; Vê o estouro do timer
	GOTO teste	    ; Espera pelo estouro do timer

	bcf T1CON, TMR1ON   ; Desliga o timer
	bcf PIR1, TMR1IF    ; Zera a "flag" que sinaliza o estouro do timer 1
	
	decfsz Delay	    ; delay = 0?
	GOTO Delay_50ms	    ; se for igual a zero continua, se não vai à Main
	return
	
Toggle_LED:
	movlw d'20'
	movwf Delay
	
	btfsc PORTB, LED    ; O LED está desligado?
	GOTO Esta_Ligado    ; Vá para Esta_Ligado. Será pulado se o LED estiver desligado

Esta_Desligado:			    ; Executa se o LED está desligado
	bsf PORTB, LED
	return

Esta_Ligado:			    ; Executa se o LED está ligado
	bcf PORTB, LED
	return
end
