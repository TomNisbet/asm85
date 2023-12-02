//
// Source line scanner
//
// Copyright (c) 2016 Tom Nisbet
// Licensed under the MIT license
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "scanner.h"


// Initialize the scanner with a new source line and do preliminary scan to see if a
// label is present in column 1.  After this call, the scanner is agnostic to the
// column where elements appear.
//
// Returns the type of the first element seen.
int Scanner::Init(const char * ln) {
    // Save the original line for future calls to Next().
    strncpy(line, ln, sizeof(line));
    line[sizeof(line) - 1] = '\0';
    pCursor = line;

    // If the first column is non-white then it is a label.
    if (isalpha(*pCursor) || (*pCursor == '_')) {
        if (ScanIdentifier() == T_ERROR) {
            // Overwrite the error message from ScanIdentifier to read 'label'
            // instead of 'identifier'.
            Failure("Illegal character in label.  Must be alphanum or underscore.");
        }
        else {
            if ((*pCursor == ':') || isspace(*pCursor)) {
                tokenType = T_LABEL;
                ++pCursor;
            }
            else {
                Failure("Label must end with ':' or space or tab character.");
            }
            tokenValue = 0;
        }
        return tokenType;
    }

    else if (!isspace(*pCursor) && (*pCursor != ';') && (*pCursor != '\0')) {
        return Failure("Illegal character in column 1.  Must be label, comment, or space. Found:", pCursor);
    }

    // No label and first character was space.  Return the first token.
    tokenType = T_IDENTIFIER;   // Arbitrary - set to non-ERROR and non-EOF.
    return Next();              // This will set tokenType.
}


int Scanner::Next() {
    // Just continue to return ERROR or EOF if in that state.
    if (tokenType == T_ERROR)  return T_ERROR;
    if (tokenType == T_EOF)    return T_EOF;

    SkipWhite();
    if ((isalpha(*pCursor)) || (*pCursor == '_')) {
        ScanIdentifier();
    }

    else if (isdigit(*pCursor)) {
        ScanConstant();
    }

    else if ((*pCursor == '"') || (*pCursor == '\'')) {
        ScanString();
    }

    else {
        bool twochar = false;
        tokenValue = 0;
        switch (*pCursor) {
        case ';':   tokenType = T_EOF;                                  break;
        case '\0':  tokenType = T_EOF;                                  break;
        case ',':   tokenType = T_COMMA;                                break;
        case '$':   tokenType = T_DOLLAR;                               break;
        case '(':   tokenType = T_OPEN_PAREN;                           break;
        case ')':   tokenType = T_CLOSE_PAREN;                          break;
        case '|':   tokenType = T_BIT_OR_OPER;  tokenValue = V_OR;      break;
        case '^':   tokenType = T_BIT_OR_OPER;  tokenValue = V_XOR;     break;
        case '&':   tokenType = T_BIT_AND_OPER; tokenValue = V_AND;     break;
        case '+':   tokenType = T_SUM_OPER;     tokenValue = V_PLUS;    break;
        case '-':   tokenType = T_SUM_OPER;     tokenValue = V_MINUS;   break;
        case '*':   tokenType = T_FACTOR_OPER;  tokenValue = V_MULTIPLY;break;
        case '/':   tokenType = T_FACTOR_OPER;  tokenValue = V_DIVIDE;  break;
        case '%':   tokenType = T_FACTOR_OPER;  tokenValue = V_MOD;     break;
        case '~':   tokenType = T_BIT_NOT_OPER; tokenValue = V_MOD;     break;
        case '=':   tokenType = T_RELATE_OPER;  tokenValue = V_EQ;      break;
        case '<':
            if (pCursor[1] == '<') {
                tokenType = T_FACTOR_OPER;  
                tokenValue = V_SHL;
                twochar = true;
            }
            break;
        case '>':
            if (pCursor[1] == '>') {
                tokenType = T_FACTOR_OPER;  
                tokenValue = V_SHR;
                twochar = true;
            }
            break;
        default:
            tokenType = T_ERROR;
            Failure("Illegal character", pCursor);
        }

        // Store the character as the string and skip to next character.
        tokenStr[0] = *pCursor++;
        if (twochar) {
            tokenStr[1] = *pCursor++;
            tokenStr[2] = '\0';
        } else {
            tokenStr[1] = '\0';
        }
    }

//    printf("Next: token=%2d  value=%04x (%5d)  str=%s\n",
//           tokenType, tokenValue, tokenValue, tokenStr);
    return tokenType;
}


