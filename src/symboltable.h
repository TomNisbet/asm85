//
// Symbol Table
//
// Copyright (c) 2016 Tom Nisbet
// Licensed under the MIT license
//
#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

class SymbolTableEntry {
public:
    char *      name;
    unsigned    val;
    bool        rw;
    bool        updated;
};


class SymbolTable {
public:
    enum {
        RET_OK,
        RET_DUPLICATE,
        RET_NOT_FOUND,
        RET_TABLE_FULL
    };
    enum {
        MAX_ENTRIES = 66000,    // Plenty for a 16 bit assembler.
        NO_ENTRY    = 0x10000   // Outside of 16 bit range used for val.
    };

    SymbolTable() { numEntries = 0; }
    int Add(const char * name, unsigned val, bool rw=false);
    int Update(const char * name, unsigned val);
    unsigned Lookup(const char * name);
    void Dump(FILE * pFile);

private:
    SymbolTableEntry    entries[MAX_ENTRIES];
    int                 numEntries;
};

#endif
