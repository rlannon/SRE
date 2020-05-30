; SIN Runtime Environment
; array.s
; Copyright 2020 Riley Lannon

; The SIN array module
; Contains the necessary functions to implement array functionality to SIN

; Macros for constants
%define base_array_width 4

; External functions and data
extern _sre_request_resource
extern _sre_reallocate
extern _sre_get_size

sinl_dynamic_array_alloc:
    ; Allocates an array in dynamic memory
    ; Parameters:
    ;   int &unsigned width     -   The width of the contained type
    ;   int &unsigned length    -   The number of elements to be allocated
    ;
    ; This will allocate at least 16 bytes for the array, else 1.5x the initial length
    ;

    mov rax, rsi
    mul rdi
    add rax, base_array_width
    mov rdi, rax
    
    ; multiply by 1.5
    mov rcx, 2
    div rcx
    add rdi, rax

    cmp rdi, 0x10
    jge .allocate
    
    mov rdi, 0x10
.allocate:
    call _sre_request_resource
    ret

sinl_array_copy:
    ; Copies an array from one location to another
    ; Parameters:
    ;   ptr<array> src  -   The source array
    ;   pre<array> dest -   The destination
    ;
    ; Note that unlike a string copy, this function will not reallocate the destination array; instead, it will copy as many elements as it can from src to dest
    ; It will copy all of the *bytes* from the source into the destination, even if those bytes are not all filled with actual elements
    ;

    ; first, compare the lengths of the allocated memory
    push rsi
    push rdi

    ; call the sre_get_size function
    mov rdi, rsi
    call _sre_get_size

    ; the size is in RAX
    pop rdi
    push rax
    call _sre_get_size
    
    ; compare the sizes
    pop rcx
    cmp rax, rcx    ; compare destination to source
                    ; if the source can fit in the destination, proceed to copy
    jge .copy

    ; else, we need to get the number of bytes we *can* fit, which is in RAX
    mov rcx, rax
.copy:
    ; copy all of the bytes we can into the destination from the source
    pop rdi
    pop rsi
    cld
    rep movsb

    xor eax, eax    ; the routine should return void
    ret
