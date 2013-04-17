;============================================================================
; Keyboard module
;
; Summary:      Contains all keyboard capturing and processing functionality.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;============================================================================

#include-once

#include <WinAPI.au3>
#include "KeyConstants.au3"

Opt( "ExpandVarStrings", 1 )

Global Const $KEY_DECODE_CODE = 1
Global Const $KEY_DECODE_SHIFT = 2
Global Const $KEY_DECODE_USER = 3

Global $BlockInput = False
Global $KeyDll = 0
Global $KeyDownBuffer = ""
Global $KeyHandle = 0
Global $KeyHook = 0
Global $KeyProc = 0
Global $KeySendBuffer = ""
Global $KeyShiftBuffer = ""
Global $RawBuffer = ""
Global $UserBuffer = ""

Const $KEY_CODE_DELIM = "#"
Const $KEY_STATE_DOWN = "\+"
Const $KEY_STATE_UP = "\-"
Const $KEY_PRESS_BOTH = 1
Const $KEY_PRESS_UP = 2
Const $KEY_PRESS_DOWN = 3
Const $KEY_PATTERN_FULL = "(\\\+|\\\-){1}(\d{1,3})+"
Const $KEY_PATTERN_USER = "(\[\w*\]|[[:print:]]?)"

;===========================================================================
; BufferAddItem()
;
; Summary:      Adds a new item to a given buffer.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func BufferAddItem( ByRef $buffer, $item )
    $buffer &= $item
    Return $buffer
EndFunc

;===========================================================================
; BufferCheckItem()
;
; Summary:      Checks a given buffer for the presence of an item.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func BufferCheckItem( ByRef $buffer, ByRef $item )
    Return StringInStr( $buffer, $item, 1, 1 )
EndFunc

;===========================================================================
; BufferRemoveItem()
;
; Summary:      Removes an item from a given buffer.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func BufferRemoveItem( ByRef $buffer, ByRef $item )
    Return StringReplace( $buffer, $item, "", 1, 1 )
EndFunc

;===========================================================================
; CaptureKey()
;
; Summary:      Captures individual keystrokes from the Windows system
;               keyboard hook buffer.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func CaptureKey( $nCode, $wParam, $lParam )
    Local $canSendKey = False
    Local $sentByApp = False
    Local $keyCode
    Local $keyHookStruct
    Local $keyState
    Local $keyString
    Local $processKey
    Local $return

    If ( $nCode >= 0 ) Then
        $keyHookStruct = DllStructCreate( "dword;dword;dword;dword;ptr", $lParam )
        $keyCode = $KeyData[ DllStructGetData( $keyHookStruct, 1 ) ][ $KEY_DATA_REMAP ]

        Switch $wParam
            Case 256
                $keyState = $KEY_STATE_DOWN
            Case 257
                $keyState = $KEY_STATE_UP
        EndSwitch

        ; If keystroke was sent by the application, remove it from the send buffer and allow
        ; it to pass through the system keyboard buffer.  Otherwise, add keystroke to the main
        ; application keyboard buffer.

        $keyString = $keyState & $keyCode
        $sentByApp = BufferCheckItem( $KeySendBuffer, $keyString )

        If ( $sentByApp ) Then
            $KeySendBuffer = BufferRemoveItem( $KeySendBuffer, $keyString )
            $canSendKey = True
        Else
            $keyString = ProcessKey( $keyCode, $keyState )
            $canSendKey = False

            BufferAddItem( $RawBuffer, $keyString )
            BufferAddItem( $UserBuffer, DecodeKey( $keyString, $KEY_DECODE_SHIFT ) )
        EndIf
    EndIf

    $return = _WinAPI_CallNextHookEx( $KeyHook, $nCode, $wParam, $lParam )

    If ( $BlockInput ) Then
        If ( $canSendKey ) Then
            Return $return
        Else
            Return 1
        EndIf
    Else
        Return $return
    EndIf
EndFunc

;===========================================================================
; DecodeKey()
;
; Summary:      Processes an encoded keystring into a user-friendly format.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func DecodeKey( $keyString, $decodeType = $KEY_DECODE_USER )
    Local $i
    Local $isShifted = False
    Local $keyCode
    Local $keyCodes
    Local $keyState
    Local $userString

    $keyCodes = StringRegExp( $keyString, $KEY_PATTERN_FULL, 3 )

    For $i = 0 To UBound( $keyCodes ) - 1 Step 2
        $keyState = $keyCodes[ $i ]
        $keyCode = $keyCodes[ $i + 1 ]

        Switch $keyCode
            Case 16, 160, 161
                If ( $keyState == $KEY_STATE_DOWN ) Then
                    $isShifted = True
                Else
                    $isShifted = False
                EndIf
        EndSwitch

        If ( $keyState == $KEY_STATE_DOWN ) Then
            Switch $decodeType
                Case $KEY_DECODE_CODE
                    $userString &= $KEY_STATE_DOWN & $KeyData[ $keyCode ][ $KEY_DATA_CODE ]
                Case $KEY_DECODE_SHIFT
                    If ( $isShifted ) Then
                        $userString &= $KeyData[ $keyCode ][ $KEY_DATA_SHIFT ]
                    Else
                        $userString &= $KeyData[ $keyCode ][ $KEY_DATA_DESC ]
                    EndIf
                Case $KEY_DECODE_USER
                    $userString &= $KEY_STATE_DOWN & $KeyData[ $keyCode ][ $KEY_DATA_DESC ]
            EndSwitch
        EndIf
    Next

    If ( StringLeft( $userString, 1 ) == $KEY_STATE_DOWN ) Then
        $userString = StringTrimLeft( $userString, 1 )
    EndIf

    Return $userString
