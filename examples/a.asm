var5	equ	7 + 7 * 7 + 7 / 7 - 7
var6	equ	7+7*7+7/(7-7)
var0	equ	01010111b
	org 08000h
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