char Scanner::PeekChar() {
    // Peek at the next non-white character.
    SkipWhite();
    return *pCursor;
}


int Scanner::GetLength() {
    // tokenLength is set for STRING types because they don't require a
    // terminating NULL and may contain NULLs within themselves.
    if (tokenType == T_STRING) {
        return tokenLen;
    }
    else {
        return strlen(tokenStr);
    }
}


// On entry, this expects that pCursor points to an identifier character.
int Scanner::ScanIdentifier() {
    // Copy the identifier into the token string.
    char * p = tokenStr;
    while ((isalnum(*pCursor) || (*pCursor == '_') || (*pCursor == '.') || (*pCursor == '$')) &&
           (p < (tokenStr + sizeof(tokenStr) - 1))) {
        *p++ = *pCursor++;
    }
    *p = '\0';

    // Check to see if the string is a reserved register name.
    tokenValue = V_NONE;
    char c0 = toupper(tokenStr[0]);
    char c1 = toupper(tokenStr[1]);
    char c2 = toupper(tokenStr[2]);
    if (((c1 == '\0') && (strchr("ABCDEHLM", c0) != NULL)) ||
        (strcasecmp(tokenStr, "SP") == 0) || (strcasecmp(tokenStr, "PSW") == 0)) {
        tokenType = T_REGISTER;
        return tokenType;
    }
    
    // Default to IDENTIFIER, but check for reserved operators
    tokenType = T_IDENTIFIER;
    // AND, EQ, GE, GT, HIGH, LE, LT, LOW, MOD, NE, NOT, OR, SHL, SHR, XOR
    switch (c0) {
        case 'A':
            if ((c1 == 'N') && (c2 == 'D') && (tokenStr[3] == '\0')) {
                tokenType = T_LOGIC_AND_OPER;
            }
            break;
        case 'E':
            if ((c1 == 'Q') && (c2 == '\0')) {
                tokenType = T_RELATE_OPER;
                tokenValue = V_EQ;
            }
            break;
        case 'G':
            if ((c1 == 'E') && (c2 == '\0')) {
                tokenType = T_RELATE_OPER;
                tokenValue = V_GE;
            } else if ((c1 == 'T') && (c2 == '\0')) {
                tokenType = T_RELATE_OPER;
                tokenValue = V_GT;
            }
            break;
        case 'H':
            if ((c1 == 'I') && (c2 == 'G') && (tokenStr[3] == 'H') && (tokenStr[4] == '\0')) {
                tokenType = T_ISOLATE_OPER;
                tokenValue = V_HIGH;
            }
            break;
        case 'L':
            if ((c1 == 'E') && (c2 == '\0')) {
                tokenType = T_RELATE_OPER;
                tokenValue = V_LE;
            } else if ((c1 == 'T') && (c2 == '\0')) {
                tokenType = T_RELATE_OPER;
                tokenValue = V_LT;
            } else  if ((c1 == 'O') && (c2 == 'W') && (tokenStr[3] == '\0')) {
                tokenType = T_ISOLATE_OPER;
                tokenValue = V_LOW;
            }
            break;
        case 'M':
            if ((c1 == 'O') && (c2 == 'D') && (tokenStr[3] == '\0')) {
                tokenType = T_FACTOR_OPER;
                tokenValue = V_MOD;
            }
            break;
        case 'N':
            if ((c1 == 'E') && (c2 == '\0')) {
                tokenType = T_RELATE_OPER;
                tokenValue = V_NE;
            } else if ((c1 == 'O') && (c2 == 'T') && (tokenStr[3] == '\0')) {
                tokenType = T_LOGIC_NOT_OPER;
            }
            break;
        case 'O':
            if ((c1 == 'R') && (c2 == '\0')) {
                tokenType = T_LOGIC_OR_OPER;
                tokenValue = V_OR;
            }
            break;
        case 'S':
            if ((c1 == 'H') && (c2 == 'L') && (tokenStr[3] == '\0')) {
                tokenType = T_FACTOR_OPER;
                tokenValue = V_SHL;
            } else if ((c1 == 'H') && (c2 == 'R') && (tokenStr[3] == '\0')) {
                tokenType = T_FACTOR_OPER;
                tokenValue = V_SHR;
            }
            break;
        case 'X':
            if ((c1 == 'O') && (c2 == 'R') && (tokenStr[3] == '\0')) {
                tokenType = T_LOGIC_OR_OPER;
                tokenValue = V_XOR;
            }
            break;
    }
    
    return tokenType;
}