EndFunc

;===========================================================================
; DisableKeys()
;
; Summary:      Disables the keyboard module functionality.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func DisableKeys()
    If ( $KeyDll = 0 ) Then Return False

    SendRawKey( "[Alt]", $KEY_PRESS_UP )
    SendRawKey( "[Ctrl]", $KEY_PRESS_UP )
    SendRawKey( "[Shift]", $KEY_PRESS_UP )

    _WinAPI_UnhookWindowsHookEx( $keyHook )
    DllCallbackFree( $KeyProc )
    DllClose( $KeyDll )
EndFunc

;===========================================================================
; EnableKeys()
;
; Summary:      Enables the keyboard module functionality.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func EnableKeys()
    $KeyDll = DllOpen( "user32.dll" )
    $KeyProc = DllCallbackRegister( "CaptureKey", "long", "int;wparam;lparam" )
    $KeyHandle = _WinAPI_GetModuleHandle( 0 )
    $KeyHook = _WinAPI_SetWindowsHookEx( _
        $WH_KEYBOARD_LL, _
        DllCallbackGetPtr($KeyProc), _
        $KeyHandle )
EndFunc

;===========================================================================
; EncodeKey()
;
; Summary:      Encodes raw key value data into a standard format.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func EncodeKey( $keyString )
    Local $i, $j
    Local $innerCodes
    Local $keyCode
    Local $keyCodes
    Local $keyIndex
    Local $keyState
    Local $leftCodes
    Local $matchPartial = "^[0-9\$KEY_STATE_DOWN$]*$"
    Local $matchShift = "^(?:(?!\\\+|\\\-).)*$"
    Local $matchUser = "^[A-z\+\[\]]*$"
    Local $returnCodes
    Local $rightCodes

    Select
        Case StringRegExp( $keyString, $matchPartial )
            $keyCodes = StringRegExp( $keyString, $KEY_PATTERN_FULL, 3 )

            If ( UBound( $keyCodes ) > 0 ) Then
                For $i = 0 To UBound( $keyCodes ) - 1 Step 2
                    $keyState = $keyCodes[ $i ]
                    $keyCode = $keyCodes[ $i + 1 ]

                    If ( $keyState == $KEY_STATE_DOWN ) Then
                        $innerCodes &= $KEY_STATE_DOWN & $keyCode
                        $rightCodes = $KEY_STATE_UP & $keyCode & $rightCodes
                    EndIf
                Next
            EndIf

            Return $innerCodes & $rightCodes
        Case StringRegExp( $keyString, $matchShift )
            $keyCodes = StringRegExp( $keyString, $KEY_PATTERN_USER, 3 )
            $keyString = ""

            If ( UBound( $keyCodes ) > 0 ) Then
                For $i = 0 To UBound( $keyCodes ) - 1
                    If ( $keyCodes[ $i ] <> "" ) Then
                        $keyString &= $KEY_STATE_DOWN & $keyCodes[ $i ]
                    EndIf
                Next
            EndIf

            ContinueCase
        Case StringRegExp( $keyString, $matchUser )
            $keyCodes = StringSplit( $keyString, $KEY_STATE_DOWN )

            If ( UBound( $keyCodes ) = 0 ) Then Return ""

            $innerCodes = ""
            $leftCodes = ""
            $rightCodes = ""

            For $i = 1 To UBound( $keyCodes ) - 1
                If ( $keyCodes[ $i ] = "" ) Then ContinueLoop

                For $j = 0 To UBound( $KeyData, 1 ) - 1
                    Select
                        Case ( $keyCodes[ $i ] == $KeyData[ $j ][ $KEY_DATA_DESC ] )
                            If ( $KeyData[ $j ][ $KEY_DATA_MOD ] ) Then
                                $leftCodes = $KEY_STATE_DOWN & $j
                                $rightCodes = $KEY_STATE_UP & $j
                            Else
                                $innerCodes = _
                                    $leftCodes _
                                    & $KEY_STATE_DOWN _
                                    & $j _
                                    & $KEY_STATE_UP _
                                    & $j _
                                    & $rightCodes
                                $leftCodes = ""
                                $rightCodes = ""
                            EndIf

                            ExitLoop
                        Case ( $keyCodes[ $i ] == $KeyData[ $j ][ $KEY_DATA_SHIFT ] )
                            If ( $KeyData[ $j ][ $KEY_DATA_MOD ] ) Then
                                $leftCodes = $KEY_STATE_DOWN & $j
                                $rightCodes = $KEY_STATE_UP & $j
                            Else
                                $innerCodes = _
                                    "$KEY_STATE_DOWN$16" _
                                    & $leftCodes _
                                    & $KEY_STATE_DOWN _
                                    & $j _
                                    & $KEY_STATE_UP _
                                    & $j _
                                    & $rightCodes _
                                    & "$KEY_STATE_UP$16"
                                $leftCodes = ""
                                $rightCodes = ""
                            EndIf

                            ExitLoop
                    EndSelect
               Next

               $returnCodes &= $innerCodes
            Next

            Return $returnCodes
        Case Else
            Return $keyString
    EndSelect
