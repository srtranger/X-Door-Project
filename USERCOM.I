;                   User Command Definitions Module
;
;-------------------------------------------------------------------------
UserCommand:
                mov     a,num_key
                cjne    a,#1,next_test$
                cpl     Armed                  ; +
                jmp     exit$
next_test$
                cjne    a,#2,next_test1$
                cpl     Hold                   ; +
                jmp     exit$
next_test1$
                cjne    a,#3,next_test2$
                cpl     Panic                  ; +
                jmp     exit$
next_test2$
                jb      Armed,next_test3$
                cjne    a,#4,next_test3$
                setb    Learn
                jmp     exit$
next_test3$
                cjne    a,#5,exit$
                cpl     Visio                  ; +
exit$
                mov     num_key,#0
                clr     CommandReady
                ret


