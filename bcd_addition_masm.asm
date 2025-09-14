; =============================================================================
; Program: BCD Adder
; Description: Reads two 10-digit numbers from the user, validates them,
;              adds them using packed BCD arithmetic, and displays the result.
; Assembler: MASM/TASM
; Environment: DOS (Emu8086, DOSBox, etc.)
; =============================================================================

data segment
    ; --- User prompts and messages ---
    prompt1     db  'Enter the first 10-digit number : $'
    prompt2     db  'Enter the second 10-digit number: $'
    error_msg   db  0Dh, 0Ah, 'Invalid input. Please enter exactly 10 digits (0-9).$'
    result_msg  db  0Dh, 0Ah, 'The sum is                      : $'
    newline     db  0Dh, 0Ah, '$'
    
    ; --- Buffers for numbers ---
    ; Buffer to read user input from DOS.
    ; First byte: max length. Second byte: actual length read by DOS.
    input_buffer    label   byte
    max_len         db      11          ; Max 10 chars + 1 for Enter key
    actual_len      db      ?
    input_data      db      11 dup(?)
    
    ; Storage for the two input numbers (ASCII format)
    data1_asc   db  10 dup(?), '$'
    data2_asc   db  10 dup(?), '$'
    
    ; Storage for numbers in packed BCD format (10 digits = 5 bytes)
    data1_bcd   db  5   dup(?)
    data2_bcd   db  5   dup(?)
    
    ; Result can be up to 11 digits, so we need 6 bytes for BCD
    ; and 12 bytes for ASCII (11 digits + terminator).
    result_bcd  db  6   dup(?)
    result_asc  db  12  dup('$')

data    ends

stack segment
    dw  128 dup(?)
stack   ends

code segment
    
    main    proc    far
        ; --- Standard DOS program setup ---
        assume  cs:code, ds:data, ss:stack
        mov     ax, data
        mov     ds, ax

        ; --- Get first number from user ---
        mov     dx, offset prompt1
        mov     di, offset data1_asc
        call    get_validated_number

        ; --- Get second number from user ---
        mov     dx, offset prompt2
        mov     di, offset data2_asc
        call    get_validated_number

        ; --- Convert ASCII inputs to packed BCD ---
        mov     si, offset data1_asc    ; Source: ASCII string 1
        mov     di, offset data1_bcd    ; Destination: BCD buffer 1
        call    conv_to_bcd

        mov     si, offset data2_asc    ; Source: ASCII string 2
        mov     di, offset data2_bcd    ; Destination: BCD buffer 2
        call    conv_to_bcd

        ; --- Add the two BCD numbers ---
        call    add_bcd_numbers

        ; --- Convert BCD result back to an ASCII string for display ---
        mov     si, offset result_bcd
        mov     di, offset result_asc
        call    conv_to_asc

        ; --- Display the final result ---
        mov     dx, offset result_msg
        mov     ah, 09h
        int     21h
        
        mov     dx, offset result_asc
        mov     ah, 09h
        int     21h

        ; --- Terminate program ---
        mov     ah, 4ch
        int     21h
        
    main endp
    
; =============================================================================
; Procedure: get_validated_number
; Description: Displays a prompt, reads a line of text from the user,
;              validates it (must be 10 digits), and stores it.
; Input: DX = offset of prompt message, DI = offset of destination buffer.
; Output: The validated 10-character string is stored at [DI].
; =============================================================================
get_validated_number proc
read_loop:
    ; Display the prompt message
    mov     ah, 09h
    int     21h

    ; Read a line of input from the user using DOS func 0Ah
    mov     dx, offset input_buffer
    mov     ah, 0Ah
    int     21h
    
    ; Print a newline for better formatting
    mov     dx, offset newline
    mov     ah, 09h
    int     21h

    ; --- Validation ---
    ; Check if exactly 10 characters were entered
    cmp     actual_len, 10
    jne     invalid_input

    ; Check if all 10 characters are digits ('0' through '9')
    mov     si, offset input_data
    mov     cx, 10
