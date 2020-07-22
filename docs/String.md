# SRE Documentation

## The String Module

The module `string.s` implements SIN's string functionality. Without it, string allocation, assignment, and concatenation would be impossible. Its functions follow the sincall convention as described [in the docs for the compiler](https://rlannon.github.com/SINx86/Calling%20Convention).

### String Memory Management

Since strings are automatically managed by the MAM, they will be automatically reallocated when necessary. This means that all references to the string can be invalidated whenever an assignment is made to the string. The MAM will determine whether a reallocation is necessary. A few rules to keep in mind:

* If the length of the string at the destination is equal greater than the length of the string to be copied in, a reallocation will never occur.
* If a string reallocation might be necessary, the following steps are taken:
  * The module calls the `mam_reallocate` function to request a reallocation; if the requested new size is equal to or less than the old size, nothing happens and the original pointer is returned.
  * If the new size is greater than the currently allocated size, memory is reallocated and a new node is created. This will invalidate all existing references to the object.

### Subroutines

The following subroutines are required in the `string` module:

#### `sinl_string_alloc`

Allocates a new string. Note that all allocated string will require 5 additional bytes of memory in addition to the actual string data:

* 4 bytes (one SIN `int &unsigned`) for the length
* 1 null byte at the end; all SIN strings are null-terminated to allow compatibility with C libraries

#### `sinl_string_copy`

Copies a string from the addres in `rsi` to the address in `rdi`. This function will automatically reallocate the destination string if necessary. This function returns a pointer to the destination string in case a reallocation occurs.

Note that this function follows the [SINCALL](https://rlannon.github.io/SINx86/Calling%20Convention) convention.

#### `sinl_string_concat`

Concatenates two strings (address of the left side in `rsi`, and of the right side in `rdi`) and returns a pointer to the result in `rax`. This function dynamically allocates a string so that the concatenated string can be returned by value, and this resource will be freed appropriately after it is used.

#### `sinl_string_append`

Similar to the concatenation subroutine, except that it appends a single character located in `dil` to the string in `rsi`. The address is returned in `rax`.
