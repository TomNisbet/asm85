// Image store for assembler opcodes and data.
//
// Copyright (c) 2016 Tom Nisbet
// Licensed under the MIT license
//
#ifndef IMAGESTORE_H
#define IMAGESTORE_H

#include <stdio.h>
#include <stdint.h>


class ImageStore
{
public:
    ImageStore(unsigned entries);
    unsigned GetNumEntries() { return numEntries; }
    void Store(unsigned addr, uint8_t val);
    void Store(unsigned addr, const uint8_t * values, unsigned numValues);
    void WriteHexFile(FILE * f);

private:
    class ImageStoreEntry
    {
      public:
        uint16_t    addr;
        uint8_t     value;
    };

    ImageStoreEntry *   pStore;
    unsigned            numEntries;
    unsigned            maxEntries;
};

#endif
