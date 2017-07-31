	title "Código Base para Motor de Passo"
	subtitle "Acionamento de um 28BYJ-48 em 6 modos diferentes"

CONFIG WDTEN = OFF
CONFIG FOSC = INTIO67
CONFIG PBADEN = OFF
CONFIG PLLCFG = OFF
CONFIG IESO = ON
CONFIG HFOFST = OFF
		
#include "p18f45k22.inc"

;(65535-2000) = 63535 = 1111 1000 0010 1111	
HIGH_BYTE_2ms	equ b'11111000' ; Esses dois valores são carregados no Timer1
LOW_BYTE_2ms	equ b'00101111' ; Que neste caso está contando microssegundos

;(65535-900) = 64635 = 1111 1100 0111 1011
HIGH_BYTE   equ b'11111100' ; Esses dois valores são carregados no Timer1
LOW_BYTE    equ b'01111011' ; Que neste caso está contando microssegundos

MOTOR		equ PORTC

MODO	    equ 1 ; 1 <= MODO <= 6 (Para mudar o modo de operação do motor, basta mudar o valor do MODO)
LED	        equ 0
	
; Programa
org 0			    ; começa no endereço 0

Start_Program:
	call Init_Osc	    ; Inicializa o Oscilador Interno
	call Init_Ports	    ; Inicializa os ports do PIC
	call Init_Timer    ; Inicializa o timer
	call Init_Intr	    ; Inicializa as interrupções
	
Comeco:
	movlw 43h
	addlw MODO
	movwf TBLPTRL
	movlw 01h
	movwf TBLPTRH
	clrf TBLPTRU
	tblrd*
	movf TABLAT,0,0 ; Mover TABLAT para WREG(Work Register - Registrador de Trabalho)
	
	movwf TBLPTRL
	movlw 01h
	movwf TBLPTRH 
	clrf TBLPTRU ; UPPER BITS
	
Main:
    tblrd*+ ;TABLAT POINT TOWARD THE FIRST STRING 
	movlw '%'
	cpfseq TABLAT
	goto Acionar
	goto Comeco 
	
Acionar:
	movff TABLAT,MOTOR
	call Delay
	goto Main
	
				
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
	
Delay:
	bcf T1CON, TMR1ON   ; Desliga o timer 1
	bcf PIR1, TMR1IF    ; Zera a "flag" que sinaliza o estouro do timer 1
	
	movlw 23h
	cpfsgt TBLPTRL
	goto _2ms
	goto _900us
	
_2ms:
	movlw LOW_BYTE_2ms	    ; Configura o byte mais baixo
	movwf TMR1L
	movlw HIGH_BYTE_2ms	    ; Configura o byte mais alto
	movwf TMR1H
	goto liga

_900us:
	movlw LOW_BYTE	    ; Configura o byte mais baixo
	movwf TMR1L
	movlw HIGH_BYTE	    ; Configura o byte mais alto
	movwf TMR1H

liga:
	bsf T1CON, TMR1ON   ; Liga o timer 1

Teste:	btfss PIR1, TMR1IF  ; Vê o estouro do timer
	goto Teste	    ; Espera pelo estouro do timer

	bcf T1CON, TMR1ON   ; Desliga o timer
	bcf PIR1, TMR1IF    ; Zera a "flag" que sinaliza o estouro do timer 1
	return

; Passos Completos - 4 Passos - Menor torque
org 100h
	db b'00001000', b'00000100', b'00000010', b'00000001', '%'						; Rotação no sentido anti-horário Passo Completo
org 106h
	db b'00001000', b'00000001', b'00000010', b'00000100', '%'						; Rotação no sentido horário Passso Completo

; Passos Completos - 4 Passos - Maior torque
org 112h
	db b'00001100', b'00000110', b'00000011', b'00001001', '%'						; Rotação no sentido anti-horário Passo Completo
org 118h
	db b'00001100', b'00001001', b'00000011', b'00000110', '%'

; Meios Passos - 8 Passos - Maior precisão
org 124h
	db b'00001100', b'00000100', b'00000110', b'00000010'
	db b'00000011', b'00000001', b'00001001', b'00001000', '%' ; Sentido anti-horário - meio passo
org 134h
	db b'00000001', b'00000011', b'00000010', b'00000110'
	db b'00000100', b'00001100', b'00001000', b'00001001', '%' ; Sentido horário - meio passo

; Apontador das posições de memória
org 144h
	db 00h, 06h, 12h, 18h, 24h, 34h ; Tabela que determina os modos de acionamento do motor
end
