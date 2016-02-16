//
// Symbol Table
//
// Copyright (c) 2016 Tom Nisbet
// Licensed under the MIT license
//
#include <stdio.h>
#include <string.h>
#include "SymbolTable.h"


int SymbolTable::Add(const char * name, unsigned val)
{
    if (numEntries >= MAX_ENTRIES)
    {
        return RET_TABLE_FULL;
    }

    for (int ix = 0; (ix < numEntries); ix++)
    {
        if (strcasecmp(entries[ix].name, name) == 0)
        {
            // This symbol has already been added.
            return RET_DUPLICATE;
        }
    }

    entries[numEntries].name = strdup(name);
    entries[numEntries].val = val;
    ++numEntries;

    return RET_OK;
}


int SymbolTable::Update(const char * name, unsigned val)
{
    for (int ix = 0; (ix < numEntries); ix++)
    {
        if (strcasecmp(entries[ix].name, name) == 0)
        {
            entries[ix].val = val;
            return RET_OK;
        }
    }

    return RET_NOT_FOUND;
}


unsigned SymbolTable::Lookup(const char * name)
{
    for (int ix = 0; (ix < numEntries); ix++)
    {
        if (strcasecmp(entries[ix].name, name) == 0)
        {
            return entries[ix].val;
        }
    }

    return NO_ENTRY;
}


void SymbolTable::Dump(FILE * pFile)
{
    for (int ix = 0; (ix < numEntries); ix++)
    {
        fprintf(pFile, "%-16s: %04x (%d)\n", entries[ix].name, entries[ix].val, entries[ix].val);
    }
}


