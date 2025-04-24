
; Pin Connection
; D0-7  =   PA0-7	Data BUS	    Put your command or data on this bus
; RD    =   PA8		Read pin	    Read from touch screen input 
; WR    =   PA9		Write pin	    Write data/command to display
; RS    =   PA10	Command pin	    Choose command or data to write
; CS    =   PA11	Chip Select	    Enable the TFT,(active low)
; RST   =   PA12	Reset		    Reset the TFT (active low)
; D0-7  =   PB0-4	5 Keys

		
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
    
	EXPORT __main
		
    
; STRING DATA
string1              DCB     "ONE PLAYER MODE => 2.", 13, 10, "$"
string2              DCB     "CO-OP PING PONG  => 4.", 13, 10, "$"
string3              DCB     "Exit => Esc.", 13, 10, "$"

; ESCAPE STATUS
ESCSTATUS            DCB     0

; TWO PLAYER MODE PADDLE DATA
PADDLE_COLOR1        DCB     8
PADDLE_COLOR2        DCB     8

PADDLE_X1            DCW     50
PADDLE_Y1            DCW     100

PADDLE_X2            DCW     270
PADDLE_Y2            DCW     100
						

            AREA    MYcode, CODE, READONLY
		
__main FUNCTION
	
    BL GPIO_Init

    
Options_page
    ; Clear the screen colour
    BL      TFT_FillScreen

    ; Display option strings
    MOV     R0, #10                ; Row (approximately 10 for the first string)
    MOV     R1, #32                ; Column (approximately 32 for horizontal centering)
    LDR     R2, =string1           ; Load address of first string
    BL      Draw_Msg               ; Print string

    MOV     R0, #12                ; Row (approximately 12 for the second string)
    MOV     R1, #30                ; Column (approximately 30 for horizontal centering)
    LDR     R2, =string2           ; Load address of second string
    BL      Draw_Msg	           ; Print string

    MOV     R0, #14                ; Row (approximately 14 for third string)
    MOV     R1, #29                ; Column (approximately 29 for horizontal centering)
    LDR     R2, =string3           ; Load address of third string
    BL      Draw_Msg	           ; Print string

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


