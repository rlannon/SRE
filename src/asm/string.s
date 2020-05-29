; SIN Runtime Environment
; string.s
; Copyright 2020 Riley Lannon

; The SIN string module. Contains various functions to add string functionality to the language

; Declare some macros
%define default_string_length    15
%define base_string_width 5

; Declare our external routines and data
extern _sre_request_resource
extern _sre_reallocate
extern _sinl_str_buffer

sinl_string_alloc:
    ; allocates a new string and returns its address
    ; parameters:
    ;   unsigned int size   -   An initial size for the string, if known, otherwise 0
    ;
    ; note that strings take up 5 bytes more than the number of characters:
    ;   * 4 bytes for the length
    ;   * 1 null byte at the end
    ; these values are in macros to allow this to be modified more easily

    cmp rax, 0
    je .known
    cmp rax, base_string_width
    jl .default ; the amount we allocate should be at least the base string width
    jmp .known
.default:
    ; the default size
    mov edi, default_string_length
    add edi, base_string_width
    call _sre_request_resource
    ; RAX now contains the address of the string (the return value)
    jmp .done
.known:
    ; a known initial length
    ; multiply by 1.5 to avoid reallocation if the length is adjusted
    mov edi, esi
    mov ecx, 2
    div edi, ecx
    add edi, esi
    add edi, base_string_width
    call _sre_request_resource
.done:
    mov [rax], 0    ; move 0 into the string length, as it is empty
    mov rbx, rax
    add rbx, 4
    mov [rbx], 0    ; move a null byte into the first byte of the string
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
    add eax, base_string_width  ; add the extra string bytes

    ; reallocate the destination string -- use the SRE
    ;   pass old address in RDI
    ;   pass new size in RSI
    mov r12, rsi    ; first, preserve pointer values in registers
    mov r13, rdi    ; r12-r15 are considered "owned" by the caller and must be restored if used by the callee

    ; pass addesses
    mov rdi, [rdi]
    mov esi, eax
    call _sre_reallocate

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

    ; todo: handle string concatenations where the first pointer is to the string buffer

    ; Calculate length of the resultant string
    mov eax, [rsi]
    add eax, [rdi]
    add eax, 4  ; add one for the null byte, 4 for the length
    push rax    ; preserve the length
    
    ; Request a reallocation -- does nothing if a reallocation is not needed
    mov r12, rsi
    mov r13, rdi    ; preserve RSI and RDI

    mov rdi, _sinl_str_buffer ; move the address of the buffer in
    mov esi, eax
    call _sre_reallocate

    ; assign the string buffer pointer
    mov [_sinl_str_buffer], rax

    pop rcx ; restore the length

    ; Perform the concatenation
    cld ; clear the direction flag (just in case)
    mov rbx, [_sinl_str_buffer]
    mov [rbx], ecx ; move the combined length in
    add rbx, 4  ; RBX contains a pointer to the first 

    ; Copy the first string in
    mov rsi, r12    ; restore the first string address
    mov ecx, [rsi]  ; get the length of the first string
    add rsi, 4  ; skip the length
    mov rdi, rbx
    rep movsb

    ; And now the second string
    mov rsi, r13    ; restore the source of the right-hand string
    mov ecx, [rsi]  ; get the length of the second string
    add rsi, 4  ; skip the length of the source string
    mov rdi, rbx    ; get the destination operand
    add rdi, rcx    ; skip the left-hand string data
    rep movsb

    ; now, append a null byte
    mov rbx, [_sinl_str_buffer]
    mov ecx, [rbx]
    add ecx, 4  ; ensure we skip the length
    mov al, 0
    mov [rbx + rcx], al

    ; return the address of the buffer
    mov rax, [_sinl_str_buffer]
    ret
