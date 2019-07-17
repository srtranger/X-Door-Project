;-------------------------------------------------------------------------
DomeLightCommand:
          push  a
          mov   a,DomeLigtTimer
          cjne  a,#0,lamp_on$
          Lamp  Off
          clr   Start_LampTimer
          jmp   exit$
lamp_on$
          Lamp  On
exit$
          pop   a
          ret
;-------------------------------------------------------------------------
PanicCommand:
          jnb    Panic,off$
          Siren  On
          jmp    exit$
off$
          Siren  Off
exit$
          ret
;-------------------------------------------------------------------------
VisioCommand:
          push  a

          jb    Visio,test_start$
          jmp   reset$
test_start$
          jb    Start_VisioTimer,exit$
          mov   dptr,#T_Visio
          call  NVReadByte
          cjne  a,#1,tst1$
          jmp   reset$
tst1$
          cjne  a,#2,tst2$
          mov   VisioTimer,#2
          jmp   set$
tst2$
          cjne  a,#3,tst3$
          mov   VisioTimer,#5
          jmp   set$
tst3$
          cjne  a,#3,reset$
          mov   VisioTimer,#10
set$
          mov     secund,#0
          setb    Start_VisioTimer
          jmp     exit$
reset$
          mov     VisioTimer,#0
          clr     Start_VisioTimer
exit$
          mov   a,VisioTimer
          cjne  a,#0,cam_on$
          Camera  Off
          clr   Start_VisioTimer
          clr   Visio
          jmp   exit1$
cam_on$
          Camera  On
exit1$
          pop   a
          ret
;------------------------------------------------------------------------

