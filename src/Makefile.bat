@echo off
setlocal
set PATH=%WUDSN_TOOLS_FOLDER%\PAS\FPC.jac;%WUDSN_TOOLS_FOLDER%\ASM\MADS\bin\windows_x86_64;%PATH%
set MP_FOLDER=%~dp0..
set MP_SRC_FOLDER=%MP_FOLDER%\src

set TEST_EXE=%MP_SRC_FOLDER%\Test-0.exe
set MP_EXE=%MP_SRC_FOLDER%\mp.exe

set WUDSN_MP_EXE=%WUDSN_TOOLS_FOLDER%\PAS%\MP\bin\windows\mp.exe

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

set TEST_1_FOLDER=%MP_SRC_FOLDER%
set TEST_1_FILE=Test-MP

set TEST_2_FOLDER=C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal\samples\a8\games\PacMad
set TEST_2_FILE=pacmad

rem Regression test with standard MP.
if 1==1 (
if not "%MP_EXE%"=="" (
  echo.
  echo INFO: Compiling with WUDSN version.
  echo ===================================
  echo.
  call :run_mp %WUDSN_MP_EXE% %TEST_1_FOLDER% %TEST_1_FILE%
  call :run_mp %WUDSN_MP_EXE% %TEST_2_FOLDER% %TEST_2_FILE%

   
  echo.
  echo.
  echo INFO: Comiling with new version.
  echo ================================
  echo.
  if exist "%MP_EXE%" del "%MP_EXE%"
  call fpc.bat %MP_SRC_FOLDER%\mp.pas
  if errorlevel 1 goto :eof
  if exist "%MP_EXE%" (
    call :run_mp %MP_EXE% %TEST_1_FOLDER% %TEST_1_FILE%
    call :run_mp %MP_EXE% %TEST_2_FOLDER% %TEST_2_FILE%
  )
)
)

goto :eof


:run_mp
  set MP=%1
  set TEST_FOLDER=%2
  set TEST_MP=%3
  
  set MP_INPUT_PAS=%TEST_MP%.pas
  set MP_OUTPUT_ASM=%TEST_MP%.a65
  if %MP%==%WUDSN_MP_EXE% (
    set MADS_OUTPUT_XEX=%TEST_MP%-WUDSN.xex
  ) else (
    set MADS_OUTPUT_XEX=%TEST_MP%.xex
  )
  
  pushd %TEST_FOLDER%
  echo INFO: Compiling "%MP_INPUT_PAS%" in "%TEST_FOLDER%" with "%MP%".
  if exist %MP_OUTPUT_ASM% del %MP_OUTPUT_ASM%
  %MP% -ipath:%MP_FOLDER%\lib %MP_INPUT_PAS%
  if errorlevel 1 goto :mp_error
  if exist %MP_OUTPUT_ASM% (
     if exist %MADS_OUTPUT_XEX% del %MADS_OUTPUT_XEX%
     mads %MP_OUTPUT_ASM% -x -i:%MP_FOLDER%\base -o:%MADS_OUTPUT_XEX%
     if exist %MADS_OUTPUT_XEX% (
       echo Starting test program "%MADS_OUTPUT_XEX%".
       %MADS_OUTPUT_XEX%
     ) else (
       echo ERROR: MADS output file %MADS_OUTPUT_XEX% not created.
       pause
     ) 
  ) else (
    echo ERROR: MP output file %MP_OUTPUT_ASM% not created.
    pause
  )
  popd
goto :eof

:mp_error
  popd
  echo ERROR: Mad-Pascal error.
  pause
  goto :eof

