; asm_macros.s
; Macros to ensure we use the _ prefix on macOS (macho64 format) but not on linux (elf64)

%ifndef ASM_C_MACROS
%define ASM_C_MACROS
    %ifidn __OUTPUT_FORMAT__, elf64
        %define MANAGER manager

        ; SRE functions
        %define SRE_REQUEST_RESOURCE sre_request_resource
        %define SRE_REALLOCATE sre_reallocate
        %define SRE_MAM_CONTAINS sre_mam_contains
        %define SRE_GET_RC sre_get_rc
        %define SRE_GET_SIZE sre_get_size
        %define SRE_ADD_REF sre_add_ref
        %define SRE_FREE sre_free

        ; Runtime errors
        %define SINL_RTE_OUT_OF_BOUNDS sinl_rte_index_out_of_bounds

        ; SRE init/cleanup
        %define SRE_INIT sre_init
        %define SRE_CLEAN sre_clean
        %define SIN_MAIN main
    %elifidn __OUTPUT_FORMAT__, macho64
        %define MANAGER _manager

        ; SRE functions
        %define SRE_REQUEST_RESOURCE _sre_request_resource
        %define SRE_REALLOCATE _sre_reallocate
        %define SRE_MAM_CONTAINS _sre_mam_contains
        %define SRE_GET_RC _sre_get_rc
        %define SRE_GET_SIZE _sre_get_size
        %define SRE_ADD_REF _sre_add_ref
        %define SRE_FREE _sre_free

        ; Runtime errors
        %define SINL_RTE_OUT_OF_BOUNDS _sinl_rte_index_out_of_bounds

        ; SRE init/cleanup
        %define SRE_INIT _sre_init
        %define SRE_CLEAN _sre_clean
        %define SIN_MAIN _main
    %endif
%endif
