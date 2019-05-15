;============================================================================
; C64 Bedtime Coding
; By Phaze 101
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

;==============================================================================
; Main Entry
;==============================================================================

Main
        ldx     #$6
        ldy     #$0
        jsr     SetBgBorder

        lda     #$20
        jsr     ClearScreen

        jsr     DisplayScreen

        jsr     WaitForSpace
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
        ldx     #$FF              ; init index

ClrLoop
        sta     ScrBase,x         ; 1024
        sta     ScrBase+250,x     ; 1024 + 250
        sta     ScrBase+500,x     ; 1024 + 500
        sta     ScrBase+750,x     ; 1024 + 750
        dex
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
; Print At
;==============================================================================

PrintAt
        sta     $fb            ;source
        sty     $fc

;Set Postion on Display
SetPos
        ldy     #$0
        lda     ($fb),y        ;Get No of Rows
        tax
        iny
        lda     ($fb),y        ;Get No of Colums
        tay
        jsr     SetCurs


;Set Destination
        lda     Buf3           ;destination
        sta     $fd
        lda     Buf3+1
        sta     $fe
        
;Read String and Display it
        ldy     #$02
        lda     ($fb),y
PrtLoop
        beq     PrintNextString
        dey
        dey
        sta     ($fd),y
        iny
        iny
        iny
        lda     ($fb),y
        bne     PrtLoop

;Is there more strings to print
PrintNextString
        dec     NoStrs
        cmp     NoStrs
        beq     PrintExit

;If there is then Point to the next String
        iny

AddrNextString
        clc
        tya     
        adc     $fb
        sta     $fb
        lda     #$0
        adc     $fc
        sta     $fc
        jsr     ClearBuffers
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
;==============================================================================

NoStrs
        byte    $06    

Strings
;        byte    $09,$06                                 ;X,Y Position
        byte    $0,$0                                 ;X,Y Position
        text    'retroprogramming italia',0
        byte    $0a,$08    
        text    'in collaboration with',0
        byte    $11,$0a    
        text    'phaze101',0
        byte    $11,$0c    
        text    'presents',0
        byte    $0b,$0e    
        text    'c64 bedtime coding',0
        byte    $0,$18  
        text    'code for article 9',0