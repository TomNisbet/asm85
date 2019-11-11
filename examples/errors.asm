sym1	equ	55
sym2	equ	55h
sym3 equ 1234h
num4	equ	0110b		; Binary constant
bah	equ	77h
dater:  dw	1234h,5678h
modater:db	12h  , 34hi ,56h,78h
str:    DB	"LILY",00h
str2:   DB	"Katie" , 80
str3:   db	"Tom","Rox"
bad:	db	"where is the end
hexy:   db	"cobb\xbe\xef"
quote:  db	"\"air\""
quote2: db	"\"bud\"more"
slash:  db	"\\abc"
special:db	"\t\n\r",bah,beh, bad,sym1,sym2 
123
"abc"
+

buffer	ds	8		; Can reserve space with DS.
char2:  mvi	a,'A'
char3:	mvi	b,'abc'		; ERR: Can't use string in expression.
symbol: dw str,nope,str2,65535,cafeh,sym3
        LXI	SP,2100H

VeryVeryVeryLongLabel:
	db	"Labels can be up to 32 characters and must start with an alpha."


single: db	"'"
char:	db	'"'

; Some common C-style string escapes are supported: CR, LF, tab, NULL, and
; hex value.  Hex escapes can use upper or lower case and must be 2 digits.
	db	"\r\n\t\x2a\x2B\0"

; The backslash can also be used to escape quotes or the backslash character itself.
	db	'\\'			; Backslash character.
	db	'\''			; Single quote character.
	db	"'"			; Same string using double quotes.
	db	"A \"quoted\" string"	; Quotes within quotes.
	db	'A "quoted" string'	; Same string using single quotes.
	db	"mismatch'		; ERR: quotes must match.
	
CR	equ	13
LF	equ	'\n'
	db	"ABC123\r\n"
	db	"ABC123",CR,LF
	db	"ABC123",13,10
	db	'A','B','C','1','2','3','\r','\n'
	db	"ABC",31h,32h,"3",'\r',LF








var6	equ	7+7*7+7/(7-7)
var0	equ	01010111b

	org $ + 08000h
var1	equ	32
var2	equ	$ + 1
var3	equ	16* 3
var4	equ	(2+3)
stuff	ds	20
ssize	equ	$ - stuff
stuff2	dw	0ffffh & 01248h
stuff3	db	var0   |05ah
stuff4	db	"ABC"
stuff5	db 	'a','b','c'
stuff6	db	020H | 'A'
stuff7	db	'B'&11011111B
stuff8	db	"123",09H, "456", 0AH
stuff9  db      "abc\ndef\rghi\x00\x30"
stuff10 db      "abc\"d"

var7:	db	00dh, 00ah
var8:	equ	0
var9:	db	"yeah, baby"



        mvi     c,'T'           ; Send a test character
        mvi     b,OUTBITS       ; Number of output bits
        xra     a               ; Clear carry for start bit
        mvi     a,080H          ; Set the SDE flag
        rar                     ; Shift carry into SOD flag
        cmc                     ;   and invert carry.  Why? (serial is inverted?)
        sim                     ; Output data bit
        lxi     h,BITTIME       ; Load the time delay for one bit width
        dcr     l               ; Wait for bit time
        jnz     CO2
        dcr     h
        jnz     CO2
        stc                     ; Shift in stop bit(s)
        mov     a,c             ; Get char to send
        rar                     ; LSB into carry
        mov     c,a             ; Store rotated data
        dcr     b
        jnz     CO1             ; Send next bit
        ei
        jmp     START


