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

unsigned int mam::node::get_rc() {
    return this->rc;
}

mam::node::node(unsigned long address) {
    this->address = address;
    this->rc = 0;
    this->freed = false;
}

mam::node::~node() {

}

// mam functions
bool mam::contains(unsigned long key) {
    // todo: check containment
}

void mam::insert(unsigned long address) {
    // todo: insert
}

void mam::add_ref(unsigned long key) {
    // increment the RC of the resource by one
    std::unordered_map<unsigned long, node>::iterator it = this->resources.find(key);
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

void mam::free(unsigned long key) {
    // decrease RC of the resource by one, erasing it if the RC hits 0
    std::unordered_map<unsigned long, node>::iterator it = this->resources.find(key);
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

bool mam_contains(mam *m, unsigned long key) {
    return m->contains(key);
}

void mam_insert(mam *m, unsigned long address) {
    m->insert(address);
}

void mam_add_ref(mam *m, unsigned long address) {
    m->add_ref(address);
}

void mam_free(mam *m, unsigned long address) {
    m->free(address);
}
