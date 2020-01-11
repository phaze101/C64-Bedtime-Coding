;============================================================================
; C64 Bedtime Coding
; By Phaze 101
;
; Article 12 - Example 02
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
; Automatically Executed
; The Bytes below mean SYS49152 Better than us typing it
; This was Generated by CBM Prog Studio
;==============================================================================

; 10 SYS (49152):REM sys49152


*=$0801

        byte    $0E, $08, $0A, $00, $9E, $20, $28, $34 
        byte    $39, $31, $35, $32, $29, $00, $00, $00

;==============================================================================
; Where to assemble in memory
;==============================================================================

*               =       $c000

;==============================================================================
; All our functions will be included here
; Therefore we need to skip them and jump to our Main Code Routine
;==============================================================================

        jmp     Main

;==============================================================================
; All our Include Files
;==============================================================================

        IncAsm "Constants.asm"
        IncAsm "DispFunc.asm"
        IncAsm "DisplayScreens.asm"

;==============================================================================
; Main Entry
;==============================================================================

Main
        ldx     #Green
        ldy     #LightGreen
        jsr     SetBgBorder

        jsr     DisplayScreens

        jsr     WaitForSpace

        ldx     #Blue           ;Restore Background Colour
        ldy     #LightBlue      ;Restore Border Colour
        jsr     SetBgBorder

        lda     #SpaceCharacter ;Fill value
        ldy     #Black          ;Colour Value
        jsr     ScrFill

        rts

;==============================================================================
; All Our Data
; It is nice to keep our Data at the end of our code
;==============================================================================

        IncAsm "Data.asm"