; SIN Runtime Environment
; memory.s
; Copyright 2020 Riley Lannon

; This file implements the SIN memory module, giving the language the ability to manage memory
; Note these functions are sincall wrappers to C functions, though they could be implemented differently if desired

sinl_alloc:
    ; allocate dynamic memory through the C malloc function
    ; parameters:
    ;   unsigned int len 
    ; returns:
    ;   ptr< T > - address of the allocated memory; 'null' if there was a failure
    ;   int - the number of bytes allocated
    ;

    ret

sinl_free:
    ; free dynamic memory through the C free function
    ; parameters:
    ;   ptr< T > addr
    ; returns:
    ;   bool - 0 if failure, 1 if success
    ;

    ret

sinl_realloc:
    ; reallocate dynamic memory
    ; parameters:
    ;   ptr< T > addr
    ;   int len
    ; returns:
    ;   ptr< T > - address of the allocated memory; 'null' if there was a failure
    ;   int - the new length
    ;
    ; note the address of the memory may or may not change, depending on
    ;   a) whether we are increasing or decreasing the size of the block
    ;   b) how much memory is available after the block
    ;

    ret
