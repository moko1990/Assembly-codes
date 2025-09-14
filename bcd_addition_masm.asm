data segment
    
    data1_asc   db  '1234567892'
    data2_asc   db  '1234567891'
    data1_bcd   db  5   dup(?)
    data2_bcd   db  5   dup(?)
    result_bcd  db  6   dup(?)
    result_asc  db  12  dup(?)
    data    ends

stack segment
    
    db  128 dup(?)
    stack   ends

code segment
    
    main    proc    far
        
        assume  cs:code, ds:data, ss:stack
        mov     ax, data
        mov     ds, ax
        mov     bx, offset data1_asc
        mov     di, offset data1_bcd
        mov     cx, 10
        call    conv_bcd
        mov     bx, offset data2_asc
        mov     di, offset data2_bcd
        mov     cx, 10
        call    conv_bcd
        call    result_add_bcd
        mov     si, offset result_bcd
        mov     di, offset result_asc
        mov     cx, 5
        call    conv_asc
        mov dx, offset result_asc
        mov ah, 09h
        int 21h

        mov     ah, 4ch
        int     21h
        
    main endp
    
    conv_bcd    proc
        
    again:
        mov     ax, [bx]
        xchg    ah, al
        and     ax, 0f0fh
        push    cx
        mov     cl, 4
        shl     ah, cl
        or      al, ah
        mov     [di], al
        add     bx, 2
        inc     di
        pop     cx
        loop    again
        ret     
    conv_bcd endp
    
    result_add_bcd  proc
        
        mov     bx, offset data1_bcd
        mov     di, offset data2_bcd
        mov     si, offset result_bcd
        mov     cx, 5
        clc
    back:
        mov     al, [bx]
        add     al, [di]
        daa     
        mov     [si], al
        inc     bx
        inc     di
        inc     si
        loop    back
        ret
    result_add_bcd endp     
    
    conv_asc    proc
    
    again2:
        mov     al, [si]
        mov     ah, al
        and     ax, 0f00fh
        push    cx
        mov     cl, 4
        shr     ah, cl
        or      ax, 3030h
        xchg    ah,al
        mov     [di], ax
        inc     si
        add     bx, 2
        pop     cx
        loop     again2
        mov byte ptr [di],'$'
        ret
    conv_asc endp
    code ends
end main
        
        
        
        

