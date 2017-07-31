	title "Código Base para Motor de Passo"
	subtitle "Acionamento de um 28BYJ-48 em 6 modos diferentes"

CONFIG WDTEN = OFF
CONFIG FOSC = INTIO67
CONFIG PBADEN = OFF
CONFIG PLLCFG = OFF
CONFIG IESO = ON
CONFIG HFOFST = OFF
		
#include "p18f45k22.inc"

;(65535-10000) = 55535 = 1101 1000 1110 1111	
HIGH_BYTE_10ms	equ b'11011000' ; Esses dois valores são carregados no Timer1
LOW_BYTE_10ms	equ b'11101111' ; Que neste caso está contando microssegundos

;(65535-2000) = 63535 = 1111 1000 0010 1111	
HIGH_BYTE_2ms	equ b'11111000' ; Esses dois valores são carregados no Timer1
LOW_BYTE_2ms	equ b'00101111' ; Que neste caso está contando microssegundos

;(65535-900) = 64635 = 1111 1100 0111 1011
HIGH_BYTE   equ b'11111100' ; Esses dois valores são carregados no Timer1
LOW_BYTE    equ b'01111011' ; Que neste caso está contando microssegundos

SEL_MODO    equ PORTB
SEL_MODO_L  equ LATB
SEL_MODO_A  equ ANSELB
SEL_MODO_T  equ TRISB

MOTOR	    equ PORTC
MOTOR_L	    equ LATC
MOTOR_A	    equ ANSELC
MOTOR_T	    equ TRISC

REG0	    res 1
REG	    res 1
MODO	    res 1 ; 1 <= MODO <= 6
LED	    equ 0

; Programa
org 0	; começa no endereço 0
    goto Start_Program
    
org 18h
    tstfsz REG0
    goto Comeco0
    
    bcf T1CON, TMR1ON   ; Desliga o timer
    bcf PIR1, TMR1IF    ; Zera a "flag" que sinaliza o estouro do timer 1 
    bsf PIE1, TMR1IE    ; Habilita a interrupção do timer 1
    bsf INTCON, GIE
    
    incf REG
    goto Main

Comeco0:
	bcf T1CON, TMR1ON   ; Desliga o timer
	bcf PIR1, TMR1IF    ; Zera a "flag" que sinaliza o estouro do timer 1 
	bsf PIE1, TMR1IE    ; Habilita a interrupção do timer 1
	bsf INTCON, GIE
	
Teste_0:
	btfss SEL_MODO, 0
	goto Teste_1
    BIT0: 
	btfsc SEL_MODO, 0
	goto BIT0

	movlw 1
	movwf MODO
	goto Comeco
Teste_1:
	btfss SEL_MODO, 1
	goto Teste_2
    BIT1: 
	btfsc SEL_MODO, 1
	goto BIT1

	movlw 2
	movwf MODO
	goto Comeco
Teste_2:
	btfss SEL_MODO, 2
	goto Teste_3
    BIT2: 
	btfsc SEL_MODO, 2
	goto BIT2

	movlw 3
	movwf MODO
	goto Comeco
Teste_3:
	btfss SEL_MODO, 3
	goto Teste_4
    BIT3: 
	btfsc SEL_MODO, 3
	goto BIT3

	movlw 4
	movwf MODO
	goto Comeco
Teste_4:
	btfss SEL_MODO, 4
	goto Teste_5
    BIT4: 
	btfsc SEL_MODO, 4
	goto BIT4

	movlw 5
	movwf MODO
	goto Comeco
Teste_5:
	btfss SEL_MODO, 5
	goto Main
    BIT5: 
	btfsc SEL_MODO, 5
	goto BIT5

	movlw 6
	movwf MODO
	goto Comeco
	
Start_Program:
	movlw 1
	movwf MODO
	
	call Init_Osc	    ; Inicializa o Oscilador Interno
	call Init_Ports	    ; Inicializa os ports do PIC
	call Init_Timer    ; Inicializa o timer
	call Init_Intr	    ; Inicializa as interrupções
Comeco:	
	clrf REG0
	movlw 43h
	addwf MODO,0,0
	movwf TBLPTRL
	movlw 02h
	movwf TBLPTRH
	clrf TBLPTRU
	tblrd*
	movf TABLAT,0,0 ; Mover TABLAT para WREG(Work Register - Registrador de Trabalho)
	
	movwf REG
