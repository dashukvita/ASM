include console.inc

COMMENT *
   Дана последовательность от 1 до 20 слов, каждое из которых содержит от 1 до 8 заглавных латинских букв;
	соседние слова разделены запятой, за последним словом следует точка.

	А. Внутреннее представление последовательности слов:
	7) Список слов, упорядоченных по алфавиту.

	Б. Какие слова и в каком порядке печатать:
	12)Все слова, входящие в последовательность только один раз.

	В. Дополнительная информация о слове:
	2) Порядковый номер слова в последовательности.

	Требуется ввести эту последовательность и преобразовать ее во внутреннее представ-
ление, а затем напечатать по алфавиту определенные слова с дополнительной инфор-
мацией о каждом из них.
*
Elem struc
	new_word db 8 dup (?)
	next 	 dd ?
	num_char dd ?
	index	 dd ?
	flag	 dd 0
	freq	 dd 0
Elem ends

.data
	List 	 dd nil
	List1 	 dd nil
	X    	 db ?
	Y 		 db 8 dup (?)
	Num_char dd ?
	Index_w	 dd ?
	Vsp_w    db 8 dup (?)
	Comp_w	 dd 0
	Rem_ind	 dd ?
.code

;-------------------------------------------------
;Процедура добавления слов в список
InList proc uses eax ebx ecx edx esi edi, @List:dword, @N:byte
    mov  	ebx, @List
    new  	sizeof Elem
	mov 	esi, 0
    mov  	ecx, Num_char
@Fill_word:
	mov 	dl,  Y[esi]
    mov  	[eax].Elem.new_word[esi],dl
	cmp  	ecx, 0
	je 		@Fill_elem
	dec 	ecx
	inc 	esi
	jmp 	@Fill_word
@Fill_elem:
    mov  	[eax].Elem.next,nil
	mov 	ecx, Num_char
	mov  	[eax].Elem.num_char, ecx
	mov		ecx, Index_w
	mov  	[eax].Elem.index, ecx
	xor 	ecx, ecx
	xor 	edx, edx
	mov 	cl,[eax].Elem.new_word[edx]
    cmp  	dword ptr [ebx],nil
    jne  	@Add_list;
    mov  	[ebx], eax;
    jmp  	@KOH

@Add_list:
	mov  	ebx,[ebx]
    mov  	[eax].Elem.next, ebx
    mov  	edi,@List
    mov  	[edi],eax;
@KOH:
	ret
InList endp
;-------------------------------------------------
;Процедура определения длины для сравнения слов
Leght_loop proc uses ecx
	xor		ecx,ecx
	xor 	esi,esi
	mov 	ecx, [ebx].Elem.num_char
	cmp 	Num_char, ecx
	jge 	@next
	mov 	esi, Num_char
	jmp 	@End
@next:
	mov 	esi, [ebx].Elem.num_char
@End:
	ret
Leght_loop endp
;-------------------------------------------------
;Процедура сравнения слов
Compare_char proc uses ecx edx ebx esi edi
	xor  	edx,edx
	xor 	ecx,ecx
	xor 	esi,esi
	xor		edi,edi
	mov 	edi, [ebx].Elem.num_char
	mov     Comp_w, 0
	call 	Leght_loop
@Comp:
	mov  	cl, Vsp_w[edx]
	cmp		[ebx].Elem.new_word[edx],cl
	jg		@Larger
	cmp		[ebx].Elem.new_word[edx],cl
	jl		@KOH
	cmp		edx, esi
	je		@Larger
	inc		edx
	jmp		@Comp
@Larger:
	mov     Comp_w, 1
@KOH:
	ret
Compare_char endp
;-------------------------------------------------
;Процедура сортировки
SortList proc uses eax ebx ecx edx esi edi, @List:dword, @List1:dword
	mov  	ebx,@List
@Find_Vsp_w :
	cmp 	[ebx].Elem.flag,1
	je 		@Next_elem
	mov 	esi, 0
    mov  	ecx, [ebx].Elem.num_char
	mov		Num_char, ecx
	mov     eax, [ebx].Elem.index
	mov 	Index_w,eax
@Fill_w:
	mov 	dl, [ebx].Elem.new_word[esi]
    mov  	Vsp_w [esi],dl
	cmp  	ecx, 0
	je 		@Cursor
	dec 	ecx
	inc 	esi
	jmp 	@Fill_w
@Next_elem:
	cmp  	[ebx].Elem.next,nil
	je		@Empty_list
	mov  	edi,[ebx].Elem.next
	mov  	ebx,edi
	jmp		@Find_Vsp_w
@Empty_list:
	jmp 	@KOH
@Cursor:
	mov	    Rem_ind, ebx
	xor		ebx, ebx
    mov  	ebx,@List
	jmp		@Search
