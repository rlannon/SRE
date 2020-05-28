/*

SIN Runtime Environment
Copyright 2020 Riley Lannon

Memory Allocation Manager (MAM)

The MAM plays a crucial role in the SRE, particularly in memory safety. Specifically, it implements the allocation and release of dynamic memory from the operating system.
The MAM contains a hashmap with the address of the resource paired with the associated information (the address, the size, and the reference count).
This is implemented as a C++ class (for ease of development), but includes a number of C wrapper functions.
In order for this file to be included in both the C and C++ files, the preprocessor is used.

*/

#ifndef MAM_H
#define MAM_H

#include "runtime_error_codes.h"

#ifdef __cplusplus

    #include <unordered_map>
    #include <iostream>
    #include <exception>
    #include <cstdint>

    class mam {
        class node {
            uintptr_t address;
            unsigned int size;
            unsigned int rc;
        public:
            void add_ref();
            void remove_ref();

            unsigned int get_size();
            unsigned int get_rc();

            node(uintptr_t address, size_t size);
            ~node();
        };

        std::unordered_map<uintptr_t, node> resources;

        void insert(uintptr_t address, size_t size);
    public:
        bool contains(uintptr_t key);
        node find(uintptr_t key);
        uintptr_t request_resource(size_t size);

        void add_ref(uintptr_t key);
        void free(uintptr_t key);

        mam();
        ~mam();
    };

    // C wrappers
    extern "C" mam* new_mam();
    extern "C" void delete_mam(mam *m);
    extern "C" bool mam_contains(mam *m, uintptr_t key);
    extern "C" uintptr_t mam_allocate(mam *m, size_t size);
    extern "C" void mam_add_ref(mam *m, uintptr_t address);
    extern "C" void mam_free(mam *m, uintptr_t address);

#else   /* C declarations */

    #include <stdint.h>
    #include <stdbool.h>

    struct mam* new_mam();
    void delete_mam(struct mam *m);
    bool mam_contains(struct mam *m, unsigned long key);
    uintptr_t mam_allocate(struct mam *m, size_t size);
    void mam_add_ref(struct mam *m, unsigned long address);
    void mam_free(struct mam *m, unsigned long address);

#endif

#endif  /* MAM_H */
