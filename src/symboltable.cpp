//
// Symbol Table
//
// Copyright (c) 2016 Tom Nisbet
// Licensed under the MIT license
//
#include <stdio.h>
#include <string.h>
#include "symboltable.h"

// Entries are added in the first pass and updated in the second.  Symbols
// that are RW can be aded more than once; the subsequent adds update the value.
int SymbolTable::Add(const char * name, unsigned val, bool rw) {
    if (numEntries >= MAX_ENTRIES) {
        return RET_TABLE_FULL;
    }

    for (int ix = 0; (ix < numEntries); ix++) {
        if (strcasecmp(entries[ix].name, name) == 0) {
            if (entries[ix].rw) {
                entries[ix].val = val;
                return RET_OK;
            }
            else {
                // This read-only symbol has already been added.
                return RET_DUPLICATE;
            }
        }
    }

    entries[numEntries].name = strdup(name);
    entries[numEntries].val = val;
    entries[numEntries].rw = rw;
    entries[numEntries].updated = false;
    ++numEntries;

    return RET_OK;
}


int SymbolTable::Update(const char * name, unsigned val) {
    for (int ix = 0; (ix < numEntries); ix++) {
        if (strcasecmp(entries[ix].name, name) == 0) {
            if (entries[ix].rw || !entries[ix].updated) {
                entries[ix].val = val;
                entries[ix].updated = true;
                return RET_OK;
            }
            else {
                // This read-only symbol cannot be updated twice.
                return RET_DUPLICATE;
            }
        }
    }

    // This should never happen because the symbol should have been added in
    // the first pass.
    return RET_NOT_FOUND;
}


unsigned SymbolTable::Lookup(const char * name) {
    for (int ix = 0; (ix < numEntries); ix++) {
        if (strcasecmp(entries[ix].name, name) == 0) {
            return entries[ix].val;
        }
    }

    return NO_ENTRY;
}


void SymbolTable::Dump(FILE * pFile) {
    for (int ix = 0; (ix < numEntries); ix++) {
        fprintf(pFile, "%-16s: %04x (%d)\n", entries[ix].name, entries[ix].val, entries[ix].val);
    }
}
