;============================================================================
; StatusBar module
;
; Summary:      Contains application status bar functionality.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;============================================================================

#include-once

#include <Math.au3>

Global Const $STATUS_BAR = 0
Global Const $STATUS_BAR_LABEL = 1
Global Const $STATUS_BAR_ALPHA = 2

Const $BAR_DEFAULT_ALPHA = 200
Const $BAR_DEFAULT_FADE = 4
Const $BAR_DEFAULT_FONT_NAME = "Lucida Console"
Const $BAR_DEFAULT_FONT_SIZE = 9
Const $BAR_DEFAULT_FONT_WEIGHT = 400
Const $BAR_DEFAULT_HEIGHT = 24
Const $BAR_DEFAULT_MOVE = 3
Const $BAR_DEFAULT_WIDTH = 400
Const $BAR_ENUM_COUNT = 3
Const $BAR_MIN_HEIGHT = 24
Const $BAR_MIN_WIDTH = 256

; Status bar functions

;===========================================================================
; StatusBar_Close()
;
; Summary:      Destroys the given status bar object.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func StatusBar_Close( $barObject )
    If ( Not IsArray( $barObject ) ) Then
        Return False
    Else
        Local $barControl = $barObject[ $STATUS_BAR ]
    EndIf

    If ( IsHwnd( $barControl ) ) Then
        GUIFadeOut( $barControl, $BAR_DEFAULT_FADE )
        GUIDelete( $barControl )
    EndIf
EndFunc

;===========================================================================
; StatusBar_Create()
;
; Summary:      Creates a new status bar object.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func StatusBar_Create( _
    $barLeft = 0, _
    $barTop = 0, _
    $barWidth = $BAR_DEFAULT_WIDTH, _
    $barHeight = $BAR_DEFAULT_HEIGHT, _
    $barAlpha = $BAR_DEFAULT_ALPHA )

	Local $barControl
    Local $barLabel
    Local $barObject[ $BAR_ENUM_COUNT ]

    $barControl = GUICreate( "", $barWidth, $barHeight, $barLeft, $barTop, $WS_POPUP )
    $barLabel = GUICtrlCreateLabel( "", 12, 7, $barWidth - 12, $barHeight - 7 )

    GUICtrlSetFont( _
        $barLabel, _
        $BAR_DEFAULT_FONT_SIZE, _
        $BAR_DEFAULT_FONT_WEIGHT, _
        0, _
        $BAR_DEFAULT_FONT_NAME _
    )
    WinSetOnTop( $barControl, "", 1 )

    GUIFadeIn( $barControl, $BAR_DEFAULT_FADE, $barAlpha )

    $barObject[ $STATUS_BAR ] = $barControl
    $barObject[ $STATUS_BAR_LABEL ] = $barLabel
    $barObject[ $STATUS_BAR_ALPHA ] = $barAlpha

    Return $barObject
EndFunc

;===========================================================================
; StatusBar_Follow()
;
; Summary:      Resize and reposition the given status bar.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func StatusBar_Follow( $barObject )
    If ( Not IsArray( $barObject ) ) Then Return False

    Local $barTop

    If ( StatusBar_Visible( $barObject ) ) Then
        $barTop = _Min( _
            $ActiveTop + $ActiveHeight, _
            $DesktopBottom - StatusBar_Height( $barObject ) )

        StatusBar_Resize( $barObject, $ActiveWidth, Default )
        StatusBar_Move( $barObject, $ActiveLeft, $barTop, $BAR_DEFAULT_MOVE )
    EndIf
EndFunc

;===========================================================================
; StatusBar_Height()
;
; Summary:      Return the given status bar height.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func StatusBar_Height( $barObject )
    If ( Not IsArray( $barObject ) ) Then Return False
    Local $metrics = WinGetPos( $barObject[ $STATUS_BAR ] )
    Return $metrics[ 3 ]
EndFunc

;===========================================================================
; StatusBar_Move()
;
; Summary:      Move the given status bar to the give coordinates.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func StatusBar_Move( $barObject, $barLeft, $barTop, $moveSpeed = 1 )
    If ( Not IsArray( $barObject ) ) Then
        Return False
    Else
        Local $barControl = $barObject[ $STATUS_BAR ]
    EndIf

    If ( IsHwnd( $barControl ) ) Then
        WinMove( $barControl, "", $barLeft, $barTop, Default, Default, $moveSpeed )
    EndIf
EndFunc

