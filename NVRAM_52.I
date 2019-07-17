CodeCompare:
                mov     dptr,#NCards     ; читать кол-во карточек, которым...

                call    NVReadByte       ; ... система обучена
                dec     a                ; кол-во -1 = r7
                mov     r7,a             ; сохранить кол-во - 1 в r7
                mov     r1,#data_buffer  ; в r1 - указатель на буфер приёма
                mov     r5,#0h           ; в r5 - текущий номер карточки
                                         ; начало таблицы карточек (смещение)
CardLoop$
                call    GetAdr           ; вычислить начальный
                                         ; адрес в NVRAM для r5
                mov     r4,#8            ; ожидается читать 8 байт из NVRAM
                                         ; 8 байт - длина кода карточки
loop$                              ; ЦИКЛ ЧТЕНИЯ ОЧЕРЕДНОЙ КАРТОЧКИ ИЗ NVRAM
                call    NVReadByte       ; читать байт из NVRAM
                mov     b,@r1            ; читать байт из буфера приёма кода
                cjne    a,b,bad$         ; сравнить коды, если не равны ....
                inc     r1               ; инкремент указателей, если
                inc     dptr             ; очередные байты идентичны
                djnz    r4,loop$         ; цикл, если не все байты перебраны
                setb    c                ; КОДЫ ОК - установлен флаг С
                mov     a,r5             ; в A - условный номер совпавшей
exit$                                    ; карточки
                ret                      ; ВОЗВРАТ

bad$                                     ; .... Проверить, все ли карточки
                mov     b,r7
                mov     a,r5
                cjne    a,b,card_inc$    ; перебраны?
card_inc$       jc      lowest$
                clr     c
                jmp     exit$            ; если да - на ВЫХОД со сброшенным
lowest$                                  ; флагом С . A - не определён
                inc     r5               ; если нет - взять очередной номер
                jmp     CardLoop$        ; карточки и повторить для неё сравнение
;-----------------------------------------------------------------------------
; Read byte from NVRAM into A. Address: DPTR
;---------------------------------------------------------------
NVReadByte:
                orl     WMCON,#EEMEN
                movx    a,@dptr
                xrl     WMCON,#EEMEN
                ret
;---------------------------------------------------------------
; Write byte from A into NVRAM. Address: DPTR
; Routine sets the Carry flag if write atempt is fail and clear C flag if Ok.
;---------------------------------------------------------------
NVWriteByte:
                orl     WMCON,#EEMEN
                orl     WMCON,#EEMWE
                mov     b,a
                movx    @dptr,a
                pause   10
                movx    a,@dptr
                cjne    a,b,write_error$
                xrl     WMCON,#EEMWE
                xrl     WMCON,#EEMEN
                clr     C
                jmp     exit$
write_error$
                setb    C
exit$
                ret

;--------------------------------------------
; сохраняет принятый код карточки, находящийся в буфере приёма, в NVRAM
; по адресу, определяемому условным номером карточки (r5).
; Начальный адрес определяется как Adr= r5*8 в процедуре GetAdr
CodeSave:
               mov      a,r4
               push     a
               call     GetAdr             ; dptr = начальный адрес текущей
               mov      r1,#data_buffer    ; карточки, r1 - указатель на
                                           ; буфер приёмника
               mov      r4,#8              ; кол-во сохраняемых байт
loop$                                      ; ЦИКЛ СОХРАНЕНИЯ КОДА В NVRAM
               mov      a,@r1              ; в А - текущий байт из буфера приёма
               call     NVWriteByte        ; записать байт в NVRAM
               inc      r1                 ; инкремент указатея буфера приёма
               inc      dptr               ; инкремент адреса в NVRAM
               djnz     r4,loop$           ; все байты кода карточки?
               pop      a
               mov      r4,a
               ret

;-----------------------------------------------------------------
;        коды карточек хранятся в NVRAM с 0000 адреса!
;        вычисление начального адреса для текущей карточки
;        её номер на входе в r5. На выходе - dptr = искомый адрес
;        Начало таблицы в NVRAM - *Adr=000h*

GetAdr:
               push     a               ;   Начальный адрес вычисляется
               push     b               ;
               mov      a,#08h          ;   по формуле
               mov      b,r5            ;   Adr= N*8,
               mul      ab              ;   где
               mov      dpl,a           ;   Adr - начальный aдрес карточки в
               mov      dph,b           ;   NVRAM
               pop      b               ;   N - условный номер карточки (r5)
               pop      a               ;   8 - константа
               ret

