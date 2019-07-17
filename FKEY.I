;                       X-DOOR  version 02.
;                       Fkey service module
;                       19/10/99
;
;------------------------------------------------------------------------
Wait_Fkey:
                jb      Fkey,exit_clr$   ; ожидание нажатия (спадающего фронта)
                pause   10               ; антидребезговая задержка 5ms
                jb      Fkey,exit_clr$   ; проверить после задержки
                Speaker On
                jnb     Fkey,$
                pause   10
                jnb     Fkey,exit_clr$
                Speaker Off
                setb    C
                jmp     exit$
exit_clr$
                clr     C
exit$
                ret
;-------------------------------------------------------------------------
;       Процедура подсчитывает N нажатий кнопки Fkey.
;       N - граничное число нажатий = 3    N= 0,1,2,3.
;       на выходе в A - число нажатий Fkey до нажатия Enter_key или 0
;       если Enter_key была нажата до нажатий
WaitPressN_Fkey:

               clr     a
               mov     r3,#3
loop$
               clr     c
               call    Wait_Fkey
               jc      ok$
               jnb     Enter_key,exit$
               jmp     loop$
ok$
               inc     a
               djnz    r3,loop$
exit$
               ret