Main:	
	movff REG, TBLPTRL
	movlw 02h
	movwf TBLPTRH 
	clrf TBLPTRU ; UPPER BITS
	
	tblrd* ;TABLAT POINT TOWARD THE FIRST STRING
	movlw '%'
	cpfseq TABLAT
	goto Acionar
	goto Comeco 
	
Acionar:
	movff TABLAT,MOTOR
	goto Delay
	
				
Init_Osc:
; Oscilador interno configurado para 4MHz
	movlw b'01010111'
	movwf OSCCON
	return

Init_Ports:
	clrf MOTOR
	clrf MOTOR_L
	clrf MOTOR_A	; Faz o Port C ser digital
	clrf MOTOR_T	; Faz o Port C ser saída
	
	clrf SEL_MODO
	clrf SEL_MODO_L
	clrf SEL_MODO_A	; Faz o Port B ser digital
	setf SEL_MODO_T	
	return

Init_Timer:
; Registradores do Timer1 
; Prescaler=1:1; Ciclo de máquina: 1us
	movlw b'00000010'
	movwf T1CON
	return

Init_Intr:
	bsf INTCON, GIE
	
	bsf INTCON, PEIE
	bcf RCON, IPEN
	
	bsf PIE1, TMR1IE    ; Habilita a interrupção do timer 1
	bcf PIR1, TMR1IF    ; Zera a "flag" que sinaliza o estouro do timer 1
	return
	
Delay:
    bcf T1CON, TMR1ON   ; Desliga o timer 1
    bcf PIR1, TMR1IF    ; Zera a "flag" que sinaliza o estouro do timer 1

    movlw 4
    cpfsgt MODO
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
    clrf REG0
    bsf T1CON, TMR1ON   ; Liga o timer 1
    
    goto Teste0

Teste0:
    btfss SEL_MODO, 0
    goto Teste1
    
    goto Delay_10ms

Teste1:
    btfss SEL_MODO, 1
    goto Teste2

    goto Delay_10ms

Teste2:
    btfss SEL_MODO, 2
    goto Teste3

    goto Delay_10ms

Teste3:
    btfss SEL_MODO, 3
    goto Teste4

    goto Delay_10ms
  
Teste4:
    btfss SEL_MODO, 4
    goto Teste5

    goto Delay_10ms
   
Teste5:
    btfss SEL_MODO, 5
    goto Teste0

    goto Delay_10ms

Delay_10ms:
    bcf INTCON, GIE
    bcf T1CON, TMR1ON   ; Desliga o timer 1
    bcf PIR1, TMR1IF    ; Zera a "flag" que sinaliza o estouro do timer 1   

    movlw LOW_BYTE_10ms	; Configura o byte mais baixo
    movwf TMR1L
    movlw HIGH_BYTE_10ms; Configura o byte mais alto
    movwf TMR1H
    bsf T1CON, TMR1ON   ; Liga o timer 1
    bsf INTCON, GIE
    
    setf REG0
    
    goto $
    
 
; Passos Completos - 4 Passos - Menor torque
org 200h
	db b'00001000', b'00000100', b'00000010', b'00000001', '%'						; Rotação no sentido anti-horário Passo Completo
org 206h
	db b'00001000', b'00000001', b'00000010', b'00000100', '%'						; Rotação no sentido horário Passso Completo

; Passos Completos - 4 Passos - Maior torque
org 212h
	db b'00001100', b'00000110', b'00000011', b'00001001', '%'						; Rotação no sentido anti-horário Passo Completo
org 218h
	db b'00001100', b'00001001', b'00000011', b'00000110', '%'

; Meios Passos - 8 Passos - Maior precisão
org 224h
	db b'00001100', b'00000100', b'00000110', b'00000010'
	db b'00000011', b'00000001', b'00001001', b'00001000', '%' ; Sentido anti-horário - meio passo
org 234h
	db b'00000001', b'00000011', b'00000010', b'00000110'
	db b'00000100', b'00001100', b'00001000', b'00001001', '%' ; Sentido horário - meio passo

; Apontador das posições de memória
org 244h
	db 00h, 06h, 12h, 18h, 24h, 34h ; Tabela que determina os modos de acionamento do motor

end