;  THIS IS A FILE SEGREGATION UTILITY DESIGNED
;  TO FILTER A FOLDER'S CONTENT ACCORDING
;  TO TYPE OF FILES STORED
;  TYPICALLY CREATES FOLDERS AND COPIES 
;  THE FILES TO THE RESPECTIVE TYPE FOLDER
	 
	
	name    FILESEG
	.model 	small
	.stack  100
	.data

namepar1	label	byte
maxlen1	db	1
namelen1	db	01
namerec1	db	3 dup(' ')
namerrc1	db	0
recd_len1	equ	3

	
namepar	label	byte
maxlen	db	64
namelen	db	?
fpath	db	64 dup(' '),0dh,0ah

area	db	43 dup(' ')
aj	db	'$'

errcode	db	00
ffpath	db	64	dup(' '),0dh,0ah
aa	db	'$'
prompt1  	db     	'Enter The Folders Path You Want To Segregate  $' 
prompt2	db	0ah,0dh,'Creating Subfolders  '
ab	db	'$'
prompte	db	0ah,0dh,'Error'
ac	db	'$'
promptee db	0ah,0dh,'error cre'
ad	db	'$'

flen	dw	00h
fflen	dw	00h


docs	db	'DOCUMENTS',0
aud	db	'AUDIO',0
vid	db	'VIDEO',0
img	db	'IMAGES',0
sps	db	'SPREADSHEET',0
dbs	db	'DATABASE',0
exe	db	'EXECUTABLES',0
gam	db	'GAMES',0
web	db	'WEB DOCUMENTS',0
com	db	'COMPRESSED FILES',0
dev	db	'DEVELOPER FILES',0
oth	db	'OTHERS',0


a1	db	'MP3',0
d1	db	'TXT',0
de1	db	'CPP',0
e1	db	'EXE',0
g1	db	'GAM',0
i1	db	'JPG',0
s1	db	'XLS',0
v1	db	'MP4',0
w1	db	'HTML',0
eof	db	'0'

filehand1	dw	?
filehand2	dw	?

pathnam1	db	64 dup(00h),'$',0dh,0ah
ao	db	'$'
pathnam2 db	64 dup(00h),'$',0dh,0ah
ap	db	'$'

row	db 	0

openmsg	db	'*** open error ***'
writemsg	db 	'*** write error  ***'
readmsg	db	'*** read  error ***'
.386
	.code 
	
start	proc	near
 	mov	ax, @data
	mov	ds, ax
	mov	es,ax
   	
	call	crtdir		;create
	cmp	errcode,01	;directories
	je	exits		
		
	mov	al,00h
	mov	cx,50
	lea	di,fpath
	repne	scasb
	
	neg cx
	add	cx,50
	mov	bx,cx
	mov	flen,bx
	
	mov	cx,flen+10
	lea	di,pathnam1
	lea	si,fpath
	rep	movsb
	
	mov bx,flen
	mov	pathnam1[bx],00h
	mov	pathnam1[bx+1],00h
	
	mov	cx,flen+10
	lea	di,pathnam2
	lea	si,fpath
	rep	movsb
	mov bx,flen
	mov	pathnam2[bx],00h
	mov	pathnam2[bx+1],00h

	mov	fpath[bx-1],'\'
	mov fpath[bx],'*'
	mov fpath[bx+1],'.'
	mov fpath[bx+2],'*'
	mov fpath[bx+3],00
	
	call	readdir		;read directory
	cmp	errcode,01	;and copy files
	je	exits		; to subdirectories
	
exits:	mov	ax, 4c00h	;4c in ah is dos exit fn with return code in al
	int 	21h	
	
start	endp


