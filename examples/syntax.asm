; The assembler runs two passes over the source file.  The first pass builds
; the symbol table and the second emits the hex file and list file.
;
; Note that the assembler is case-insensitive for instructions, directives,
; register names, and labels.  The labels "label2" and "LABEL2" are the same,
; and an error would be thrown if both were defined.
 
; The ORG directive sets the current address for assembly.  A file can
; contain more than one ORG.  The assembler does not detect overlapping
; ORG directives and will silently overwrite output in that case.
        org     RAMST + 02000h


; Column one must contain whitespace or a label or a comment start.
; Labels can be up to 32 characters and must start with an alpha.  
; Numbers and the underscore character are permitted in a label.
; Labels end with a colon character.
LABEL1: db      123             ; labels can be on the same line as code
LABEL2:
        POP     PSW             ; or the label can be before the code
NOSPACE:push    D               ; a space is not required after a label
VeryVeryVeryLongLabel:
    db  "Labels can be up to 32 characters and must start with an alpha."

; The EQU directive is used to define a constant value.  It does not emit
; any code.  The name label for an EQU does not need the trailing but it
; does need to be followed by whitespace.
RAMST   equ     00000h          
ROMST   equ     0c000h         

; Constants can be decimal, binary, hex, or octal.  Binary is indicated with a
; trailing 'b' hex with a trailing 'h', and octal with a trailing 'o' or 'q'
; character.  Decimal constants can have a trailing 'd' character, but it is
; not required.  All constants must start with a numeric character, so hex 
; values starting with A-F must have a leading zero.
num0    equ     55              ; Decimal constant
num1    equ     55D             ; Decimal constant with optional suffix
num3    equ     0a6h            ; Hex with leading zero
num4    equ     1AB4H           ; Hex without leading zero
num5    equ     01100101b       ; Binary
num6    equ     1357o           ; Octal with trailing 'o'
num7    equ     1011Q           ; Octal with trailing 'q'

; The DB directive places one or more bytes of data in the output.
d1:     db      5               ; single byte
d2:     db      12h,34h,56h,78h ; multiple bytes
d3:     db      5, 02Ah, 1011B  ; Mixed decimal, hex, and binary

; The DB directive can also be used with strings.  Each octet in the string
; generates one octet of output.  Strings and numeric constants can be mixed
; in a single directive.
str1:   db      'T'             ; Single character constant
str2:   DB      "Welcome"       ; String constant
str3:   db      "red","green"   ; Multiple strings
str4:   db      3,"red",4,"blue"; Mixed strings and numerics

; Note that a single character string can also be used anywhere a numeric
; would be allowed.  It evaluates to the ASCII value of the single character.
        mvi     c, 65           ; Move the letter 'A' into register C.
        mvi     c, 041H         ; Move the letter 'A' into register C.
        mvi     c, 'A'          ; Move the letter 'A' into register C.

; A two character string can also be used anywhere a numeric would be allowed.
; It evaluates to the 16-bit value of ASCII value of the two characters, where
; the MSB is the first char and the LSB is the second.
        lxi     h,04142H        ; All of these evaluate to 4142H
        lxi     h,'AB'          ; All of these evaluate to 4142H
        lxi     h,"AB"          ; All of these evaluate to 4142H
        lxi     h,'A'*256 | 'B' ; All of these evaluate to 4142H


; Some common C-style string escapes are supported: CR, LF, tab, NULL, and
; hex value.  Hex escapes can use upper or lower case and must be 2 digits.
    db  "\r\n\t\x2a\x2B\0"

; The backslash can also be used to escape quotes or the backslash character
; itself.  Embedded quotes can also be handled by placing double quotes
; inside single quotes or single quotes inside double quotes.
    db  '\\'                    ; Backslash character.
    db  '\''                    ; Single quote character.
    db  "'"                     ; Same string using double quotes.
    db  "A \"quoted\" string"   ; Quotes within quotes.
    db  'A "quoted" string'     ; Same string using single quotes.
    db  "This isn't bad"        ; Single quote in double quotes.
    
; The following DBs are all equivalent  
CR  equ 13
LF  equ '\n'
    db  "ABC123\r\n"
    db  "ABC123",CR,LF
    db  "ABC123",13,10
    db  'A','B','C','1','2','3','\r','\n'
    db  "ABC",31h,32h,"3",'\r',LF

; The DW directive stores one or more 16 bit values.
words1: dw      0203h           ; One word value in hex
words2: dw      num4            ; One word value in decimal
words3: dw      1010101001010101B ; One word value in binary
words4: dw      02h, 03h        ; Two word values
words5: dw      02h, 03, 04ffh  ; Three word values

