# asm85
Intel 8085 Assembler

This is an assembler for Intel 8080 and 8085 processors.  It produces Intel Hex format object files as output.  A separate list file is also created that contains all of the assembled data and opcodes as well as a symbol table.

Important features of this assembler include expression evaluation for constants and string initialization for data.  It supports the following directives: ORG, EQU, DB, DW, DS, and END.  It does not support macros.

This is a two-pass assembler.  The first pass creates the symbol table and the second produces the output files.
