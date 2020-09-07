; SIN Runtime Environment
; string.s
; Copyright 2020 Riley Lannon

; The SIN string module
; Contains various functions to add string functionality to the language

; Macros to centralize constants/magic numbers
%define default_string_length    15
%define base_string_width 5

%include "asm_macros.s"

; Declare our external routines and data
extern %[SRE_REQUEST_RESOURCE]
extern %[SRE_REALLOCATE]

global sinl_string_alloc
sinl_string_alloc:
    ; allocates a new string and returns its address
    ; parameters:
    ;   ESI   -   An initial size for the string, if known, otherwise 0
    ;
    ; note that strings take up 5 bytes more than the number of characters:
    ;   * 4 bytes for the length
    ;   * 1 null byte at the end
    ; these values are in macros to allow this to be modified more easily

    cmp esi, default_string_length
    jl .default ; the amount we allocate should be at least the base string width
    jmp .known
.default:
    ; the default size
    mov edi, default_string_length
    add edi, base_string_width
    mov si, 0   ; it's not a fixed resource

    ; align the stack to 16 bytes before a call to a C function
    mov rax, rsp
    and rsp, -0x10
    push rax
    sub rsp, 8
    call %[SRE_REQUEST_RESOURCE]
    add rsp, 8
    pop rsp

    ; RAX now contains the address of the string (the return value)
    jmp .done
.known:
    ; a known initial length
    ; multiply by 1.5 to avoid reallocation if the length is adjusted
    push rsi    ; preserve RSI
    mov eax, esi
    mov edx, 0
    mov ecx, 2
    div ecx
    mov edi, eax    ; move the length into EDI and restore RSI
    pop rsi
    add edi, esi
    add edi, base_string_width
    mov esi, 0  ; it's not a fixed resource

    ; align the stack to 16 bytes
    mov rax, rsp
    and rsp, -0x10
    push rax
    sub rsp, 8
    call %[SRE_REQUEST_RESOURCE]
    add rsp, 8
    pop rsp
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
    ;   RSI     -   the source string
    ;   RDI     -   the destination string
    ; returns:
    ;   The address of the destination string
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

    ; first, align the stack to 16 bytes
    mov rax, rsp
    and rsp, -0x10
    push rax
    sub rsp, 8
    call %[SRE_REALLOCATE]
    add rsp, 8
    pop rsp

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
    ;   RSI     -   the left-hand string
    ;   RDI     -   the right-hand string
    ;   CL      -   whether the string can be concatenated directly (1) or requires a new string (0)
    ; returns:
    ;   A pointer to the resultant string (usually just the data buffer)
    ;

    ; Get the length of the resultant string
    mov eax, [rsi]
    add eax, [rdi]
    add eax, base_string_width

    ; Request a new resource from the MAM
    mov r12, rsi    ; preserve LHS in r12
    mov r13, rdi    ; preserve RHS in r13
    mov edi, eax    ; Length in EDI
    mov esi, 0      ; Not a fixed resource

    ; align the stack to a 16-byte boundary
    mov rax, rsp
    and rsp, -0x10
    push rax
    sub rsp, 8
    call %[SRE_REQUEST_RESOURCE]
    add rsp, 8
    pop rsp

    ; Resource address is in RAX; preserve it
    push rax
    
    ; Copy the first string in
    mov rdi, rax
    mov rsi, r12
    mov ecx, [rsi]
    add ecx, 4      ; ensure we copy in the length dword (but not the null byte)
    rep movsb

    ; Copy in the second string
    ; We need to add the lengths together and figure out the destination
    ; RSI and RDI have been incremented accordingly; we want to keep RDI
    mov r12, [rsp]
    mov eax, [r13]  ; get the length of the RHS string
    add [r12], eax  ; add it to the length in the destination
    mov rsi, r13    ; move the RHS into RSI
    mov ecx, [rsi]  ; get its length in ECX
    add ecx, 1      ; ensure we account for the null byte
    add rsi, 4      ; ensure we skip the length dword
    rep movsb

    ; Get the original address back and return
    pop rax
    ret

global sinl_string_append
sinl_string_append:
    ; appends a single character to a string
    ; this is like concatenation, and the string will be located on the buffer
    ; parameters:
    ;   RSI     -   The address of the string to which we are appending
    ;   DIL     -   The character to append
    ; returns:
    ;   RAX     -   a pointer to the string buffer
    ;

    ; preserve our registers; we need to allocate memory
    mov r12b, dil
    mov r13, rsi

    ; request the resource
    mov edi, [rsi]
    add edi, base_string_width + 1  ; account for the new character, width, null byte
    mov esi, 0  ; the resource is not fixed

    ; align to a 16-byte boundary before the call
    mov rax, rsp
    and rsp, -0x10
    push rax
    sub rsp, 8
    call %[SRE_REQUEST_RESOURCE]
    add rsp, 8
    pop rsp
    
    ; copy the string over
    mov rdi, rax
    mov rsi, r13
    mov ecx, [rsi]
    add ecx, 4
    rep movsb

    ; append the character and a null byte
    mov rsi, rax
    mov ebx, [rsi]
    inc dword [rsi]
    add rsi, rbx
    add rsi, 4
    mov [rsi], r12b
    inc rsi
    mov bl, 0
    mov [rsi], bl
    
    ret

global sinl_string_copy_construct
sinl_string_copy_construct:
    ; Constructs a new string with an initial value
    ; Equivalent to a C++ copy constructor
    ; Parameters are:
    ;   RSI -   The address of the initial string value
    ;   RDI -   The address where we are storing the reference
    ; This function returns no values, calling an SRE panic function if there was an error
    ;

    ; first, preserve RSI and RDI for later
    push rdi
    push rsi    ; push this second so we can pop it without popping RDI

    ; allocate a string
    mov esi, [rsi]
    push rbp
    mov rbp, rsp
    call sinl_string_alloc
    mov rsp, rbp
    pop rbp

    ; the address of the newly-allocated string is in RAX
    mov rdi, rax
    pop rsi
    push rbp
    mov rbp, rsp
    call sinl_string_copy
    mov rsp, rbp
    pop rbp

    ; the address of the string is in RAX
    ; store it in the address pointed to by our second parameter
    pop rdi
    mov [rdi], rax

    ; todo: error code? panic?

    ret
