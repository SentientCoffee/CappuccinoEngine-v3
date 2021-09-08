package src;

import "core:runtime";

g_context : runtime.Context;

main :: proc() {
    g_context = context;
    g_context.logger = createConsoleLogger(lowestLevel = Debug);
    context = g_context;

    when ODIN_OS == "windows" do win32Main();
}