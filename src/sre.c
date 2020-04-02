/*

SIN Runtime Environment
Copyright 2020 Riley Lannon

This file contains the implementation of the SIN runtime environment.

*/

#include "sre.h"

void sinl_rte_index_out_of_bounds() {
    /*

    sinl_rte_index_out_of_bounds
    A routine to handle out-of-bounds errors

    This error will cause the program to exit and should be considered a crash

    */

    printf("Fatal runtime error: index value out of range\n");

    exit(SRE_RTE_OUT_OF_BOUNDS);
}
