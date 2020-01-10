;==============================================================================
; Constants V1.0
;
; In future this will be a separate file
;==============================================================================

;Base Addresses
ScrBase         =       $0400
ScrCol          =       $d800

ZeroPtr1Low     =       $03
ZeroPtr1High    =       $04
ZeroPtr2Low     =       $05
ZeroPtr2High    =       $06

;Temp Memory Locations in Page Zero
ZeroTmpMem01    =       $02
ZeroTmpMem02    =       $2A
ZeroTmpMem03    =       $52

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