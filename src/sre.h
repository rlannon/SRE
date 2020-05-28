/*

SIN Runtime Environment
Copyright 2020 Riley Lannon

Contains function definitions for the SIN runtime environment.

Some of the SRE is implemented in C because it would be a waste of time, and more error-prone, to do it in ASM. Further, some aspects of the SRE, like the Memory Allocation Manager, are even implemented in C++ and use C wrapper functions to allow it to be used here.
Much of the assembly present in the runtime environment and standard library is simply to serve as a wrapper to C functions.

*/

#ifndef SRE_H
#define SRE_H

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

#include "runtime_error_codes.h"
#include "mam.h"

// If this file is being used by a C++ program, this is necessary
#ifdef __cplusplus
extern "C" {
#endif

// global variables required by the SRE
static struct mam *manager;

// MAM-related entry functions (call the C wrappers enumerated in mam.h)
uintptr_t sre_request_resource(size_t size);
bool sre_mam_contains(uintptr_t address);
unsigned int sre_get_rc(uintptr_t address);
void sre_add_ref(uintptr_t address);
void sre_free(uintptr_t address);

// Initialization and clean-up functions; called on program startup and exit
void sre_init();
void sre_clean();

// SIN runtime errors
void sinl_rte_index_out_of_bounds();

#ifdef __cplusplus
}
#endif

#endif
