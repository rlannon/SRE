; SIN Runtime Environment
; asm_include.s
; Copyright 2020 Riley Lannon

; A list of SRE dependencies
; This is to be included in the SIN compiler source file to allow the compiled
;   program access to the SRE. The SRE should then be statically linked with
;   the assembled file to produce the executable.

%include "asm_macros.s"

%ifndef ASM_INCLUDE
    %define ASM_INCLUDE
        ; assembly string routines
        extern sinl_string_alloc
        extern sinl_string_copy
        extern sinl_string_concat
        extern sinl_string_append
	    extern sinl_string_copy_construct

        ; assembly array routines
        extern sinl_dynamic_array_alloc
        extern sinl_array_copy

        ; data
        extern %[MANAGER]

        ; SRE error functions
	    extern %[SINL_RTE_OUT_OF_BOUNDS]

        ; SRE MAM interaction
        extern %[SRE_REQUEST_RESOURCE]
        extern %[SRE_REALLOCATE]
        extern %[SRE_MAM_CONTAINS]
        extern %[SRE_GET_RC]
        extern %[SRE_GET_SIZE]
        extern %[SRE_ADD_REF]
        extern %[SRE_FREE]

        ; SRE init/cleanup
        extern %[SRE_INIT]
        extern %[SRE_CLEAN]
%endif
