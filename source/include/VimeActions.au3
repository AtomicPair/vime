;============================================================================
; VimeActions module
;
; Summary:      Contains all publicly available support functions which may
;               be called by a user for a given keypress.
; Author(s):    Adam Parrott
; Updated:      2012-04-28
;============================================================================

#include-once

#include <EditConstants.au3>
#include <GuiEdit.au3>
#include <GUIConstants.au3>
#include <ScrollBarConstants.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>

Local Const $VI_SELECTION_DELAY = 10

; Standard Vime key functions

;===========================================================================
; CursorLineEnd()
;
; Summary:      Moves the cursor to the end of the current line.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func CursorLineEnd()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount - 1
        SendKeyString( EncodeKey( "[Down]" ) )
    Next

    SendKeyString( EncodeKey( "[End]" ) )
EndFunc

;===========================================================================
; CursorLineStart()
;
; Summary:      Moves the cursor to the start of the current line.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func CursorLineStart()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount - 1
        SendKeyString( EncodeKey( "[Up]" ) )
    Next

    SendKeyString( EncodeKey( "[Home]" ) )
EndFunc

;===========================================================================
; CursorMoveDown()
;
; Summary:      Moves the cursor down the specified number of times.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func CursorMoveDown()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount
        SendKeyString( EncodeKey( "[Down]" ) )
    Next
EndFunc

;===========================================================================
; CursorMoveLeft()
;
; Summary:      Moves the cursor left the specified number of times.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func CursorMoveLeft()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount
        SendKeyString( EncodeKey( "[Left]" ) )
    Next
EndFunc

;===========================================================================
; CursorMoveRight()
;
; Summary:      Moves the cursor right the specified number of times.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func CursorMoveRight()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount
        SendKeyString( EncodeKey( "[Right]" ) )
    Next
EndFunc

;===========================================================================
; CursorMoveUp()
;
; Summary:      Moves the cursor up the specified number of times.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func CursorMoveUp()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount
        SendKeyString( EncodeKey( "[Up]" ) )
    Next
EndFunc

;===========================================================================
; CursorPageEnd()
;
; Summary:      Moves the cursor to the end of the current page/screen.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func CursorPageEnd()
    If ( $ActiveMapCount = 0 ) Then
        $ActiveMapCount = _GUICtrlEdit_GetLineCount( $ActiveControl ) - 1
    EndIf

    If StringInStr( $ActiveControlType, "Edit" ) Then
        _GotoLine( $ActiveControl, $ActiveMapCount )
    Else
        SendKeyString( EncodeKey( "[Ctrl][End]" ) )
    EndIf
EndFunc

;===========================================================================
; CursorPageStart()
;
; Summary:      Moves the cursor to the start of the current page/screen.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func CursorPageStart()
    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 0

    If StringInStr( $ActiveControlType, "Edit" ) Then
        _GotoLine( $ActiveControl, $ActiveMapCount )
    Else
        SendKeyString( EncodeKey( "[Ctrl][Home]" ) )
    EndIf
EndFunc

;===========================================================================
; CursorWordBack()
;
; Summary:      Moves the cursor to the end of the previous word.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func CursorWordBack()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount
        SendKeyString( EncodeKey( "[Ctrl][Left]" ) )
    Next
EndFunc

;===========================================================================
; CursorWordStart()
;
; Summary:      Moves the cursor to the start of the next word.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func CursorWordStart()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount
        SendKeyString( EncodeKey( "[Ctrl][Right]" ) )
    Next
EndFunc

;===========================================================================
; CursorWordEnd()
;
; Summary:      Moves the cursor to the end of the current word.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func CursorWordEnd()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount
        SendKeyString( EncodeKey( "[Ctrl][Right]" ) )
    Next

    If ( StringInStr( $ActiveControlType, "Edit" ) ) Then
        While ( _CaretChar() = " " )
            SendKeyString( EncodeKey( "[Left]" ) )
        WEnd
    Else
        SendKeyString( EncodeKey( "[Left]" ) )
    EndIf
EndFunc

;===========================================================================
; DeleteCursor()
;
; Summary:      Deletes the specified number of characters from the
;               current cursor position.
; Author(s):    Adam Parrott
; Updated:      2012-04-27
;===========================================================================

Func DeleteCursor()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount
        SendKeyString( EncodeKey( "[Delete]" ) )
    Next

    _RegisterLastCommand( $ActiveFunction, $ActiveMapCount, $ActiveMapExtra )
