package main;

import "src";

main :: proc() {
    context = src.setupContext();
    when ODIN_OS == "windows" do src.win32Main();
}