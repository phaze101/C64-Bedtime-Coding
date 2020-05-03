;============================================================================
; C64 Bedtime Coding
; Copyright (c) by Phaze101 
; eMail - info@phaze101.com
; website - https://www.phaze101.com
; MIT License - https://choosealicense.com/licenses/mit/
;============================================================================

;##############################################################################
; Using the Random methods #6
; Using Colour Memory to obtain Random Numbers
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

        jsr     GetRandom

        ldx     _101_RNDV2

        lda     #$51
        sta     $0400,x

        lda     _101_RNDv1
        sta     $d800,x

        jmp     Main            ; Not a fan of jumps