EndFunc

;===========================================================================
; DeleteLine()
;
; Summary:      Deletes the specified number of lines from the current
;               cursor position.
; Author(s):    Adam Parrott
; Updated:      2012-04-28
;===========================================================================

Func DeleteLine()
    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    Local $i
    Local $lineNum = _GUICtrlEdit_LineFromChar( $ActiveControl, -1 )
    Local $startPos = _GUICtrlEdit_LineIndex( $ActiveControl, $lineNum )
    Local $endPos = _GUICtrlEdit_LineIndex( $ActiveControl, $lineNum + $ActiveMapCount ) - 1

    If ( $startPos == -1 Or $endPos == -1 ) Then
        SendKeyString( EncodeKey( "[End][Home][Home]" ) )

        For $i = 1 To $ActiveMapCount
            SendKeyString( EncodeKey ( "[Shift][Down]" ) )
        Next
    Else
        _GUICtrlEdit_SetSel( $ActiveControl, $startPos, $endPos )
    EndIf

    SendKeyString( EncodeKey( "[Backspace][Home][Home]" ) )
    _RegisterLastCommand( $ActiveFunction, $ActiveMapCount, $ActiveMapExtra )
EndFunc

;===========================================================================
; GotoFirstLine()
;
; Summary:      Moves the cursor to the first line on the page/screen.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func GotoFirstLine()
    If ( $ActiveMapCount = 0 ) Then
        SendKeyString( EncodeKey( "[Ctrl][Home]" ) )
    Else
        _GotoLine( $ActiveControl, $ActiveMapCount )
    EndIf
EndFunc

;===========================================================================
; GotoLastLine()
;
; Summary:      Moves the cursor to the last line on the page/screen.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func GotoLastLine()
    If ( $ActiveMapCount = 0 ) Then
        SendKeyString( EncodeKey( "[Ctrl][End]" ) )
    Else
        _GotoLine( $ActiveControl, $ActiveMapCount )
    EndIf
EndFunc

;===========================================================================
; InsertAfterCursor()
;
; Summary:      Inserts the given text after the current cursor position.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func InsertAfterCursor()
    SendKeyString( EncodeKey( "[Right]" ) )
    ChangeEditMode( $VI_MODE_INSERT )

    If ( $ActiveMapCount = 0 ) Then
        $ActiveMapCount = 1
    Else
        InsertEscape_Reset( $ActiveMapCount )
    EndIf
EndFunc

;===========================================================================
; InsertBeforeCursor()
;
; Summary:      Inserts the given text before the current cursor position.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func InsertBeforeCursor()
    ChangeEditMode( $VI_MODE_INSERT )

    If ( $ActiveMapCount = 0 ) Then
        $ActiveMapCount = 1
    Else
        InsertEscape_Reset( $ActiveMapCount )
    EndIf
EndFunc

;===========================================================================
; InsertLineAbove()
;
; Summary:      Inserts the specified number of lines above the current
;               cursor position.
; Author(s):    Adam Parrott
; Updated:      2012-04-27
;===========================================================================

Func InsertLineAbove()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount
        SendKeyString( EncodeKey( "[Home][Enter][Up]" ) )
    Next

    ChangeEditMode( $VI_MODE_INSERT )
    _RegisterLastCommand( $ActiveFunction, $ActiveMapCount, $ActiveMapExtra )
EndFunc

;===========================================================================
; InsertLineBelow()
;
; Summary:      Inserts the specified number of lines below the current
;               cursor position.
; Author(s):    Adam Parrott
; Updated:      2012-04-27
;===========================================================================

Func InsertLineBelow()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount
        SendKeyString( EncodeKey( "[End][Enter]" ) )
    Next

    ChangeEditMode( $VI_MODE_INSERT )
    _RegisterLastCommand( $ActiveFunction, $ActiveMapCount, $ActiveMapExtra )
EndFunc

;===========================================================================
; InsertLineEnd()
;
; Summary:      Inserts the given text at the end of the current line.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func InsertLineEnd()
    SendKeyString( EncodeKey( "[End]" ) )
    ChangeEditMode( $VI_MODE_INSERT )

    If ( $ActiveMapCount = 0 ) Then
        $ActiveMapCount = 1
    Else
        InsertEscape_Reset( $ActiveMapCount )
    EndIf
EndFunc

