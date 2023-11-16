# asm85
Intel 8085 Assembler with expressions and directives

This is an assembler for Intel 8080 and 8085 processors.  It produces an Intel Hex format object file as output.  A separate list file is also created that contains all of the assembled data and opcodes as well as a symbol table.  One or more binary image files can also be created.

Important features of this assembler include expression evaluation for constants and string initialization for data.  It supports the following directives: ORG, EQU, DB, DW, DS, and END.  It does not support macros.

This is a two-pass assembler.  The first pass creates the symbol table and the second produces the output files.

## Usage
Syntax is:

    asm85 [-b ssss:eeee [-b ssss:eeee ...]] [-g aaaa] <file.asm>

The -b option creates one or more binary image files.  The ssss and eeee arguments are hexadecimal start and end addresses, respectively.  These arguments MUST be 4 hex digits, using leading zeroes if the address is less that 1000 hex.

the -g option adds a Start Segment Address record to the output hex file.  This contains the execution (go) address for the program.  Some loaders may use this to start execution when the download is complete.

If the file test.asm is specified as the input, new files test.lst and test.hex will be created for the listing and hex records.

If one or more -b options is specified, the output files (in the above example) would be named test-ssss.bin for each address range specified.  Bytes not present in the assembly source will be initialized to FF in the binary image files.

### Examples
    asm85 test02.asm
creates test02.lst and test02.hex.


    asm85 -b 7eff:7fff -b f000:ffff prog.asm
creates:
* The assembler listing in prog.lst
* The hex records in prog.hex
* A 512 byte binary image file prog-7eff.bin
* A 4096 byte binary image file prog-f000.bin
