# Vime Developers Guide

## Requirements

Vime is built using [AutoIt 3.x][AutoItLink] for Windows.  You will need to install the [latest version][DownloadLink] of AutoIt before you can develop, test, and build the solution on your local machine.

Due to it's simplistic purpose and structure, Vime requires no specific IDE package for development.  In fact, the author himself uses Vim to edit source code and a Windows Command Prompt to build and test the solution; however, any modern editor or IDE may be used for this purpose.  If you do not already have a preferred AutoIt development environment or you are looking for a new editor/IDE for this project, we recommend you evaluate the excellent [SciTE4AutoIt package][SciteLink] for your needs.

## Project Structure

The Vime project is composed of the following directory structure:

```
build\              Build tools and scripts
dev\                Development files and media
docs\               Project documentation
release\            Release binaries and installation packages
source\             Project source code
source\include      Include files
source\resources    Resource files
```

**New code submissions should conform to this structure.**  If you feel the need to add a new directory to this structure, please first submit a feature request on the [Issues page][IssuesLink] and add a few detailed notes explaining your request for the structure change.  The project team will then discuss and consider your request — and no reasonable idea will be refused.  :-)

## Developing for Vime

Before you create any new code (or modify any existing code) in the Vime project, make sure you first read the [Vime Style Guide][StyleGuideLink].  Following these guidelines will help ensure consistency across code submissions from all contributors, thereby greatly reducing the amount of time it may take to accept your own submissions into the master repository.

#### Application Flow

The following steps outline the basic program flow for the Vime application:

1. Configure environment and set defaults.
2. If enabled, run main application loop.
3. If exited, clean up environment and quit Vime.

Additionally, the following steps detail the **main application loop** noted in step (2) above.

1. Process user input.
    * Check each input character against configured key map definitions.
    * If a key map definition exists for the current editing mode, call the appropriate Vime function with any given modifiers (command repeat count, etc).
2. Clear the user input buffer.
3. Update the status bar and program metrics.

All code describing this flow is contained in the [`Vime.au3`][SourceVimeLink] source file under the project root.

#### Editing Modes

Currently, there are three Vim-like editing modes emulated by Vime:

1. **Global** mode applies to all editing modes and overrides any functionality within those modes.

2. **Normal** mode (also known as ** Command** mode) is the default mode from Vime.  This mode permits the user to navigate the file, move the cursor, and apply various commands to the file contents.  *This mode will accept command count modifiers from 0-9999 before each Normal mode command (i.e. `99gg`).*

3. **Insert** mode is the mode used when inserting/typing text into a file or control.  *This mode will accept command count modifiers from 0-9999 before each Normal mode command (i.e. `2iABC`).*

#### Updating Key Mappings

Currently, the default key map information is stored in the [`DefaultKeys.ini`][SourceDefaultKeysLink] file under the `source\include` folder.  This file is then included as an inline resource file with the Vime executable when the solution is built.  As a result, manual updates to key map data by end-users are not (yet) possible without the developer first making these changes themselves.

Once we have granted users the ability to modify the existing key map defaults through interactive dialog windows, Vime will move all configuration files out the resource pool and into external files, which can then be viewed and edited by end-users and developers alike.  The interactive dialogs will also remove the need for most users to manually any configuration files themselves, as Vime will automatically take care of this task for them.

The following table outlines the current structure of the [`DefaultKeys.ini`][SourceDefaultKeysLink] file:

| Mode | Keys     | Function        |
| ---- | -------- | --------------- |
| gmap | [Ctrl]V  | App_Toggle      |
| nmap | $        | CursorLineEnd   |
| nmap | 0        | CursorLineStart |
| imap | [Escape] | ModeNormal      |

* The Mode column describes the editing mode to which the key mapping applies.  This column may accept one of three values: `gmap` for Global mode, `nmap` for Normal mode, and `imap` for Insert mode.

* The Keys column contains the key combination assigned to that particular mapping.  Codes used to describe the individual keys in this column may be found under the "user key descriptions" block (`$KEY_DATA_DESC`) in the [`KeyConstants.au3`][SourceKeyCodesLink] file under the `source\include` folder.

* The Function column contains the Vime function name to be called when the Keys combination is pressed.  Function names described in this section may be found in the [`VimeActions.au3`][SourceActionsLink] file under the `source\include` folder.

#### Creating New Functions

Before adding any new functions to the [`VimeActions.au3`][SourceActionsLink] file, first scan the available functions to verify that the desired function(ality) does not already exist.  Once you have verified that a new function is truly needed, code your functions using the following notes as your guide:

