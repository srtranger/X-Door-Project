;--------------------------------------------------------
On:             equ     1
Off:            equ     0
open:           equ     0
close:          equ     1
waitkey_time:   equ     5        ; время, отведенное для ввода номера команды
red:            equ     1
green:          equ     2



door1:          reg     P0.0     ; вход датчика первой зоны (двери)       (-)
door2:          reg     P0.1     ; вход датчика второй зоны (двери)       (-)
powertest:      reg     P0.2     ; вход "тест напряжения питания"         (-)
input:          reg     P0.3     ; дополнительный вход                    (-)
Fkey:           reg     P0.4     ; кнопка "Valet"                         (-)
ropen:          reg     P0.5     ; команда открыть дверь                  (-)
rclose:         reg     P0.6     ; команда закрыть дверь                  (-)
rzone:          reg     P0.7     ; выбор зоны (0 или 1)                   (-)


TXCT:           reg     P1.3     ; выход управления передатчиком RFM
RXDT:           reg     P1.4     ; вход данных от приёмника RFM
RXCK:           reg     P1.5     ; вход синхроимпульсов от приёмника RFM
rpoweron:       reg     P1.6     ; включение питания RFM и NVRAM          (-)
rout2:          reg     P1.7     ; дополнительный выход-2                 (+)

resen:          reg     P2.0      ; выход разрешения сброса от датчика     (+)
rWDI:           reg     P2.1      ; выход сброс сторожевого таймера        (+)
rantcom:        reg     P2.2      ; переключение антен с зоны на зону
rlamp:          reg     P2.3      ; включение освещения перед дверью       (-)
rbell:          reg     P2.4      ; включение дверного входного звонка     (-)
rspeaker:       reg     P2.5      ; встроенная пищалка                     (+)
rled_g:         reg     P2.6      ; зелёный светодиод                      (+)
rled_r:         reg     P2.7      ; красный светодиод                      (+)

rcamera:        reg     P3.0      ; выход включения камеры                 (-)
rout1:          reg     P3.1      ; дополнительный выход-1                 (+)
start:          reg     P3.2      ; вход прерывания от дптчика "старт"     (-)          (-)
PFO:            reg     P3.3      ; вход прерывания от АККУМУЛЯТОРА        (-)
rsiren:         reg     P3.4      ; выход включения сирены                 (-)
jamp1:          reg     P3.5      ; вход джампрера-1                       (-)
jamp2:          reg     P3.6      ; вход джампрера-2                       (-)
jamp3:          reg     P3.7      ; вход джампрера-3                       (-)

ET2:            reg     IE.5      ;
;T2CON:          reg     0C8h
;T2MOD:          reg     0C9h

;                        <БИТОВЫЕ ФЛАГИ>
flaggs:         reg     23h             ; Флаги
state:          reg     24h             ; флаги режимов
time:           reg     25h             ; флаги временных уставок (таймера)
;---------------------------------------------------------------------------
;                       Разбивка битовых флагов
crc_ok          reg     flaggs.0        ; код принят
stored_rxdt     reg     flaggs.1        ; принятый бит RXDT
Short_close     reg     flaggs.2        ; авто-замок 0.5 сек
Enter_state     reg     flaggs.3        ; флаг разрешения проц. откр. дверей
ind_bit         reg     flaggs.4        ; бит индикации

armed           reg     state.0         ; режим охраны 1 -активный
hold            reg     state.1         ; режим "защёлка" 1 -активный
save_bit        reg     state.2         ; режим энергосбережения
Lamp_bit        reg     state.3         ; освещение вкл/выкл.1 -активный
Chirp_bit       reg     state.4         ; сирена вкл/выкл.1 -активный
T_Jack_Define   reg     state.5         ; режим High_Jack 1 -активный
Camera_bit      reg     state.6         ; камера вкл/выкл.1 -активный

key_time:       reg     time.0          ; вкл. счётчика времени для Input(ввода комманд)
;-------------------------------------------------------------------------
;               Переменные - времена и временные уставки
ms:             reg     30h             ;-----\
secund:         reg     31h             ;----- ------ часы (переменные)
minute:         reg     32h             ;-----/
time_of_key:    reg     33h             ; счётчик секунд для Input
ms_of_lamp:     reg     34h             ; сч. ms  для DomeLight
sec_of_lamp:    reg     35h             ; сч. sec для DomeLight
min_of_lamp:    reg     36h             ; сч. min для DomeLight
ms_of_TJack:    reg     37h
sec_of_TJack:   reg     38h
min_of_TJack:   reg     39h
ms_of_camera:   reg     3Ah
sec_of_camera:  reg     3Bh
min_of_camera:  reg     3Ch

