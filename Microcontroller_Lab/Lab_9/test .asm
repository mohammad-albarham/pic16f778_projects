;**********************************************************
; This program to receive a character from the PC and return (send) next character to PC again. 
;**********************************************************

	include "p16f877A.inc"

       __CONFIG   	_CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _XT_OSC

;**********************************************************
; User-defined variables

	cblock	0x20
		WTemp			; Must be reserved in all banks
		StatusTemp
		counter
	endc

	cblock	0x0A0			; bank 1 assignnments
		WTemp1			; bank 1 WTemp
	endc

	cblock	0x120			; bank 2 assignnments
		WTemp2			; bank 2 WTemp
	endc

	cblock	0x1A0			; bank 3 assignnments
		WTemp3			; bank 3 WTemp
	endc

;**********************************************************
; Macro Assignments

push	macro
	movwf	WTemp		;WTemp must be reserved in all banks
	swapf	STATUS,W	;store in W without affecting status bits
	banksel	StatusTemp	;select StatusTemp bank
	movwf	StatusTemp	;save STATUS
	endm

pop	macro
	banksel	StatusTemp	;point to StatusTemp bank
	swapf	StatusTemp,W	;unswap STATUS nybbles into W	
	movwf	STATUS		;restore STATUS (which points to where W was stored)
	swapf	WTemp,F		;unswap W nybbles
	swapf	WTemp,W		;restore W without affecting STATUS
	endm

;**********************************************************
; Start of executable code

	org	0x00		; Reset vector
	nop
	goto	Main

;**********************************************************
; Interrupt vector

	org	0x04		; interrupt vector
	goto	IntService

;**********************************************************
; Main program 

Main
	call	Initial		; Initialize everything
MainLoop	
	nop
	nop
	goto	MainLoop	; Do it again

;**********************************************************
; Initial Routine

Initial	
	movlw	D'25'		; This sets the baud rate to 9600
	banksel	SPBRG		; assuming BRGH=1 and Fosc=4.000 MHz
	movwf	SPBRG

	banksel	RCSTA		
	bsf		RCSTA,SPEN	; Enable the serial port
	bcf		RCSTA,RX9	; Disable9-bit Receive 
	bsf		RCSTA,CREN	; Enable continuous receive

	banksel	TXSTA
	bcf		TXSTA,SYNC	; Set up the port for asynchronous operation
	bsf		TXSTA,TXEN	; Transmit enabled
	bsf		TXSTA,BRGH	; High baud rate
	bcf		TXSTA,TX9	; Disable9-bit send

	banksel	PIE1		; Enable the Timer2 interrupt
	bsf	PIE1, RCIE
	bcf	TRISC,RC6		; Set RC6 to output Send Pin
	bsf	TRISC,RC7		; Set RC7 to input Receive Pin

	banksel	INTCON		; Enable global and peripheral interrupts
	bsf	INTCON, GIE
	bsf	INTCON, PEIE

	banksel	counter
	clrf    counter
	banksel TRISB 	
	clrf 	TRISB	
	banksel PORTB	
	clrf 	PORTB	

	return

;**********************************************************
; Interrupt Service Routine
; This routine is called whenever we get an interrupt.

IntService
	push
	btfsc	PIR1, RCIF	; Check for a Timer2 interrupt
	call	RECEIVE
;	btfsc	...		; Check for another interrupt
;	call	...
;	btfsc	...		; Check for another interrupt
;	call	...
	pop
	retfie

;**********************************************************
RECEIVE
	
	movf	RCREG,w
	movf	RCREG,w
	movwf	counter

 	sublw	0x43	
	btfsc	STATUS,C
	goto 	ONE	
	
	movf	counter,0
	sublw	0x46	
	btfsc	STATUS,C
	goto 	TWO

	movf	counter,0
	sublw	0x49	
	btfsc	STATUS,C
	goto 	THREE
	
	movf	counter,0
	sublw	0x4C	
	btfsc	STATUS,C
	goto 	FOUR

	movf	counter,0
	sublw	0x4F	
	btfsc	STATUS,C
	goto 	FIVE	
	
	movf	counter,0
	sublw	0x52	
	btfsc	STATUS,C
	goto 	SIX	
	
	movf	counter,0
	sublw	0x55	
	btfsc	STATUS,C
	goto 	SEVEN
	
	movf	counter,0
	sublw	0x58	
	btfsc	STATUS,C
	goto 	EIGHT
	
	movf	counter,0
	sublw	0x5A	
	btfsc	STATUS,C
	goto 	NINE
	
	movlw 	0
	movwf 	counter	

	FINISH		
	call  	look_up
	banksel PORTB 
	movwf 	PORTB
	
	return

ONE 	
	movlw	1
	movwf	counter	
	goto 	FINISH
TWO	
	movlw	2
	movwf	counter
	goto 	FINISH

THREE	
	movlw	3
	movwf	counter
	goto 	FINISH
FOUR
	movlw	4
	movwf	counter
	goto 	FINISH
FIVE
	movlw	5
	movwf	counter
	goto 	FINISH
SIX
	movlw	6
	movwf	counter
	goto 	FINISH
SEVEN 
	movlw	7
	movwf	counter
	goto 	FINISH
EIGHT 
	movlw	8
	movwf	counter
	goto 	FINISH
NINE
	movlw	9
	movwf	counter
	goto 	FINISH



look_up 
movf    counter,0 
addwf 	PCL,1	
retlw 	b'00111111' ;0
retlw 	b'00000110' ;1	
retlw 	b'01011011' ;2	 
retlw 	b'01001111' ;3	
retlw 	b'01100110'	;4
retlw   b'01101101'	;5
retlw 	b'01111101'	;6
retlw 	b'00000111'	;7
retlw 	b'01111111'	;8
retlw 	b'01100111'	;9


	end