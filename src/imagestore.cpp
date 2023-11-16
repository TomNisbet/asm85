// A table to store the instruction and data bytes from the assembly process.
// Includes a method to write the entire store to an Intel Hex file.
//
// Copyright (c) 2016 Tom Nisbet
// Licensed under the MIT license
//
#include "imagestore.h"

#include <string.h>
#include <stdlib.h>

ImageStore::ImageStore(unsigned entries)
{
    numEntries = 0;
    maxEntries = entries;
    pStore = new ImageStoreEntry[entries + 1];
}

void ImageStore::Store(unsigned addr, uint8_t val)
{
    if (numEntries < maxEntries)
    {
        pStore[numEntries].addr = addr;
        pStore[numEntries].value = val;

        // Set the address of the last entry so that it is not addr+1.
        // WriteHex needs this to detect that a sequential block is complete.
        pStore[++numEntries].addr = addr;
    }
}


void ImageStore::Store(unsigned addr, const uint8_t * values, unsigned numValues)
{
    for (unsigned ix = 0; (ix < numValues); ix++)
    {
        Store(addr + ix, values[ix]);
    }
}


void ImageStore::WriteHexFile(FILE * f, const char * goAddr)
{
    uint16_t lineAddr;
    uint8_t lineBytes = 0;
    uint8_t checksum;
    char hexData[80];
    char * p = hexData;
    const char hex[] = "0123456789ABCDEF";
    const unsigned LINE_LIMIT = 32; // 16 also common in Intel Hex format.

    for (unsigned ix = 0; (ix < numEntries); ix++)
    {
        uint8_t val = pStore[ix].value;
        if (lineBytes == 0)
        {
            lineAddr = pStore[ix].addr;
            checksum = 0;
            p = hexData;
        }
        *p++ = hex[(val >> 4) & 0x0f];
        *p++ = hex[(val     ) & 0x0f];
        checksum += val;

        // If the next address is the start of a new block, or if this line
        // already has 16 characters, then write a Data record.
        if ((++lineBytes >= LINE_LIMIT) || (pStore[ix+1].addr != (pStore[ix].addr + 1)))
        {
            *p = '\0';
            checksum += lineBytes;
            checksum += ((lineAddr >> 8) & 0xff);
            checksum += ((lineAddr     ) & 0xff);

            checksum = (~checksum) + 1;
            fprintf(f, ":%02X%04X00%s%02X\n", lineBytes, lineAddr, hexData, checksum);

            // Start a new line.
            lineBytes = 0;
        }
    }

    // Add a Start Segment Address record with the Go address as the IP field
    if (goAddr) {
        unsigned addr = unsigned(strtol(goAddr, 0, 16));
        checksum = ~(4 + 3 + ((addr >> 8) &0xff) + (addr & 0xff)) + 1;
        fprintf(f, ":040000030000%04X%02X\n", addr, checksum);
    }

    // Add an End of File record
    fprintf(f, ":00000001FF\n");
}


void ImageStore::WriteBinFile(FILE * f, uint16_t startAddr, uint16_t endAddr)
{
    uint8_t mem[65536];

    memset(mem, 0xff, sizeof(mem));
    for (unsigned ix = 0; (ix < numEntries); ix++)
    {
        mem[pStore[ix].addr] = pStore[ix].value;
    }

    size_t writeSize = endAddr - startAddr + 1;
    fwrite(mem + startAddr, 1, writeSize, f);
}


