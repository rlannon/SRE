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
        extern _manager
        extern _sinl_str_buffer

        ; SRE functions

        ; SRE MAM interaction
        extern _sre_request_resource
        extern _sre_reallocate
        extern _sre_mam_contains
        extern _sre_get_rc
        extern _sre_get_size
        extern _sre_add_ref
        extern _sre_free

        ; SRE init/cleanup
        extern _sre_init
        extern _sre_free
%endif
