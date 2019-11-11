LABEL:  db    "abc"", "def"
	rst	0
	rst	7
	rst	8
	rst	30
	rst	3 + 1
	rst	c
	rst     3 ; ok
        rst     3,x
	mov	a
	mov	a,b,c
	mov	f,c
	push	h,4
	lxi	d,LABEL
	lxi	b
	