@Vsp_w :
	cmp 	[ebx].Elem.flag,1
	je 		@Next_elem
	mov	    Rem_ind, ebx
	mov 	esi, 0
    mov  	ecx, [ebx].Elem.num_char
	mov		Num_char, ecx
	mov     eax, [ebx].Elem.index
	mov 	Index_w,eax
@Fill_w1:
	mov 	dl, [ebx].Elem.new_word[esi]
    mov  	Vsp_w [esi],dl
	cmp  	ecx, 0
	je 		@Next
	dec 	ecx
	inc 	esi
	jmp 	@Fill_w1
@Next:
	cmp  	[ebx].Elem.next,nil
	je		@Add
	mov  	edi,[ebx].Elem.next
	mov  	ebx,edi
	jmp		@Search
@Search:
	cmp 	[ebx].Elem.flag,1
	je		@Next
	call  	Compare_char
	cmp 	Comp_w,1
	je  	@Vsp_w
	jmp 	@Next
@Add:
	mov		ebx, Rem_ind
	mov		[ebx].Elem.flag,1
    mov  	ebx,@List1
    new  	sizeof Elem
    mov  	ecx, Num_char
	mov     esi, Index_w
	mov		[eax].Elem.index,esi
	mov 	esi, 0
@Fill_word:
	mov 	dl, Vsp_w[esi]
    mov  	[eax].Elem.new_word[esi],dl
	cmp  	ecx, 0
	je 		@Fill_elem
	dec 	ecx
	inc 	esi
	jmp 	@Fill_word
@Fill_elem:
    mov  	[eax].Elem.next,nil
	mov 	ecx, Num_char
	mov  	[eax].Elem.num_char, ecx
	mov		ecx, Index_w
	mov  	[eax].Elem.index, ecx
	xor 	ecx, ecx
	xor 	edx, edx
	mov 	cl,[eax].Elem.new_word[edx]
    cmp  	dword ptr [ebx],nil
    jne  	@Add_list;
    mov  	[ebx],eax;
    jmp  	@Continue
@Add_list:
	mov  	ebx,[ebx]
    mov  	[eax].Elem.next, ebx
    mov  	edi,@List1
    mov  	[edi],eax;
@Continue:
	xor		ebx, ebx
	mov  	ebx,@List
	jmp 	@Find_Vsp_w
@KOH:
	ret
SortList endp
;-------------------------------------------------
;Распечатываем исходный лист
OutList proc uses ecx ebx esi, @List:dword
    mov  	ebx,@List;
assume 		ebx:ptr Elem
    cmp  	ebx,nil
    jne  	@L1
    outstr "Список пуст"
    jmp  	@KOH
@L4:
	cmp  	ebx,nil
    je   	@KOH
	outchar ','
@L1:
	mov 	esi, 0
	mov 	ecx, [ebx].Elem.num_char
@L3:
	outchar [ebx].Elem.new_word[esi]
	cmp 	ecx, 0
	je 		@L2
	dec 	ecx
	inc 	esi
    jmp 	@L3
@L2:
	mov  	ebx,[ebx].next
    jmp  	@L4
assume ebx:NOTHING
@KOH:
	outchar '.'
    newline
    ret
OutList endp
;-------------------------------------------------
;Распечатываем отсортированный лист с порядковым номером
OutList2 proc uses ecx ebx esi, @List1:dword
    mov  	ebx,@List1
assume 		ebx:ptr Elem
    cmp  	ebx,nil
    jne  	@L1
    outstr  'Список пуст'
    jmp  	@KOH
@L4:
	cmp  	ebx,nil
    je   	@KOH
	outchar ','
@L1:
	mov 	esi, 0
	mov 	ecx, [ebx].Elem.num_char
@L3:
	outchar [ebx].Elem.new_word[esi]
	cmp 	ecx, 0
	je 		@L2
	dec 	ecx
	inc 	esi
    jmp 	@L3
@L2:
	outchar  ' '
	outint  [ebx].Elem.index
	mov  	ebx,[ebx].next
    jmp  	@L4
assume ebx:NOTHING
@KOH:
	outchar '.'
    newline
    ret
OutList2 endp
;-------------------------------------------------
Leght_loop1 proc uses ecx
	xor		ecx,ecx
	xor 	esi,esi
	mov 	ecx, [eax].Elem.num_char
	cmp 	[ebx].Elem.num_char, ecx
	je 		@next
	mov		esi, -1
	jmp 	@End
@next:
	mov 	esi, [ebx].Elem.num_char
@End:
	ret
Leght_loop1 endp

Compare_char1 proc uses ecx edx ebx esi eax
	xor  	edx,edx
	xor 	ecx,ecx
	xor 	esi,esi
	call 	Leght_loop1
	cmp		esi, -1
	je		@KOH
@Comp:
	mov  	cl, [eax].Elem.new_word[edx]
	cmp		[ebx].Elem.new_word[edx],cl
	jne		@KOH
	cmp		edx, esi
	je		@Equal
	inc		edx
	jmp		@Comp