;===========================================================================
; ModeInsert()
;
; Summary:      Changes to the Insert editing mode.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func ModeInsert()
    ChangeEditMode( $VI_MODE_INSERT )
EndFunc

;===========================================================================
; ModeNormal()
;
; Summary:      Changes to the Normal editing mode.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func ModeNormal()
    ChangeEditMode( $VI_MODE_NORMAL )
EndFunc

;===========================================================================
; PutAfterCursor()
;
; Summary:      Pastes the global put buffer text after the cursor.
; Author(s):    Adam Parrott
; Updated:      2012-04-27
;===========================================================================

Func PutAfterCursor()
    Local $curPos
    Local $i
    Local $putText

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    If ( StringInStr( $ActiveControlType, "Edit" ) ) Then
        For $i = 1 To $ActiveMapCount
            $putText &= $ActiveRegister
        Next

        $curPos = _GUICtrlEdit_GetSel( $ActiveControl )

        If IsArray( $curPos ) Then
            _GUICtrlEdit_SetSel( $ActiveControl, $curPos[ 1 ], $curPos [ 1 ] )
            _GUICtrlEdit_ReplaceSel( $ActiveControl, $putText )
        EndIf
    EndIf

    _RegisterLastCommand( $ActiveFunction, $ActiveMapCount, $ActiveMapExtra )
EndFunc

;===========================================================================
; RepeatLastCommand()
;
; Summary:      Repeats the last user command (and count, if given).
; Author(s):    Adam Parrott
; Updated:      2012-04-27
;===========================================================================

Func RepeatLastCommand()
    Local $i

    $ActiveFunction = $LastCommand
    $ActiveMapCount = $LastCommandCount
    $LastCommand = ""
    $LastCommandCount = ""

    Call( $ActiveFunction )

    If ( @error = 0xDEAD And @extended = 0xBEEF ) Then
        ; Log negative function match
    Else
        ; Log positive function match
    EndIf
EndFunc

;===========================================================================
; ScrollScreenDown()
;
; Summary:      Scrolls the current page/screen down a specified number of times.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func ScrollScreenDown()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount
        SendKeyString( EncodeKey( "[PageDown]" ) )
    Next
EndFunc

;===========================================================================
; ScrollScreenUp()
;
; Summary:      Scrolls the current page/screen up a specified number of times.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func ScrollScreenUp()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount
        SendKeyString( EncodeKey( "[PageUp]" ) )
    Next
EndFunc

;===========================================================================
; UndoChange()
;
; Summary:      Undoes the last Vime action.
; Author(s):    Adam Parrott
; Updated:      2012-04-27
;===========================================================================

Func UndoChange()
    SendKeyString( EncodeKey( "[Ctrl]z" ) )
    _RegisterLastCommand( $ActiveFunction, $ActiveMapCount, $ActiveMapExtra )
EndFunc

;===========================================================================
; YankDown()
;
; Summary:      Copies both the current and next lines to the put buffer.
; Author(s):    Adam Parrott
; Updated:      2012-04-28
;===========================================================================

Func YankDown()
    SendKeyString( EncodeKey( "[Home][Home][Shift][Down][Shift][Down]" ) )
    Sleep( $VI_SELECTION_DELAY )

    $ActiveRegister = _GetSelection()

    SendKeyString( EncodeKey( "[Up][Up]" ) )
    _RegisterLastCommand( $ActiveFunction, $ActiveMapCount, $ActiveMapExtra )
EndFunc

;===========================================================================
; YankLeft()
;
; Summary:      Copies the character(s) to the left of the cursor to the
;               global put buffer.
; Author(s):    Adam Parrott
; Updated:      2012-04-28
;===========================================================================

Func YankLeft()
    SendKeyString( EncodeKey( "[Shift][Left]" ) )
    Sleep( $VI_SELECTION_DELAY )

    $ActiveRegister = _GetSelection()

    SendKeyString( EncodeKey( "[Right]" ) )
    _RegisterLastCommand( $ActiveFunction, $ActiveMapCount, $ActiveMapExtra )
EndFunc

;===========================================================================
; YankLines()
;
; Summary:      Copies the current line (and the requested number of lines
;               below the current line) to the global put buffer.
; Author(s):    Adam Parrott
; Updated:      2012-04-28
;===========================================================================

