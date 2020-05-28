; SIN Runtime Environment
; string.s
; Copyright 2020 Riley Lannon

; The SIN string module. Contains various functions to add string functionality to the language

; Declare our external routines
extern sre_reallocate

sinl_string_alloc:
    ; allocates a new string and returns its address
    ret

sinl_str_copy:
    ; copies a string from one location to another
    ; parameters:
    ;   ptr<string> src     -   the source string
    ;   ptr<string> dest    -   the destination string
    ; returns:
    ;   bool    -   0 if failure, 1 if success
    ;
    ; According to the SIN calling convention, 'src' will be in RSI and 'dest' will be in RDI

    ; compare the lengths; see if we need to reallocate the destination string
    mov eax, [rsi]
    mov ebx, [rdi]
    cmp eax, ebx
    jg .copy

    ; todo: check to see if we need to reallocate here? the MAM will do it upon request for reallocation...
    ; if the MAM actually has enough memory, the request for reallocation will ultimately do nothing

    ; get the new size -- should be size of the source string * 1.5 for safety
    mov eax, [rsi]
    mov ebx, 2
    div ebx   ; in 64-bit mode, the div instruction's default size is 32 bits
    add eax, [rsi]

    ; reallocate the destination string -- use the SRE
    ;   pass old address in RDI
    ;   pass new size in RSI
    mov r12, rsi    ; first, preserve pointer values in registers -- r12 - r15 are "owned" by the caller
    mov r13, rdi

    ; pass addesses
    mov rdi, [rdi]
    mov esi, eax
    call sre_reallocate

    ; restore pointer values
    mov rsi, r12
    mov rdi, r13
.copy:
    cld ; ensure the direction flag is clear (so 'rep' increments the pointers)
    mov ecx, [rsi]
    movsd   ; copy the length information
    add rsi, 4
    add rsi, 4  ; add the width of the string length information (4 bytes) to the pointers
.loop:
    rep movsb

    ; done
    ret

sinl_str_concat:
    ; concatenates two strings, returning a pointer to the end result
    ; parameters:
    ;   ptr<string> left    -   the left-hand string
    ;   ptr<string> right   -   the right-hand string
    ; returns:
    ;   ptr<string> -   a pointer to the resultant string (usually just the data buffer)
    ;
    
    ret
