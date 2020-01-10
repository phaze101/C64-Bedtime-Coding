;==============================================================================
; Display Screen with Text
;==============================================================================

DisplayScreens

        lda     #SpaceCharacter    ;Fill value
        ldy     #Black             ;Colour Value
        jsr     ScrFill

;Display Home Screen
        lda     HomeScreen         ;Get number of strings
        sta     ZeroTmpMem01       ;store it in out templocation
        lda     #<HomeScreen+1     ;CBMProgStudio Enable
                                   ;Calc address first then Lo/Hi Byte
        ldy     #>HomeScreen+1     ;CBMProgStudio Enable
                                   ;Calc address first then Lo/Hi Byte
        jsr     PrintAT
 
        jsr     WaitForSpace

        lda     #SpaceCharacter    ;Fill value
        ldy     #Black             ;Colour Value
        jsr     ScrFill

;Display Game Screen
        jsr     CBMScreen

        jsr     WaitForSpace

        lda     #SpaceCharacter    ;Fill value
        ldy     #Black             ;Colour Value
        jsr     ScrFill

;Display Game Over Screen
        lda     GameOverScreen     ;Get number of strings
        sta     ZeroTmpMem01       ;store it in out temp location
        lda     #<GameOverScreen+1 ;CBMProgStudio Enable
                                   ;Calc address first then Lo/Hi Byte
        ldy     #>GameOverScreen+1 ;CBMProgStudio Enable
                                   ;Calc address first then Lo/Hi Byte
        jsr     PrintAT

        rts
