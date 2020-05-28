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

#include <unordered_map>
#include <iostream>

#include "runtime_error_codes.h"

class mam {
    class node {
        unsigned long address;
        unsigned int rc;
        bool freed;
    public:
        void add_ref();
        void remove_ref();
        unsigned int get_rc();

        node(unsigned long address);
        ~node();
    };

    std::unordered_map<unsigned long, node> resources;
public:
    bool contains(unsigned long key);
    void insert(unsigned long address);

    void add_ref(unsigned long key);
    void free(unsigned long key);

    mam();
    ~mam();
};

// C wrappers
extern "C" mam* new_mam();
extern "C" void delete_mam(mam *m);
extern "C" bool mam_contains(mam *m, unsigned long key);
extern "C" void mam_insert(mam *m, unsigned long address);
extern "C" void mam_add_ref(mam *m, unsigned long address);
extern "C" void mam_free(mam *m, unsigned long address);

#endif
