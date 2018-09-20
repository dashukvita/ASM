Include io.asm

Stack segment stack
	db 128 dup(?)
stack ends

data segment
	s_cf db ' CF = ', '$'
	s_zf db ' ZF = ', '$'
	s_sf db ' SF = ', '$'
	s_of db ' OF = ', '$'
	rez dw ?
data ends

code segment
	assume ss:stack, cs:code, ds: data
start:
	mov ax, data
	mov ds, ax
	call cond_flag_register

	finish
;-------------------------------------
cond_flag_register proc
	xor cx,cx
	lea dx, s_cf
	outstr
	call print_flags

	lea dx, s_zf
	outstr
	mov cl, 6
    call print_flags

	lea dx, s_sf
	outstr
	mov cl, 7
    call print_flags

	lea dx, s_of
	outstr
	mov cl, 11
    call print_flags
	ret
cond_flag_register endp
;-------------------------------------
;number_flags proc
;    xor ax,ax
;    pushf
;    pushf
;	pop ax
;	shr ax, cl
;	and ax, 1b
;    popf
;    ret
;number_flags endp
;-------------------------------------
print_flags proc
	xor ax,ax
    pushf
    pushf
	pop ax
	shr ax, cl
	and ax, 1b
    popf

	mov rez, ax
	outint rez
	newline
	ret
print_flags endp
;-------------------------------------
code ends
end start