@Equal:
	inc     [ebx].Elem.freq
@KOH:
	ret
Compare_char1 endp

Repeat_word proc uses ecx eax esi, @List:dword
    mov  	eax,@List
assume 		eax:ptr Elem
@L4:
    cmp  	eax,nil
    je  	@KOH
	call	Compare_char1
	mov  	eax,[eax].next
    jmp  	@L4
assume ebx:NOTHING
@KOH:
    ret
Repeat_word endp
;-------------------------------------------------
;Распечатываем слова, которые входят в последовательность только один раз
OutList3 proc uses ecx ebx esi, @List:dword
    mov  	ebx,@List
assume 		ebx:ptr Elem
    cmp  	ebx,nil
    jne  	@L1
    outstr  'Список пуст'
    jmp  	@KOH
@L4:
	cmp  	ebx,nil
    je   	@KOH
@L1:
	invoke  Repeat_word,List
	cmp		[ebx].Elem.freq, 1
	jg		@L5
	mov 	esi, 0
	mov 	ecx, [ebx].Elem.num_char
@L3:
	outchar [ebx].Elem.new_word[esi]
	cmp 	ecx, 0
	je 		@L2
	dec 	ecx
	inc 	esi
    jmp 	@L3
@L2:
	outchar  ' '
@L5:
	mov  	ebx,[ebx].next
    jmp  	@L4
assume ebx:NOTHING
@KOH:
    newline
    ret
OutList3 endp
;-------------------------------------------------
;Процедура удаления листа
DeleteList proc uses eax ebx, @List:dword
    mov     ebx,@List
    mov     ebx,[ebx]
@L1:
	cmp     ebx,nil
    je      @KOH
    mov     eax,ebx
assume ebx:ptr Elem
    mov     ebx,[ebx].Elem.next
assume ebx:NOTHING
    dispose eax
    jmp     @L1
@KOH:
    mov     ebx,@List
    mov     dword ptr [ebx],nil
    ret
DeleteList endp
;-------------------------------------------------
Err:
	outstrln 'Превышено число слов!'
	jmp 	End_program

Wrong_char:
	outstrln 'Слово содержит неверный символ!'
	jmp 	End_program

Wrong_num_char:
	outstrln 'В слове неверное количество символов!'
	jmp 	End_program
;-------------------------------------------------
Start:
	clrscr
	newline
	SetTextAttr Yellow
    outstrln 'Введите от 1 до 20 слов:'
	SetTextAttr
	xor 	edi, edi
Vvod:
	cmp 	edi, 20
	jge		Err
	xor 	esi, esi
	xor 	eax, eax
L1:
	inchar X
	cmp 	X, '.'
	je 		End_Vvod
	cmp 	X, ','
	je 		End_Word
	cmp		esi, 8
	jge		Wrong_num_char
	cmp 	X, 'A'
	jl 		Wrong_char
	cmp 	X, 'Z'
	jg 		Wrong_char
	mov 	al, X
	mov 	Y[esi], al
	inc 	esi
	jmp 	L1

End_Word:
	dec 	esi
	inc		edi
	mov 	Num_char, esi
	mov		Index_w, edi
	invoke  InList,offset List, Y
	jmp 	Vvod

End_Vvod:
	cmp esi, 0
	je Wrong_num_char
	dec 	esi
	inc		edi
	mov 	Num_char, esi
	mov		Index_w, edi
	invoke  InList,offset List, Y
	newline
	SetTextAttr Yellow
	outstrln 'Заполнили список:'
	SetTextAttr
	invoke  OutList,List
	newline
	invoke 	SortList,List,offset List1
	SetTextAttr Yellow
	outstrln 'А. Внутреннее представление последовательности слов:'
	outstrln '7) Список слов, упорядоченных по алфавиту.'
	SetTextAttr
	invoke  OutList,List1
	newline
	SetTextAttr Yellow
	outstrln 'В. Дополнительная информация о слове:'
	outstrln '2) Порядковый номер слова в последовательности.'
	SetTextAttr
	invoke  OutList2,List
	newline
	SetTextAttr Yellow
	outstrln 'Б. Какие слова и в каком порядке печатать:'
	outstrln '12)Все слова, входящие в последовательность только один раз.'
	SetTextAttr
	invoke  OutList3,List
	newline
	SetTextAttr Yellow
	outstrln 'Удаляем последовательность:'
	invoke  DeleteList,offset List
	invoke  DeleteList,offset List1
	SetTextAttr
	outstrln 'проверяем, что список пуст...'
	invoke  OutList,List
	newline
KOH:
MsgBox "  Конец задачи", \
    <"Попробуем",13,10,"ещё раз ?">, \
    MB_YESNO+MB_ICONQUESTION
    cmp  	eax,IDYES
    je   	Start
End_program:
    exit
    end Start
