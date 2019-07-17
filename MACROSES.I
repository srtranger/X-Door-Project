pause           macro   ms
                mov     r2,#ms
                call    r2x1ms
                endm
;---------------------------------
Power           macro   Pstate
                If      Pstate
                clr     rpoweron
                else
                setb    rpoweron
                endif
                endm
;---------------------------------
Door            macro   Doorstate
                if      Doorstate
                setb    ropen
                clr     rclose
                else
                setb    rclose
                clr     ropen
                endif
                endm
;---------------------------------
Zone            macro   Zstate     ; выбор зоны (0 или 1)
                if      Zstate
                clr     rzone
                else
                setb    rzone
                endif
                endm
;---------------------------------
Out2            macro   O2State
                if      O2State
                setb    rout2
                else
                clr     rout2
                endif
                endm
;---------------------------------
VOHR            macro   O1State
                if      O1State
                setb    rout1
                else
                clr     rout1
                endif
                endm
;---------------------------------
Camera          macro   Cstate         ; включение/отключение камеры
                if      Cstate
                clr     rcamera
                else
                setb    rcamera
                endif
                endm
;---------------------------------
Siren           macro   SrState        ; включение/отключение сирены                 (-)
                if      SrState
                clr     rsiren
                else
                setb    rsiren
                endif
                endm
;----------------------------------
Antene          macro   AntState   ; переключение антен с зоны на зону
                if      AntState
                setb    rantcom
                else
                clr     rantcom
                endif
                endm

;----------------------------------
Lamp            macro   LState    ; включение освещения перед дверью
                if      LState
                clr     rlamp
                else
                setb    rlamp
                endif
                endm
;----------------------------------
Bell            macro   BellState  ; включение/отключение дверного звонка
                if      BellState
                clr     rbell
                else
                setb    rbell
                endif
                endm
;----------------------------------
Speaker         macro   SpState     ; включение/отключение пищалки
                if      SpState
                setb    rspeaker
                else
                clr     rspeaker
                endif
                endm
;----------------------------------
GreenLed        macro   GLState    ; включение/отключение зел. светодиода
                if      GLState
                setb    rled_g
                else
                clr     rled_g
                endif
                endm
;----------------------------------
RedLed          macro   RLState    ; включение/отключение красн. светодиода
                if      RLState
                setb    rled_r
                else
                clr     rled_r
                endif
                endm
;--------------------------------------------------------------------------