```AutoIt
Func CursorLineEnd()
    Local $i

    If ( $ActiveMapCount = 0 ) Then $ActiveMapCount = 1

    For $i = 1 To $ActiveMapCount - 1
        SendKeyString( EncodeKey( "[Down]" ) )
    Next

    SendKeyString( EncodeKey( "[End]" ) )
EndFunc
```

1. Functions may use any one of the built-in functions from the AutoIt standard library.  **Carefully consider (twice!) the use of any AutoIt UDF functions**, as these libraries will increase developer compile times and, more importantly, end-user memory bloat.

2. In addition to the standard AutoIt functions, there are also several Vime custom support functions included in the second block near the end of the [`VimeActions.au3`][SourceActionsLink] file.  (These functions have an underscore prefix in the function name, i.e. `_GotoLine()`.) Where possible, use these support functions to augment your own key action functions.  If you require specific functionality that does not already exist in the AutoIt standard library or Vime project, feel free to code your own support function and add it to the code block at the end of the [`VimeActions.au3`][SourceActionsLink] file.

3. The `$ActiveMapCount` global variable contains the command repeat count that was entered by the user.  If this variable equals 0, then no repeat count was requested, so a default value of 1 should be assumed.  Use this variable when implementing any command repeat loops in your function code.

4. When sending new key combinations to the Windows keyboard buffer, use the `SendKeyString()` and `EncodeKey()` functions, combined with the appropriate key code combinations (i.e. `"[Ctrl][Home]"`), to encode and send the desired keystrokes.

5. **Keep your functions and small and light as possible.**  This will reduce execution times for the end-user and source code bloat for other developers.

6. **All functions should be listed alphabetically** in the source code file, sorted ascending from A to Z.  Make sure you follow the coding conventions outlined in the [Vime Style Guide][StyleGuideLink] when crafting your new function(s).

7. If you want to **add your new action function to the list of repeatable commands** in Command mode, make sure you register the current active function parameters with the _RegisterLastCommand() function.  Action functions that do not register themselves with the _RegisterLastCommand() function will not be repeatable by the user.

```
Func UndoChange()
    SendKeyString( EncodeKey( "[Ctrl]z" ) )
    _RegisterLastCommand( $ActiveFunction, $ActiveMapCount )
EndFunc
```

## Testing the Solution

#### SciTE4AutoIt

To run/test the solution using the SciTE4AutoIt editor, simply click to *Tools > Go* in the SciTE editor.

#### Command Prompt

To run/test the solution using the Command Prompt or similar manual solution:

1. Ensure that your AutoIt installation directory is included in your user environment PATH.
2. Run the following command from the project root directory: `autoit3 vime.au3`

### Unit Testing

Since no unit testing solution currently exists for AutoIt or Vime, *suggestions and contributions are welcome* for helping us cross off that item from our project roadmap by adding an appropriate testing solution to the project.

That said, we still expect **all** contributors to *fully test their code as much as possible* before submitting said code to the repository.  Lack of a proper testing suite does not mean you can write bad or sloppy code!  :-)

## Building the Solution

To build the solution into a releasable package, simply run the `build.bat` file in the `build` folder from the Command Prompt.

The build script will attempt to locate the `AutoIt3Wrapper.exe` build tool — which is used by AutoIt to compile and build the release files — on your local machine.  If the script is unable to locate this file, you will need to manually update the path variables in the script with the correct values.  If this happens, follow any error instructions given by the script to correct the problem.

Upon completion, the generated files will be stored in the `release` folder.

[AutoItLink]: http://www.autoitscript.com/
[DownloadLink]: http://www.autoitscript.com/site/autoit/downloads/
[IssuesLink]: https://github.com/Axianator/Vime/issues
[SciteLink]: http://www.autoitscript.com/site/autoit-script-editor/
[SourceDefaultKeysLink]: https://github.com/Axianator/Vime/blob/master/source/include/DefaultKeys.ini
[SourceActionsLink]: https://github.com/Axianator/Vime/blob/master/source/include/VimeActions.au3
[SourceKeyCodesLink]: https://github.com/Axianator/Vime/blob/master/source/include/KeyConstants.au3
[SourceVimeLink]: https://github.com/Axianator/Vime/blob/master/source/Vime.au3
[StyleGuideLink]: https://github.com/Axianator/Vime/blob/master/docs/STYLE-GUIDE.txt

