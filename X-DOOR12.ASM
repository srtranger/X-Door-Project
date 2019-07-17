;-------------------------------------------------------------------


                       include define.i
                       include macroses.i      ; файл макроопределений



                        CODE

                        org   0
                        jmp   begin

                        org   0003h
                        ljmp   Sensor    ; прерывания INT0 от датчика

                        org   000Bh     ; прерывания от  T0
                        reti

                        org   0013h     ; прерывания от  INT1
                        reti

                        org   001Bh     ; прерывания от T1
                        reti

                        org   0023h     ; прерывания от RS-232 R1 и T1
                        reti

                        org   002Bh     ; прерывания от T2
                        ljmp  Tick_50ms
;-------------------------------------------------------------------------
                org   30h
;============================================================================
begin:
                clr     EA
                mov     sp,#060h
                call    Init
                jmp     MainLoop
;============================================================================
MainLoop:
                jnb     CommandReady,goone$
                call    UserCommand
goone$
                jb      powertest,go$
                ljmp    SaveEnergie_Loop
go$
                jnb     Armed,next_t1$     ; Цикл с Охраной
                call    AlarmTest          ; Проверить датчики охраны
                jb      Alarm,AlarmCommand
next_t1$
                jnb     Learn,next$
                call    LearnMode
next$           jnb     Enter_state,next1$
                call    DoorOpen
next1$
                call    DomeLightCommand
                call    VisioCommand
                call    PanicCommand
                call    Indicate
                jmp     MainLoop
;-------------------------------------------------------------------------
AlarmCommand:
                clr     EX0            ;
time_test$
                mov   a,AlarmTimer
                cjne  a,#0,siren_on$
                Siren  Off
                clr   Start_AlarmTimer
                clr   Alarm
                GreenLed Off
                RedLed   Off
                clr   IE0
                setb  EX0
                jmp   MainLoop
siren_on$
                Siren    On
                GreenLed Off
                RedLed   On
                jb    Fkey,time_test$
                clr   Alarm
                clr   Start_AlarmTimer
                GreenLed Off
                RedLed   Off
                clr   IE0
                setb  EX0
                jmp    MainLoop
;============================================================================
SaveEnergie_Loop:
                Speaker On
                RedLed  On
                jmp    SaveEnergie_Loop

;-------------------------------------------------------------------------

                include usercom.i
                include int.i
                include init.i
                include time.i
                include fkey.i
                include indicate.i
                include rfm1.i
                include nvram_52.i
                include dooropen.i
                include out_sign.i
                include alarm.i
                include learn.i
                include acc_con.i
;-------------------------------------------------------------------------
                        org     1F00h
; TablePreset: ----->
; 1) LockType:            ; тип и параметры замка
; 2) LigtSens:            ; наличие датчика освещённости
; 3) MainSensType:        ; тип основного датчика движения.
; 4) T_Alarm:             ; время основного цикла тревоги
; 5) T_DomeLight:         ; время работы лампы после закр. двери
; 6) T_Visio:             ; время работы системы видеонаблюдения в реж. "Обзор"
; 7) T_Panic:             ; время работы сирены в реж. "Паника"

; 8) NCards:              ; number of knowing cards


TablePreset:    DB      3,2,1,1,2,2,1 ; таблица переменных-функций по умолчанию
NumVar:         DB      7    ; общее кол-во переменных-функций в TablePreset
MaxNCard:       DB      10   ; максимальное кол-во чип-карт, которое может хранить система

;-------------------------------------------------------------------------

