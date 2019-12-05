;============================================================================
; C64 Bedtime Coding
; By Phaze 101
;
; Article 10 - Example 02
;============================================================================

; I wish to thank all those that sent me emails or get in touch with me 
; regarding this serious or articles.
;
; Also I would like to thank my team for their help in making these articles
; possible and for their help in translating these articles to Italian.
;
; If you find any bugs (I am not not perfect) or issues please get in touch.
; I will do my best to help out where possible however do allow sometime
; since I also have a day job to deal with.

;==============================================================================
; Where to assemble in memory
;==============================================================================

*               =       $c000

;==============================================================================
; Constants
;==============================================================================

ScrBase         =       $0400
ColMem          =       $d800

TempMem         =       $02

;==============================================================================
; Main Entry
;==============================================================================

Main
        ldx     #$05
        ldy     #$0d
        jsr     SetBgBorder

        lda     #$20            ;Fill value
        ldy     #$00            ;Colour Value
        jsr     ScrFill

        jsr     DisplayScreen

        jsr     WaitForSpace

        ldx     #$06
        ldy     #$0e
        jsr     SetBgBorder

        lda     #$20            ;Fill value
        ldy     #$0e            ;Colour Value
        jsr     ScrFill

        rts

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
        sta     ColMem,x          ; Colour Mem 55296
        sta     ColMem+250,x      ; Colour Mem 55296 + 250
        sta     ColMem+500,x      ; Colour Mem 55296 + 500
        sta     ColMem+750,x      ; Colour Mem 55296 + 750

        inx
        cpx     #$fa
        bne     ScrLoop

        rts

;==============================================================================
; Wait for Space bar to be pressed
;==============================================================================

WaitForSpace
        lda     #$7f    ;%01111111 - only row 7 KB matrix
        sta     $dc00
        lda     $dc01
        and     #$10    ;mask %00010000
        bne     WaitForSpace

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
; Print At - No colour
; 1. Handles number Strings in one Pass
; 2. Read X and Y values from first 2 bytes before each string
;
; Source Address of string stored at $fb & $fc
; Destination Address to Screem Memory sored at $fd & $fe
;==============================================================================

PrintAt

;Init Part
        sta     $fb             ;source - Pointing to first byte X value
        sty     $fc

        lda     NoStrs          ;load the number of strings we have
        sta     TempMem         ;store it in out temp location

;Set Postion on Display
SetPos
        jsr     ClearBuffers    ;make sure buffers are clear

        ldy     #$0
        lda     ($fb),y         ;Get No of Columns
        tax
        iny
        lda     ($fb),y         ;Get No of Row
        tay
        jsr     SetCurs

;Set Source to the String that will be Printed - skip 2 Bytes
        clc
        lda     #$02     
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
        lda     ($fb),y         ;check if string is empty
PrtLoop
        beq     PrintNextString
        sta     ($fd),y
        iny
        lda     ($fb),y
        bne     PrtLoop

;Are there more strings to print?
PrintNextString
        dec     TempMem         ;we could have used DEC NoStrs but in doing so
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
; Display Screen with Text
;==============================================================================

DisplayScreen

        lda     #<Strings
        ldy     #>Strings
        jsr     PrintAt


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
; Our Text
; 
; First byte is number of strings to Read
; First 2 bytes of each string are the X and Y position on the screen
; Each String ternimantes with a value of 0
;==============================================================================

NoStrs
        byte    $06    

Strings
        byte    $01,$01                                 ;X,Y Position
        text    'retroprogramming italia',0
        byte    $04,$05    
        text    'in collaboration with',0
        byte    $07,$09    
        text    'phaze101',0
        byte    $0a,$0d    
        text    'presents',0
        byte    $0d,$11    
        text    'c64 bedtime coding',0
        byte    $10,$15  
        text    'article 10 - example 02',0
