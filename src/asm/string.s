; SIN Runtime Environment
; string.s
; Copyright 2020 Riley Lannon

; The SIN string module
; Contains various functions to add string functionality to the language

; Macros to centralize constants/magic numbers
%define default_string_length    15
%define base_string_width 5

; Declare our external routines and data
extern sre_request_resource
extern sre_reallocate
extern sinl_str_buffer

global sinl_string_alloc
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
    call sre_request_resource
    ; RAX now contains the address of the string (the return value)
    jmp .done
.known:
    ; a known initial length
    ; multiply by 1.5 to avoid reallocation if the length is adjusted
    push rax    ; preserve RAX
    mov eax, esi
    mov edx, 0
    mov ecx, 2
    div ecx
    mov edi, eax    ; move the length into EDI and restore RAX
    pop rax
    add edi, esi
    add edi, base_string_width
    call sre_request_resource
.done:
    mov [rax], dword 0    ; move 0 into the string length, as it is empty
    mov rbx, rax
    add rbx, 4
    mov [rbx], byte 0    ; move a null byte into the first byte of the string
    ret

global sinl_string_copy
sinl_string_copy:
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
    jle .copy

; if we need to reallocate the string, this will execute
.reallocate:
    ; note the *actual* size of the allocated block for the string is in the MAM
    ; if the MAM actually has enough memory for the new string, the request for reallocation will do nothing

    ; get the new size -- should be size of the source string * 1.5 for safety
    mov eax, [rsi]
    mov edx, 0
    mov ebx, 2
    div ebx   ; in 64-bit mode, the div instruction's default size is 32 bits
    add eax, [rsi]
    add eax, base_string_width  ; add the extra string bytes

    ; reallocate the destination string -- use the SRE
    ;   pass old address in RDI
    ;   pass new size in RSI
    mov r12, rsi    ; first, preserve pointer values in registers
    mov r13, rdi    ; r12-r15 are considered "owned" by the caller and must be restored if used by the callee

    ; pass addresses -- the string to reallocate is already in rdi
    mov esi, eax
    call sre_reallocate

    ; restore pointer values
    mov rsi, r12

    ; the new destination address is in RAX; copy it into RDI
    mov rdi, rax
; the actual copy routine
.copy:
    mov rax, rdi    ; ensure the address of the destination string is preserved in RAX
    cld ; ensure the direction flag is clear (so 'rep' increments the pointers)
    movsd   ; copy the length information (rsi and rdi automatically incremented)
    
    mov ecx, [rax]
    add ecx, 1  ; make sure the null byte is copied

    rep movsb   ; perform the copy

    ; done
    ret

global sinl_string_concat
sinl_string_concat:
    ; concatenates two strings, returning a pointer to the end result
    ; parameters:
    ;   ptr<string> left    -   the left-hand string
    ;   ptr<string> right   -   the right-hand string
    ; returns:
    ;   ptr<string> -   a pointer to the resultant string (usually just the data buffer)
    ;

    ; Calculate length of the resultant string
    mov eax, [rsi]
    add eax, [rdi]
    push rax    ; preserve the length
    add eax, base_string_width  ; add the base width to determine actual memory footprint

    ; Request a reallocation -- does nothing if a reallocation is not needed
    mov r12, rsi
    mov r13, rdi    ; preserve RSI and RDI

    lea rbx, [rel sinl_str_buffer] ; move the address of the buffer in
    mov rdi, [rbx]
    mov esi, eax
    call sre_reallocate    ; returns the new address

    ; assign the string buffer pointer
    lea rbx, [rel sinl_str_buffer]
    mov [rbx], rax

    ; if the LHS is the string buffer, we can just adjust the string's length and copy the second string in
    ; note we don't need to worry about whether or not the buffer was reallocated, as a reallocation will automatically copy the old data into the new location
    cld ; clear the direction flag for 'rep' (just in case)
    pop rcx ; restore the total length
    lea rbx, [rel sinl_str_buffer] ; compare addresses
    cmp r12, [rbx]
    jne .full_copy

    ; adjust the length
    lea rbx, [rel sinl_str_buffer]
    mov rbx, [rbx]
    mov eax, [rbx]  ; get the length of the first string
    mov [rbx], ecx  ; adjust the string length
    ; add the length of the data dword and the first string to get the proper address
    add rbx, 4
    add rbx, rax
    ; now, copy the second string
    jmp .copy_second
.full_copy:
    ; Perform the full concatenation
    lea rbx, [rel sinl_str_buffer]
    mov rbx, [rbx]
    mov [rbx], ecx ; move the combined length in
    add rbx, 4  ; RBX contains a pointer to the first 

    ; Copy the first string in
    mov rsi, r12    ; restore the first string address
    mov ecx, [rsi]  ; get the length of the first string
    add rsi, 4  ; skip the length
    mov rdi, rbx
    rep movsb
.copy_second:
    ; And now the second string
    mov rsi, r13    ; restore the source of the right-hand string
    mov ecx, [rsi]  ; get the length of the second string
    add rsi, 4  ; skip the length of the source string
    mov rdi, rbx    ; get the destination operand
    add rdi, rcx    ; skip the left-hand string data
    rep movsb

    ; now, append a null byte
    lea rbx, [rel sinl_str_buffer]
    mov rbx, [rbx]
    mov ecx, [rbx]
    add ecx, 4  ; ensure we skip the length
    mov al, 0
    mov [rbx + rcx], al

    ; return the address of the buffer
    lea rax, [rel sinl_str_buffer]
    mov rax, [rax]
    ret
