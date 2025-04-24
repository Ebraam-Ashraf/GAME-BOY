
PING_PONG_MODE

	PUSH {R0-R12, LR}
	
	;CLEAR THE SCREEN
	BL Clear_Screen
	
	; DRAWS PLAYER 1
	LDR R5,=PADDLE_COLOR1
	LDRH R0, [R5]
	LDR R5,=PADDLE_Y1
	LDRH R1, [R5]
	MOV R2, R1
	LDR R6, =PADDLE_HEIGHT
	LDRH R5, [R6]
	ADD R2, R5
	LDR R5,=PADDLE_X1
	LDRH R3 ,[R5]
	MOV R4, R3
	LDR R6, =PADDLE_WIDTH
	LDRH R5, [R6]
	ADD R4, R5
	BL Draw_Rectangle
	
	;DARWS PLAYER 2
	LDR R5,=PADDLE_COLOR1
	LDRH R0, [R5]
	LDR R5,=PADDLE_Y1
	LDRH R1, [R5]
	MOV R2, R1
	LDR R6, =PADDLE_HEIGHT
	LDRH R5, [R6]
	ADD R2, R5
	LDR R5,=PADDLE_X1
	LDRH R3 ,[R5]
	MOV R4, R3
	LDR R6, =PADDLE_WIDTH
	LDRH R5, [R6]
	ADD R4, R5
	BL Draw_Rectangle


        ; Draw Square Center at (x=R5, y=R6 ,Color=R1)
        ; el function f a5r el code 3ashan lw 7abb t3.adlha 
        ; in another word till IBRAHIM BAKR TEST IT 
	LDR R0, =BALL_COLOR
        LDRH R1, [R0]
        LDR R0, =BALL_Y
        LDRH R2, [R0]
        LDR R0, =BALL_X
        BL Draw_Square
	
	POP {R0-R12, PC}



 
;ONE_PLAYER_MODE END

EXIT
	BX LR



 PING_PONG_MODE
    LOOP:
        BL BALL_CHECK_MOVE        ; Move the ball, handle collisions, etc.

        ; Read PB5 status (we can simulate or read GPIO directly)
        LDR R0, =0x40010C08       ; GPIOB_IDR address
        LDR R1, [R0]              ; Read full IDR (32-bit)
        MOV R2, #0x20             ; Mask for bit 5 (PB5)
        TST R1, R2                ; Check if PB5 is high

        BNE EXIT                  ; If PB5 is high (pressed), exit

        B LOOP                    ; Else repeat

ONE_PLAYER_MODE
	BX LR



	ALIGN
	END
        
        
        
        
        
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



; *************************************************************
; Draw Square Center at (x=R5, y=R6 ,Color=R1)
; *************************************************************
Draw_Square
    PUSH {R0-R12, LR}
    MOV R8, R1

    SUBS R1, R5, #5
    ADDS R2, R5, #5
    SUBS R3, R6, #5
    ADDS R4, R6, #5

    ; Set Column Address (0-239)
    MOV R0, #0x2A
    BL TFT_WriteCommand
    MOV R0, R1, LSR #8
    BL TFT_WriteData
    MOV R0, R1
    BL TFT_WriteData
    MOV R0, R2, LSR #8
    BL TFT_WriteData
    MOV R0, R2
    BL TFT_WriteData

    ; Set Page Address (0-319)
    MOV R0, #0x2B
    BL TFT_WriteCommand
    MOV R0, R3, LSR #8
    BL TFT_WriteData
    MOV R0, R3
    BL TFT_WriteData
    MOV R0, R4, LSR #8      ; High byte of 0x013F (319)
    BL TFT_WriteData
    MOV R0, R4
    BL TFT_WriteData

    ; Memory Write
    MOV R0, #0x2C
    BL TFT_WriteCommand

    ; Prepare color bytes
    MOV R1, R8, LSR #8     ; High byte
    AND R2, R8, #0xFF      ; Low byte

    ; Fill screen with color (320x240 = 76800 pixels)
    LDR R3, =100
DrawSquare_Loop
    ; Write high byte
    MOV R0, R1
    BL TFT_WriteData
    
    ; Write low byte
    MOV R0, R2
    BL TFT_WriteData
    
    SUBS R3, R3, #1
    BNE DrawSquare_Loop

    POP {R0-R12, LR}
    BX LR
