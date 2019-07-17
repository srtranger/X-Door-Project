                        CHIP 8052

;--------------------------------------------------------
On:             equ     1
Off:            equ     0
open:           equ     0
close:          equ     1
waitkey_time:   equ     5        ; время, отведенное для ввода номера команды
red:            equ     1
green:          equ     2



door1:          reg     P0.0     ; вход датчика двери                     (-)
IRsensor:       reg     P0.1     ; вход IR датчика перемещения            (-)
powertest:      reg     P0.2     ; вход "тест напряжения питания"         (-)
LigtSensor:     reg     P0.3     ; вход датчика наружной освещённости     (-)
Fkey:           reg     P0.4     ; кнопка управления Fkey                 (-)
ropen:          reg     P0.5     ; команда открыть дверь                  (-)
rclose:         reg     P0.6     ; команда закрыть дверь                  (-)
rzone:          reg     P0.7     ; выбор зоны (замка) (1-й или 2-й)       (-)

Enter_key:      reg     P1.2     ; кнопка "ВВОД"
TXCT:           reg     P1.3     ; выход управления передатчиком RFM
RXDT:           reg     P1.4     ; вход данных от приёмника RFM
RXCK:           reg     P1.0     ; вход синхроимпульсов от приёмника RFM
rpoweron:       reg     P1.1     ; включение питания RFM и NVRAM          (-)
rout2:          reg     P1.7     ; дополнительный выход                   (+)

; resen:          reg     P2.0     ; не использован                         (+)
; rWDI:           reg     P2.1     ; не использован                         (+)
rantcom:        reg     P2.2     ; переключение антен с зоны на зону
rlamp:          reg     P2.3     ; включение освещения перед дверью       (-)
rbell:          reg     P2.4     ; включение дверного входного звонка     (-)
rspeaker:       reg     P2.5     ; встроенная пищалка                     (+)
rled_g:         reg     P2.6     ; зелёный светодиод                      (+)
rled_r:         reg     P2.7     ; красный светодиод                      (+)

rcamera:        reg     P3.0     ; выход включения камеры                 (-)
rout1:          reg     P3.1     ; выход подключения к ВОХР               (+)
start:          reg     P3.2     ; вход прерывания от дптчика "старт"     (-)          (-)
PFO:            reg     P3.3     ; вход теста АККУМУЛЯТОРА                (+)
rsiren:         reg     P3.4     ; выход включения сирены                 (-)
jamp1:          reg     P3.5     ; вход джампрера-1                       (-)
jamp2:          reg     P3.6     ; вход джампрера-2                       (-)
jamp3:          reg     P3.7     ; вход джампрера-3                       (-)

;---------------------------------------------------------------------------
;                           SFR - registers
T2MOD:           reg  0C9h
ET2:             reg  IE.5
WMCON:           reg   96h
;----WMCON ------
WDTEN     EQU   00000001b ; watchdog start (enable) bit
WDTRST    EQU   00000010b ; watchdog reset bit
EEMWE     EQU   00010000b ; EEPROM write enable ORL mask
EEMWD     EQU   11101111b ; EEPROM write disable ANL mask
EEMEN     EQU   00001000b ; 1-Internal EEPROM Access enable
EEMDN     EQU   11110111b ; 0- Internal EEPROM Access disable
DPS       EQU   00000100b ; Data Pointer Select bit dps=0-dptr0; dps=1-dptr1
PS0       EQU   00100000b ; WatchDog time select bit0
PS1       EQU   01000000b ; WatchDog time select bit1
PS2       EQU   10000000b ; WatchDog time select bit2


;----------------------
;                        Битовые переменные.

command          reg    20h
CommandReady     reg    command.0
Hold             reg    command.1
Visio            reg    command.2
Panic            reg    command.3

;---------------------------------

state            reg    21h
Enter_state      reg    state.0
Armed            reg    state.1
Learn            reg    state.2
Alarm            reg    state.3

flags            reg    22h
stored_rxdt      reg    flags.0
crc_ok           reg    flags.1
HighJack         reg    flags.2

timers           reg    23h
Start_LampTimer  reg    timers.0
Start_VisioTimer reg    timers.1
Start_PanicTimer reg    timers.2
Start_AlarmTimer reg    timers.3
Indicate_bit     reg    timers.4
Indicate_bit1    reg    timers.5
;------------   Переменные обмена с RFM

data_buffer:    reg     30h             ; Буфер приема:
rec_data:       reg     data_buffer     ; принятые данные
rec_bcc:        reg     rec_data+8      ; принятые BCC
rec_stop:       reg     rec_bcc+2       ; принятый стоп-байт
rec_end:        reg     rec_stop+1      ; принятые end-биты
bcc:            reg     rec_end+2
;----------------------------------

time_variable:  reg     bcc+2
ms:             reg     time_variable
secund:         reg     ms+1
minute:         reg     secund+1
DomeLigtTimer:  reg     minute+1
PanicTimer:     reg     DomeLigtTimer+1
VisioTimer:     reg     PanicTimer+1
AlarmTimer:     reg     VisioTimer+1
num_key:        reg     AlarmTimer+1    ; number of presses Fkey button
Fkey_timer:     reg     num_key+1       ; wotch timer for Fkey.



;*************************************************************************
;           Переменные размещаемые в NVRAM
;
Cards:         EQU  0000h

VarPreset:     EQU  00F0h
LockType:      EQU  00F0h      ; тип и параметры замка
LigtSens:      EQU  00F1h      ; наличие датчика освещённости
MainSensType:  EQU  00F2h      ; тип основного микроволнового датчика движения.
T_Alarm:       EQU  00F3h      ; время основного цикла тревоги
T_DomeLight:   EQU  00F4h      ; время работы лампы после закр. двери
T_Visio:       EQU  00F5h      ; время работы системы видеонаблюдения в реж. "Обзор"
T_Panic:       EQU  00F6h      ; время работы сирены в реж. "Паника"

NCards:        EQU  00F7h      ; number of knowing cards

