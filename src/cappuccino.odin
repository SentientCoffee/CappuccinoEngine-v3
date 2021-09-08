package src;

import "core:mem";

BitmapBuffer :: struct {
    memory        : rawptr,
    width, height : int,
    pitch         : int,
    bytesPerPixel : i8,
}

renderWeirdGradient :: proc(using buffer : ^BitmapBuffer, blueOffset, greenOffset : int) {
    bitmap := mem.byte_slice(memory, width * height * cast(int) bytesPerPixel);
    for y in 0 ..< height {
        for x in 0 ..< width {
            index := y * pitch + (x * cast(int) bytesPerPixel);
            r, g, b, a : u8 = 0, cast(u8) (y + greenOffset), cast(u8) (x + blueOffset), 0;
            bitmap[index    ] = b;
            bitmap[index + 1] = g;
            bitmap[index + 2] = r;
            bitmap[index + 3] = a;
        }
    }
}

gameUpdateAndRender :: proc(buffer : ^BitmapBuffer, blueOffset, greenOffset : int) {
    renderWeirdGradient(buffer, blueOffset, greenOffset);
}