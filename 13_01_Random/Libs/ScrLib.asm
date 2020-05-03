;============================================================================
; C64 Bedtime Coding
; Copyright (c) by Phaze101 
; eMail - info@phaze101.com
; website - https://www.phaze101.com
; MIT License - https://choosealicense.com/licenses/mit/
;============================================================================

;==============================================================================
; Set Baground and Border
;
; Input
; X Register - Value for Background
; Y Register - Valeu for Border
;==============================================================================

SetBgBorder
        stx     $d021
        sty     $d020
        rts

;==============================================================================
; Screen Fill
; Set the screen text to a colour
;
; Input
; A register = Fill Value
; Y register = Colour Value
;==============================================================================

ScrFill
        sta     $fb               ; Fill Character
        ldx     #$00

ScrLoop
        lda     $fb
        sta     ScrBase,x         ; Screen 1024
        sta     ScrBase+250,x     ; Screen 1024 + 250
        sta     ScrBase+500,x     ; Screen 1024 + 500
        sta     ScrBase+750,x     ; Screen 1024 + 750

        tya                       ; Colour Value is in Y register
        sta     ScrCol,x          ; Colour Mem 55296
        sta     ScrCol+250,x      ; Colour Mem 55296 + 250
        sta     ScrCol+500,x      ; Colour Mem 55296 + 500
        sta     ScrCol+750,x      ; Colour Mem 55296 + 750

        inx
        cpx     #$fa
        bne     ScrLoop

        rts

;==============================================================================
; Wait for Space bar to be pressed
;==============================================================================

WaitForSpace
;        sei
        lda     #%11111111
        sta     $dc02
        lda     #%00000000
        sta     $dc03

        lda     #$7f    ;%01111111 - only row 7 KB matrix
        sta     $dc00
@WaitLoop1
        lda     $dc01
        and     #$10    ;mask %00010000
        bne     @WaitLoop1
@WaitLoop2
        lda     $dc01
        and     #$10    ;mask %00010000
        beq     @WaitLoop2

;        cli
        rts             

;==============================================================================
; Set Cursor Position on Screen
;
; *** Important - Call ClearBuffers before initialinsing X and Y
; Input
;       X - X coordinate Stored in ScrX
;       Y - Y coordinate Stored in ScrY
; Output
;       Buf2 - Holds offset from Screen Base Address
;       Buf3 - Holds Screen Address where to write first char
;==============================================================================

SetCurs
        cld

        jsr     ClearBuffers

        ldx     ScrX
        ldy     ScrY
        cpy     #$0
        beq     @AddColumn

;Use an addition to calculate rows
@CalcRow                         
        clc
        lda     #$28
        adc     Buf2
        sta     Buf2
        lda     #$0
        adc     Buf2+1
        sta     Buf2+1
        dey
        bne     @CalcRow

;Add Column
@AddColumn
        cpx     #$0
        beq     @AddScrBase
     
        clc
        txa     
        adc     Buf2
        sta     Buf2
        lda     #$0
        adc     Buf2+1
        sta     Buf2+1

;Add position to base address
@AddScrBase
        clc
        lda     Buf1
        adc     Buf2
        sta     Buf3

        lda     Buf1+1
        adc     Buf2+1
        sta     Buf3+1

        rts

;Input
ScrX
        byte    $00
ScrY
        byte    $00

;Output
Buf1   
        word     ScrBase
Buf2   
        word     $0000          ;Holds offset from Screen Base Address
Buf3   
        word     $0000          ;Holds Screen Address where to write first char

;==============================================================================
; Screen Poke
; Pokes a Character at the specified address calculated by SetCurs
; Pokes a colour for the characther 
;==============================================================================

ScreenPoke

;Calculate Offset in colour memory 

        clc
        lda     #<ScrCol
        adc     Buf2
        sta     ZeroPtr1Low

        lda     #>ScrCol
        adc     Buf2+1
        sta     ZeroPtr1High
 
;Set Destination on the Screen
        lda     Buf3            ;destination
        sta     $fd
        lda     Buf3+1
        sta     $fe
        
;Read String and Display it
        ldy     #$0
        lda     ZeroTmpMem01
        sta     ($fd),y
        lda     #$01
        sta     (ZeroPtr1Low),y

        rts

;==============================================================================
; Clear Memory Buffers
;==============================================================================

ClearBuffers
        ldy     #$4
        lda     #$0
@ClrBufLoop
        dey
        sta     Buf2,y
        bne     @ClrBufLoop
        rts

;==============================================================================
; WaitVBlank
;==============================================================================

WaitVBlank
		lda		$d012
        cmp     #250
        bcc     WaitVBlank      ; bcc = branch if less then

@VB_Loop1
        cmp     $d012       
        bcc     @VB_Loop1       ; bcc = branch if less than

        rts
