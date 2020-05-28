/*

SIN Runtime Environment
Copyright 2020 Riley Lannon

This file contains the implementation of the SIN runtime environment.

*/

#include "sre.h"

void sre_init() {
    // todo: initialize the SRE
    manager = new_mam();    // allocate the MAM
}

void sre_clean() {
    delete_mam(manager);    // delete the MAM
    // todo: additional clean-up
}

/*

Entry functions for the SRE Memory Allocation Manager

*/

uintptr_t sre_request_resource(size_t size) {
    // Requests memory from the MAM
    return mam_allocate(manager, size);
}

bool sre_mam_contains(uintptr_t address) {
    // Checks to see whether the MAM contains a resource beginning at the given address
    return mam_contains(manager, address);
}

void sre_add_ref(uintptr_t address) {
    // Adds a reference to the resource at 'address'
    mam_add_ref(manager, address);
}

void sre_free(uintptr_t address) {
    // Frees the resource at 'address' (or, more accurately, decrements the RC)
    mam_free(manager, address);
}

/*

SRE error handlers

*/

void sinl_rte_index_out_of_bounds() {
    /*

    sinl_rte_index_out_of_bounds
    A routine to handle out-of-bounds errors

    This error will cause the program to exit and should be considered a crash

    */

    printf("Fatal runtime error: index value out of range\n");
    exit(SRE_RTE_OUT_OF_BOUNDS);
}