;===========================================================================
; StatusBar_Resize()
;
; Summary:      Resize the given status bar to the given width and height.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func StatusBar_Resize( $barObject, $barWidth = Default, $barHeight = Default )
    If ( Not IsArray( $barObject ) ) Then
        Return False
    Else
        Local $barControl = $barObject[ $STATUS_BAR ]
    EndIf

    If ( $barHeight = Default ) Then $barHeight = StatusBar_Height( $barObject )
    If ( $barWidth = Default ) Then $barWidth = StatusBar_Width( $barObject )

    If ( IsHwnd( $barControl ) ) Then
        $barHeight = _Max( $barHeight, $BAR_MIN_HEIGHT )
        $barWidth = _Max( $barWidth, $BAR_MIN_WIDTH )

        WinMove( $barControl, "", Default, Default, $barWidth, $barHeight )
    EndIf
EndFunc

;===========================================================================
; StatusBar_Text()
;
; Summary:      Set the current text for the given status bar.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func StatusBar_Text( $barObject, $barText = "" )
    If ( Not IsArray( $barObject ) ) Then
        Return False
    Else
        Local $barLabel = $barObject[ $STATUS_BAR_LABEL ]
    EndIf

    If ( $barText = "" ) Then
        Return GUICtrlRead( $barLabel )
    Else
        If ( GUICtrlRead( $barLabel ) <> $barText ) Then
            GUICtrlSetData( $barLabel, $barText )
        EndIf
    EndIf
EndFunc

;===========================================================================
; StatusBar_Visible()
;
; Summary:      Determine whether the given status bar is visible.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func StatusBar_Visible( $barObject )
    If ( Not IsArray( $barObject ) ) Then Return False

    If ( BitAnd( WinGetState( $barObject[ $STATUS_BAR ] ), 2 ) ) Then
        Return True
    Else
        Return False
    EndIf
EndFunc

;===========================================================================
; StatusBar_Width()
;
; Summary:      Return the given status bar widthh.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func StatusBar_Width( $barObject )
    If ( Not IsArray( $barObject ) ) Then Return False
    Local $metrics = WinGetPos( $barObject[ $STATUS_BAR ] )
    Return $metrics[ 2 ]
EndFunc

; Support functions

;===========================================================================
; GUIFadeIn()
;
; Summary:      Applies a fade in animation to a given GUI window.
;               http://www.autoitscript.com/forum/topic/106766-gui-fade-in-fade-out/ 
; Author(s):    Insignia96, Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func GUIFadeIn( $guiHandle, $fadeSpeed = 4, $fadeTo = 255 )
    Local $i

    WinSetTrans( $guiHandle, "", 0 )
    GUISetState( @SW_SHOW, $guiHandle )

    For $i = 1 To $fadeTo Step $fadeSpeed
        WinSetTrans( $guiHandle, "", $i )
        Sleep( 1 )
    Next
EndFunc

;===========================================================================
; GUIFadeOut()
;
; Summary:      Applies a fade out animation to a given GUI window.
;               http://www.autoitscript.com/forum/topic/106766-gui-fade-in-fade-out/ 
; Author(s):    Insignia96, Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func GUIFadeOut( $guiHandle, $fadeSpeed = 4 )
    Local $i

    Local $fadeFrom = _Max( 1, WinGetTrans( $guiHandle ) )

    For $i = $fadeFrom To 1 Step -( $fadeSpeed )
        WinSetTrans( $guiHandle, "", $i )
        Sleep( 1 )
    Next

    WinSetTrans( $guiHandle, "", 0 )
    GUISetState( @SW_HIDE, $guiHandle )
EndFunc

;===========================================================================
; TaskBar_Height()
;
; Summary:      Returns the current Windows taskbar height.
;               http://pastebin.com/D1eLuez3
; Author(s):    Unknown, Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func TaskBar_Height()
    Local $barPos = WinGetPos( "[CLASS:Shell_TrayWnd; W:" & @DesktopWidth & "]" )
    Return $barPos[ 3 ]
EndFunc

;===========================================================================
; WinGetTrans()
;
; Summary:      Returns a given window's current transparency value.
;               http://www.autoitscript.com/forum/topic/104121-wingettrans-by-valik/ 
; Author(s):    Melba23, Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func WinGetTrans( $sTitle, $sText = "" )
    Local $hWnd = WinGetHandle( $sTitle, $sText )
    Local $ptr = DllStructCreate( "int" )
    Local $out = DllCall( _
        "user32.dll", _
        "int", "GetLayeredWindowAttributes", _
        "hwnd", $hWnd, _
        "ulong_ptr", 0, _
        "int_ptr", DllStructGetPtr( $ptr ), _
        "ulong_ptr", 0 )

    If ( Not $hWnd ) Then Return -1

    If (@error Or Not $out[ 0 ] ) Then
        Return -1
    Else
        Return DllStructGetData( $ptr, 1 )
    EndIf
EndFunc

