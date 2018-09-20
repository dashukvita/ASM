Include io.asm

Stack segment stack
	db 128 dup(?)
stack ends

data segment
	T1 db 'Вводите текст до точки, не более 100 символов:', '$'
	T2 db 'Превышено число допустимых символов.', '$'
	T3 db 'Tекст выполняет свойство 3.', '$'
	T4 db 'Tекст НЕ выполняет свойство 3.', '$'
	T5 db 'Введенный текст в стек: ', '$'
	T6 db 'Преобразованный текст по правилу 1.', '$'
	T7 db 'Пустой текст.', '$'
	T8 db 'Преобразованный текст по правилу 2.', '$'
	Result dw 0
	N dw ?
	M dw ?
	J dw ?
	I dw ?
	Const_2 db 2
data ends

code segment
	assume ss:stack, cs:code, ds: data

start:
; Очистка экрана
	mov ah, 00h
	mov al, 03h
	int 10h
; Устанавливаем адрес сегмента данных
	mov ax, data
	mov ds, ax
	xor bx, bx
	xor ax, ax
; Приглашение к вводу текста
	lea dx, T1
    outstr
	newline
; Ввод текст, не более 100 символов
Input:
    cmp bl, 100
	je Err
    mov ah, 0
    inch al
    cmp al, '.'
    je Begin_program
    push ax
    inc bl
    Loop Input
; Ошибка, превышено количество вовдимых символов
Err:
	lea dx, T2
    outstr
	jmp Exit_Print
; Текст пустой
Empty_text:
	lea dx, T7
	outstr
	jmp Exit_Print

Begin_program:
	cmp bl, 0
	je Empty_text
; Вычисляем регистра si для работы с данными внутри стека
	push ax
	mov ah, 0
	mov al, bl
	mov N, 2
	mul N
	mov si, ax
	pop ax
; Распечатываем введенный в текст
	newline
	lea dx, T5
	outstr
	newline
	call Print_char
; Проверяем обладает ли текст свойством
	call Property_check
	newline
	cmp Result, 2
; Текст обладает свойством, используем для преобразование правило 1
	je Print_make
; Текст не обладает свойством, используем для преобразование правило 2
	lea dx, T4
	outstr
	call Invert_char
; Распечатываем преобразованный текст
L5:
    cmp bx, 0
    je Exit_Print
    pop ax
    outch al
    dec bx
    Loop L5

Exit_Print:
	newline
	newline
	finish

; Текст обладает свойством, используем для преобразование правило 1
Print_make:
	lea dx, T3
	outstr
	newline
	call Replacement_char
	newline
	lea dx, T6
    outstr
	newline
	jmp L5
;-------------------------------------------------------------------------------------
; Печать исходного текста
Print_char proc
	push si
	push bp
	mov bp, sp
	mov cx, bx
	mov si, 6
L:	mov ax, ss:[bp+si]
	outch al
	add si, 2
	loop L
	pop bp
	pop si
	ret
Print_char endp
;-------------------------------------------------------------------------------------
; Проверка свойства: Текст начинается латинской буквой и оканчивается латинской буквой.
Property_check proc
	newline
	push si
	push bp
	mov bp, sp
	mov ax, ss:[bp+6]
	call Is_char_latin_let
	mov ax, ss:[bp+si+4]
	call Is_char_latin_let
	pop bp
	pop si

	ret
Property_check endp

Is_char_latin_let proc
	push bx
	push cx
	mov cx, 26
	mov bx, 'A'
Upper:
	cmp al, bl
	JE Equal_char
	inc bx
	loop Upper

	mov cx, 26
	mov bx, 'a'
Lower:
	cmp al, bl
	JE Equal_char
	inc bx
	loop Lower
Return_proc_Is:
	pop cx
	pop bx

	ret
Is_char_latin_let endp

Equal_char:
	inc Result
	jmp Return_proc_Is
;-------------------------------------------------------------------------------------
; Текст соответствует свойству. Заменяем все заглавные латинские буквы на строчные.
Replacement_char proc
	push si			; сохраняем регистр si
	push bp			; сохраняем регистр bp
	mov bp, sp		; устанавливаем bp на начало стека
	mov cx, bx
L2:	mov ax, ss:[bp+si+4]
	call Replace_char
	sub si, 2
	loop L2
	pop bp
	pop si
	ret
Replacement_char endp

Replace_char proc
	push bx
	push cx
	mov cx, 26
	mov bx, 'A'
Upper_rep:
	cmp al, bl
	JE Equal_rep
Return_proc_Rep:
	inc bx
	loop Upper_rep

	pop cx
	pop bx

	ret
Replace_char endp

Equal_rep:
	push ax
	mov ax, ss:[bp+si+4]
	add ax, 32
	mov ss:[bp+si+4], ax
	pop ax
	jmp Return_proc_Rep
;-------------------------------------------------------------------------------------
; Текст НЕ соответствует свойству. Перевернуть текст, не используя дополнительную память.
Invert_char proc
	newline
	newline
	lea dx, T8
	outstr
	newline
	cmp bx, 1
	je L4

	mov N, si
	mov M, bx
	mov J, bp
	mov I, di

	mov bp, sp
	mov ax, bx
	div Const_2
	mov ah, 0
	mov cx, ax
	mov di, 2
L3: mov ax, ss:[bp+si]
	mov bx, ss:[bp+di]
	xchg ax, bx
	mov ss:[bp+si], ax
	mov ss:[bp+di], bx
	sub si, 2
	add di, 2
	Loop L3

	mov di, I
	mov bp, J
	mov bx, M
	mov si, N
L4:
	ret
Invert_char endp
;-------------------------------------------------------------------------------------
code ends
end start
