package main;

import "src";

main :: proc() {
    context = src.setupContext();
    when ODIN_OS == .Windows do src.win32Main();
}
