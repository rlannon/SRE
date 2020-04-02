/*

set.h
A simple set to contain 64-bit unsigned integer key values
Copyright 2020 Riley Lannon

This is for use in the SIN Runtime Environment, with the Memory Allocation Manager, and so it is unlikely to see

*/

#ifndef SET_H
#define SET_H

#include <stdbool.h>

// nodes to be contained within the set
typedef struct node {
    unsigned long key;
    bool value;
};

// the set itself
typedef struct set {
    // todo: implement C set
};

// utility functions
unsigned int hash(unsigned int key);

// set functions
void insert(set *s, unsigned int key, bool value);
bool exists(set *s, unsigned int key);  // check whether the key is in the set
node* find(set *s, unsigned int key);    // get the node associated with the key
void erase(node *n);    // erase a given node

#endif
