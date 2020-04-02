/*

SIN Runtime Environment
Copyright 2020 Riley Lannon

Contains function definitions for the SIN runtime environment.

Some of the SRE is implemented in C because it would be a waste of time, and more error-prone, to do it in ASM.
Much of the assembly present in the runtime environment and standard library is simply to serve as a wrapper to C functions

*/

#ifndef SRE_H
#define SRE_H

#include <stdio.h>

#include "runtime_error_codes.h"
#include "mam.h"

// Initialization functions; called on program startup

// SIN runtime errors
void sinl_rte_index_out_of_bounds();

#endif
