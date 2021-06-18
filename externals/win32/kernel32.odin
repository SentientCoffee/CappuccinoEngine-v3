package winapi;

foreign import "system:kernel32.lib";

// -----------------------------------------------------------------------------------
// Procedures
// -----------------------------------------------------------------------------------

getLastError      :: proc{      wGetLastError };
getModuleHandle   :: proc{   getModuleHandleA,   getModuleHandleW, getModuleHandleN };
outputDebugString :: proc{ outputDebugStringA, outputDebugStringW };

// -----------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------

getModuleHandleN :: proc()                     -> HModule do return wGetModuleHandleA(nil);
getModuleHandleA :: proc(moduleName : cstring) -> HModule do return wGetModuleHandleA(moduleName);
getModuleHandleW :: proc(moduleName : WString) -> HModule do return wGetModuleHandleW(moduleName);

// -----------------------------------------------------------------------------------

outputDebugStringA :: proc(message : cstring) do wOutputDebugStringA(message);
outputDebugStringW :: proc(message : WString) do wOutputDebugStringW(message);

// -----------------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------------

@(private="file", default_calling_convention="std")
foreign kernel32 {
    @(link_name="GetLastError")       wGetLastError       :: proc() -> DWord ---;
    @(link_name="GetModuleHandleA")   wGetModuleHandleA   :: proc(moduleName : cstring) -> HModule ---;
    @(link_name="GetModuleHandleW")   wGetModuleHandleW   :: proc(moduleName : WString) -> HModule ---;

    @(link_name="OutputDebugStringA") wOutputDebugStringA :: proc(message : cstring) ---;
    @(link_name="OutputDebugStringW") wOutputDebugStringW :: proc(message : WString) ---;
}
