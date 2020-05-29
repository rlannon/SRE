/*

SIN Runtime Environment
Copyright 2020 Riley Lannon

This file contains the implementation of the SIN runtime environment.

*/

#include "sre.h"

void sre_init() {
    manager = new_mam();    // allocate the MAM
    sinl_str_buffer = (char*)sre_request_resource(134); // use the MAM to request a 128-character string buffer
}

void sre_clean() {
    delete_mam(manager);    // delete the MAM
    manager = NULL;
    sinl_str_buffer = NULL;
}

/*

Entry functions for the SRE Memory Allocation Manager

*/

uintptr_t sre_request_resource(size_t size) {
    // Requests memory from the MAM
    return mam_allocate(manager, size);
}

uintptr_t sre_reallocate(uintptr_t old_address, size_t new_size) {
    // Reallocates the specified resource with the new size
    return mam_reallocate(manager, old_address, new_size);
}

bool sre_mam_contains(uintptr_t address) {
    // Checks to see whether the MAM contains a resource beginning at the given address
    return mam_contains(manager, address);
}

unsigned int sre_get_rc(uintptr_t address) {
    // Returns the number of references to the given resource
    return mam_get_rc(manager, address);
}

size_t sre_get_size(uintptr_t address) {
    // Returns the size of the given resource (in bytes)
    return mam_get_size(manager, address);
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
