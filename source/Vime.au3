;============================================================================
; Vime module
;
; Summary:      Contains primary Vime application functionality.
; Author(s):    Adam Parrott
; Updated:      2012-04-27
;============================================================================

#AutoIt3Wrapper_Icon=resources\logo-small.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=Emulates basic Vim editor functionality in any Windows-based application.
#AutoIt3Wrapper_Res_Description=Vim Everywhere
#AutoIt3Wrapper_Res_Fileversion=0.1.2.0
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Outfile=..\release\Vime.exe

Opt( "ExpandVarStrings", 1 )
Opt( "GUICloseOnESC", 0 )
Opt( "GUIOnEventMode", 1 )
Opt( "MustDeclareVars", 1 )
Opt( "TrayAutoPause", 0 )
Opt( "TrayIconHide", 0 )
;Opt( "TrayMenuMode", 1 )

#include <Array.au3>
#include "include\Keyboard.au3"
#include "include\StatusBar.au3"
#include "include\VimeActions.au3"
#include "include\VimeConstants.au3"

FileInstall( "include\DefaultKeys.ini", @TempDir & "\" & $VI_FILE_DEFAULT_KEYS, 1 )

Global $ActiveBuffer
Global $ActiveControl
Global $ActiveControlType
Global $ActiveFunction
Global $ActiveHeight
Global $ActiveLeft
Global $ActiveMapBuffer
Global $ActiveMapCount
Global $ActiveMapExtra
Global $ActivePos
Global $ActiveTop
Global $ActiveRegister
Global $ActiveWidth
Global $ActiveWindow
Global $AppMode
Global $AppModeDesc
Global $AppToggleKeys
Global $DesktopBottom
Global $DebugInfo
Global $EditMode
Global $EditModeDesc
Global $InsertEscapeBuffer
Global $InsertEscapeCheck
Global $InsertEscapeCount
Global $KeyExtended
Global $KeyMappings[ 1 ][ 3 ]
Global $LastCommand
Global $LastCommandCount
Global $LastCommandExtra
Global $PrevHeight
Global $PrevLeft
Global $PrevTop
Global $PrevWidth
Global $PrevWindow
Global $StatusBar

Main()

; Main aplication loop functions

;===========================================================================
; ConfigureDefaults()
;
; Summary:      Configures application defaults.
; Author(s):    Adam Parrott
; Updated:      2012-04-27
;===========================================================================

Func ConfigureDefaults()
    $AppToggleKeys = $VI_APP_TOGGLE_KEYS
    $DesktopBottom = @DesktopHeight - TaskBar_Height()
    $KeyMappings = ReadDefaultKeys()

    TraySetIcon( $VI_FILE_APP_ICON )
    UpdateMetrics()
    App_Disable()
EndFunc

;===========================================================================
; Main()
;
; Summary:      Default application lifecycle function.
; Author(s):    Adam Parrott
; Updated:      2012-04-27
;===========================================================================

Func Main()
    ConfigureDefaults()

    While 1
        If App_IsActive() Then
            CheckInput()
            UpdateMetrics()
            UpdateStatusBar()
        EndIf

        Sleep( $VI_DELAY_MAIN_LOOP )
    WEnd
EndFunc

; Application object functions

;===========================================================================
; App_Disable()
;
; Summary:      Disables application functionality.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func App_Disable()
    StatusBar_Close( $StatusBar )
    DisableKeys()
    HotKeySet( $AppToggleKeys, "App_Toggle" )
    TraySetToolTip( "Vime | Disabled" )

    $AppMode = $VI_APP_MODE_OFF
    $StatusBar = 0
EndFunc

;===========================================================================
; App_Enable()
;
; Summary:      Enables application functionality.
; Author(s):    Adam Parrott
; Updated:      2012-04-27
;===========================================================================

Func App_Enable()
    Local $controlLeft
    Local $controlTop
    Local $controlWidth
    Local $statusObj

    UpdateMetrics()

    If IsArray( $ActivePos ) Then
        $controlLeft = $ActivePos[ 0 ]
        $controlTop = $ActivePos[ 1 ] + $ActivePos[ 3 ]
        $controlWidth = $ActivePos[ 2 ]

        If ( $StatusBar = 0 ) Then
            $StatusBar = StatusBar_Create( $controlLeft, $controlTop, $controlWidth )
            StatusBar_Text( $StatusBar, $VI_BAR_TEXT_MASK )
        EndIf
    EndIf

    ChangeEditMode( $VI_MODE_NORMAL )
    EnableKeys()
    HotKeySet( $AppToggleKeys )
    TraySetToolTip( "Vime | Enabled" )

    $AppMode = $VI_APP_MODE_ON
EndFunc

;===========================================================================
; App_IsActive()
;
; Summary:      Determines whether Vime is currently enabled.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func App_IsActive()
    If ( $AppMode = $VI_APP_MODE_ON ) Then
        Return True
    Else
        Return False
    EndIf
EndFunc

;===========================================================================
; App_ShowMapKeys()
;
; Summary:      Shows a user dialog of the current keymap configuration.
; Author(s):    Adam Parrott
; Updated:      2012-04-17
;===========================================================================

Func App_ShowMapKeys()
    _ArrayDisplay( $KeyMappings, "Vime Key Definitions", -1, 0, "", "|", "ID|Mode|Keys|Function" )
EndFunc

;===========================================================================
; App_Toggle()
;
; Summary:      Enables or disables Vime functionality.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func App_Toggle()
    Switch $AppMode
        Case $VI_APP_MODE_ON
            App_Disable()
        Case $VI_APP_MODE_OFF
            App_Enable()
    EndSwitch
EndFunc

; Editor mode functions

;===========================================================================
; ChangeEditMode()
;
; Summary:      Changes the current Vime editing mode (Normal or Insert).
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func ChangeEditMode( $modeType = $VI_MODE_NORMAL )
    Switch $modeType
        Case $VI_MODE_INSERT
            $EditMode = $VI_MODE_INSERT
            $EditModeDesc = $VI_MODE_INSERT_DESC
            $BlockInput = False
        Case $VI_MODE_NORMAL
            $EditMode = $VI_MODE_NORMAL
            $EditModeDesc = $VI_MODE_NORMAL_DESC
            $BlockInput = True
    EndSwitch

    FlushBuffers()
EndFunc

;===========================================================================
; CheckInput()
;
; Summary:      Processes and validates new keyboard buffer input data.
; Author(s):    Adam Parrott
; Updated:      2012-04-14
;===========================================================================

Func CheckInput()
    Const $MATCH_ITEM_COUNT = 3
    Const $MATCH_REPEAT = 0
    Const $MATCH_BUFFER = 1
    Const $MATCH_COMMAND = 2

    Local $curMatch
    Local $curResult
    Local $fullMatch
    Local $i
    Local $matchItem[ $MATCH_ITEM_COUNT ]
    Local $prevMatch
    Local $prevResult

    If ( $ActiveBuffer = "" ) And ( $RawBuffer = "" ) Then
        Return False
    Else
        $ActiveBuffer &= $UserBuffer
        $UserBuffer = ""
        $RawBuffer = ""
    EndIf

    Switch $EditMode
        Case $VI_MODE_NORMAL
            $fullMatch = StringRegExp( $ActiveBuffer, $VI_MODE_NORMAL_PATTERN, 3 )

            If ( @error <> 0 ) Then
                $ActiveBuffer = ""
                Return False
            EndIf

            For $i = 0 To UBound( $fullMatch ) - 1 Step $MATCH_ITEM_COUNT
                $matchItem[ $MATCH_REPEAT ] = $fullMatch[ $i ]
                $matchItem[ $MATCH_BUFFER ] = $fullMatch[ $i + 1 ]
                $matchItem[ $MATCH_COMMAND ] = $fullMatch[ $i + 2 ]

                $curMatch = _
                    $matchItem[ $MATCH_REPEAT ] _
                    & $matchItem[ $MATCH_BUFFER ] _
                    & $matchItem[ $MATCH_COMMAND ]

                If ( $curMatch == $prevMatch ) Then
                    $curResult = $prevResult
                Else
                    $curResult = CheckInput_Normal( _
                        $matchItem[ $MATCH_COMMAND ], _
                        $matchItem[ $MATCH_REPEAT ], _
                        $matchItem[ $MATCH_BUFFER ] )

                    Switch $curResult
                        Case $VI_MATCH_PARTIAL
                            ; Allow result to pass through.
                        Case $VI_MATCH_NONE, $VI_MATCH_FULL
                            $ActiveBuffer = StringReplace( $ActiveBuffer, $curMatch, "" )
                    EndSwitch
                EndIf

                $prevMatch = $curMatch
                $prevResult = $curResult
            Next
        Case $VI_MODE_INSERT
            $InsertEscapeBuffer &= $ActiveBuffer
            $fullMatch = StringRegExp( $ActiveBuffer, $VI_MODE_INSERT_PATTERN, 3 )

            If ( @error <> 0 ) Then
                $ActiveBuffer = ""
                Return False
            EndIf

            For $i = 0 To UBound( $fullMatch ) - 1 Step 1
                $curMatch = $fullMatch[ $i ]

                If ( $curMatch == $prevMatch ) Then
                    $curResult = $prevResult
                Else
                    $curResult = CheckInput_Insert( $curMatch )

                    Switch $curResult
                        Case $VI_MATCH_PARTIAL
                            ; Allow result to pass through
                        Case $VI_MATCH_NONE, $VI_MATCH_FULL
                            $ActiveBuffer = StringReplace( $ActiveBuffer, $curMatch, "" )
                    EndSwitch
                EndIf

                $prevMatch = $curMatch
                $prevResult = $curResult
            Next
    EndSwitch

    InsertEscape_Check()
EndFunc

;===========================================================================
; CheckInput_Insert()
;
; Summary:      Validates a given input command against Insert mode rules.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func CheckInput_Insert( $inCommand )
    Local $i
    Local $mapKey
    Local $mapFunction
    Local $mapMode
    Local $result = False

    For $i = 0 To UBound( $KeyMappings, 1 ) - 1
        $mapKey = $KeyMappings[ $i ][ $VI_MAP_KEY ]
        $mapMode = $KeyMappings[ $i ][ $VI_MAP_MODE ]

        If ( $mapMode == $VI_MODE_INSERT ) Then

            ; If we find an exact match in the global keymapping with the current command,
            ; set the global map variables (command, et al) with the parameters values
            ; passed to this function and then call the mapped user function.

            If ( $mapKey == $inCommand ) Then
                $mapFunction = $KeyMappings[ $i ][ $VI_MAP_FUNC ]

                $ActiveFunction = $mapFunction
                $ActiveMapExtra = $inCommand

                Call( $mapFunction )

                If ( @error = 0xDEAD And @extended = 0xBEEF ) Then
                    $result = $VI_MATCH_NONE
                Else
                    $result = $VI_MATCH_FULL
                EndIf

                ExitLoop

            ; Otherwise, test whether current command has a partial match in the global
            ; keymapping list.  If it does, return a partial match flag so the program can
            ; wait for the rest of the command on the next pass before clearing the buffer.

            ElseIf ( StringLeft( $mapKey, StringLen( $inCommand ) ) == $inCommand ) Then
                $result = $VI_MATCH_PARTIAL
                ExitLoop
            EndIf
        EndIf
    Next

    Return $result
EndFunc

;===========================================================================
; CheckInput_Normal()
;
; Summary:      Validates a given input command against Normal mode rules.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func CheckInput_Normal( $inCommand, $inCount = 0, $inBuffer = "" )
    Local $i
    Local $mapKey
    Local $mapFunction
    Local $mapMode
    Local $result = $VI_MATCH_NONE

    $inCount = Number( $inCount )

    For $i = 0 To UBound( $KeyMappings, 1 ) - 1
        $mapKey = $KeyMappings[ $i ][ $VI_MAP_KEY ]
        $mapMode = $KeyMappings[ $i ][ $VI_MAP_MODE ]

        If ( $mapMode == $VI_MODE_NORMAL ) Then

            ; If we find an exact match in the global keymapping with the current command,
            ; set the global map variables (count, buffer, command) with the parameters
            ; values passed to this function and then call the mapped user function.

            If ( $mapKey == $inCommand ) Then
                $mapFunction = $KeyMappings[ $i ][ $VI_MAP_FUNC ]

                $ActiveFunction = $mapFunction
                $ActiveMapBuffer = $inBuffer
                $ActiveMapCount = $inCount
                $ActiveMapExtra = $inCommand

                Call( $mapFunction )

                If ( @error = 0xDEAD And @extended = 0xBEEF ) Then
                    $result = $VI_MATCH_NONE
                Else
                    $result = $VI_MATCH_FULL
                EndIf

                ExitLoop

            ; Otherwise, test whether current command has a partial match in the global
            ; keymapping list. If it does, return a partial match flag so the program can
            ; wait for the rest of the command on the next pass before clearing the buffer.

            ElseIf ( StringLeft( $mapKey, StringLen( $inCommand ) ) == $inCommand ) Then
                $result = $VI_MATCH_PARTIAL
                ExitLoop
            EndIf
        EndIf
    Next

    Return $result
EndFunc

;===========================================================================
; InsertEscape_Check()
;
; Summary:      Checks global keyboard buffer for Escape (reset) keypress.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func InsertEscape_Check()
    Local $escapeBuffer
    Local $escapePos
    Local $i
    Local $putText

    If ( $InsertEscapeCheck And $EditMode = $VI_MODE_NORMAL ) Then
        $escapePos = StringInStr( $InsertEscapeBuffer, "[Escape]" )

        If $escapePos Then
            $escapeBuffer = StringLeft( $InsertEscapeBuffer, $escapePos - 1 )

            For $i = 1 To $InsertEscapeCount
                $putText &= $escapeBuffer
            Next

            InsertEscape_Reset()
            SendKeyString( EncodeKey( $putText ) )

            $ActiveBuffer = ""
        EndIf
    EndIf
EndFunc

;===========================================================================
; InsertEscape_Reset()
;
; Summary:      Resets the global Insert mode Escape keybuffer.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func InsertEscape_Reset( $countNum = 0 )
    If ( $countNum = 0 ) Then
        $InsertEscapeCheck = False
        $InsertEscapeCount = 0
    Else
        $InsertEscapeCheck = True
        $InsertEscapeCount = $countNum
    EndIf

    $InsertEscapeBuffer = ""
EndFunc

; Miscellaneous support functions

;===========================================================================
; FlushBuffers()
;
; Summary:      Flushes all global keyboard buffers.
; Author(s):    Adam Parrott
; Updated:      2012-04-15
;===========================================================================

Func FlushBuffers()
    $ActiveBuffer = ""
    $KeyDownBuffer = ""
    $KeyShiftBuffer = ""
    $RawBuffer = ""
    $UserBuffer = ""
EndFunc

;===========================================================================
; ReadDefaultKeys()
;
; Summary:      Reads default keymapping data from configuration file.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func ReadDefaultKeys()
    Local $delim = " "
    Local $doMap
    Local $file
    Local $i, $j
    Local $keyMap[ 1 ][ 3 ]
    Local $line
    Local $mapMode
    Local $parse

    $file = FileOpen( @TempDir & "\" & $VI_FILE_DEFAULT_KEYS, 0 )

    If ( $file = -1 ) Then Return $keyMap

    While 1
        $line = FileReadLine( $file )

        If ( @error = -1 ) Then ExitLoop

        $parse = StringSplit( $line, $delim )

        If IsArray( $parse ) Then
            $doMap = False
        Else
            ContinueLoop
        EndIf

        Switch $parse[ 1 ]
            Case "imap"
                $mapMode = $VI_MODE_INSERT
                $doMap = True
            Case "nmap"
                $mapMode = $VI_MODE_NORMAL
                $doMap = True
        EndSwitch

        If $doMap Then
            $i = UBound( $keyMap, 1 )
            $j = UBound( $keyMap, 2 )

            ReDim $keyMap[ $i + 1 ][ $j ]

            $keyMap[ $i ][ $VI_MAP_MODE ] = $mapMode
            $keyMap[ $i ][ $VI_MAP_KEY ] = $parse[ 2 ]
            $keyMap[ $i ][ $VI_MAP_FUNC ] = $parse[ 3 ]
        EndIf
    WEnd

    FileClose( $file )

    Return $keyMap
EndFunc

;===========================================================================
; UpdateMetrics()
;
; Summary:      Updates global application metrics.
; Author(s):    Adam Parrott
; Updated:      2012-04-27
;===========================================================================

Func UpdateMetrics()
    $ActiveWindow = WinActive( "[ACTIVE]", "" )
    $ActiveControl = ControlGetHandle( $ActiveWindow, "", ControlGetFocus( $ActiveWindow ) )
    $ActiveControlType = _WinAPI_GetClassName( $ActiveControl )
    $ActivePos = WinGetPos( $ActiveWindow )

    If IsArray( $ActivePos ) Then
        $ActiveHeight = $ActivePos[ 3 ]
        $ActiveLeft = $ActivePos[ 0 ]
        $ActiveTop = $ActivePos[ 1 ]
        $ActiveWidth = $ActivePos[ 2 ]
        $DesktopBottom = @DesktopHeight - TaskBar_Height()
    EndIf
EndFunc

;===========================================================================
; UpdateStatusBar()
;
; Summary:      Updates Vime status bar metrics.
; Author(s):    Adam Parrott
; Updated:      2012-04-27
;===========================================================================

Func UpdateStatusBar()
    If ( $StatusBar <> 0 ) Then
        If ( $ActiveWindow <> $StatusBar[ $STATUS_BAR ] ) Then

            ; Check whether active window has changed.

            If ( $PrevWindow <> $ActiveWindow ) Then
                $PrevHeight = $ActiveHeight
                $PrevLeft = $ActiveLeft
                $PrevTop = $ActiveTop
                $PrevWidth = $ActiveWidth
                $PrevWindow = $ActiveWindow

                StatusBar_Follow( $StatusBar )
            EndIf

            ; Check whether if active window has moved position.

            If ( $PrevLeft <> $ActiveLeft ) _
                Or ( $PrevHeight <> $ActiveHeight ) _
                Or ( $PrevTop <> $ActiveTop ) _
                Or ( $PrevWidth <> $ActiveWidth ) _
            Then
                StatusBar_Follow( $StatusBar )
            EndIf
        EndIf
    EndIf

    StatusBar_Text( $StatusBar, $VI_BAR_TEXT_MASK )
EndFunc
