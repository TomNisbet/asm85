; Test and demonstrate assembly errors
; lines marked with ERR are detected by the assenbler
; lines marked as *ERR should be detected, but are currently not

; constants
symd1   equ 55          ; decimal constant
symd2   equ 5X5         ; *ERR: bad decimal constant
symh1   equ 5A5h        ; hex constant
symh2   equ 5A5         ; ERR: missing H for hex constant
symh3   equ ffffH       ; ERR: hex must start with numeric
symh4   equ 0ffffH      ; Hex with leading zero
symb1   equ 01100110b   ; Binary constant
symb2   equ 01101210b   ; ERR: bad binary constant

bah     equ 77h
bad:    db  "where is the end  ; ERR: unterminated string
special:db  "\t\n\r",bah,beh, bad  ; ERR: undefined symbol

; column zero
LABEL1:                 ; label can start in column 0
LABEL2: MOV   C,A       ; label with instruction also OK
NAME1   EQU   7         ; name can start in column zero
123                     ; ERR: not name or label
"abc"                   ; ERR: not name or label
+                       ; ERR: not name or label
mov h,l                 ; *ERR: instruction can't start in column zero

; extra information on line and extra/incorrect arguments
        nop     SP      ; ERR: extra register argument
        nop     d,e     ; ERR: multiple extra registers
        nop     str     ; ERR: extra expression argument
        nop     12XX    ; ERR: extra characters
        MOV     A       ; ERR: missing second register
        MOV     A,4     ; ERR: missing second register
        MVI     B,A     ; ERR: second arg should be expression
        JMP     SP      ; ERR: first arg should be expression
        JZ              ; ERR: missing arg

; RST instructions
        RST     0       ; OK
        RST     A       ; ERR: must be number
RNUM    equ     1
        RST     RNUM    ; ERR: expression not allowed
        RST     1+1     ; ERR: expression not allowed
        RST     7       ; OK
        RST     9       ; ERR: RST number must be 0..7
; characters in expressions      
        mvi     b,'P'   ; single char is a byte
        lxi     d,'QR'  ; two chars is a sixteen bit value
        mvi     e,'abc' ; ERR: Can't use string in expression
        lxi     b,'a'*'B' ; weird, but legal


; math
var1    equ     23 / 0  ; ERR: divide by zero
var2    dw      255 + 10; OK as a 16 bit value
var3    db      255 + 10; *ERR: 8 bit constant overflow
