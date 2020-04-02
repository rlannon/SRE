/*

SIN Runtime Environment
Copyright 2020 Riley Lannon

Memory Allocation Manager (MAM)

The MAM plays a crucial role in the SRE

*/

#ifndef MAM_H
#define MAM_H

#include <stdbool.h>

// Define the MAM struct
typedef struct mam {
    // contains a hash table (more like a _set_) to store the addresses of memory obtained with malloc
};

// Initialization and clean-up routines
void init_mam(mam *m);
void clean_mam(mam *m);

// Utility functions
bool mam_contains(mam *m, unsigned int key);

#endif
