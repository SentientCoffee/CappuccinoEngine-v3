@echo off
setlocal

set level=0
set dir=debug
set command=run
set exe_name=cappuccino
set collections="-collection:externals=externals"

if not "%1"=="release" (
    set exe_name=cappuccino_d
) else (
    set level=2
    set dir=release
)

if not exist "build\%dir%\" mkdir "build\%dir%\"


if not "%1"=="dbg" (
    odin run src\main.odin %collections% -out:"build\%dir%\%exe_name%.exe" -opt:%level%
) else (
    odin build src\main.odin %collections% -out:"build\%dir%\%exe_name%.exe" -opt:%level% -debug
    pushd .
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
    popd
    devenv "build\%dir%\%exe_name%.exe"
)