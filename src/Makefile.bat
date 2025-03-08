@echo off
setlocal
set PATH=%WUDSN_TOOLS_FOLDER%\PAS\FPC.jac;%PATH%
set MP_FOLDER="%~dp0"\..
set MP_SRC_FOLDER=%MP_FOLDER%\src

set TEST_EXE=%MP_SRC_FOLDER%\Test-0.exe
set MP_EXE=%MP_SRC_FOLDER%\mp.exe

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
  if exist "%MP_EXE%" del "%MP_EXE%"
  call fpc.bat %MP_SRC_FOLDER%\mp.pas
  if errorlevel 1 goto :eof
  if exist "%MP_EXE%" (
    echo Starting test program %MP_EXE%.
    if exist %MP_EXE%  %MP_EXE% -ipath:%MP_FOLDER%\lib Test-MP.pas
  )
)
