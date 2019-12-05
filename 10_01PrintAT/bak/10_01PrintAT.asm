;============================================================================
; C64 Bedtime Coding
; By Phaze 101
;
; Article 10 - Example 01
;============================================================================

; I wish to thank all those that sent me emails or get in touch with me 
; regarding this serious or articles.
;
; Also I would like to thank my team for their help in making these articles
; possible and for their help in translating these articles to Italian.
;
; If you find any bugs (I am not not perfect)or issues please get in touch.
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

;==============================================================================
; Main Entry
;==============================================================================

Main
        ldx     #$0
        ldy     #$0
        jsr     SetBgBorder

        lda     #$20
        jsr     ClearScreen

        jsr     DisplayScreen

        jsr     WaitForSpace

        lda     #$20
        jsr     ClearScreen

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
; Clean / Fill Screen
;
; Input
; A register = Fill Value
;==============================================================================

ClearScreen
        ldx     #$00
 
ClrLoop
        sta     ScrBase,x         ; 1024
        sta     ScrBase+250,x     ; 1024 + 250
        sta     ScrBase+500,x     ; 1024 + 500
        sta     ScrBase+750,x     ; 1024 + 750
 
        inx
        cpx     #$fa
        bne     ClrLoop
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
;==============================================================================

SetCurs
        cld

;Use an addition to calculate rows

        clc
CalcRow                         
        lda     #$28
        adc     Buf2
        sta     Buf2
        lda     #$0
        adc     Buf2+1
        sta     Buf2+1
        dey
        bne     CalcRow

;Add Column

        clc
AddColumn
        txa     
        adc     Buf2
        sta     Buf2
        lda     #$0
        adc     Buf2+1
        sta     Buf2+1

;Add poistion to base address

        clc
AddScrBase
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
; Print At
;==============================================================================

PrintAt
        sta     $fb             ;source
        sty     $fc

        lda     Buf3           ;destination
        sta     $fd
        lda     Buf3+1
        sta     $fe
        
        ldy     #$0
        lda     ($fb),y

PrtLoop
        beq     EndPrint
        sta     ($fd),y
        iny
        lda     ($fb),y
        bne     PrtLoop

EndPrint
        rts

;==============================================================================
; Display Screen with Text
;==============================================================================

DisplayScreen

        jsr     ClearBuffers

        ldy     #$06
        ldx     #$09
        jsr     SetCurs

        lda     #<Text1
        ldy     #>Text1
        jsr     PrintAt

        jsr     ClearBuffers

        ldy     #$08
        ldx     #$0A
        jsr     SetCurs

        lda     #<Text2
        ldy     #>Text2
        jsr     PrintAt

        jsr     ClearBuffers

        ldy     #$0a
        ldx     #$11
        jsr     SetCurs

        lda     #<Text3
        ldy     #>Text3
        jsr     PrintAt

        jsr     ClearBuffers

        ldy     #$0c
        ldx     #$11
        jsr     SetCurs

        lda     #<Text4
        ldy     #>Text4
        jsr     PrintAt

        jsr     ClearBuffers

        ldy     #$0e
        ldx     #$0d
        jsr     SetCurs

        lda     #<Text5
        ldy     #>Text5
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
;==============================================================================

Text1
        text 'retroprogramming italia',0
Text2
        text 'in collaboration with',0
Text3
        text 'phaze101',0
Text4
        text 'presents',0
Text5
        text 'c64bc example 01',0
