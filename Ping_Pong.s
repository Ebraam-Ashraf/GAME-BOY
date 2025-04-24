

;                          TFT Coordinate System (240x320)
;
;  --------------------------------------------------------------------------------->
;  |                         							X-axis (right) 320
;  |                                                        Y1
;  |                                                   	   |█|
;  |                              ●                     X1 |█|  X2
;  |       |█|                                             |█|
;  |       |█|                                             |█|
;  |       |█|                                             |█|
;  |       |█|                                             Y2
;  |       |█|                                             
;  |                                                    
;  |  Player 1 Paddle 				    Player 2 Paddle
;  |
;  |
;  v
;
;  Y-axis (down)240

                              




	EXPORT PING_PONG_MODE

    AREA PING_DATA, DATA, READWRITE

; ---------- COLORS ----------
Red     EQU 0x001F   ; 00000 000000 11111
Green   EQU 0x07E0   ; 00000 111111 00000
Blue    EQU 0xF800   ; 11111 000000 00000
Yellow  EQU 0x06FF   ; 11111 111111 00000
White   EQU 0xFFFF   ; 11111 111111 11111
Black   EQU 0x0000   ; 00000 000000 00000

; PADDLE DATA
PADDLE_WIDTH         DCW     10
PADDLE_HEIGHT        DCW     40
PADDLE_COLOR         DCW     3
PADDLE_SPEED         DCW     2

; BALL DATA
BALL_X               DCW     170
BALL_Y               DCW     110
BALL_VELOCITY_X      DCW     2
Ball_VELOCITY_Y      DCW     2
BALL_COLOR           DCB     0

; SCORE_COUNT
SCORE_COUNT_PLAYER_1 DCW     0
SCORE_COUNT_PLAYER_2 DCW     0

; ESCAPE STATUS
ESCSTATUS            DCB     0

; TWO PLAYER MODE PADDLE DATA
PADDLE_COLOR1        DCB     8
PADDLE_COLOR2        DCB     8

PADDLE_1_X1            DCW     50
PADDLE_1_X2            DCW     50
PADDLE_1_Y1            DCW     50
PADDLE_1_Y2            DCW     50

PADDLE_2_X1            DCW     50
PADDLE_2_X2            DCW     50
PADDLE_2_Y1            DCW     50
PADDLE_2_Y2            DCW     50



    AREA PING_PONG_MODE, CODE, READONLY
     
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

LOOP:
        BL BALL_CHECK_MOVE        ; Move the ball, handle collisions, etc.

        ; Read PB5 status
        LDR R0, =0x40010C08       ; GPIOB_IDR address
        LDR R1, [R0]              ; Read full IDR (32-bit)
        MOV R2, #0x20             ; Mask for bit 5 (PB5)
        TST R1, R2                ; Check if PB5 is high

        BNE EXIT                  ; If PB5 is high (pressed), exit

        B LOOP                    ; Else repeat


EXIT
	BX LR        



BALL_CHECK_MOVE
        PUSH {R4-R9, LR}

        ; === Erase old ball ===
        ; Draw Square Center at (x=R5, y=R6 ,Color=R1)
        ; el function f a5r el code 3ashan lw 7abb t3.adlha 
        ; in another word till IBRAHIM BAKR TEST IT 
	LDR R0, =Black
        LDRH R1, [R0]
        LDR R0, =BALL_Y
        LDRH R2, [R0]
        LDR R0, =BALL_X
        BL Draw_Square

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
        ; Draw Square Center at (x=R5, y=R6 ,Color=R1)
        ; el function f a5r el code 3ashan lw 7abb t3.adlha 
        ; in another word till IBRAHIM BAKR TEST IT 
	LDR R0, =BALL_COLOR
        LDRH R1, [R0]
        LDR R0, =BALL_Y
        LDRH R2, [R0]
        LDR R0, =BALL_X
        BL Draw_Square

         ; === Load BALL X into R4 and BALL Y into R5 ===
        LDR     R0, =X_BALL
        LDR     R4, [R0]        ; R4 = X_BALL
        LDR     R0, =Y_BALL
        LDR     R5, [R0]        ; R5 = Y_BALL


CHECK_PADDLE_1
        ; === Load PADDLE 1 coordinates ===
        LDR     R0, =PADDLE_1_X1
        LDRH    R6, [R0]        ; R6 = X1
        LDR     R0, =PADDLE_1_X2
        LDRH    R7, [R0]        ; R7 = X2
        LDR     R0, =PADDLE_1_Y1
        LDRH    R8, [R0]        ; R8 = Y1
        LDR     R0, =PADDLE_1_Y2
        LDRH    R9, [R0]        ; R9 = Y2

	; === Paddle 1 Collision Check ===
        MOV R10, #0
        CMP R4, R6
        ADDLT R10, R10, #1
        CMP R4, R7
        ADDGE R10, R10, #1
        CMP R5, R8
        ADDLT R10, R10, #1
        CMP R5, R9
        ADDGE R10, R10, #1
        CMP R10, #4
        BNE CHECK_PADDLE_2          ;if not equat go to check wall
	
        ; Invert X_VELOCITY
        LDR R0, =X_VELOCITY
        LDR R1, [R0]
        RSBS R1, R1, #0
        STR R1, [R0]


CHECK_PADDLE_2
        ; === Load PADDLE 2 coordinates ===
        LDR     R0, =PADDLE_2_X1
        LDRH    R6, [R0]        ; R6 = X1
        LDR     R0, =PADDLE_2_X2
        LDRH    R7, [R0]        ; R7 = X2
        LDR     R0, =PADDLE_2_Y1
        LDRH    R8, [R0]        ; R8 = Y1
        LDR     R0, =PADDLE_2_Y2
        LDRH    R9, [R0]        ; R9 = Y2

	; === Paddle 2 Collision Check ===
        MOV R10, #0
        CMP R4, R6
        ADDLT R10, R10, #1
        CMP R4, R7
        ADDGE R10, R10, #1
        CMP R5, R8
        ADDLT R10, R10, #1
        CMP R5, R9
        ADDGE R10, R10, #1
        CMP R10, #4
        BNE CHECK_WALL          ;if not equat go to check wall
	
        ; Invert X_VELOCITY
        LDR R0, =X_VELOCITY
        LDR R1, [R0]
        RSBS R1, R1, #0
        STR R1, [R0]

CHECK_WALL
        ; === Top/Bottom Wall Bounce ===
        CMP R4, #0
        BEQ invert_y
        CMP R4, #240
        BEQ invert_y
        B CHECK_GOAL
invert_y
        LDR R0, =Y_VELOCITY
        LDR R1, [R0]
        RSBS R1, R1, #0
        STR R1, [R0]

CHECK_GOAL
        ; === IF X = 0: Player 2 Scores ===
        LDR R0, =X_BALL
        LDR R1, [R0]
        CMP R1, #0
        BNE PLAYER_1_GOAL
	
PLAYER_2_GOAL	
        LDR R2, =P2_SCORE
        LDR R3, [R2]
        ADD R3, R3, #1
        STR R3, [R2]
        B reset_ball

PLAYER_1_GOAL
        ; === X = 320: Player 1 Scores ===
        CMP R1, #320
        BNE done
        LDR R2, =P1_SCORE
        LDR R3, [R2]
        ADD R3, R3, #1
        STR R3, [R2]

RESET_BALL
        ; Reset ball to center
        LDR R0, =Y_BALL
        MOV R1, #160
        STR R1, [R0]
        LDR R0, =X_BALL
        STR R1, [R0]

        POP {R4-R9, PC}

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

    END
