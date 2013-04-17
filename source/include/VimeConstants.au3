; Vime app modes

Global Const $VI_APP_MODE_ON = 1
Global Const $VI_APP_MODE_OFF = 2

; Vime file/path constants

Global Const $VI_FILE_DEFAULT_KEYS = "_VimeDefaultKeys.ini"
Global Const $VI_FILE_APP_ICON = "logo-small.ico"
Global Const $VI_PATH_INCLUDES = "include"
Global Const $VI_PATH_RESOURCES = "resources"

; Vime mapping modes

Global Const $VI_MAP_MODE = 0
Global Const $VI_MAP_KEY = 1
Global Const $VI_MAP_FUNC = 2

; Vime match types

Global Const $VI_MATCH_NONE = 0
Global Const $VI_MATCH_PARTIAL = 1
Global Const $VI_MATCH_FULL = 2

; Vime normal mode values

Global Const $VI_MODE_NORMAL = 1
Global Const $VI_MODE_NORMAL_DESC = "NORMAL"
Global Const $VI_MODE_NORMAL_PATTERN = _
    "([1-9]+\d{0,3})?" & _  ; Repeat count
    "(\""[a-z])?" & _       ; Buffer assignment
    "(.*)"                  ; Command string

; Vime insert mode values

Global Const $VI_MODE_INSERT = 2
Global Const $VI_MODE_INSERT_DESC = "INSERT"
Global Const $VI_MODE_INSERT_PATTERN = "((?:\[[A-Z]\w*\])*.?)"

; Vime miscellaneous constants

Global Const $VI_APP_TOGGLE_KEYS = "+^V" ; Ctrl+Shift+V
Global Const $VI_BAR_TEXT_MASK = "Vime [$EditModeDesc$] $ActiveBuffer$"
Global Const $VI_DELAY_MAIN_LOOP = 20

