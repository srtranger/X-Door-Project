;                       X-DOOR  version 02.
;                       Interrupt service module
;                       19/10/99
;------------------------------------------------------------------------
;
;               Interrupt service routine for T2 timer
;
;               Serve the _Fkey_ button and time period long as 1 hour-
;                                                       -(system CLOCK).
;
Tick_50ms:
                push    a
                push    PSW
                push    b
                push    dptr
                push    00h
                push    01h
                push    02h
                push    03h
                push    04h
                push    05h
                push    06h
                push    07h



                inc     Fkey_timer            ; increment wotch timer for Fkey
;----------------------------------------------
                inc     ms                    ;
                cpl     Indicate_bit1
                mov     a,ms                  ;
                cjne    a,#20,next_timer$     ;
                mov     ms,#0                 ;
                inc     secund                ;
                cpl     Indicate_bit

                jnb     Start_AlarmTimer,t4$
                mov     a,AlarmTimer
                cjne    a,#0,dcr4$
                clr     Alarm
                clr     Start_AlarmTimer
                jmp     t4$
dcr4$
                dec     AlarmTimer
t4$
                mov     a,secund              ;           CLOCK
                cjne    a,#60,next_timer$     ;
                mov     secund,#0             ;
                inc     minute                ;

                jnb     Start_LampTimer,t1$
                mov     a,DomeLigtTimer
                cjne    a,#0,dcr1$
                clr     Start_LampTimer
                jmp     t1$
dcr1$
                dec     DomeLigtTimer
t1$
                jnb     Start_VisioTimer,t2$
                mov     a,VisioTimer
                cjne    a,#0,dcr2$
                clr     Visio
                clr     Start_VisioTimer
                jmp     t2$
dcr2$
                dec     VisioTimer
t2$
                jnb     Start_PanicTimer,t3$
                mov     a,PanicTimer
                cjne    a,#0,dcr3$
                clr     Panic
                clr     Start_PanicTimer
                jmp     t3$
dcr3$
                dec     PanicTimer
t3$
                mov     a,minute              ;
                cjne    a,#60,next_timer$     ;
                mov     ms,#0                 ; fill 0 value after 1 hour
                mov     secund,#0             ;         overflow
                mov     minute,#0             ;
;---------------------------------------------;
next_timer$                                   ;
                jb      CommandReady,exit$    ; if Command is curently redy, then ignore Wait_Fkey
                call    Wait_Fkey             ; otherwise Wait press Fkey
                jnc     test_key_timer$       ; if Fkey not pressed, then tests Fkey_timer
                mov     Fkey_timer,#0         ; if Fkey is curently pressed, then reset watch timer Fkey_timer and
                inc     num_key               ; increment number of presses a Fkey button
                mov     a,num_key             ; tests the num_key for maximum avaliable presses
                cjne    a,#5,exit$            ; if num_key is equel 5, then
                setb    CommandReady          ; set bit CommandReady and leave the num_key = 5
                jmp     exit$                 ; exit
test_key_timer$                               ;
                mov     a,num_key             ; In it's place verefy num_key
                jz      exit$                 ; if it is equel 0, then go to exit
                mov     a,Fkey_timer          ; otherwise tests the wotch timer Fkey_timer
                cjne    a,#15,exit$           ; if Fkey_timer is equel 15 tick period of this routine (15*50ms=0.75 sec.)
                setb    CommandReady          ; then seting bit CommandReady
exit$
                clr     TF2

                pop     07h
                pop     06h
                pop     05h
                pop     04h
                pop     03h
                pop     02h
                pop     01h
                pop     00h
                pop     dptr
                pop     b
                pop     PSW
                pop     a

                reti
;-------------------------------------------------------------------------
; прерывания INT0 от датчика
Sensor:
                clr     EA

                push    a
                push    PSW
                push    b
                push    dptr
                push    00h
                push    01h
                push    02h
                push    03h
                push    04h
                push    05h
                push    06h
                push    07h

                mov     r4,#30                ; 30 попыток прочитать чип-карту.
                clr     crc_ok                ; установить бит - код не принят
loop1$
                jb      crc_ok,ok_rec$        ; проверить принят ли код
                call    ReadCard
                djnz    r4,loop1$             ; читать 10 раз
                jnb     crc_ok,AntiHighJck$   ; проверить принят ли код
ok_rec$                                       ; код принят -
                clr     c
                call    CodeCompare           ; сравнить код с блоком в NVRAM
                jnc     AntiHighJck$          ; если не совпадает ни одна!
                setb    Enter_state           ; установить бит доступа
                Speaker On                    ;
                pause   20                    ; индицировать звуком
                Speaker Off                   ; что карточка прочитана
                jnb     start,$
                clr     IE0
                jmp     exit$
AntiHighJck$
                clr     Enter_state
                setb    HighJack
                jnb     start,$
                clr     IE0
exit$
                pop     07h
                pop     06h
                pop     05h
                pop     04h
                pop     03h
                pop     02h
                pop     01h
                pop     00h
                pop     dptr
                pop     b
                pop     PSW
                pop     a
                setb    EA
                reti



