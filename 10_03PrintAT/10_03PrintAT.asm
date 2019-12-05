;============================================================================
; C64 Bedtime Coding
; By Phaze 101
;
; Article 10 - Example 03
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
;
; In future this will be a separate file
;==============================================================================

;Base Addresses
ScrBase         =       $0400
ScrCol          =       $d800

ZeroPtr1Low     =       $02
ZeroPtr1High    =       $03
ZeroPtr2Low     =       $04
ZeroPtr2High    =       $05

;Temp Memory Locations in Page Zero
ZeroTmpMem01    =       $2A
ZeroTmpMem02    =       $52
ZeroTmpMem03    =       $06

;C64 colours Definitions
Black           =       0
White           =       1
Red             =       2
Cyan            =       3 
Purple          =       4
Green           =       5
Blue            =       6
Yellow          =       7
Orange          =       8
Brown           =       9
LightRed        =       10
DarkGray        =       11
MediumGray      =       12
LightGreen      =       13
LightBlue       =       14
LightGray       =       15

;Character Values
SpaceCharacter  =       32

;Logic constants
False           =       0
True            =       1

;==============================================================================
; Main Entry
;==============================================================================

Main
        ldx     #Black
        ldy     #DarkGray
        jsr     SetBgBorder

        lda     #SpaceCharacter ;Fill value
        ldy     #White          ;Colour Value
        jsr     ScrFill

        jsr     DisplayScreen

        jsr     WaitForSpace

        ldx     #Blue           ;Restore Background Colour
        ldy     #LightBlue      ;Restore Border Colour
        jsr     SetBgBorder

        lda     #SpaceCharacter ;Fill value
        ldy     #Black          ;Colour Value
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
; Print At with Colour
; 1. Handles number Strings in one Pass
; 2. Read X and Y values from first 2 bytes before each string
; 3. String 3rd byte contains Colour
; 4. Handles colour for the string
;
; PrintAT requires that ZeroTmpMem01 is set before it is called.
; ZeroTmpMem01 is used by PrintAT to know how many strings it needs to print
;==============================================================================

PrintAt

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
; Display Screen with Text
;==============================================================================

DisplayScreen

        lda     Strings
        sta     ZeroTmpMem01   ;store it in out temp location
        lda     #<Strings+1
        ldy     #>Strings+1
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
; Third Byte is the colour of our string
; Each String ternimantes with a value of 0
;==============================================================================

Strings
        byte    $06                                  ;No of Strings to Print
        byte    $01,$01,Orange                       ;X,Y Position + colour
        text    'retroprogramming italia',0
        byte    $04,$05,Brown    
        text    'in collaboration with',0
        byte    $07,$09,LightRed    
        text    'phaze101',0
        byte    $0a,$0d,DarkGray    
        text    'presents',0
        byte    $0d,$11,MediumGray    
        text    'c64 bedtime coding',0
        byte    $10,$15,LightGray  
        text    'article 10 - example 03',0

