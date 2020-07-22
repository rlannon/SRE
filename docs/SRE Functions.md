# SRE Documentation

## General SRE Functions and Data

While the SRE is divided into a series of modules, there are a few general functions that do not fit into one particular module. Most of these functions are related to SRE maintenance, and are only called in initialization, etc.. The purpose of this document is to outline these functions.

The SRE also contains some data that must be accessed by SIN programs and the SRE itself. Such data is declared in `sre.h` and will be discussed here.

## Data

### `static struct mam * manager`

The [MAM](Memory%20Allocation%20Manager.md) object which is allocated and freed by the runtime.

## Functions

### Initialization and clean-up

#### `sre_init()`

The entry point for SRE initialization. This function performs the following functions (delegating to each module as necessary):

* Initializes the MAM and saves its address to `manager`

#### `sre_clean()`

The entry point for SRE clean-up. Deletes dynamically-allocated memory and assigns `NULL` to accessible pointers.

### Errors

Some of the functions declared in `sre.h` serve error-handling purposes that do not belong in other modules.

#### `sinl_rte_out_of_bounds()`

Executes the out of bounds error routine, printing a message and exiting with the appropriate code.
