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
        sta     $fb     ;Fill Character
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
WaitLoop1
        lda     $dc01
        and     #$10    ;mask %00010000
        bne     WaitLoop1
WaitLoop2
        lda     $dc01
        and     #$10    ;mask %00010000
        beq     WaitLoop2

;        cli
        rts             

;==============================================================================
; Set Cursor Position on Screen
;
; Input
; X register - number of Colums
; Y register - number of rows
;==============================================================================

SetCurs
        cld

        cpy     #$0
        beq     AddColumn

;Use an addition to calculate rows
CalcRow                         
        clc
        lda     #$28
        adc     Buf2
        sta     Buf2
        lda     #$0
        adc     Buf2+1
        sta     Buf2+1
        dey
        bne     CalcRow

;Add Column
AddColumn
        cpx     #$0
        beq     AddScrBase
     
        clc
        txa     
        adc     Buf2
        sta     Buf2
        lda     #$0
        adc     Buf2+1
        sta     Buf2+1

;Add position to base address
AddScrBase
        clc
        lda     Buf1
        adc     Buf2
        sta     Buf3

        lda     Buf1+1
        adc     Buf2+1
        sta     Buf3+1

        rts

Buf1   
        word     ScrBase
Buf2   
        word     $0000          ;Holds offset from Screen Base Address
Buf3   
        word     $0000          ;Holds Screen Address where to write first char

;==============================================================================
; Print At with Colour
; 1. Handles number Strings in one Pass
; 2. Read X and Y values from first 2 bytes before each string
; 3. String 3rd byte contains Colour
; 4. Handles colour for the string
;
; PrintAT requires that ZeroTmpMem01 is set before it is called.
; ZeroTmpMem01 is used by PrintAT to know how many strings it needs to print
;==============================================================================

PrintAT

;Init Part
        sta     $fb             ;source - Pointing to first byte X value
        sty     $fc

;Get offset for screen and colour men
SetPos
        jsr     ClearBuffers    ;make sure buffers are clear

        ldy     #$0
        lda     ($fb),y         ;Get No of Columns
        tax
        iny
        lda     ($fb),y         ;Get No of Rows
        tay
        jsr     SetCurs

;Calculate Offset in colour memory 

        clc
        lda     #<ScrCol
        adc     Buf2
        sta     ZeroPtr1Low

        lda     #>ScrCol
        adc     Buf2+1
        sta     ZeroPtr1High
 
;Get text colour and sore it in memory
        ldy     #$2
        lda     ($fb),y
        sta     ZeroTmpMem02

;Set Source to the String that will be Printed - skip 3 Bytes
        clc
        lda     #$03     
        adc     $fb
        sta     $fb
        lda     #$0
        adc     $fc
        sta     $fc

;Set Destination on the Screen
        lda     Buf3            ;destination
        sta     $fd
        lda     Buf3+1
        sta     $fe
        
;Read String and Display it
        ldy     #$0
        lda     ($fb),y
PrtLoop
        beq     PrintNextString
        sta     ($fd),y
        lda     ZeroTmpMem02
        sta     (ZeroPtr1Low),y
        iny
        lda     ($fb),y
        bne     PrtLoop

;Is there more strings to print
PrintNextString
        dec     ZeroTmpMem01    ;we could have used DEC NoStrs but in doing so
                                ;the next time we run the program NoStrs will
                                ;be a zero and we will not know how many
                                ;strings there are to read

;        cmp     NoStrs       ;this is not needed but for clarity is commented

        beq     PrintExit

;If there is then Point to the next String
        iny

;AddrNextString
        clc
        tya     
        adc     $fb
        sta     $fb
        lda     #$0
        adc     $fc
        sta     $fc
        jmp     SetPos

PrintExit
        rts

;==============================================================================
; Clear Memory Buffers
;==============================================================================

ClearBuffers
        ldy     #$4
        lda     #$0
ClrBufLoop
        dey
        sta     Buf2,y
        bne     ClrBufLoop
        rts

;==============================================================================
; CBM Prog Studio Screen Display
;==============================================================================

CBMScreen
        ldx     #$00
        ldy     #$00
@Loop
        lda     Screen_1_Screen_data,y
        sta     ScrBase,x                       ; Screen 1024
        lda     Screen_1_Screen_data+250,y
        sta     ScrBase+250,x                   ; Screen 1024 + 250
        lda     Screen_1_Screen_data+500,y
        sta     ScrBase+500,x                   ; Screen 1024 + 500
        lda     Screen_1_Screen_data+750,y
        sta     ScrBase+750,x                   ; Screen 1024 + 750

        lda     Screen_1_Colour_data,y
        sta     ScrCol,x                        ; Colour Mem 55296
        lda     Screen_1_Colour_data+250,y
        sta     ScrCol+250,x                    ; Colour Mem 55296 + 250
        lda     Screen_1_Colour_data+500,y
        sta     ScrCol+500,x                    ; Colour Mem 55296 + 500
        lda     Screen_1_Colour_data+750,y
        sta     ScrCol+750,x                    ; Colour Mem 55296 + 750

        iny
        inx
        cpx     #$fa
        bne     @Loop

        rts
