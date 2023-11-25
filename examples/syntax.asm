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

; Constants can be decimal, hex, or binary.  Binary is indicated with a
; trailing 'b' and hex with a trailing 'h' character.  All constants must
; start with a numeric character, so hex values starting with A-F must have
; a leading zero.
num0    equ     55              ; Decimal constant
num1    equ     55D             ; Decimal constant with optional suffix
num2    EQU     55h             ; Hex
num3    equ     0a6h            ; Hex with leading zero
num4    equ     1234H           ; Hex without leading zero
num5    equ     01100101b       ; Binary
CAB     equ     0CABh           ; Note label 'CAB' and constant '0CABh'

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
SP:     dw      256             ; define a word at location named SP
        LXI     H,SP            ; laod address of "SP" word into HL pair
        LXI     H,SP+0
        LXI     H,0+SP