CountFkey:      reg     3Dh             ; кол-во нажатий на Fkey
T_Dome:         reg     3Eh             ; время подсвета при ручном наж.
T_Camera_on:    reg     3Fh
alarm_time:     reg     40h             ; Время полного цикла тревоги
Number_of_TJack: reg    41h            ; счетчик сработок датчика
T_Jack_Counter: reg     42h

;-------------------------------------------------------------------------
;               Переменные обмена с RFM

data_buffer:    reg     50h             ; Буфер приема:
rec_data:       reg     data_buffer     ; принятые данные
rec_bcc:        reg     rec_data+8      ; принятые BCC
rec_stop:       reg     rec_bcc+2       ; принятый стоп-байт
rec_end:        reg     rec_stop+1      ; принятые end-биты
bcc:            reg     rec_end+2





;-------------------------------------------------------------------




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
                        ljmp   Tick_50ms

                        org   0023h     ; прерывания от RS-232 R1 и T1
                        reti

                        org   002Bh     ; прерывания от T2
                        reti


;-------------------------------------------------------------------------
                        org   30h

begin:
                call    Init
                ljmp    PassiveState
;=========================================================================
;                         Пассивный цикл
;-------------------------------------------------------------------------
PassiveState:
Ps1:
                jnb     Fkey,ScanKey_P
Ps4:            jnb     powertest,Go_SaveEnergie_Loop
                jb      Enter_state,Go_DoorOpen_P
Ps3             jb      hold,Break_hold_P
Ps2:            jb      Lamp_bit,Control_Lamp
Ps5:            jb      Chirp_bit,Go_Chirp_P
Ps6:            jb      Camera_bit,Go_test_camera_P
Ps7:            nop
                jmp     PassiveState
Go_test_camera_P
                call    Camera_Off_time
                jmp     Ps7
;---------------------------------------------------------
Go_Chirp_P:
                call    Chirp_proc
                jmp     Ps6
;---------------------------------------------------------
Control_Lamp:
                call    Lamp_Off_time
                jmp     Ps5
;-------------------------------------------------------------------
Go_SaveEnergie_Loop:
                ljmp    SaveEnergie_Loop

;---------------------------------------------------
Break_hold_P:
                jnb     door1,exit$
                clr     rled_g
                clr     rled_r
                clr     hold
                Speaker  On
                call    halfsec
                Speaker  Off
                jmp     Ps2

exit$           jmp     Ps2
;-------------------------------------------------------------------
Go_DoorOpen_P:
                call    DoorOpen
                jmp     Ps3

;-------------------------------------------------------------------
ScanKey_P:
                mov     r4,#5                 ; кол-во ожидаемых нажатий + 1
                mov     time_of_key,#0        ; обнулить счётчик времени
                setb    key_time              ; запуск таймера на счёт
                call    Input                 ; (4)
                clr     key_time

                mov     a,CountFkey           ; Режим "ПРОГРАММИРОВАНИЯ"
                cjne    a,#4,Sc1$
                jmp     Programming_

Sc1$
                mov     a,CountFkey             ; Сирена On/Off
                cjne    a,#3,Sc2$
                jmp     Chirp_P
Sc2$
                mov     a,CountFkey
                cjne    a,#2,Sc3$
                jmp     HoldDoor_P              ; Ржим "ЗАЩЁЛКА" On/Off
Sc3$
                mov     a,CountFkey             ; Переход в Режим  (On/Off)
                cjne    a,#1,Ps1
                jmp     Go_ArmedState_P         ;    "ОХРАНА"

;-------------------------------------------------------------------

HoldDoor_P:
                call    Hold
                jmp     Ps4
;----------------принудительный ---- Вкл/Откл. сирены -----------------
Chirp_P:
                clr     EX0
                Siren   On

loop$           cpl     rWDI
                jnb     Fkey,loop$

exit$           Siren   Off
                call    onesec
wait_loop$      cpl     rWDI
                jnb     start,wait_loop$
                call    onesec
                clr     IE0
                setb    EX0
                jmp     Ps4







;=========================================================================