; Note that DW stores the two octet values in intel (little endian) order, so
; the following two declarations are equivalent:
        dw      01234h
        db      034h, 012h

; The DS directive reserves space, but does not generate any output.  It
; simply advances the target address for the next code or data.
StrSize equ     32
buffer: ds  StrSize * 4     ; Reserve space for 4 strings

; Expressions can be used in place of any numeric constant.
t:      dw      1024 * 3
        LXI     SP, 32 * 4 + 2
        lxi     h, str4 + 5
        lxi     d, buffer + StrSize
        db      7+7*7+7/(7+7-7)
        mvi     c, 'A' | 020H
        mvi     c, 'a' & 11011111b

; Operators and precedence
PREC:
        dw      (8+7)           ; Parenthesis hve highest precedence
        dw      -1              ; bitwise NOT, unary plus and minus
        db      HIGH 512        ; byte isolation: HIGH, LOW
        dw      100 / 10 MOD 4  ; multiply, divide, SHL, SHR, MOD - left to right
        dw      2 + 8 - 1       ; add, subtract, unary plus, minus - left to right
        dw      2 LE 3          ; relational: EQ, NE, GT, GE, LT, LE =
        dw      23H & 0FH       ; bitwise AND (extension to Intel Assembler)
        dw      23H | 0FH ^0FFH ; bitwise OR and XOR (extension to Intel Assembler)
        dw      NOT 0           ; logicat NOT
        dw      1 AND 0         ; logical AND
        dw      1 XOR 0         ; logical OR and XOR

; The precedence rules above have a few differences from those listed in the Intel
; Assembler manual.
; Intel85 has unary - at the same level as addition and subtraction, but asm85
; evaluates the unary before most other operations.  The asm85 produces the more
; intuitive result.
; In the expression below, asm85 shifts the all-ones -1 to the right.  Intel85
; would shift 1 to the right, producing zero, and then negate that.
        dw      -1 SHR 3        ; asm85 evaluates -1 first and then shifts it
        dw      (-1) SHR 3      ; same as above
        dw      -(1 SHR 3)      ; Intel would shift 1 first then negate the result

; Intel85 places the logical NOT operator at a lower precedence than C++. The
; asm85 code follows the Intel result, so this may not be what C++ programmers
; are expecting.
        dw      NOT 3 EQ 2      ; Intel and asm85 use the obvious 3 not equal 2
        dw      NOT (3 EQ 2)    ; same as above
        dw      (NOT 3) EQ 2    ; C++ version !3 == 2 would do the NOT first

; Additions to Intel85 expressions in asm85
; There are several new operators in asm85 to support additional operations or to
; give compatibility with other observed .asm files
EXPR01: db      3 << 4, 128 >> 1 ; C++ style alias are provided for SHL and SHR
        db      99 % 8          ; C++ style alias is provided for MOD
        dw      EXPR01 = 0ffffH ; the = alias is provided for the EQ test
        dw      ~02211H         ; the ~ (tilde) performs bitwise NOT
        dw      't' & 5fH       ; the & (ampersand) performs bitwise AND
        dw      'T' | 20H       ; the | (vertical bar) performs bitwise OR
        dw      3377H ^ 1111H   ; the ^ (carat) performs bitwise XOR

; The behavior of the logical (NOT, AND, OR, and XOR) operators isn't entirely
; clear in the Intel85 manual.  The operations only evaluate the least significant
; bit of the operand.  For example, the manual states that 1 is returned if both
; ANDed bits are 1, so 0001 AND 0001 would return 0001.  It is not clear if other
; bits are also ANDed or if they are masked.  For axample, 1001 AND 1011 could
; return either 1001 or just 0001.  The relations (EQ, NE, LT, etc) operators
; return 00H or FFH, so that would also be a reasonable model to follow.
; The expression evaluator in asm85 will mask off all bits other than the LSB,
; so 1011 AND 1011 will return 1.
; In the end, it shouldn't matter because relational operators will only use the
; LSB and this is the typical use of the logical operators.  The ambiguiity will
; only be a problem if the results of a logical are used in an arithmetic or
; bitwise expression.
        db      NOT 0           ; 1
        db      NOT 1           ; 0
        db      NOT 0111B       ; 0, because LSB is 1
        db      NOT 0110B       ; 1, because LSB is 0
        db      0 AND 0         ; 0
        db      1 AND 1         ; 1
        db      1 AND 0         ; 0
        db      0 AND 1         ; 0
        db      2 AND 3         ; 0, both LSBs not 0
        db      7 AND 3         ; 1, both LSBs are 1
        db      0 OR 0          ; 0
        db      1 OR 1          ; 1
        db      1 OR 0          ; 1
        db      0 OR 1          ; 1
        db      2 OR 4          ; 0, both LSBs are 0
        db      7 OR 3          ; 1, both LSBs are 1
        db      0 XOR 0         ; 0, LSBs equal
        db      1 XOR 1         ; 0, LSBs equal
        db      1 XOR 0         ; 1, LSBs not equal
        db      0 XOR 1         ; 1, LSBs not equal
        db      2 XOR 3         ; 1, LSBs not equal
        db      7 XOR 3         ; 0, LSBs equal
        db      not not 0       ; 0
        db      not not 1       ; 1

