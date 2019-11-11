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



