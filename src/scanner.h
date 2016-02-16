//
// Source line scanner
//
// Copyright (c) 2016 Tom Nisbet
// Licensed under the MIT license
//
//
// Instruction set for the 8085 processor.

#ifndef SCANNER_H
#define SCANNER_H

#include <stdint.h>

class Scanner
{
public:
    enum
    {
        T_ERROR,
        T_EOF,
        T_LABEL,
        T_IDENTIFIER,
        T_CONSTANT,
        T_STRING,
        T_COMMA,
        T_DOLLAR,
        T_OPEN_PAREN,
        T_CLOSE_PAREN,
        T_BIT_OR_OPER,
        T_BIT_AND_OPER,
        T_SUM_OPER,
        T_FACTOR_OPER
    };

    enum
    {
        V_OR,
        V_XOR,
        V_AND,
        V_PLUS,
        V_MINUS,
        V_MULTIPLY,
        V_DIVIDE,
        V_MOD
    };

    int Init(const char * ln);
    int Next();
    char PeekChar();
    int GetLength();
    int GetType() { return tokenType; }
    int GetValue() { return tokenValue; }
    const char * GetString() { return tokenStr; }
    const uint8_t * GetBuffer() { return (uint8_t *) tokenStr; }
    const char * GetErrorMsg() { return errorMsg; }

private:
    enum 
    {
        BUFFER_SIZE = 256
    };

    int     tokenType;              // Token type.
    int     tokenValue;             // Value of constant or subtype.
    int     tokenLen;               // Used when tokenStr has binary string data.
    char    line[BUFFER_SIZE];      // Source line to parse.
    char    errorMsg[BUFFER_SIZE];  // Error message.
    char    tokenStr[BUFFER_SIZE];  // Identifier, constant, or binary string data.
    char *  pCursor;                // Next position in line to be parsed.

    int ScanIdentifier();
    int ScanConstant();
    int ScanString();
    void SkipWhite();
    int Failure(const char * pMsg, const char * pParam = NULL);
    unsigned char HexDigit(unsigned char c);
};

#endif