crtdir	proc	near
	
	lea dx, prompt1		;ask user to enter 
	mov	ah,9		;folders path
	int	21h		;
	
	mov	ah,0ah		;take
	lea	dx,namepar	;keyboard
	int	21h		;input
	
	cmp	namelen,00	;if no
	je	exit		;input
	
	mov	al,00h	;eof character
	movzx	cx,namelen	;embed
	lea	di,fpath		;eof
	add	di,cx		;at
	neg	cx		;inputs
	movzx	dx,maxlen		;end
	add	cx,dx
	rep	stosb
	
	
	mov	ah,3bh		;move
	lea	dx,fpath	;to the
	int	21h		;required folder

	cmp	ax,03		;if
	je	exit
		
	mov	ah,39h
	lea	dx,docs
	int	21h

	mov	ah,39h
	lea	dx,aud
	int	21h	
	
	mov	ah,39h
	lea	dx,vid
	int	21h

	mov	ah,39h
	lea	dx,img
	int	21h

	mov	ah,39h
	lea	dx,sps
	int	21h

	mov	ah,39h
	lea	dx,exe
	int	21h

	mov	ah,39h
	lea	dx,dbs
	int	21h

	mov	ah,39h
	lea	dx,gam
	int	21h

	mov	ah,39h
	lea	dx,web
	int	21h

	mov	ah,39h
	lea	dx,com
	int	21h

	mov	ah,39h
	lea	dx,oth
	int	21h

	mov	ah,39h
	lea	dx,dev
	int	21h
	
exit:	ret
crtdir	endp


readdir	proc	near

lea    	dx, area	;set
	mov	ah,1ah	;disk tranfer area
	int	21h
	
	mov	ah,4eh	;read
	mov	cx,00h	;first
	lea	dx,fpath	;file
	int	21h

	cld
	mov	bx,flen	;set
	mov 	pathnam1[bx-1],'\'	;first
	mov	cx,13	;pathname
	lea	si,area[30]
	lea	di,pathnam1[bx]
	rep	movsb
	
	call	setpath2
	call	copy
	
readnex:	mov	ah,4fh	;read
	lea	dx,fpath	;next
	int	21h	;file	attributes
	
	cmp	ax,00	;exit if
	jne	exitr	;no more files
	
	cld
	mov	bx,flen
	mov 	pathnam1[bx-1],'\'	;set
	mov	cx,13	;pathname1
	lea	si,area[30]
	lea	di,pathnam1[bx]
	rep	movsb
	
	call	setpath2
	call	copy
	
	jmp	readnex	

exitr:ret
readdir	endp


setpath2	proc	near
	
	cld		
	mov	al,00h
	mov	cx,50
	lea	di,pathnam1
	repne	scasb
	
	neg cx
	add	cx,50
	mov	bx,cx
	mov	fflen,bx

	std
	mov	al,'.'
	mov	cx,fflen
	lea	di,pathnam1[bx]
	repne	scasb
	
	add	cx,2
	mov	fflen,cx
	mov	bx,fflen

	cld

aud1:	mov	cx,3
	lea	si,pathnam1[bx]
	lea	di,a1
	repe	cmpsb
	jne	vid1
	
	mov	bx,flen
	mov	pathnam2[bx-1],'\'
	
	mov	cx,5
	lea	si,aud
	lea	di,pathnam2[bx]
	rep	movsb
	
	mov	pathnam2[bx+5],'\'		
	mov	pathnam2[bx+6],00h

	mov	cx,13
	lea	si,area[30]
	lea	di,pathnam2[bx+6]
	rep	movsb

	jmp	exits2

vid1:	mov	cx,3
	lea	si,pathnam1[bx]
	lea	di,v1
	repe	cmpsb
	jne	doc1
	
	mov	bx,flen
	mov	pathnam2[bx-1],'\'
	
	mov	cx,5
	lea	si,vid
	lea	di,pathnam2[bx]
	rep	movsb
	
	mov	pathnam2[bx+5],'\'		
	mov	pathnam2[bx+6],00h

	mov	cx,13
	lea	si,area[30]
	lea	di,pathnam2[bx+6]
	rep	movsb

	jmp	exits2
		
