; SIN Runtime Environment
; string.s
; Copyright 2020 Riley Lannon

; The SIN string module. Contains various functions to add string functionality to the language

sinl_str_cpy:
    ; copies a string from one location to another
    ; parameters:
    ;   ptr<string> src     -   the source string
    ;   ptr<string> dest    -   the destination string
    ; returns:
    ;   bool    -   0 if failure, 1 if success
    ;

    ret

sinl_str_concat:
    ; concatenates two strings, returning a pointer to the end result
    ; parameters:
    ;   ptr<string> left    -   the left-hand string
    ;   ptr<string> right   -   the right-hand string
    ; returns:
    ;   ptr<string> -   a pointer to the resultant string (usually just the data buffer)
    ;
    
    ret
