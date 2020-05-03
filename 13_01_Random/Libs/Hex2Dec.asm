;============================================================================
; C64 Bedtime Coding
; Copyright (c) by Phaze101 
; eMail - info@phaze101.com
; website - https://www.phaze101.com
; MIT License - https://choosealicense.com/licenses/mit/
;============================================================================

;============================================================================
; These routines do 2 things
; 1. Converting a 16 Bit or 32 Bit Number from Hex to Decimal
; 2. Display the number stored in ResultX_XX
;============================================================================

; last part similiar to my routine however I did my version
; before I came accross this one and mine doesn't use OS routines
; https://codebase64.org/doku.php?id=base:32_bit_hexadecimal_to_decimal_conversion

;============================================================================
; Display a 16 Bit Number
; Number to be Displayed on screen in Result1_XX
; Uses 5 Characters on the Screen
;============================================================================

Show_16Bit
        jsr     SetCurs

;Set Screen Position

        lda     Buf3            ;destination
        sta     $fb
        lda     Buf3+1
        sta     $fc

        ldy     #$04       ; Number of Digits to print - 5 in this case for a 16bit
@Next
        jsr     Div10_16Bit
        ora     #$30
        sta     ($fb),Y
        dey
        bpl     @Next
        rts

;============================================================================
; Display a 32 Bit Number
; Number to be Displayed on Screen in ResultX_XX
; Uses 10 Characters of the Screen
;============================================================================

Show_32Bit
        jsr     SetCurs

;Set Screen Position
        lda     Buf3        ;destination
        sta     $fb
        lda     Buf3+1
        sta     $fc

        ldy     #$09        ;Number of digits to print - 10 in case of a 32 bit
@Next
        jsr     Div10_32Bit
        ora     #$30
        sta     ($fb),Y
        dey
        bpl     @Next
        rts

;============================================================================
; Divides a 16 bit Number by 10 and store it in Result1_XX
; Store the Number to be Divided by 10 in div1_XX
; Result will be store in result1_XX
; This routine is actually a divide by 10
;============================================================================

Div10_16Bit
        ldx     #$11        ; number of bits - 16 + 1 since 0 is ignored
        lda     #$00
        clc
@loop    
        rol
        cmp     #$0a
        bcc     @skip
        sbc     #$0a
@skip    
        rol     div1_lo
        rol     div1_hi
        dex
        bne     @loop
        rts

;============================================================================
; Divides a 32 bit Number by 10 and store it in ResultX_XX
; Store the Number to be Divided by 10 in divX_XX
; Result will be store in resultX_XX
; This routine is actually a divide by 10
; Remainder in Accumulator
;============================================================================

Div10_32bit
        ldx     #$21
        lda     #$00
        clc
@loop    
        rol
        cmp     #$0a
        bcc     @skip
        sbc     #$0a
@skip
        rol     div1_lo
        rol     div1_hi
        rol     div2_lo
        rol     div2_hi
        dex
        bne     @loop
        rts

;##############################################################################
; Support Routines
;##############################################################################

;==============================================================================
; Clear Data Area
;==============================================================================

ClrDataArea
        ldy     #result2_hi - div1_lo
        lda     #$0
@Loop
        sta     div1_lo,y
        dey
        bne     @Loop
        rts

;============================================================================
; Data in Memory used by the above routines
;============================================================================

;Inputs
div1_lo
        byte    $00
div1_hi
        byte    $00
div2_lo
        byte    $00
div2_hi
        byte    $00

;Output
result1_lo
        byte    $00
result1_hi
        byte    $00
result2_lo
        byte    $00
result2_hi
        byte    $00