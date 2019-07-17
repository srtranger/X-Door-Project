;      Routines of this module provide open the doorlock in a few type of it.
;     _LockType_ variable save the type of doorlock in the NV_RAM
;     _LockType_ must be set to:
;
;     1 - замок-защёлка (время импульса 3   сек.)
;     2 - замок-защёлка (время импульса 5   сек.)
;     3 - полный замок  (время импульса 3   сек.)
;     4 - полный замок  (время импульса 7   сек.)
;-------------------------------------------------------------------------
DoorOpen:
                    clr   EX0
                    jb    Hold,exit$          ; выход, если на защёлке
                    jb    door1,exit$         ; выход, если дверь уже открыта
                    call  TestDomeLight       ; процедурка проверки упр. освещением.
                    jnb   Start_LampTimer,next_t1$
                    call  DomeLightCommand
next_t1$
                    mov   dptr,#LockType
                    call  NVReadByte

                    cjne  a,#1,next1$
                    call  Half_OpenCommand
                    jmp   exit$
next1$
                    cjne  a,#2,next2$
                    call  Half_OpenCommand
                    jmp   exit$
next2$
                    cjne  a,#3,next3$
                    call  Full_OpenCommand
                    jmp   exit$
next3$
                    cjne  a,#4,exit$
                    call  Full_OpenCommand
exit$
                    clr   Enter_state
                    jnb   start,$
                    clr   IE0
                    setb  EX0
                    ret
;-------------------------------------------------------------------------
Half_OpenCommand:
                clr     ropen                   ; команда откр.
                setb    rclose
                cjne    a,#1,half1$
                mov     r5,#3                   ; 3 сек.
                jmp     W_time1$
half1$
                mov     r5,#5                   ; 5 сек.
W_time1$
                jb      door1,endcomand_open$
                call    onesec                  ; держать команду не более
                jb      door1,endcomand_open$   ; 5 сек.
                djnz    r5,W_time1$
endcomand_open$                                 ; иначе снять команду откр.
                setb    ropen
                setb    rclose
W_loop1$
                call    onesec                  ; задержка на вход
                jnb     door1,exit$             ; дверь закрыта - выход
                Speaker On                      ; пищать
                pause   50
                Speaker Off
                jmp     W_loop1$                ; ждать пока не закрыта

exit$
                ret
;-------------------------------------------------------------------------
Full_OpenCommand:
                clr     ropen                   ; команда откр.
                setb    rclose                  ;
                push    a
                cjne    a,#3,full1$
                mov     r5,#3
                jmp     W_time1$
full1$
                mov     r5,#7                   ; 5 сек.
W_time1$
                jb      door1,endcomand_open$
                call    onesec                  ; держать команду не более
                jb      door1,endcomand_open$   ; 5 сек.
                djnz    r5,W_time1$
endcomand_open$
                setb    ropen                   ; снять команду откр.
                setb    rclose

                mov     r5,#5
WaitOpen$
                jb      door1,Wait_Close$       ; ждать 5 сек. пока не откр.
                call    onesec
                jb      door1,Wait_Close$
                djnz    r5,WaitOpen$
                jmp     Close_door$             ; если не откр. - дать ком. закрыть
Wait_Close$
                call    onesec                  ; ждать пока не закр и пищать.
                jnb     door1,Close_door$       ; дверь закрыта
                Speaker On                      ; пищать
                pause   50
                Speaker Off
                jb      door1,Wait_Close$
Close_door$
                call    onesec
                setb    ropen                   ; дать команду закр.
                clr     rclose
                pop     a
                cjne    a,#3,full2$
                mov     r5,#3
                jmp     W_time2$
full2$
                mov     r5,#7                   ; 7 сек.
W_time2$
                call    onesec                  ; держать команду не более
                djnz    r5,W_time2$
endcomand_close$
                setb    ropen                   ; снять команду закр.
                setb    rclose

                ret
;-------------------------------------------------------------------------
TestDomeLight:
               jb      Start_LampTimer,exit$
               mov     dptr,#LigtSens       ; получить наличие датчика освещ.
               call    NVReadByte
               cjne    a,#1,test_T_dome$    ; если датчика нет - проверить T_DomeLight
               jnb     LigtSensor,Lamp_On$  ; активный - низкий. Команда вкл. свет
test_T_dome$
               mov     dptr,#T_DomeLight
               call    NVReadByte

               cjne    a,#1,Lamp_On$        ;
               jmp     reset$               ; 1 - свет не включать.

Lamp_On$
               mov     dptr,#T_DomeLight
               call    NVReadByte
               cjne    a,#2,next$
               mov     DomeLigtTimer,#1     ; зарядить таймер на 1 мин.
               jmp     set$
next$
               cjne    a,#3,next1$
               mov     DomeLigtTimer,#2     ; зарядить таймер на 2 мин.
               jmp     set$
next1$
               cjne    a,#4,reset$
               mov     DomeLigtTimer,#5     ; зарядить таймер на 5 мин.
set$
               mov     secund,#0
               setb    Start_LampTimer
               jmp     exit$

reset$
               clr     Start_LampTimer
               mov     DomeLigtTimer,#0
exit$
               ret
