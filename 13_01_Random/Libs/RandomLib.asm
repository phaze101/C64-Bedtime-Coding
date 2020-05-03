;============================================================================
; C64 Bedtime Coding
; Copyright (c) by Phaze101 
; eMail - info@phaze101.com
; website - https://www.phaze101.com
; MIT License - https://choosealicense.com/licenses/mit/
;============================================================================

;##############################################################################
; Random Numbers Code Routines
; Futher info here
; https://www.atarimagazines.com/compute/issue72/random_numbers.php
; https://codebase64.org/doku.php?id=base:6502_6510_maths
;##############################################################################

;==============================================================================
; Method 1
; Use Raster Line and CIA Timers
; Input - None
; Output - Accumulator holds Random number
;==============================================================================

RNDRasCIA
        lda     $d012           ; Retuens Raster Line Number
        eor     $dc04           ; Low byte of Timer A
        sbc     $dc05           ; Low Byte of Timer B
        rts


;==============================================================================
; Method 2
; Using Only CIA Timers
; Output - A = Random Number
;==============================================================================

RNDTimer

        lda     #$ff
@loop
        eor     $dc04           ;Lo Byte Timer A
        bcc     @L1
        ror
@L1
        eor     $dc05           ;Hi Byte Timer B
        bcc     @L2
        ror
@L2
        eor     $dc06           ;Lo Byte Timer B
        bcc     @L3
        ror
@L3
        eor     $dc07           ;Hi Byte Time B
        bcc     @L4
        ror
@L4
        rts

;==============================================================================
; Method 3
; Use Sound Wave Generator
; Output - Value in $D41B
;==============================================================================

RNDSndSeed1
        lda     #$6F
        sta     $D413           ;Voice 3 - ADSR Register
        lda     #$81
        sta     $D412           ;Voice 3 - Control Register
        lda     #$FF
        sta     $D40E           ;Voice 3 - Frequency Control Lo byte
        sta     $D40F           ;Voice 3 - Frequency Control Hi Byte
        sta     $D414           ;Envelope Generator 3
        RTS


;==============================================================================
; Method 4
; Use Sound Wave Generator
; Output - Value in $D41B
;==============================================================================

RNDSndSeed2
        lda     #$FF    ; maximum frequency value
        sta     $D40E   ; voice 3 frequency low byte
        sta     $D40F   ; voice 3 frequency high byte
        lda     #$81    ; noise waveform, gate bit off
        sta     $D412   ; voice 3 control register
        rts

;==============================================================================
; Method 5
; Seed Generator
; Accumulator = Random number
; https://codebase64.org/doku.php?id=base:fast_8bit_ranged_random_numbers
; Note - Not 100% random, Noticed patterns however it can do the job :)
;==============================================================================

RndSeed1
        lda     $d012
        beq     @doEor
        clc
        asl
        beq     @noEor    ;if the input was $80, skip the EOR
        bcc     @noEor
@doEor      
        eor     #$1d
@noEor   
        rts

;==============================================================================
; Method 6
; pseudo-random routine
; Output - value in random+1 (Or Accumulator) and random
; https://codebase64.org/doku.php?id=base:16bit_pseudo_random_generator
;==============================================================================

GetRandom

         lda    $dc04
         sta    _101_RNDv2

         lda    $dc05
         sta    _101_RNDv1  

         lda    _101_RNDv2
         sta    _101_RNDv3
         lda    _101_RNDv1
         asl    
         rol    _101_RNDv3
         asl    
         rol    _101_RNDv3

         clc
         adc    _101_RNDv1
         pha
         lda    _101_RNDv3
         adc    _101_RNDv2
         sta    _101_RNDv2
         pla

         adc    #$11
         sta    _101_RNDv1
         lda    _101_RNDv2
         adc    #$36
         sta    _101_RNDv2

         rts

;==============================================================================
; Method 7
; pseudo-random routine, value in random+1 (akku also) and random
; https://codebase64.org/doku.php?id=base:another_16bit_pseudo_random_generator
;==============================================================================

Randomise
        lda     _101_Seed+1
        asl
        asl
        eor     _101_Seed+1
        asl
        eor     _101_Seed+1
        asl
        asl
        eor     _101_Seed+1
        asl
        rol     _101_Seed
        rol     _101_Seed+1
        rts

;##############################################################################
; Random Support Routines
;##############################################################################

;==============================================================================
; Divide number based on range
; Input - A holding random value
;       - Y divisor
; Output - A Random Number divided
;==============================================================================

RandomValue
        sta     Dividend        ; The number to be divided
        beq     @div2
        sty     Divisor         ; The number that will divide
        ldy     #$0
        sec
@div1
        sbc     Divisor
        bcc     @div2
        sty     Result
        iny
        bne     @div1
@div2    
        rts


;==============================================================================
; This routine does the following
; 1. Uses the Noise Genertor Method RNDSoundX to get a Value in $D41B
; 2. Specify a range of numbers from 0 to N
; Input - Store Range in _101_Range
;       - Store mask value of bits that are not used
; Output - A = Randon Value within Range
;==============================================================================

SoundRange
        lda     $d41b
        and     _101_mask
        cmp     _101_range
        bcs     SoundRange      ; branch if > than range
        rts


;==============================================================================
; Data Area
;==============================================================================

; Range Values

_101_range
        byte    $00

_101_mask               ; Masks the bits that you need
        byte    $00     ; Eg if range is from 0 to 10 or %00001010
                        ; then masks needs to be %00001111
                        ; This prevents numbers higher than 16 to be truncated
                        ; and only lower nibble in this case is used

; Display Number Variables

Dividend
        byte    $00
Divisor
        byte    $00
Result
        byte    $00

; Temporary Area

_101_RNDv1
        byte    $00
_101_RNDv2
        byte    $00
_101_RNDv3
        byte    $00

; Seed Values

_101_Seed
        byte    $01,$20