// On entry, this expects that pCursor points to a numeric constant character.
int Scanner::ScanConstant() {
    int base = 10;

    // Copy the constant into the token string.  Note that isxdigit is also
    // catching the 'B' and 'D' suffixes for decimal and binary.
    char * p = tokenStr;
    while ((isxdigit(*pCursor) || (toupper(*pCursor) == 'H')) &&
           (p < (tokenStr + sizeof(tokenStr) - 1))) {
        *p++ = *pCursor++;
    }
    *p = '\0';

    // Check the last character of the string for a base identifier.
    char c = toupper(*--p);
    if (c == 'H') {
        base = 16;
    }
    else if (c == 'B') {
        base = 2;
    }
    else if ((c == 'D') || isdigit(c)) {
        // Decimal suffix is optional.
        base = 10;
    }
    else {
        // String ended with A, C, E, or F.  Probably hex with no suffix.
        return Failure("Bad numeric constant.  Hex constants must end with 'H'", tokenStr);
    }

    tokenType = T_CONSTANT;
    tokenValue = int(strtol(tokenStr, NULL, base));

    // Scan back thru the string and verify the characters all match the base.
    while (--p >= tokenStr) {
        if ((base == 10) && !isdigit(*p)) {
            return Failure("Illegal character in decimal constant", tokenStr);
        }
        else if ((base == 2) && (*p != '0') && (*p != '1')) {
            return Failure("Illegal character in binary constant", tokenStr);
        }
        else if (!isxdigit(*p)) {
            return Failure("Illegal character in hex constant", tokenStr);
        }
    }

    return tokenType;
}


// On entry, this expects that pCursor points to a quote character.
int Scanner::ScanString() {
    bool bEscape = false;
    unsigned char c;
    const char * pStr = pCursor;
    char quote = *pCursor++;

    tokenLen = 0;
    tokenType = T_STRING;
    tokenValue = 0;

    while (*pCursor != '\0') {
        if (bEscape) {
            if (*pCursor == 'n') {
                c = '\n';
            }
            else if (*pCursor == 'r') {
                c = '\r';
            }
            else if (*pCursor == 't') {
                c = '\t';
            }
            else if (*pCursor == '0') {
                c = '\0';
            }
            else if (*pCursor == 'x') {
                if (isxdigit(pCursor[1]) && isxdigit(pCursor[2])) {
                    c = (HexDigit(*++pCursor) << 4);
                    c |= HexDigit(*++pCursor);
                }
                else {
                    return Failure("Bad hex escape in string", pCursor);
                }
            }
            else {
                // Any other character following a '\' just returns itself.
                // This also covers the special cases of \", \', and \\ to
                // return quotes and \ within a string.
                c = *pCursor;
            }
            bEscape = false;
        }
        else if (*pCursor == '\\') {
            bEscape = true;
            ++pCursor;
            continue;
        }
        else if (*pCursor == quote) {
            break;
        }
        else {
            c = *pCursor;
        }
        tokenStr[tokenLen++] = (char) c;
        ++pCursor;
    }

    if (*pCursor != quote) {
        return Failure("Unterminated string", pStr);
    }

    // Skip the trailing quote.
    ++pCursor;

    return tokenType;
}


void Scanner::SkipWhite() {
    while ((*pCursor == ' ') || (*pCursor == '\t')) {
        ++pCursor;
    }
}


int Scanner::Failure(const char * pMsg, const char * pParam) {
    tokenType = T_ERROR;
    if (pParam) {
        snprintf(errorMsg, sizeof(errorMsg), "%s: %s", pMsg, pParam);
    }
    else {
        snprintf(errorMsg, sizeof(errorMsg), "%s", pMsg);
    }

    return tokenType;
}


unsigned char Scanner::HexDigit(unsigned char c) {
    if ((c >= '0') && (c <= '9')) {
        return c - '0';
    }
    else if ((c >= 'A') && (c <= 'F')) {
        return c - 'A' + 10;
    }
    return c - 'a' + 10;
}
