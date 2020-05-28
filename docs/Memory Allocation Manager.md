# SRE Documentation

## Memory Allocation Manager

The Memory Allocation Manager (MAM) is at the center of the SRE; it is not only responsible for safely allocating and releasing memory (by abstracting away calls to `malloc()` and `free()`), but it also serves as a garbage collector. This increases memory safety by maintaining a reference counter for all dynamically-allocated memory and automatically removing such resources when they become inaccessible.

## Required Functions

Any SIN compiler should support any properly-implemented SRE distribution, and so the behavior of the necessary functions as well as the necessary data members are detailed here so that anyone may implement it.

### Functions

The following are all of the functions that must be accessible to the compiler. In this implementation, they are mostly wrappers to C++ class member functions.

#### `struct mam* new_mam()`

Creates a new MAM, returning a pointer to it. Used in `sre_init()`.

#### `void delete_mam(struct mam *m)`

Deletes the specified MAM. Used in `sre_clean()`.

#### `bool mam_contains(struct mam *m, uintptr_t key)`

Returns whether the MAM contains a resource at the given address.

#### `uintptr_t mam_allocate(struct mam *m, size_t size)`

Allocates an object of the specified size using `malloc()`, adding it to the table. The reference count always starts at 1, as it is not possible for an inaccessible object to be created. If memory cannot be allocated, it causes a fatal runtime error, exiting with code `0xE0`.

#### `unsigned int mam_get_rc(struct mam *m, uintptr_t address)`

Returns the reference count of the specified resource. If the resource does not exist, causes a fatal runtime error, exiting with code `0xEA`.

#### `unsigned int mam_get_size(struct mam *m, uintptr_t address)`

Gets the size (in bytes) of the specified resource. If the resource does not exist, causes a fatal runtime error, exiting with code `0xEA`.

#### `void mam_add_ref(struct mam *m, uintptr_t address)`

Adds a reference to the dynamic object. If the object cannot be located, exits with code `0xEA`. If the resource contains the maximum number of references before the count is incremented, causes a program crash, exiting with code `0xE5`.

#### `void mam_free(struct mam *m, uintptr_t address)`

Decrements the reference count of the specified resource by one. If the reference count hits 0, the resource is freed and its node is deleted from the MAM's hash table. Since the SIN keyword `free` is considered safe, if the specified object does not exist, this function will return with no effect.
