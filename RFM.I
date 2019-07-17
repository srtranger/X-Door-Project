;               Module RFM provide to Read transponder
;               Мoдуль обеспечения чтения карточек
;
;

;===================================================================
;  Читает карточку.
;  Устанавливает бит crc_ok, если карточка прочитана успешно
;  иначе он неопределён

ReadCard:
                clr     rled_r
                clr     rled_g
                Power    On
                pause   10
                clr     TXCT            ; начало импульса накачки
                call    start_t0_50ms   ; ──┐<- 50 мс ->┌──
                jnb     TF0,$           ;   └───────────┘
                setb    TXCT            ; конец импульса накачки
                pause   1
                call    start_t0_19ms

rx0:
                jnb     RXDT,rx1        ; ожидание старт-байта
                jnb     TF0,rx0
                jbc     TF0,rx_end
rx1:
                mov     r0,#0           ; R0 - счетчик битов
rx2:
                call    RXCK_front
                jbc     TF0,rx_end
                jb      RXDT,rx0
                inc     r0
                cjne    r0,#6,rx2       ; кол-во "1" старт-битов
                call    RXCK_front
                jbc     TF0,rx_end
                jnb     RXDT,rx0
                ;-------------------------------;Цикл чтения данных
                mov     bcc,#0                  ; Обнуление BCC
                mov     bcc+1,#0                ;
                mov     r0,#0                   ; R0 - счетчик битов
                mov     r1,#data_buffer-1       ; R1 - указатель
rx3:
                call    RXCK_front              ;
                jbc     TF0,rx_end              ;
                call    store_rxdt              ;
                call    gen_bcc                 ;
                inc     r0                      ;
                cjne    r0,#80,rx4              ;
                mov     a,bcc                   ; Конец чтения
                cjne    a,#0,rx_end             ; если BCC<>0
                mov     a,bcc+1                 ;
                cjne    a,#0,rx_end             ;
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
                call    start_t0_50ms
                jnb     TF0,$
                Power    Off
                setb    rled_r
                clr     rled_g
                ret
rx_end:
                clr     TR0
                call    start_t0_50ms
                jnb     TF0,$
                Power    Off
                setb    rled_g
                clr     rled_r
                ret


;---------------------------------------------------------
RXCK_front:
        ; Процедура ожидания фронта RXCK
        ; Проверяет таймер, при окончании времени возвращает
        ; установленный CY
                jnb     RXCK,RXCKf1
                jnb     TF0,RXCK_front
                jmp     RXCKf2
RXCKf1:
                jb      RXCK,RXCKf2
                jnb     TF0,RXCKf1
RXCKf2:
;               mov     c,TF0
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

