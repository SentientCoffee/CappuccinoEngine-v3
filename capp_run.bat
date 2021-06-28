@echo off
setlocal

set dir=release
set exe_name=cappuccino

if "%1"=="debug" (
    set dir=debug
    set exe_name=%exe_name%_d
    echo Running debug build...
) else (
    echo Running release build...
)

"build\%dir%\%exe_name%.exe"