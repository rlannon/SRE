; SIN Runtime Environment
; string.s
; Copyright 2020 Riley Lannon

; The SIN string module. Contains various functions to add string functionality to the language

; Declare our external routines
extern sre_reallocate

sinl_string_alloc:
    ; allocates a new string and returns its address
    ; note that strings take up 5 bytes more than the number of characters:
    ;   * 4 bytes for the length
    ;   * 1 null byte at the end
    ret

sinl_str_copy:
    ; copies a string from one location to another
    ; parameters:
    ;   ptr<string> src     -   the source string
    ;   ptr<string> dest    -   the destination string
    ; returns:
    ;   ptr<string>     -   The address of the destination string
    ;
    ; According to the SIN calling convention, 'src' will be in RSI and 'dest' will be in RDI
    ; 
    ; Note that the destination string *must* be returned by this function in case the string needs to be reallocated
    ; This prevents the reference to the string (variable on the stack, for example) from being invalidated

    ; compare the lengths; see if we need to reallocate the destination string
    mov eax, [rsi]
    mov ebx, [rdi]
    cmp eax, ebx
    jg .reallocate

; if we need to reallocate the string, this will execute
.reallocate:
    ; todo: check to see if we need to reallocate here? the MAM will do it upon request for reallocation...
    ; note the *actual* size of the allocated block for the string is in the MAM
    ; if the MAM actually has enough memory for the new string, the request for reallocation will do nothing

    ; get the new size -- should be size of the source string * 1.5 for safety
    mov eax, [rsi]
    mov ebx, 2
    div ebx   ; in 64-bit mode, the div instruction's default size is 32 bits
    add eax, [rsi]
    add eax, 5  ; add the extra string bytes

    ; reallocate the destination string -- use the SRE
    ;   pass old address in RDI
    ;   pass new size in RSI
    mov r12, rsi    ; first, preserve pointer values in registers
    mov r13, rdi    ; r12-r15 are considered "owned" by the caller and must be restored if used by the callee

    ; pass addesses
    mov rdi, [rdi]
    mov esi, eax
    call sre_reallocate

    ; restore pointer values
    mov rsi, r12
    mov rdi, r13

    ; the new destination address is in RAX; copy it into RDI
    mov rdi, rax
; the actual copy routine
.copy:
    mov rax, rdi    ; ensure the address of the destination string is preserved in RAX
    cld ; ensure the direction flag is clear (so 'rep' increments the pointers)
    mov ecx, [rsi]
    add ecx, 1  ; make sure the null byte is copied
    movsd   ; copy the length information
    add rsi, 4
    add rsi, 4  ; add the width of the string length information (4 bytes) to the pointers

    rep movsb   ; perform the copy

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
