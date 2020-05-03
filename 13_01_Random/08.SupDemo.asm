;============================================================================
; C64 Bedtime Coding
; Copyright (c) by Phaze101 
; eMail - info@phaze101.com
; website - https://www.phaze101.com
; MIT License - https://choosealicense.com/licenses/mit/
;============================================================================

;##############################################################################
; Using the Random methods #1
; Reading RasterLine in Combination with the CIA Timer to obtain a Random No.
;##############################################################################

*       =       $C000

        jmp     Start
        
        IncAsm  "Libs\Constants.asm"
        IncAsm  "Libs\ScrLib.asm"
        IncAsm  "Libs\RandomLib.asm"
        IncAsm  "Libs\Hex2Dec.asm"

Start
        ldx     #$00
        ldy     #$00
        jsr     SetBgBorder

        lda     #' '
        ldy     #7
        jsr     ScrFill

Main
        jsr     RNDRasCIA
        
        sta     ZeroTmpMem01
        tax

        lda     #$51
        sta     ScrBase,x


        ;----------------------------------------------------------------------
        ; This is how to Call the Hex2Dec Conversion Routines
        ; 1. Store number to be displayed - all registers are destroyed
        ; 2. Clear the routines memory area
        ; 3. Get the store number and load it in DivX_XX
        ; 4. Set the X and Y coordinates where you want the number displayed
        ; 5. Call the Conersion routine - Show_16Bit or Show_32Bit
        ;----------------------------------------------------------------------

        jsr     ClrDataArea     ; Before calling the conversion routines
                                ; We need to clear the Data Area

        lda     ZeroTmpMem01    ; Retore our Number
        sta     div1_lo         ; Store Random Number in divX_XX
                                ; If number < 255 ignore divX_hi

        lda     #$0f            ; Store X Position in ScrX memory location
        sta     ScrX
        lda     #$14            ; Store Y Position in ScrY memory location
        sta     ScrY

        jsr     Show_32Bit      ; Convert and Show number in decimal noation

        ;----------------------------------------------------------------------

        ldx     ZeroTmpMem01
@Loopy        
        jsr     RNDRasCIA       ; This time we use Random routine to get Colour
        and     #%00001111      ; we only need to use lower nibble for color
        beq     @Loopy          ; if it is a zero (black) get another colour
        sta     ScrCol,x

        jsr     WaitForSpace

        jmp     Main            ; Not a fan of jumps
