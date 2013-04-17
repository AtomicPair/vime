@::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@:: Vime build script
@::
@:: Author(s):  Adam Parrott
@:: Updated:    2012-04-14
@::
@:: Credits:    http://stackoverflow.com/questions/4781772/how-to-test-if-executable-exists-in-path-inside-windows-batch-files
@::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF
SETLOCAL

SET buildPath=%ProgramFiles%\AutoIt3\SciTE\AutoIt3Wrapper\
SET buildFile=AutoIt3Wrapper.exe
SET foundBuild=
SET sourcePath=..\source

PUSHD %sourcePath%

ECHO | SET /P outMessage=Locating AutoIt3Wrapper.exe...

FOR %%i IN (%buildFile%) DO (SET foundBuild=%%~$PATH:i)

IF DEFINED foundBuild (
  SET buildFile=%buildFile%
) ELSE (
  FOR /R "%buildPath%" %%i IN ("*%buildFile%") DO SET buildFile=%%i
)

IF "%buildFile%"=="" (
  ECHO failed.
  ECHO.
  ECHO The build script was unable to locate your AutoIt3Wrapper.exe installation.  You will need to manually specify the location of your AutoIt3Wrapper executable by updating the buildPath and buildFile variables on lines 14 and 15 of this batch file with the location of your executable.
  GOTO :Quit
) ELSE (
  ECHO located.
  ECHO | SET /P outMessage=Building Vime project...
)

"%buildFile%" /in ..\source\Vime.au3

ECHO complete.
ECHO.
ECHO You may find the generated file(s) in the release\ folder.

:Quit

POPD
ENDLOCAL
GOTO :EOF