// Programmgeruest zur Aufgabe Termin6 WS2019
// von: Manfred Pester
// vom: 18.09.2013
// @ int Operationen(volatile unsigned int* u_int_Taster, volatile unsigned int* u_int_LedsOn) 
@ Diese Funktion soll auf 
@ - LED DS1 (Bit 8) das Ergebnis von SW1 AND SW2 anzeigen 
@ - LED DS2 (Bit 9) das Ergebnis von SW1 OR SW2 anzeigen 
@ - LED DS3 (Bit 10) das Ergebnis von SW1 EOR SW2 anzeigen 
@ - LED DS4 und 5 (Bit 11/12) das Ergebnis von SW1 ADD SW2 anzeigen 
@ - LED DS6 und 7 (Bit 13/14) das Ergebnis von SW1 SUB SW2 anzeigen 
@ und bei gedrueckter TASTE SW3 (Bit 5) soll die Funktion ein TRUE (Wert ungleich 0) ansonsten FALSE (Wert gleich 0) an das aufrufende Programm zurueck geben.
@ ACHTUNG die Tasten und auch die Leuchtdioden sind Low-Aktiv beschaltet.
	.file	"Funktionen.S" 
	.text 
	.align	2 
	.global	Operationen 
	.type	Operationen, %function 
Operationen: 

	@ r0 = &PDSR
	@ r1 = &CODR
	// bis hier ist Aufgabe 1. Man muss mit dem APCS die Registern fuer die Parameterns richtig waehlen 
	
	LDR	r2, [r0]		// r2 = *PDSR
	AND 	r3, r2, #0x38		// so only bit 3..5 are visible
	LSR 	r3, r3, #3		// bit0=SW1, bit1=SW2, bit2=SW3
	// Aufgabe 2, Wert von PDSR in r2 einsetzen. Adresse von PDSR wird in r0 uebergegeben
	
	MOV	r2, #0x01
	LSL	r2, r2, #8		// bit8 = 1
	ORR     r2, r2, #0x0400 	// DS3 (bit10)
    	ORR     r2, r2, #0x8000 	// DS8 (bit15)
	STR	r2, [r1]		// write to CODR, LED ON (low active) -> turning on DS1,3,8
	// Aufgabe 3
	
	
	LDR 	r2, [r0]		// r2 = *PDSR
	LSR 	r2, r2, #3		// shift 3 to right, just to make it more visible
	AND 	r2, r2, #0x03		// mask other bits to make bit 0 and 1 more visible
	
	AND 	r3, r2, #1      	// r3 = SW1
    	LSR 	r4, r2, #1
    	AND 	r4, r4, #1		// r4 = SW2
	
	MOV 	r5, #0			// LED Mask, just zeros. To save the bits from the operations and pass it to the LED
	
//AND
	AND	r6, r3, r4		// DS1
	TST	r6, #1			// check the result from the operation
	ORRNE	r5, r5, #0x100		// write the 1 to bit8, if the result is 1

//OR	
	ORR 	r6, r3, r4		// DS2
    	TST 	r6, #1
    	ORRNE 	r5, r5, #0x0200		// bit9

//XOR	
	EOR 	r6, r3, r4		// DS3
    	TST 	r6, #1
    	ORRNE 	r5, r5, #0x0400		// bit10

//ADDITION	
	ADD 	r6, r3, r4		// DS4,5
	TST 	r6, #1
	ORRNE 	r5, r5, #0x0800		// bit11
	TST 	r6, #2
	ORRNE 	r5, r5, #0x1000		// bit12
	
//SUBSTRACTION
	SUB	r6, r3, r4		// DS6,7
	AND	r6, r6, #3		// modulo 4
	TST 	r6, #1
	ORRNE	r5, r5, #0x2000		// bit13
	TST 	r6, #2
	ORRNE	r5, r5, #0x4000		// bit14
	
	
	MOV 	r6, #0xFF
    	LSL 	r6, r6, #8
    	STR 	r6, [r1, #-4]   	// all LEDs off
	
	STR 	r5, [r1]		// CODR -> LEDs on
	
	// Aufgabe 4			// 
	
	
	// return value depends on SW3 (bit5)
    	LDR     r2, [r0]          	// read PDSR again (or reuse earlier value)
    	TST     r2, #(1<<5)      	// SW3?

	// return value
    	MOVEQ   r0, #1            	// pressed (active-low) -> TRUE
    	MOVNE   r0, #0            	// not pressed -> FALSE
	// Aufgabe 5
	
// Beenden 
	BX 	lr // return to main program

 
.Lfe1: 
	.size	Operationen,.Lfe1- Operationen 
// End of File
