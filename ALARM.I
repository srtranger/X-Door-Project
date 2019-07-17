AlarmTest:
          jb    Start_AlarmTimer,exit$
          jnb   door1,next_sensor1$
          jmp   alrm$
next_sensor1$
          jb    IRsensor,exit$
alrm$
          setb  Alarm
          mov   dptr,#T_Alarm
          call  NVReadByte
          cjne  a,#1,time1$
          mov   AlarmTimer,#60
          jmp   go$
time1$
          cjne  a,#2,time2$
          mov   AlarmTimer,#120
          jmp   go$
time2$
          cjne  a,#3,exit$
          mov   AlarmTimer,#240
go$
          mov   secund,#0
          setb  Start_AlarmTimer
exit$
          ret
;------------------------------------------------------------------------