validate_loop:
    mov     al, [si]
    cmp     al, '0'
    jb      invalid_input   ; If character is less than '0'
    cmp     al, '9'
    ja      invalid_input   ; If character is greater than '9'
    inc     si
    loop    validate_loop

    ; --- If input is valid, copy it to the destination buffer ---
    mov     si, offset input_data
    mov     cx, 10
copy_loop:
    mov     al, [si]
    mov     [di], al
    inc     si
    inc     di
    loop    copy_loop
    
    ret ; Success

invalid_input:
    mov     dx, offset error_msg
    mov     ah, 09h
    int     21h
    jmp     read_loop ; Ask the user to try again

get_validated_number endp

; =============================================================================
; Procedure: conv_to_bcd
; Description: Converts a 10-digit ASCII string to 5 bytes of packed BCD.
; Input: SI = offset of source ASCII string, DI = offset of dest BCD buffer.
; =============================================================================
conv_to_bcd    proc
    mov     cx, 5 ; We will process 5 pairs of digits
again:
    push    cx           ; <<-- FIX: Save the main loop counter

    ; Get two ASCII digits, e.g., '1' (31h) and '2' (32h)
    mov     ah, [si]     ; ah = '1'
    mov     al, [si+1]   ; al = '2'
    
    ; Convert from ASCII to numeric value by masking
    and     ax, 0F0Fh    ; ah = 01h, al = 02h
    
    ; Pack them into one byte. Move the high nibble to the left.
    mov     cl, 4
    shl     ah, cl       ; ah = 10h (CL is modified here)
    
    ; Combine them
    or      al, ah       ; al = 12h
    
    ; Store the packed BCD byte
    mov     [di], al
    
    ; Move pointers to the next pair
    add     si, 2
    inc     di
    
    pop     cx           ; <<-- FIX: Restore the main loop counter
    loop    again
    
    ret
conv_to_bcd endp
    
; =============================================================================
; Procedure: add_bcd_numbers
; Description: Adds two 5-byte packed BCD numbers.
; Input: data1_bcd and data2_bcd are used.
; Output: result_bcd contains the sum.
; =============================================================================
add_bcd_numbers  proc
    mov     si, offset data1_bcd
    mov     di, offset data2_bcd
    mov     bx, offset result_bcd
    mov     cx, 5   ; We are adding 5 bytes
    clc             ; Clear Carry Flag before starting addition

back:
    mov     al, [si]
    adc     al, [di]    ; Add with Carry - CRITICAL FIX
    daa                 ; Decimal Adjust after Addition
    mov     [bx], al
    inc     si
    inc     di
    inc     bx
    loop    back
    
    ; Handle the final carry, if any (for results > 10 digits)
    
    ret
add_bcd_numbers endp     
    
; =============================================================================
; Procedure: conv_to_asc
; Description: Converts a 6-byte packed BCD number to a displayable ASCII string.
; Input: SI = offset of source BCD buffer, DI = offset of dest ASCII string.
; =============================================================================
conv_to_asc    proc
    mov     cx, 5   ; Process 6 BCD bytes (up to 12 digits)
again2:
    push    cx
    mov     al, [si]    ; Get one packed BCD byte, e.g., 12h
    
    ; Isolate the high digit
    mov     ah, al      ; ah = 12h
    mov     cl, 4
    shr     ah, cl       ; ah = 01h (the high nibble)
    
    ; Isolate the low digit
    and     al, 0Fh     ; al = 02h (the low nibble)
    
    ; Convert both digits to ASCII
    or      ax, 3030h   ; ah = '1', al = '2'
    
    ; Store the two ASCII characters
    mov     [di], ah
    mov     [di+1], al
    
    ; Move pointers
    inc     si
    add     di, 2       ; Move destination pointer by 2 - CRITICAL FIX
    pop     cx
    loop    again2
    
    ret
conv_to_asc endp

code ends
end main
