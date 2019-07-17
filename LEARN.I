;-------------------------------------------------------------------------
LearnMode:
                clr     EA
                mov     r6,#3                 ; 3 попытки прочитать чип-карту.
                clr     crc_ok                ; установить бит - код не принят
loop1$
                jb      crc_ok,ok_rec$        ; проверить принят ли код
                call    ReadCard              ; читать чип-карту.
                djnz    r6,loop1$             ; читать 3 разa
                jnb     crc_ok,not_entry$     ; проверить принят ли код
ok_rec$                                       ; код принят -
                clr     c
                call    CodeCompare           ; сравнить код с блоком в NVRAM
                jnc     not_entry$            ; если не совпадает ни одна!
                Speaker On                    ;
                pause   10                    ; индицировать звуком
                Speaker Off                   ; что карточка прочитана
                                              ; и совпадает с известной
                jb      door1,LearnMode$      ; если дверь открыта - "Обучение"
                call    Programming           ; иначе - "Программирование ф-ций"
                jmp     exit$
LearnMode$
                call    Learning
                jmp     exit$
not_entry$

                call    Bad_Password_ind
exit$
                clr     Learn
                jnb     start,$
                clr     IE0
                setb    EA
                ret
;-------------------------------------------------------------------------
Programming:
                call    Begin_ind_mode      ;
                call    Ind_Programming     ;
                call    onesec              ; задержка после нач. индикации
                call    onesec              ; задержка после нач. индикации

                mov     dptr,#NumVar        ; получить общее кол-во
                clr     a                   ; переменных
                movc    a,@a+dptr           ; в системе
                mov     r6,a                ; сохранить в r6
                mov     dptr,#VarPreset     ;
prog_loop$
                call    Prompt_Programm     ; на входе кол-во переменных
                call    WaitPressN_Fkey     ; возвращает в а= кол-во нажатий
                cjne    a,#0,goone$         ; если была нажата кнопка "ВВОД"
                call    PresetLoad          ; без предв. нажатий Fkey (a=0)
                mov     r6,#5
                jmp     exit_loop$          ; то загрузить переменные по умолчанию
goone$
                call    NVWriteByte         ; до откр. двери
                inc     dptr                ;
                pause   250
                pause   250
                djnz    r6,prog_loop$       ; взять след. переменную
exit$
                mov      r6,#3
exit_loop$
                Speaker  On
                GreenLed On
                RedLed   Off
                call     onesec
                Speaker  Off
                GreenLed Off
                RedLed   On
                call     onesec
                djnz     r6,exit_loop$
                GreenLed Off
                RedLed   Off

                ret


;-------------------------------------------------------------------------
Learning:
                call    Begin_ind_mode
                call    Ind_Learning
                call    onesec             ; задержка после нач. индикации
                call    onesec             ; задержка после нач. индикации

                mov     dptr,#MaxNCard     ; получить max кол-во чип-карт
                clr     a                  ; которые может хранить система
                movc    a,@a+dptr          ; в системе
                mov     r6,a               ; сохранить в r4 и r6
                mov     r4,a

                mov     r5,#0              ; N - начальный номер карточки=0
                mov     dptr,#Cards        ; Адрес в NVRAM таблицы карточек
loop$

                call    Prompt_Learn       ; запрос на ввод очередной карточки
                jb      Fkey,$
                cjne    r5,#0,tst_door$
                jmp     goone1$
tst_door$
                jnb     door1,leave$
goone1$
                mov     r3,#5              ; 5 попыток прочитать чип-карту.
                clr     crc_ok             ; установить бит - код не принят
loop1$
                jb      crc_ok,ok_rec$     ; проверить принят ли код
                call    ReadCard
                djnz    r3,loop1$          ; читать 10 раз
                jnb     crc_ok,BadRead$    ; проверить принят ли код
ok_rec$                                    ; код принят -
                call    CodeSave
                inc     r5
                pause   200
                djnz    r6,loop$
leave$
                mov     dptr,#NCards
                mov     a,r5
                call    NVWriteByte
                call   onesec
                call   onesec
ind_loop$
                Speaker  On
                GreenLed On
                pause    200
                Speaker  Off
                GreenLed Off
                pause    250
                pause    250
                pause    250
                djnz   r5,ind_loop$
                ret

BadRead$
                Speaker   On
                RedLed    On
                call   onesec
                call   onesec
                Speaker   Off
                RedLed    Off
                call   onesec
                call   onesec
                jmp   loop$
;-------------------------------------------------------------------------

Bad_Password_ind:
                RedLed   On
                GreenLed Off
                Speaker  On
                call  onesec
                call  onesec
                call  onesec
                RedLed   Off
                Speaker  Off
                ret
;-------------------------------------------------------------------------
