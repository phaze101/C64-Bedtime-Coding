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
        lda     #$00
        sta     $d020
        sta     $d021

Main
;        jsr     WaitVBlank

        jsr     RNDRasCIA

        tax
        dex                     ; this is so we start from zero

        lda     #$51
        sta     $0400,x

@Loopy        
        jsr     RNDRasCIA
        and     #%00001111      ; we only need to use lower nibble for color
        beq     @Loopy          ; if it is a zero (black) get another colour
        sta     $d800,x

        jmp     Main            ; Not a fan of jumps


