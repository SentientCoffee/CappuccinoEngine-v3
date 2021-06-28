@echo off
setlocal

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
    echo Building debug binary...
) else (
    echo Building release binary...
)

if not exist "build\%dir%\" mkdir "build\%dir%\"

odin build src\main.odin %collections% -out:"build\%dir%\%exe_name%.exe" %debug_flag% -opt:%level% -vet -show-timings
