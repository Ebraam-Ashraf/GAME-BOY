
; Pin Connection
; D0-7  =   PA0-7	Data BUS	    Put your command or data on this bus
; RD    =   PA8		Read pin	    Read from touch screen input 
; WR    =   PA9		Write pin	    Write data/command to display
; RS    =   PA10	Command pin	    Choose command or data to write
; CS    =   PA11	Chip Select	    Enable the TFT,(active low)
; RST   =   PA12	Reset		    Reset the TFT (active low)
; D0-7  =   PB0-4	5 Keys
; PB5-9 keys
		
    ;TFT
    IMPORT GPIO_Init
    IMPORT TFT_WriteCommand
    IMPORT TFT_WriteData
    IMPORT TFT_Init
    IMPORT TFT_FillScreen
    IMPORT Delay
    IMPORT font_map
    IMPORT Read_Keys
    
    ;Graphics
    IMPORT Draw_Pixel
    IMPORT Draw_Char
    IMPORT Draw_Msg
    IMPORT Draw_Line
    IMPORT Draw_Rectangle	
    IMPORT Clear_Screen
    IMPORT Init_Screen
    
    ;PING_PONG_MODE
    IMPORT PING_PONG_MODE
    
	EXPORT __main
		
; ---------- COLORS ----------
Red     EQU 0x001F   ; 00000 000000 11111
Green   EQU 0x07E0   ; 00000 111111 00000
Blue    EQU 0xF800   ; 11111 000000 00000
Yellow  EQU 0x06FF   ; 11111 111111 00000
White   EQU 0xFFFF   ; 11111 111111 11111
Black   EQU 0x0000   ; 00000 000000 00000

; STRING DATA
string1              DCB     "ONE PLAYER MODE => KEY 1 $"
string2              DCB     "CO-OP PING PONG => KEY 2 $"
string3              DCB     "Exit => KEY 5 $"

	

            AREA    MYcode, CODE, READONLY
		
__main FUNCTION
	
    BL GPIO_Init

    ; Clear the screen colour
    BL      TFT_FillScreen


    ; ---------- Display Text Options Using Draw_Msg ----------
    ; Assumes:
    ; R9 = string pointer
    ; R4 = text color (foreground)
    ; R5 = background color
    ; R6 = X coordinate
    ; R7 = Y coordinate
    ; R8 = size (can leave unset if unused)

        LDR     R4, =White         ; Text color
        LDR     R5, =Black         ; Background color

        ; --- First string ---
        MOV     R6, #32            ; X position
        MOV     R7, #10            ; Y position
        LDR     R9, =string1
        BL      Draw_Msg

        ; --- Second string ---
        MOV     R6, #30
        MOV     R7, #12
        LDR     R9, =string2
        BL      Draw_Msg

        ; --- Third string ---
        MOV     R6, #29
        MOV     R7, #14
        LDR     R9, =string3
        BL      Draw_Msg
	
    ; Wait for key press
REENTER BL      Read_Keys           ; Call function to detect key press
	
	CMP R0,#1
	BEQ ONE_PLAYER_MODE
	
	CMP R0,#2
	BEQ PING_PONG_MODE
	
	CMP R0,#3
	BEQ EXIT
	
	CMP R0,#4
	BEQ REENTER
	
	ENDFUNC


