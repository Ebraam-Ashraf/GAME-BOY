        AREA |.text|, CODE, READONLY
        EXPORT BALL_CHECK_MOVE

BALL_CHECK_MOVE
        PUSH {R4-R9, LR}

        ; === Erase old ball ===
        BL Draw_Square_Black

        ; === Update Ball Position ===
        LDR R0, =X_BALL
        LDR R1, [R0]
        LDR R2, =X_VELOCITY
        LDR R3, [R2]
        ADD R1, R1, R3
        STR R1, [R0]     ; X_BALL += X_VELOCITY

        LDR R0, =Y_BALL
        LDR R1, [R0]
        LDR R2, =Y_VELOCITY
        LDR R3, [R2]
        ADD R1, R1, R3
        STR R1, [R0]     ; Y_BALL += Y_VELOCITY

        ; === Draw updated ball ===
        BL Draw_Square_White

        ; === Load updated values into R4 (X) and R5 (Y) ===
        LDR R4, =X_BALL
        LDR R4, [R4]
        LDR R5, =Y_BALL
        LDR R5, [R5]

        ; === Paddle 1 Collision Check ===
        MOV R9, #0
        CMP R4, #234
        ADDLT R9, R9, #1
        CMP R4, #224
        ADDGE R9, R9, #1
        CMP R5, #314
        ADDLT R9, R9, #1
        CMP R5, #304
        ADDGE R9, R9, #1
        CMP R9, #4
        BNE check_paddle2
        ; Invert X_VELOCITY
        LDR R0, =X_VELOCITY
        LDR R1, [R0]
        RSBS R1, R1, #0
        STR R1, [R0]

check_paddle2
        ; === Paddle 2 Collision Check ===
        MOV R9, #0
        CMP R4, #234
        ADDLT R9, R9, #1
        CMP R4, #224
        ADDGE R9, R9, #1
        CMP R5, #14
        ADDLT R9, R9, #1
        CMP R5, #4
        ADDGE R9, R9, #1
        CMP R9, #4
        BNE check_wall
        ; Invert X_VELOCITY
        LDR R0, =X_VELOCITY
        LDR R1, [R0]
        RSBS R1, R1, #0
        STR R1, [R0]

check_wall
        ; === Top/Bottom Wall Bounce ===
        CMP R4, #0
        BEQ invert_y
        CMP R4, #240
        BEQ invert_y
        B check_goal

invert_y
        LDR R0, =Y_VELOCITY
        LDR R1, [R0]
        RSBS R1, R1, #0
        STR R1, [R0]

check_goal
        ; === Y = 0: Player 2 Scores ===
        LDR R0, =Y_BALL
        LDR R1, [R0]
        CMP R1, #0
        BNE check_p1_goal
        LDR R2, =P2_SCORE
        LDR R3, [R2]
        ADD R3, R3, #1
        STR R3, [R2]
        B reset_ball

check_p1_goal
        ; === Y = 320: Player 1 Scores ===
        CMP R1, #320
        BNE done
        LDR R2, =P1_SCORE
        LDR R3, [R2]
        ADD R3, R3, #1
        STR R3, [R2]

reset_ball
        ; Reset ball to center
        LDR R0, =Y_BALL
        MOV R1, #160
        STR R1, [R0]
        LDR R0, =X_BALL
        STR R1, [R0]

done
        POP {R4-R9, PC}
