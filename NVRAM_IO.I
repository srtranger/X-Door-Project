;---------------------------------------------------------------
; Модуль для чтения/записи NVRAM 24C16
;---------------------------------------------------------------
rWP:            reg     P1.0     ; запрет записи в NVRAM                  (+)
SCL:            reg     P1.1     ; такты для NVRAM
SDA:            reg     P1.2     ; данные NVRAM

NCards:         equ     0F0h

NV_Var:         equ     0F1h     ; область в NVRAM переменных
                                 ; текущей конфигурации
T_Jack:         equ     0F1h     ; режим Jack
T_Camera:       equ     0F2h     ; управление Camera'ой
T_Alarm:        equ     0F3h     ; Время полного цикла тревоги
T_DomeLight:    equ     0F4h     ; Режима DomeLight
T_Door1:        equ     0F5h     ; Время импульса на замки
T_Out2:         equ     0F6h     ; Время импульса на выходе Out2


T_Jack_preset:         equ     0F7h     ; режим Jack
T_Camera_preset:       equ     0F8h     ; управление Camera'ой
T_Alaem_preset:        equ     0F9h     ; Время полного цикла тревоги
T_DomeLight_preset:    equ     0FAh     ; Режима DomeLight
T_Door1_preset:        equ     0FBh     ; Время импульса на замки
T_Out2_preset:         equ     0FCh     ; Время импульса на выходе Out2






NV_State:       equ     0FFh     ; Состояние системы

;---------------------------------------------------------------
; Send START CONDITION
;---------------------------------------------------------------
send_start:
                setb SDA        ; SCL = 1, SDA = 1
                setb SCL
                nop
                clr SDA         ; SCL = 1, SDA = 0
                nop
                clr SCL         ; SCL = 0, SDA = 0
                nop
                ret
;---------------------------------------------------------------
; Send STOP CONDITION
;---------------------------------------------------------------
send_stop:
                clr SDA         ; SCL = 1, SDA = 0
                setb SCL
                nop
                setb SDA        ; SCL = 1, SDA = 1
                nop
                ret
;---------------------------------------------------------------
; Shift byte from A into NVRAM
; Return:
;        C = ACK
;---------------------------------------------------------------
PutByte:
                mov b,#8        ; Bit counter
l1$
                rlc A
                clr SCL
                nop
                mov SDA,C
                nop
                setb SCL
                djnz b,l1$
                nop
                clr SCL
                setb SDA
                nop
                setb SCL
                nop
                mov C,SDA
                nop
                clr SCL
                ret
;---------------------------------------------------------------
; Shift byte from NVRAM into A
; Return:
;        C = ACK
;---------------------------------------------------------------
GetByte:
                mov b,#8        ; Bit counter
                setb SDA
l1$
                setb SCL
                nop
                mov C,SDA
                nop
                clr SCL
                nop
                rlc A
                djnz b,l1$
                setb SDA
                setb SCL
                nop
                mov C,SDA
                clr SCL
                nop
                ret
;---------------------------------------------------------------
; Write byte from A into NVRAM. Address: DPTR
;---------------------------------------------------------------
WriteByte:
                push ACC
                call send_start
                mov A,dph
                rl A
                anl A,#0Eh
                orl A,#0A0h
                call PutByte
                mov A,dpl
                call PutByte
                pop ACC
                call PutByte
                call send_stop
                mov A,#5        ; Delay on 5 ms
                call Delay      ;
                ret
;---------------------------------------------------------------
; Read byte from NVRAM into A. Address: DPTR
;---------------------------------------------------------------
ReadByte:
                call send_start
                mov A,dph
                rl A
                anl A,#0Eh
                orl A,#0A0h
                call PutByte
                mov A,dpl
                call PutByte
                call send_start
                mov A,dph
                rl A
                anl A,#0Eh
                orl A,#0A1h
                call PutByte
                call GetByte
                call send_stop
                ret
;---------------------------------------------------------------
; Delay A ms
;---------------------------------------------------------------
Delay:
                push    acc     ; 2 мкс
                mov     a,#240  ; 1 мкс
                djnz acc,$      ; 2 мкс
                djnz acc,$      ; 2 мкс
                pop     acc     ; 2 мкс
                djnz acc,Delay  ; 2 мкс
                ret             ; 2 мкс
;---------------------------------------------------------------



