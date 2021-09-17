package src;

// import "core:math";
import "core:mem";
import "core:runtime";

GraphicsBuffer :: struct {
    memory        : rawptr,
    width, height : int,
    pitch         : int,
    bytesPerPixel : i8,
}

SoundBuffer :: struct {
    sampleOut        : []i16,
    sampleCount      : uint,
    samplesPerSecond : uint,
    volume           : f32,
}

g_context : runtime.Context;

setupContext :: proc() -> runtime.Context {
    context.logger = createConsoleLogger(lowestLevel = Debug);
    g_context = context;
    return g_context;
}

outputSound :: proc(using soundBuffer : ^SoundBuffer, toneFrequency : f32) {
    // @(static) tSine : f32 = 0;
    // wavePeriod := cast(f32) samplesPerSecond / toneFrequency;

    // for i in 0 ..< sampleCount {
    //     index := i * 2;

    //     sineValue := math.sin(tSine);
    //     sampleValue := cast(i16) (sineValue * volume);

    //     sampleOut[index    ] = sampleValue;
    //     sampleOut[index + 1] = sampleValue;

    //     tSine += 2.0 * math.PI * (1.0 / wavePeriod);
    // }
}

renderWeirdGradient :: proc(using graphicsBuffer : ^GraphicsBuffer, blueOffset, greenOffset : int) {
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

gameUpdateAndRender :: proc(
    graphicsBuffer : ^GraphicsBuffer, blueOffset, greenOffset : int,
    soundBuffer : ^SoundBuffer, toneFrequency : f32,
) {
    // outputSound(soundBuffer, toneFrequency);
    renderWeirdGradient(graphicsBuffer, blueOffset, greenOffset);
}