Func YankLines()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    SendKeyString( EncodeKey( "[Home][Home]" ) )

    For $i = 1 To $ActiveMapCount
        SendKeyString( EncodeKey( "[Shift][End][Shift][Right]" ) )
    Next

    Sleep( $VI_SELECTION_DELAY ) 

    $ActiveRegister = _GetSelection()

    For $i = 1 To $ActiveMapCount
        SendKeyString( EncodeKey( "[Up]" ) )
    Next

    _RegisterLastCommand( $ActiveFunction, $ActiveMapCount, $ActiveMapExtra )
EndFunc

;===========================================================================
; YankRight()
;
; Summary:      Copies the character(s) to the right of the cursor to the
;               global put buffer.
; Author(s):    Adam Parrott
; Updated:      2012-04-28
;===========================================================================

Func YankRight()
    SendKeyString( EncodeKey( "[Shift][Right]" ) )
    Sleep( $VI_SELECTION_DELAY )

    $ActiveRegister = _GetSelection()

    SendKeyString( EncodeKey( "[Left]" ) )
    _RegisterLastCommand( $ActiveFunction, $ActiveMapCount, $ActiveMapExtra )
EndFunc

;===========================================================================
; YankSelection()
;
; Summary:      Copies the current selection to the global put buffer.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func YankSelection()
    $ActiveRegister = _GetSelection()
EndFunc

;===========================================================================
; YankUp()
;
; Summary:      Copies both the previous and current lines to the put buffer.
; Author(s):    Adam Parrott
; Updated:      2012-04-28
;===========================================================================

Func YankUp()
    SendKeyString( EncodeKey( "[Home][Home][Down][Shift][Up][Shift][Up]" ) )
    Sleep( $VI_SELECTION_DELAY )

    $ActiveRegister = _GetSelection()

    SendKeyString( EncodeKey( "[Down][Down]" ) )
    _RegisterLastCommand( $ActiveFunction, $ActiveMapCount, $ActiveMapExtra )
EndFunc

; Vime action support functions

;===========================================================================
; _CaretChar()
;
; Summary:      Returns the given character(s) from the current caret.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func _CaretChar( $caretOffset = 0, $caretLen = 1 )
    Local $curPos = _GUICtrlEdit_GetSel( $ActiveControl )
    Local $controlText = _GUICtrlEdit_GetText( $ActiveControl )

    If ( IsArray( $curPos ) ) And ( $controlText <> "" ) Then
        Return StringMid( $controlText, $curPos[ 0 ] + $caretOffset, $caretLen )
    EndIf
EndFunc

;===========================================================================
; _GetSelection()
;
; Summary:      Returns the active text selection in the active control.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func _GetSelection( $startPos = -1, $endPos = -1 )
    Local $curPos = _GUICtrlEdit_GetSel( $ActiveControl )
    Local $controlText = _GUICtrlEdit_GetText( $ActiveControl )

    If IsArray( $curPos ) Then
        If ( $startPos = -1 ) Then $startPos = $curPos[ 0 ]
        If ( $endPos = -1 ) Then $endPos = $curPos[ 1 ]
    Endif

    If $controlText Then
        Return StringMid( $controlText, $startPos + 1, $endPos - $startPos )
    EndIf
EndFunc

;===========================================================================
; _GotoLine()
;
; Summary:      Moves the caret in the specified control to a given line.
; Author(s):    Adam Parrott
; Updated:      2012-04-12
;===========================================================================

Func _GotoLine( $controlId, $lineNum )
    Local $charPos
    Local $i

    If StringInStr( $ActiveControlType, "Edit" ) Then
        $charPos = _GUICtrlEdit_LineIndex( $controlId, $lineNum )

        _GUICtrlEdit_SetSel( $controlId, $charPos, $charPos )
        _GUICtrlEdit_Scroll( $controlId, $SB_SCROLLCARET )
    Else
        SendKeyString( EncodeKey( "[Ctrl][Home]" ) )

        For $i = 1 To $lineNum
            SendKeyString( EncodeKey( "[Down]" ) )
        Next
    EndIf
EndFunc

;===========================================================================
; _RegisterLastCommand()
;
; Summary:      Registers the given function in the last command buffer.
; Author(s):    Adam Parrott
; Updated:      2012-04-27
;===========================================================================

Func _RegisterLastCommand( $functionName, $functionCount, $functionExtra = "" )
    $LastCommand = $functionName
    $LastCommandCount = $functionCount
    $LastCommandExtra = $functionExtra
EndFunc