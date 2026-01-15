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

// CODR : Clear Output Data Register	// clear the output if the bit is 1, the output is forced to be 0
// SODR : Set Output Data Register	// set the output if the bit is 1, the output is forced to be 1

// ACHTUNG ! : alle Taste und LEDs sind low active!

// Aufgabe 1 : falls in Funktion steht nichts dann kann func Operationen von c nicht aufgerufen werden (crash) // mind. bx lr

	PUSH	{r4-r6, lr}		// secure not scratch register

// Aufgabe 2
	LDR	r2, [r0]		// r2 = value from address r0 (PDSR)
	MVN	r2, r2			// the buttons and LEDs are low active
	
// Aufgabe 3
// just skip this, this code is not the part of the task
//	STR	r0, [r1]		// pass it as the value from Address r1 (CODR), to turn all LEDs on
	
// pass SW1 from bit3 of PDSR in r3
	AND	r3, r2, #(1 << 3) 	// 0001 shifted 3 to left // bit3 and 1
	LSR	r3, r3, #3		// shift 3 to right
	
// pass SW2 from bit4 of PDSR in r4
	AND	r4, r2, #(1 << 4)
	LSR	r4, r4, #4

// register to save the result of each operations
	MOV	r5, #0
	
//AND @DS1 bit8
	AND	r6, r3, r4
	LSL	r6, r6, #8
	ORR	r5, r5, r6
	
//OR @DS2 bit9
	ORR	r6, r3, r4
	LSL	r6, r6, #9
	ORR	r5, r5, r6
	
//EOR @DS3 bit10
	EOR	r6, r3, r4
	LSL	r6, r6, #10
	ORR	r5, r5, r6
	
//ADDITION @DS4 bit11, @DS5 bit12
	ADD	r6, r3, r4
	LSL	r6, r6, #11
	ORR	r5, r5, r6
	
//SUBSTRAKTION @DS6 bit13, @DS7 bit14
	SUB	r6, r3, r4
	AND	r6, r6, #3 		// get bit0 and 1, mask the rest
	LSL	R6, R6, #13
	ORR	r5, r5, r6
	
// turn on the LEDs (Aufgabe 3)
	MOV	r6, #0xFF00		// einsen von bit 8 bis 15
	STR	r6, [r1, #-4]		// einfach zur Sicherheit falls return 0 (siehe c source), SODR = CODR - 4, alle LEDs aus
	 
	STR	r5, [r1]		// pass the value of the result to CODR
	
// return value
// depends on SW3 (bit5 of PDSR)
	TST	r2, #(1 << 5)
	
	MOVEQ	r0, #0			// return true if 1
	MOVNE	r0, #1			// else false
					// why inverted? => low active


//Beenden

	POP {r4-r6, pc}			// this command is already a return, so no need to do bx lr
	
//	BX lr				// makes no sense // this code won't be reached after pop


 
.Lfe1: 
	.size	Operationen,.Lfe1- Operationen 
// End of File
