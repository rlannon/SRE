/*

SIN Runtime Environment
Copyright 2020 Riley Lannon

Memory Allocation Manager (MAM)

The MAM plays a crucial role in the SRE, particularly in memory safety. Specifically, it implements the allocation and release of dynamic memory from the operating system.
The MAM contains a set with the addresses of all dynamic memory that has been allocated (all addresses returned by the C function malloc(), which is used to implement SIN's 'alloc dynamic'). This allows it to ensure the program never attempts to call free() on an address which was not returned by malloc().
Further, it handles all the interaction between the program and the OS, reducing the opportunities for unsafe memory management practices.

*/

#ifndef MAM_H
#define MAM_H

#include <stdbool.h>
#include "set.h"

// Define the MAM struct
typedef struct mam {
    // contains a hash table (more like a _set_) to store the addresses of memory obtained with malloc
    set *s;
};

// Initialization and clean-up routines
void init_mam(mam *m);
void clean_mam(mam *m);

// Utility functions
bool mam_contains(mam *m, unsigned int key);

#endif
