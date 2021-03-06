; SIN Runtime Environment
; array.s
; Copyright 2020 Riley Lannon

; The SIN array module
; Contains the necessary functions to implement array functionality to SIN

; Macros for constants
%define base_array_width 4

%include "asm_macros.s"

; External functions and data
extern %[SRE_REQUEST_RESOURCE]

global sinl_dynamic_array_alloc
sinl_dynamic_array_alloc:
    ; Allocates an array in dynamic memory
    ; Parameters:
    ;   RSI: int &unsigned width    -   The width of the contained type
    ;   RDI: int &unsigned length   -   The number of elements to be allocated
    ;
    ; This will allocate at least 16 bytes for the array, else 1.5x the initial length
    ;

    mov rax, rsi
    mul rdi
    add rax, base_array_width
    mov rdi, rax
    
    ; multiply by 1.5
    mov rdx, 0
    mov rcx, 2
    div rcx
    add rdi, rax

    cmp rdi, 0x10
    jge .allocate
    
    mov rdi, 0x10
.allocate:
    mov si, 0

    ; ensure stack alignment before calling a C function
    mov rax, rsp
    and rsp, -0x10
    push rax
    sub rsp, 8
    call %[SRE_REQUEST_RESOURCE]
    add rsp, 8
    pop rsp

    ret

global sinl_array_copy
sinl_array_copy:
    ; Copies an array from one location to another
    ; Parameters:
    ;   ptr<array> src  -   The source array
    ;   pre<array> dest -   The destination
    ;   int &unsigned width -   The width of the contained type
    ;
    ; Note that unlike a string copy, this function will not reallocate the destination array;
    ;   instead, it will copy as many elements as it can from src to dest
    ; It will copy all of the *bytes* from the source into the destination, 
    ;   even if those bytes are not all filled with actual elements
    ;

    ; compare the lengths of the arrays
    ; since the arrays might not be dynamic, we should use the length dword and the width parameter (rcx)
    mov eax, [rsi]
    mov ebx, [rdi]

    ; if the source array as equal to or fewer elements than the destination, we can copy the data
    cmp eax, ebx
    jle .copy
    
    ; otherwise, move the number of elements we *can* copy into eax
    mov eax, ebx
.copy:
    ; multiply the number of elements (eax) by the width of those elements (ecx)
    ; afterwards, move the result into ECX to get the number of bytes
    mul ecx
    mov ecx, eax

    ; increment the pointers to skip the length word
    add rsi, 4
    add rdi, 4
    cld
    rep movsb

    xor eax, eax    ; the routine should return void
    ret
