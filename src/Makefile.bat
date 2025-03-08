@echo off
setlocal
set PATH=%WUDSN_TOOLS_FOLDER%\PAS\FPC.jac;%WUDSN_TOOLS_FOLDER%\ASM\MADS\bin\windows_x86_64;%PATH%
set MP_FOLDER=%~dp0..
set MP_SRC_FOLDER=%MP_FOLDER%\src

set TEST_EXE=%MP_SRC_FOLDER%\Test-0.exe
set MP_EXE=%MP_SRC_FOLDER%\mp.exe

set WUDSN_MP_EXE=%WUDSN_TOOLS_FOLDER%\PAS%\MP\bin\windows\mp.exe

set TEST_MP=Test-MP
set TEST_MP_PAS=%TEST_MP%.pas
set TEST_MP_ASM=%TEST_MP%.a65
set TEST_MP_XEX=%TEST_MP%.xex

cd /d %MP_SRC_FOLDER%

if not "%TEST_EXE%"=="" (
  if exist "%TEST_EXE%" del "%TEST_EXE%"
  call fpc.bat %MP_SRC_FOLDER%\Test-0.pas
  if errorlevel 1 goto :eof
  if exist "%TEST_EXE%" (
     echo Starting test program "%TEST_EXE%".
     %TEST_EXE%
  )
)

if not "%MP_EXE%"=="" (
  echo INFO: Compiling with WUDSN version.
  call :run_mp %WUDSN_MP_EXE%
   
  echo INFO: Comiling with new version.
  if exist "%MP_EXE%" del "%MP_EXE%"
  call fpc.bat %MP_SRC_FOLDER%\mp.pas
  if errorlevel 1 goto :eof
  if exist "%MP_EXE	%" (
    call :run_mp "%MP_EXE%"
  )
)

goto :eof


:run_mp
  set MP=%1
  echo INFO: Starting compiling with "%MP%".
  if exist %TEST_MP_ASM% del %TEST_MP_ASM%
  %MP% -ipath:%MP_FOLDER%\lib %TEST_MP_PAS%
  if errorlevel 1 goto :mp_error
  if exist %TEST_MP_ASM% (
     if exist %TEST_MP_XEX% del %TEST_MP_XEX%
     mads %TEST_MP_ASM% -x -i:%MP_FOLDER%\base -o:%TEST_MP_XEX%
     if exist %TEST_MP_XEX% (
       echo Starting test program "%TEST_MP_XEX%".
       %TEST_MP_XEX%
     ) 
  )
goto :eof

:mp_error
echo ERROR: Mad-Pascal error.
pause
goto :eof

