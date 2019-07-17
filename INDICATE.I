Indicate:
           jnb      Hold,normal$
           jb       Armed,redled_on1$
           mov      C,Indicate_bit1
           mov      rled_g,C
           RedLed   Off
           jmp      next1$
redled_on1$
           mov      C,Indicate_bit1
           mov      rled_r,C
           GreenLed Off
           jmp      next1$
;-------------
normal$
           jb       Armed,redled_on$
           mov      C,Indicate_bit
           mov      rled_g,C
           RedLed   Off
           jmp      next1$
redled_on$
           mov      C,Indicate_bit
           mov      rled_r,C
           GreenLed Off
next1$
           ret
;------------------------------------------------------------------------
Begin_ind_mode
           mov      r6,#6
loop$
           RedLed   Off
           GreenLed On
           pause    250
           GreenLed Off
           RedLed   On
           pause    250
           djnz     r6,loop$
           GreenLed Off
           RedLed   Off
           ret
;------------------------
Ind_Programming:
           RedLed   On
           GreenLed On
           Speaker  On
           call   onesec
           Speaker  Off
           RedLed   Off
           GreenLed Off
           ret
;------------------------
Ind_Learning:
           RedLed   On
           GreenLed On
           mov    r6,#3
loop$
           Speaker  On
           call   onesec
           Speaker  Off
           call   onesec
           djnz   r6,loop$
           RedLed   Off
           GreenLed Off
           ret
;  -------------------------  ПРОМПТЫ ----------------------------
;   Prompt_Learn     высчитывает кол-во индикационных импульсов по r6
;                    по формуле  N= (MaxNCard-r6)+1
;
;

Prompt_Learn:

           clr      c
           mov      a,r4
           subb     a,r6
           inc      a
           mov      r1,a

loop$
           Speaker  On
           GreenLed On
           pause    250
           pause    250
           Speaker  Off
           GreenLed Off
           pause    250
           pause    250
           djnz     r1,loop$

           ret
;-------------------------------------------------------------------------
; Prompt_Programm       высчитывает кол-во индикационных импульсов по r6
;                       по формуле  N=(7-r6)+1

Prompt_Programm:
           push     a
           clr      c
           mov      a,#7
           subb     a,r6
           inc      a
           mov      r5,a
loop$
           Speaker  On
           GreenLed On
           pause    250
           pause    250
           Speaker  Off
           GreenLed Off
           pause    250
           pause    250
           djnz     r5,loop$
           pop      a

           ret
;-------------------------------------------------------------------------

