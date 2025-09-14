; BCD Addition Program for 16-bit x86 (MASM/TASM)
; Takes two 10-digit BCD numbers, adds them, and displays result
; Author: Learning Assembly
; Date: 2024

.MODEL SMALL
.STACK 100H

.DATA
    ; Messages for user interaction
    msg1        DB 'Enter first 10-digit BCD number: $'
    msg2        DB 'Enter second 10-digit BCD number: $'
    msg3        DB 'Result: $'
    msg4        DB 'Error: Invalid BCD input!$'
    newline     DB 13, 10, '$'
    
    ; BCD numbers storage (10 digits each)
    bcd1        DB 10 DUP(0)    ; First BCD number
    bcd2        DB 10 DUP(0)    ; Second BCD number
    result      DB 11 DUP(0)    ; Result (11 digits for carry)
    temp_buffer DB 12 DUP(0)    ; Temporary buffer for input/output
    
    ; Variables
    input_count DW 0
    carry_flag  DB 0

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display welcome message
    CALL DISPLAY_WELCOME
    
    ; Get first BCD number
    LEA DX, msg1
    MOV AH, 09H
    INT 21H
    
    CALL GET_BCD_INPUT
    CMP AL, 0
    JE ERROR_EXIT
    CALL STORE_BCD1
    
    ; Get second BCD number
    LEA DX, msg2
    MOV AH, 09H
    INT 21H
    
    CALL GET_BCD_INPUT
    CMP AL, 0
    JE ERROR_EXIT
    CALL STORE_BCD2
    
    ; Perform BCD addition
    CALL BCD_ADDITION
    
    ; Display result
    LEA DX, msg3
    MOV AH, 09H
    INT 21H
    
    CALL DISPLAY_RESULT
    
    ; Exit program
    JMP EXIT_PROGRAM
    
ERROR_EXIT:
    LEA DX, msg4
    MOV AH, 09H
    INT 21H
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
EXIT_PROGRAM:
    MOV AH, 4CH
    INT 21H

MAIN ENDP

; Display welcome message
DISPLAY_WELCOME PROC
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    RET
DISPLAY_WELCOME ENDP

; Get BCD input from user (10 digits)
GET_BCD_INPUT PROC
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV CX, 10          ; Counter for 10 digits
    MOV BX, 0           ; Character counter
    LEA DX, temp_buffer ; Buffer for input
    
INPUT_LOOP:
    MOV AH, 01H         ; Read character
    INT 21H
    
    ; Check if character is digit (0-9)
    CMP AL, '0'
    JB INVALID_INPUT
    CMP AL, '9'
    JA INVALID_INPUT
    
    ; Store character in buffer
    MOV [DX], AL
    INC DX
    INC BX
    
    LOOP INPUT_LOOP
    
    ; Null terminate
    MOV BYTE PTR [DX], 0
    
    ; Check if we got exactly 10 digits
    CMP BX, 10
    JNE INVALID_INPUT
    
    MOV AL, 1           ; Success
    JMP INPUT_DONE
    
INVALID_INPUT:
    MOV AL, 0           ; Error
    
INPUT_DONE:
    POP DX
    POP CX
    POP BX
    RET
GET_BCD_INPUT ENDP

; Store first BCD number
STORE_BCD1 PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA SI, temp_buffer
    LEA DI, bcd1
    MOV CX, 10
    
STORE_LOOP1:
    MOV AL, [SI]
    SUB AL, '0'         ; Convert ASCII to BCD
    MOV [DI], AL
    INC SI
    INC DI
    LOOP STORE_LOOP1
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
STORE_BCD1 ENDP

; Store second BCD number
STORE_BCD2 PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA SI, temp_buffer
    LEA DI, bcd2
    MOV CX, 10
    
STORE_LOOP2:
    MOV AL, [SI]
    SUB AL, '0'         ; Convert ASCII to BCD
    MOV [DI], AL
    INC SI
    INC DI
    LOOP STORE_LOOP2
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
STORE_BCD2 ENDP

; BCD Addition Algorithm
BCD_ADDITION PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    ; Initialize
    LEA SI, bcd1 + 9    ; Point to last digit of first number
    LEA DI, bcd2 + 9    ; Point to last digit of second number
    LEA BX, result + 10 ; Point to last position of result
    MOV CX, 10          ; Process 10 digits
    MOV DL, 0           ; Carry flag
    
ADD_LOOP:
    ; Load digits
    MOV AL, [SI]        ; First BCD digit
    ADD AL, [DI]        ; Add second BCD digit
    ADD AL, DL          ; Add carry
    
    ; Check for BCD overflow
    CMP AL, 9
    JBE NO_CORRECTION
    
    ; BCD correction needed
    SUB AL, 10
    MOV DL, 1           ; Set carry
    JMP STORE_DIGIT
    
NO_CORRECTION:
    MOV DL, 0           ; Clear carry
    
STORE_DIGIT:
    MOV [BX], AL        ; Store result digit
    
    ; Move to next digit (right to left)
    DEC SI
    DEC DI
    DEC BX
    LOOP ADD_LOOP
    
    ; Store final carry if any
    MOV [BX], DL
    
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
BCD_ADDITION ENDP

; Display result on console
DISPLAY_RESULT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA SI, result
    MOV CX, 11          ; Display 11 digits (including possible leading zero)
    MOV BX, 0           ; Flag for leading zeros
    
DISPLAY_LOOP:
    MOV AL, [SI]
    CMP AL, 0
    JNE PRINT_DIGIT
    
    ; Skip leading zeros
    CMP BX, 0
    JNE PRINT_DIGIT
    INC SI
    LOOP DISPLAY_LOOP
    JMP DISPLAY_DONE
    
PRINT_DIGIT:
    MOV BX, 1           ; Set flag - we've started printing
    ADD AL, '0'         ; Convert BCD to ASCII
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP DISPLAY_LOOP
    
DISPLAY_DONE:
    ; Print newline
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DISPLAY_RESULT ENDP

END MAIN
