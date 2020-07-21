/*

SIN Runtime Environment
Copyright 2020 Riley Lannon
mam.cpp

The implementation of the memory allocation manager and all of the C wrapper functions

*/

#include "mam.h"

// mam::node functions
bool mam::node::fixed() const {
    return this->_fixed;
}

void mam::node::add_ref() {
    this->rc += 1;
}

void mam::node::remove_ref() {
    if (this->rc != 0) {
        this->rc -= 1;
    }
}

uintptr_t mam::node::get_address() {
    return this->address;
}

size_t mam::node::get_size() {
    return this->size;
}

uint32_t mam::node::get_rc() {
    return this->rc;
}

mam::node::node(uintptr_t address, size_t size, bool fixed) {
    this->address = address;
    this->size = size;
    this->rc = 1;   // For a node to be created, it must be referenced
    this->_fixed = fixed;   // if it's fixed, it can't be freed unless overridden
}

mam::node::~node() {
}

// mam functions
bool mam::contains(uintptr_t key) {
    // check to see whether the MAM contains a resource at the specified address
    return (bool)this->resources.count(key);
}

mam::node& mam::find(uintptr_t key) {
    std::unordered_map<uintptr_t, node>::iterator it = this->resources.find(key);
    if (it == this->resources.end()) {
        sre_mam_undefined_resource_error();
    }

    return it->second;
}

uintptr_t mam::request_resource(size_t size, bool fixed) {
    /*

    request_resource

    Requests 'size' bytes from the OS, returning the address
    This automatically adds the resource to the table

    We can also request 'fixed' resources, meaning their RC cannot be decremented (meant to exist for the lifetime of the program)
    
    */

    uintptr_t address = 0;
    void* ptr = malloc(size);

    // make sure we got a valid address
    if (ptr == NULL) {
        std::cout << "Fatal: could not allocate resource" << std::endl;
        exit(SRE_MAM_BAD_ALLOC);
    } else {
        address = reinterpret_cast<uintptr_t>(ptr);
        this->insert(address, size, fixed);
    }

    return address;
}

uintptr_t mam::reallocate_resource(uintptr_t r, size_t new_size) {
    /*

    reallocate_resource

    Reallocates the resource at 'r' with the size 'new_size'.
    Note that if the new size is smaller than the old size, it may not actually perform a reallocation (to save memory fragmentation caused by continuous reallocations).
    However, if the size is significantly smaller, the resource may be shrunk.

    All of the data from the old location, if a reallocation occurs, is copied to the new location.

    Note that if more than once reference to the resource exists, a reallocation will result in dangling pointers. The MAM keeps track of *how many* references to the resource exist, not *where* those resources are located.

    */

    uintptr_t new_address = 0;

    if (this->contains(r)) {
        node& old_resource = this->find(r);

        if (old_resource.get_size() >= new_size) {
            new_address = r;
        } else {
            // get the new address
            new_address = this->request_resource(new_size, old_resource.fixed());

            // perform a memcpy from old to new
            memcpy((void*)new_address, (void*)old_resource.get_address(), old_resource.get_size());

            // decrease the RC of the old resource, forcing it to free if it's fixed
            this->free_resource(old_resource.get_address(), old_resource.fixed());
        }
    }
    else {
        sre_mam_undefined_resource_error();
    }

    return new_address;
}

void mam::insert(uintptr_t address, size_t size, bool fixed) {
    /*

    insert

    Add the resource at 'address' to the table
    
    */

    if (this->resources.count(address)) {
        // todo: throw exception if resource already exists? update RC? try again?
    } else {
        try {
            this->resources.insert(
                std::make_pair<>(
                    address,
                    node(address, size, fixed)
                )
            );
        } catch (std::exception& e) {
            std::cout << "Fatal: An error occurred when adding a resource to the MAM table" << std::endl;
            exit(SRE_MAM_OPERATION_ERROR);
        }
    }
}

void mam::add_ref(uintptr_t key) {
    // increment the RC of the resource by one
    auto it = this->resources.find(key);
    if (it == this->resources.end()) {
        // if we couldn't find the resource, just return
        // sre_mam_undefined_resource_error();
        return;
    } else if (!it->second.fixed()) {   // we also can't add references to fixed resources
        node &n = it->second;
        if (n.get_rc() + 1 == 0) {
            std::cout << "Fatal: Maximum number of references reached" << std::endl;
            exit(SRE_MAM_REFERENCE_LIMIT);
        } else {
            n.add_ref();
        }
    }
}

void mam::free_resource(uintptr_t key, bool force_free) {
    // decrease RC of the resource by one, freeing the memory and erasing the entry if the RC hits 0
    std::unordered_map<uintptr_t, node>::iterator it = this->resources.find(key);
    if (it == this->resources.end()) {
        // if the resource could not be found, the manager should ignore it
	    printf("Resource not found\n");
        return;
    } else if (!it->second.fixed() || force_free) { // we can only free if it's not a fixed resource OR we are forcing a free
        node *n = &it->second;
        n->remove_ref();
        if (n->get_rc() == 0) {
            // free the allocated memory
            void* ptr = (void*)it->first;
            free(ptr);

            // erase the entry from the MAM
            n = nullptr;
            it = this->resources.end();
            this->resources.erase(key);
        }
    }
}

// Constructor, destructor
mam::mam() {

}

mam::~mam() {
    // free all dynamically-allocated memory
    for (
        auto it = this->resources.begin();
        it != this->resources.end();
        it++
    ) {
            void *p = (void*)(it->second.get_address());
            free(p);
    }
}

// C wrappers
mam* new_mam() {
    mam *addr;
    try {
        addr = new mam;
    } catch (std::bad_alloc& e) {
        std::cout << "Fatal: Could not initialize memory allocation manager." << std::endl;
        exit(SRE_MAM_INIT_ERROR);
    }

    return addr;
}

void delete_mam(mam *m) {
    delete m;
    m = nullptr;
}

bool mam_contains(mam *m, uintptr_t key) {
    return m->contains(key);
}

uintptr_t mam_allocate(mam *m, size_t size, bool fixed) {
    return m->request_resource(size, fixed);
}

uintptr_t mam_reallocate(mam *m, uintptr_t old_address, size_t new_size) {
    return m->reallocate_resource(old_address, new_size);
}

uint32_t mam_get_rc(mam *m, uintptr_t address) {
    return m->find(address).get_rc();
}

size_t mam_get_size(mam *m, uintptr_t address) {
    return m->find(address).get_size();
}

void mam_add_ref(mam *m, uintptr_t address) {
    m->add_ref(address);
}

void mam_free(mam *m, uintptr_t address) {
    m->free_resource(address);
}

// Common functions

void sre_mam_undefined_resource_error() {
    printf("Fatal: could not locate resource (perhaps a reference was invalidated?)\n");
    exit(SRE_MAM_UNDEFINED_RESOURCE_ERROR);
}
