; SIN Runtime Environment
; asm_include.s
; Copyright 2020 Riley Lannon

; A list of SRE dependencies
; This is to be included in the SIN compiler source file to allow the compiled
;   program access to the SRE. The SRE should then be statically linked with
;   the assembled file to produce the executable.

%ifndef ASM_INCLUDE
    %define ASM_INCLUDE
        ; string routines
        extern sinl_string_alloc
        extern sinl_str_copy
        extern sinl_str_concat

        ; array routines
        extern sinl_dynamic_array_alloc
        extern sinl_array_copy

        ; data
        extern manager
        extern sinl_str_buffer

        ; SRE functions

        ; SRE MAM interaction
        extern sre_request_resource
        extern sre_reallocate
        extern sre_mam_contains
        extern sre_get_rc
        extern sre_get_size
        extern sre_add_ref
        extern sre_free

        ; SRE init/cleanup
        extern sre_init
        extern sre_clean
%endif