doc1:	mov	cx,3
	lea	si,pathnam1[bx]
	lea	di,d1
	repe	cmpsb
	jne	img1
	
	mov	bx,flen
	mov	pathnam2[bx-1],'\'
	
	mov	cx,8
	lea	si,docs
	lea	di,pathnam2[bx]
	rep	movsb
	
	mov	pathnam2[bx+8],'\'		
	mov	pathnam2[bx+9],00h

	mov	cx,13
	lea	si,area[30]
	lea	di,pathnam2[bx+9]
	rep	movsb

	jmp	exits2
	
img1:	mov	cx,3
	lea	si,pathnam1[bx]
	lea	di,i1
	repe	cmpsb
	jne	oth1
	
	mov	bx,flen
	mov	pathnam2[bx-1],'\'
	
	mov	cx,6
	lea	si,img
	lea	di,pathnam2[bx]
	rep	movsb
	
	mov	pathnam2[bx+6],'\'		
	mov	pathnam2[bx+7],00h

	mov	cx,13
	lea	si,area[30]
	lea	di,pathnam2[bx+7]
	rep	movsb

	jmp	exits2
	
oth1:	mov	bx,flen
	mov	pathnam2[bx-1],'\'
	
	mov	cx,6
	lea	si,oth
	lea	di,pathnam2[bx]
	rep	movsb
	
	mov	pathnam2[bx+6],'\'		
	mov	pathnam2[bx+7],00h

	mov	cx,13
	lea	si,area[30]
	lea	di,pathnam2[bx+7]
	rep	movsb

exits2:	ret

setpath2	endp


copy	proc	near

	call	b10create
	
	cmp	errcode,00
	jnz	a90

	call	b10open
	
	cmp	errcode,00
	jnz	a90
	
	mov	namelen1,01
	
a20:	call	c10proc
	cmp	namelen1,00
	jne	a20
	
	call	e10close

a90:	ret
copy	endp

b10open	proc 	near
	mov 	ah,3dh
	mov	al,00
	lea	dx,pathnam1
	int 	21h
	JC	B2
	MOV	FILEHAND1,AX
	JMP	B9
B2:	LEA	BP,OPENMSG
	MOV	CX,19
	CALL	F10DISPLY
	MOV	ERRCODE,01
B9:	RET
B10open	ENDP


b10create	proc 	near
	mov 	ah,3ch
	mov	cx,00
	lea	dx,pathnam2
	int 	21h
	JC	B20
	MOV	FILEHAND2,AX
	JMP	B90
B20:	LEA	BP,OPENMSG
	MOV	CX,19
	CALL	F10DISPLY
	MOV	ERRCODE,01
B90:	RET
B10CREATE	ENDP

c10proc	proc	near

	mov	ah,3fh
	mov	bx,filehand1
	mov	cx,recd_len1
	lea	dx,namerec1
	int	21h		;set maxlen to number of bytes read

	jnc	c20

	lea	bp,readmsg
	mov	cx,18
	call	f10disply	
	jmp	c90

c20:	cmp	ax,00
	jne	c80
	mov	namelen1,00
	jmp	c90	

c80:	call	d10write

c90:	ret
c10proc	endp

d10write	proc	near
	mov	ah,40h
	mov	bx,filehand2
	movzx	cx,maxlen1
	add	cx,2
	lea	dx,namerec1
	cmp	namelen1,00
	je	d20
	int	21h
	jnc	d20
	lea	bp,writemsg
	mov	cx,19
	call	f10disply
	mov	errcode,01
	mov	namelen1,00
d20:	ret
d10write	endp

e10close	proc	near
	mov	namerec1,1ah
	call	d10write
	mov	ah,3eh
	mov	bx,filehand2
	int	21h
	ret
e10close	endp

f10disply	proc	near
	mov	ax,1301h
	mov	bx,0016h
	mov	dh,row
	mov	dl,00
	int 	10h
	inc 	row
	ret
f10disply	endp
end	start
