@echo off

pushd %~dp0

rem call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
rem echo --------------------------------------------------------------

set exe_name=cappuccino
set collections=-collection:externals=externals

rem Release build config
set level=0
set dir=release
set debug_flag=""

if "%1"=="debug" (
    rem Debug build config
    set level=0
    set dir=debug
    set exe_name=%exe_name%_d
    set debug_flag=-debug
)

echo Building %dir% binary...
if not exist "build\%dir%\" mkdir "build\%dir%\"

odin build src %collections% -out:"build\%dir%\%exe_name%.exe" %debug_flag% -opt:%level% -vet -show-timings

popd
