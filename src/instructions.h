// Instruction set for the 8085 processor.
//
// Copyright (c) 2016 Tom Nisbet
// Licensed under the MIT license
//

#ifndef INSTRUCTIONS_H
#define INSTRUCTIONS_H

#include <stddef.h>


// The use of reg1, reg2, and argType isn't completely obvious.  Each instruction
// can have register args and/or an additional arg.  The additional arg is a
// value, specified using either a literal or a label.  If present, the
// additional arg always comes last and can be a byte or a word.
//   Examples:
//     nop              ; no args
//     pop h            ; one register
//     mov a, m         ; two registers
//     jmp AWAY         ; one WORD arg
//     lxi h, SAVE      ; one register, one WORD arg
//     mvi c, 23	; one register, one BYTE arg

enum
{
    EX_NONE = 0,
    EX_BYTE = 1,
    EX_WORD = 2
};

typedef struct
{
    const char *    mnemonic;   // Mnemonic name
    const char *    reg1;       // Register argument 1 name
    const char *    reg2;       // Register argument 2 name
    int             nRegs;      // Number of register args
    int             opcode;     // Opcode
    int             argType;    // Expression arg type
} InstructionEntry;


#endif