; Precedence of logical and relational operators
; From highest to lowest: EQ, NOT, AND, OR/XOR
; These are intuitive
        db      NOT 5 EQ 7      ; EQ then NOT
        db      NOT (5 EQ 7)    ; same as above
        db      5 EQ 7 OR 1 EQ 1     ; EQ then OR
        db      (5 EQ 7) OR (1 EQ 1) ; same as above
; But this is not
        db      NOT 1 OR 1      ; NOT then OR
        db      (NOT 1) OR 1    ; same as above
        db      NOT (1 OR 1)    ; force the OR before the NOT
; All of these evaluate to TRUE
        db      (2 eq 3 or not 2 eq 3)   EQ  ((2 eq 3) or (not (2 eq 3)))
        db      (2 eq 3 and not 2 eq 3)  EQ  ((2 eq 3) and (not (2 eq 3)))
        db      (2 eq 3 xor not 2 eq 3)  EQ  ((2 eq 3) xor (not (2 eq 3)))
        db      (not 2 eq 3 or not 2 eq 3)   EQ  (not (2 eq 3) or (not (2 eq 3)))
        db      (not 2 eq 3 and not 2 eq 3)  EQ  (not (2 eq 3) and (not (2 eq 3)))
        db      (not 2 eq 3 xor not 2 eq 3)  EQ  (not (2 eq 3) xor (not (2 eq 3)))
        db      (not not 2 eq 3 or not 2 eq 3)   EQ  ((not (not (2 eq 3))) or (not (2 eq 3)))
        db      (not not 2 eq 3 and not 2 eq 3)  EQ  ((not (not (2 eq 3))) and (not (2 eq 3)))
        db      (not not 2 eq 3 xor not 2 eq 3)  EQ  ((not (not (2 eq 3))) xor (not (2 eq 3)))
        db      (not (not 2 eq 3 or not 2 eq 3))   EQ  (not ((not (2 eq 3)) or (not (2 eq 3))))
        db      (not (not 2 eq 3 and not 2 eq 3))  EQ  (not ((not (2 eq 3)) and (not (2 eq 3))))
        db      (not (not 2 eq 3 xor not 2 eq 3))  EQ  (not ((not (2 eq 3)) xor (not (2 eq 3))))

; Address
; The $ symbol is used in an expression to represent the current address.
; This is useful for calculating the size of objects
hello:  db  "Hello, world"
strLen  equ     $ - hello       ; Length of the string

jump_tab:                       ; Jump table.  Each entry is 3 octets.
        db      'a'             ; ADD command
        dw      0100h           ; Handler address
        db      'e'             ; EXAMINE command
        dw      0142h
        db      'p'             ; PRINT command
        dw      0220h
        db      's'             ; STEP command
        dw      0334h
        db      'x'             ; EXIT command
        dw      0434h
entries equ     ($-jump_tab) / 3 ; Number of entries in the table


; It is legal, though probably not wise, to have a label with the same name
; as a register.  This looks confusing, but it will work.  All of the examples
; below load register pair HL with the address of the word at label "SP".  None
; of these have any relation to the SP register.
; Labels that match registers are not permitted in Intel85, but this change was
; added to support some code that was developed with a different assembler.
SP:     dw      256             ; define a word at location named SP
        LXI     H,SP            ; laod address of "SP" word into HL pair
        LXI     H,SP+0
        LXI     H,0+SP

; Names of alphabetic expression operations are reserved words in asm85 and cannot
; be used as labels or names.  This is compatible with Intel85 as well.
; Reserved words are: HIGH, LOW, MOD, SHL, SHR, EQ, NE, LE, LT, GE, GT, NOT, AND, OR, XOR.
