/*

SIN Runtime Environment
Copyright 2020 Riley Lannon
mam.cpp

The implementation of the memory allocation manager and all of the C wrapper functions

*/

#include "mam.h"

// mam::node functions
void mam::node::add_ref() {
    this->rc += 1;
}

void mam::node::remove_ref() {
    if (this->rc != 0) {
        this->rc -= 1;
    }
}

unsigned int mam::node::get_size() {
    return this->size;
}

unsigned int mam::node::get_rc() {
    return this->rc;
}

mam::node::node(uintptr_t address, size_t size) {
    this->address = address;
    this->size = size;
    this->rc = 0;
}

mam::node::~node() {

}

// mam functions
bool mam::contains(uintptr_t key) {
    // check to see whether the MAM contains a resource at the specified address
    return (bool)this->resources.count(key);
}

uintptr_t mam::request_resource(size_t size) {
    // requests 'size' bytes from the OS, returning the address
    // this automatically adds the resource to the table
    uintptr_t address = 0;
    void* ptr = malloc(size);

    // make sure we got a valid address
    if (ptr == NULL) {
        std::cout << "Fatal: could not allocate resource" << std::endl;
        exit(SRE_MAM_BAD_ALLOC);
    } else {
        address = reinterpret_cast<uintptr_t>(ptr);
        this->insert(address, size);
    }

    return address;
}

void mam::insert(uintptr_t address, size_t size) {
    // add the resource at 'address' to the table
    // first, ensure a resource at the address doesn't already exist
    if (this->resources.count(address)) {
        // todo: throw exception if resource already exists? update RC? try again?
    } else {
        try {
            this->resources.insert(
                std::make_pair<>(
                    address,
                    node(address, size)
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
    std::unordered_map<uintptr_t, node>::iterator it = this->resources.find(key);
    if (it == this->resources.end()) {
        std::cout << "Fatal: Could not locate requested resource" << std::endl;
        exit(SRE_MAM_UNDEFINED_RESOURCE_ERROR);
    } else {
        node &n = it->second;
        if (n.get_rc() + 1 == 0) {
            std::cout << "Fatal: Maximum number of references reached" << std::endl;
            exit(SRE_MAM_REFERENCE_LIMIT);
        } else {
            n.add_ref();
        }
    }
}

void mam::free(uintptr_t key) {
    // decrease RC of the resource by one, erasing it if the RC hits 0
    std::unordered_map<uintptr_t, node>::iterator it = this->resources.find(key);
    if (it == this->resources.end()) {
        // if the resource could not be found, the manager should ignore it
        return;
    } else {
        node *n = &it->second;
        n->remove_ref();
        if (n->get_rc() == 0) {
            n = nullptr;
            it = this->resources.end();
            this->resources.erase(key);
        }
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

uintptr_t mam_allocate(mam *m, size_t size) {
    return m->request_resource(size);
}

void mam_add_ref(mam *m, uintptr_t address) {
    m->add_ref(address);
}

void mam_free(mam *m, uintptr_t address) {
    m->free(address);
}
