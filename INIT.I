;                       X-DOOR  version 02.
;                       Initialization module
;                       19/10/99
;

;----------------------------------------------------------------
Init:
                clr     EA       ;  All interrupt searce disable
                setb RXDT        ;  Deactivate it's signals
                setb TXCT
                Antene   0       ;  Switch to 1-st antena
                GreenLed Off     ;  turn off both led ( green and red)
                RedLed   Off
                Speaker  Off     ;  Inboard speaker is turned off

                call  Timer1_Init
                call  Timer2_Init
                call  Variable_Init
;                call  PresetLoad  ; !!!!!!!!!! перетащить потом в нужное место.
                setb  EA
                ret
;------------------------------------------------------------------------

        ;Настройка таймера T0 & T1      ; режим 1 16-бит таймер
Timer1_Init:
                mov     IE,#0
                clr     TR0
                mov     TMOD,#00010001b
                setb    IT0             ; INT0 - от фронта
                setb    EX0             ; разрешить INT0
                ret


Timer2_Init:
                mov     T2MOD,#00000000b
                mov     T2CON,#00000000b
                mov     RCAP2L,#<(65535-50000) ; 50ms
                mov     RCAP2H,#>(65535-50000) ; период
                mov     TL2,#<(65535-50000)    ; с автоперезагрузкой
                mov     TH2,#>(65535-50000)
                setb    TR2
                setb    ET2
                clr     TF2
                ret
;------------------------------------------------------------------------

Variable_Init:
                mov   20h,#0
                mov   21h,#0
                mov   22h,#0
                mov   23h,#0

                mov   ms,#0
                mov   secund,#0
                mov   minute,#0
                mov   num_key,#0

                ret
;-------------------------------------------------------------------------
;           Load presets  variables value from programm memory to NVRAM
;

PresetLoad:

                mov     dptr,#NumVar        ; получить общее кол-во
                clr     a                   ; переменных
                movc    a,@a+dptr           ; в системе
                mov     r6,a                ; сохранить в r6
                mov     dptr,#TablePreset
                xrl     WMCON,#DPS
                mov     dptr,#VarPreset
loop$
                xrl     WMCON,#DPS
                clr     a
                movc    a,@a+dptr
                inc     dptr
                xrl     WMCON,#DPS
                call    NVWriteByte
                inc     dptr
                djnz    r6,loop$
                xrl     WMCON,#DPS

                ret
;----------------------------------------------------------------
