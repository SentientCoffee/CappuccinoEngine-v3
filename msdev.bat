@echo off

set dir=debug
set exe_name=cappuccino_d

pushd %~dp0
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
    devenv "build\%dir%\%exe_name%.exe
popd