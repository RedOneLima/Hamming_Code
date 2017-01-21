MAX_LEN		EQU	100
_		EQU	0x0A

	AREA	HCODE, CODE
	ENTRY
;-------------------------------------------------------------------------
;			Register Allocation
;-------------------------------------------------------------------------
;		Kyle Hewitt 	CS2400	Homework 6
;
;
;R0: I/0				R1: Offset for HCODE 
;R2: Offset for SRC_WORD		R3: Check bit counter
;R4: Current bit being checked		R5: Flag for marking a parity error
;R6: 					R7: 
;R8: 					R9: 
;R10: 					R11: Parity Counter
;R12: Pointer for HCODE			R13: Pointer for SRC_WORD
;-------------------------------------------------------------------------
;			Begin Main Routine
;-------------------------------------------------------------------------

Main
;-------------------------------------------------------------------------
;			Initialization
;-------------------------------------------------------------------------
	LDR R12, =H_CODE-1
	LDR R13, =SRC_WORD-1
	MOV R1, #1
	MOV R2, #1
	MOV R3, #1
	MOV R5, #0
	MOV R11,#0
;-------------------------------------------------------------------------
;		   Getting Check Bit Parities
;-------------------------------------------------------------------------

ChkBits
	LDRB R4, [R12,R1]		;loading the next bit from H_CODE
	CMP R4, #0			;check for null term
	BEQ DoneChk
	CMP R4,#'1'			;only '1' counts towards parities
	EOREQ R11, R1, R11		;keeps track of even and odd counts for each check bit parity
	ADD R1,R1,#1			;increment offset
	B ChkBits			;loop

;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
	
DoneChk
	CMP R11, #0			;if R11 == 0 there was no parity error
	BEQ NoError
	MOV R5, #1			;Sets flag that there is a parity error
	LDRB R4, [R12, R11]		;loads the bit contained at the parity error location
	CMP R4, #'0'				
	MOVEQ R4,#'1'			;if bit is '0' change to '1'
	MOVNE R4,#'0'			;if but is '1' change to '0'
	STRB R4, [R12,R11]		;store the inverted bit back into the H_CODE

;-------------------------------------------------------------------------
;-------------------------------------------------------------------------

NoError
	MOV R1, #1			;reinitalize H_CODE offset

FillSRC	
	LDRB R4,[R12,R1]		;load bit from H_CODE
	CMP R4, #0			;check for null terminator
	BEQ SRCDone			
	CMP R1, R3			;check to see if current bit is a check bit
	BEQ SkipCBit	
	STRB R4,[R13,R2]		;if data bit, store into SRC_WORD
	ADD R1, R1, #1			;increase H_CODE offset
	ADD R2, R2, #1			;increase SRC_WORD offset
	B FillSRC

SkipCBit
	ADD R1, R1, #1			;increase H_CODE offset
	MOV R3,R3,LSL#1			;move pointer to the next check bit
	B FillSRC

;-------------------------------------------------------------------------
;-------------------------------------------------------------------------

DisError
	LDR R0,=DisplayEr		;if parity error flag is set DisplayEr is printed
	SWI 2
	B Finish

;-------------------------------------------------------------------------
;-------------------------------------------------------------------------

SRCDone
	MOV R4, #0			;placing null terminator at end of SRC_WORD
	STRB R4,[R13,R2]	
	LDR R0,=H_CODE			;display H_CODE
	SWI 2
	CMP R5,#1			;Check parity error flag
	BEQ DisError
	LDR R0,=NoErrorDis		;displayed if no parity error
	SWI 2

;-------------------------------------------------------------------------
;-------------------------------------------------------------------------

Finish
	LDR R0,=SRC_WORD		;display SRC_WORD
	SWI 2

	SWI 0x11
;-------------------------------------------------------------------------
;			  End of Main
;-------------------------------------------------------------------------

	AREA	Data, DATA


SRC_WORD	% 	MAX_LEN
H_CODE		DCB	"010001100101", 0 
DisplayEr	DCB	_,_,"There was a parity error",_,_,0
NoErrorDis	DCB	_,_,"There was no parity error",_,_,0	


	END


