;               Module RFM provide to Read transponder
;
;===================================================================
;  Читает карточку.
;  Устанавливает бит crc_ok, если карточка прочитана успешно
;  иначе он неопределён
;-------------------------------------------------------------------------
ReadCard:
                Power   On
                pause   20
                call    Charge                  ; выдать импульс накачки
                call    Read
                Power   Off
                ret
;-------------------------------------------------------------------------
Read:
                call    start_t0_1ms
                jbc     TF0,$
                call    Wait_for_start_byte
                jc      time_out$
                call    Store_and_BCC
                jmp     exit$
time_out$       clr     crc_ok
exit$
                ret
;-------------------------------------------------------------------------
Wait_for_start_byte:
                call    start_t0_19ms
wait_first$
                jnb     RXDT,processed$
                jbc     TF0,time_out$
                jmp     wait_first$
processed$
                mov     r0,#0
rx_front$
                call    RXCK_front
                jbc     TF0,time_out$
                jb      RXDT,wait_first$
                inc     r0
                cjne    r0,#6,rx_front$       ; кол-во "1" старт-битов
                call    RXCK_front
                jbc     TF0,time_out$
                jb      RXDT,ok$
time_out$
                setb    C
                ret
ok$
                clr     C
exit$
                ret
;-------------------------------------------------------------------------
Store_and_BCC:
                mov     bcc,#0                  ; Обнуление BCC
                mov     bcc+1,#0                ;
                mov     r0,#0                   ; R0 - счетчик битов
                mov     r1,#data_buffer-1       ; R1 - указатель
rx3:
                call    RXCK_front
                jbc     TF0,rx_end
                call    store_rxdt              ;
                call    gen_bcc
                inc     r0                      ;
                cjne    r0,#80,rx4              ;
                mov     a,bcc                   ; Конец чтения
                cjne    a,#0,rx_end             ; если BCC<>0
                mov     a,bcc+1                 ;
                cjne    a,#0,rx_end
                           ;
rx4:
                cjne    r0,#104,rx3     ;-------;Конец цикла чтения


                mov     a,rec_stop      ;
                cjne    a,#7Eh,rx_end   ; проверка STOP=7Eh
                mov     a,rec_end       ;
                jnz     rx_end          ; проверка END=0000h
                mov     a,rec_end+1     ;
                jnz     rx_end          ;
                clr     TR0
                setb    crc_ok          ; код принят!
                clr     TR0
                ret
rx_end:
                clr     TR0
                clr     crc_ok
                ret
;-------------------------------------------------------------------------
Charge:
                clr     TXCT            ; начало импульса накачки
                call    start_t0_50ms   ; ──┐<- 69 мс ->┌──
                jnb     TF0,$           ;   └───────────┘
                call    start_t0_19ms   ;
                jnb     TF0,$
                setb    TXCT
                ret
;-------------------------------------------------------------------------
RXCK_front:
wait$           jnb     RXCK,processed$
                jb      TF0,exit$
                jmp     wait$
processed$
                jb      RXCK,exit$
                jb      TF0,exit$
                jmp     processed$
exit$

                ret
;----------------------------------------------------------------
store_rxdt:
        ; Процедура сохранения принятого бита в текущей позиции
        ; приема.  R0 - счетчик битов, R1 - указатель байта
                mov     a,r0
                anl     a,#7
                jnz     store_rxdt_0
                inc     r1
store_rxdt_0:
                mov     a,@r1
                mov     c,RXDT
                cpl     c               ; Инверсия принятого бита
                mov     stored_rxdt,c
                rrc     a
                mov     @r1,a
                ret
;----------------------------------------------------------------
gen_bcc:
        ; Подпрограмма генерации Block Check Characters
                mov     a,bcc+1
                mov     c,stored_rxdt
                rrc     a               ; Сдвиг вправо ст.б. BCC
                mov     bcc+1,a
                mov     a,bcc
                rrc     a               ; Сдвиг вправо мл.б. BCC
                mov     bcc,a
                jnc     gen_bcc_1
                xrl     bcc+1,#80h      ; Инверсия BCC.15
gen_bcc_1:
                mov     a,bcc+1
                jnb     acc.7,gen_bcc_2
                xrl     bcc+1,#04h      ; Инверсия BCC.10
                xrl     bcc,#08h        ; Инверсия BCC.3
gen_bcc_2:
                ret
;----------------------------------------------------------------

Clear_Bufer:
                mov     r7,#13
                mov     r0,#data_buffer
                clr     a
loop$
                mov     @r0,a
                djnz    r7,loop$
                inc     r0
                ret