EndFunc

;===========================================================================
; ProcessKey()
;
; Summary:      Processes a given keystroke into one of several global
;               application key buffers.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func ProcessKey( $keyCode, $keyState = $KEY_STATE_DOWN )
    Local $keyCodes
    Local $keyDown = $KEY_STATE_DOWN & $keyCode
    Local $keyUp = $KEY_STATE_UP & $keyCode
    Local $isModifier = $KeyData[ $keyCode ][ $KEY_DATA_MOD ]
    Local $isPressed = BufferCheckItem( $KeyDownBuffer, $keyDown )
    Local $return = ""

    Switch $keyState
        Case $KEY_STATE_DOWN

            ; If a modifier key was pressed, add it to the secondary shift buffer.
            ; We will use this buffer to augment normal keystrokes being sent to
            ; the application keyboard buffer.

            If ( $isModifier ) Then
                If ( Not $isPressed ) Then
                    BufferAddItem( $KeyShiftBuffer, $keyDown )
                EndIf
            Else

                ; If the same physical key is being held down, ensure that the appropriate
                ; key "up" event is being passed to the buffer before each key "down" event
                ; is repeated after the system key repeat delay.

                If ( $isPressed ) Then
                    $return = _
                        $keyUp & _
                        StringReplace( $KeyShiftBuffer, $KEY_STATE_DOWN, $KEY_STATE_UP, 1, 1 )
                EndIf

                $return &= $KeyShiftBuffer & $keyDown
            EndIf

            If ( Not $isPressed ) Then
                $KeyDownBuffer &= $keyDown
            Endif
        Case $KEY_STATE_UP
            If ( Not $isModifier ) Then
                $return = _
                    $keyUp & _
                    StringReplace( $KeyShiftBuffer, $KEY_STATE_DOWN, $KEY_STATE_UP, 1, 1 )
            EndIf

            If ( $isPressed ) Then
                $KeyDownBuffer = BufferRemoveItem( $KeyDownBuffer, $keyDown )
                $KeyShiftBuffer = BufferRemoveItem( $KeyShiftBuffer, $keyDown )
            EndIf
    EndSwitch

    Return $return
EndFunc

;===========================================================================
; SendKeyString()
;
; Summary:      Sends an encoded keystring to the Windows keyboard buffer.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func SendKeyString( $keyString, $repeatCount = 1 )
    Local $i
    Local $j
    Local $keyState
    Local $keyCode
    Local $keyCodes

    SendRawKey( 16, $KEY_PRESS_UP )

    For $i = 1 To $repeatCount
        $keyCodes = StringRegExp( $keyString, $KEY_PATTERN_FULL, 3 )

        For $j = 0 To UBound( $keyCodes ) - 1 Step 2
            $keyState = $keyCodes[ $j ]
            $keyCode = $keyCodes[ $j + 1 ]

            Switch $keyState
                Case $KEY_STATE_DOWN
                    SendRawKey( $keyCode, $KEY_PRESS_DOWN )
                Case $KEY_STATE_UP
                    SendRawKey( $keyCode, $KEY_PRESS_UP )
            EndSwitch
        Next
    Next
EndFunc

;===========================================================================
; SendRawKey()
;
; Summary:      Sends a raw keystroke event to the Windows keyboard buffer.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func SendRawKey( $keyCode, $keyState = $KEY_PRESS_BOTH )
    Local $keyString

    Switch $keyState
        Case $KEY_PRESS_DOWN, $KEY_PRESS_BOTH
            $keyString = $KEY_STATE_DOWN & $keyCode

            If ( Not BufferCheckItem( $KeySendBuffer, $keyString ) ) Then
                BufferAddItem( $KeySendBuffer, $keyString )
            EndIf

            DllCall( _
                $KeyDll, _
                'int', 'keybd_event', _
                'int', $keyCode, _
                'int', 0, _
                'int', BitOr($KEY_EXTENDED_KEY, 0 ), _
                'ptr', 0 _
            )
        Case $KEY_PRESS_UP, $KEY_PRESS_BOTH
            $keyString = $KEY_STATE_UP & $keyCode

            If ( Not BufferCheckItem( $KeySendBuffer, $keyString ) ) Then
                BufferAddItem( $KeySendBuffer, $keyString )
            EndIf

            DllCall( _
                $KeyDll, _
                'int', 'keybd_event', _
                'int', $keyCode, _
                'int', 0, _
                'int', BitOr( $KEY_EXTENDED_KEY, 2 ), _
                'ptr', 0 _
            )
    EndSwitch
EndFunc

