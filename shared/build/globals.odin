package jam_build

import "core:runtime"

// Note: Cannot index a constant???
_compiler_flag_to_arg := [Compiler_Flag]string {
    .Debug = "-debug",
    .Disable_Assert = "-disable-assert",
    .No_Bounds_Check = "-no-bounds-check",
    .No_CRT = "-no-crt",
    .LLD = "-lld",
    .Use_Separate_Modules = "-use-separate-modules",
    .Ignore_Unknown_Attributes = "-ignore-unknown-attributes",
    .No_Entry_Point = "-no-entry-point",
    .Disable_Red_Zone = "-disable-red-zone",
    .Disallow_Do = "-disallow-do",
    .Default_To_Nil_Allocator = "-default-to-nil-allocator",
    .Ignore_Vs_Search = "-ignore-vs-search",
    .Foreign_Error_Procedures = "-foreign-error-procedures",
    .Verbose_Errors = "-verbose-warnings",
    .Ignore_Warnings = "-ignore-warnings",
    .Warnings_As_Errors = "-warnings-as-errors",
    .Keep_Temp_Files = "-keep-temp-files",
    .No_Threaded_Checker = "-no-threaded-checker",
}

_optimization_mode_to_arg := [Optimization_Mode]string {
    .Minimal = "-o:minimal",
    .Size = "-o:size",
    .Speed = "-o:speed",
}

_build_mode_to_arg := [Build_Mode]string {
    .EXE = "-build-mode:exe",
    .Shared = "-build-mode:shared",
    .OBJ = "-build-mode:obj",
    .ASM = "-build-mode:asm",
    .LLVM_IR = "-build-mode:llvm-ir",
}

_vet_mode_to_arg := [Vet_Mode]string {
    .None = "",
    .Vet = "-vet",
    .Vet_Extra = "-vet-extra",
}

_style_mode_to_arg := [Style_Mode]string {
    .None = "",
    .Strict = "-strict-style",
    .Strict_Init_Only = "-strict-style-init-only",
}

_os_to_arg := [runtime.Odin_OS_Type]string {
    .Unknown = "UNKNOWN_OS",
    .Windows = "windows",
    .Darwin = "darwin",
    .Linux = "linux",
    .Essence = "essence",
    .FreeBSD = "freebsd",
    .OpenBSD = "openbsd",
    .WASI = "wasi",
    .JS = "js",
    .Freestanding = "freestanding",
}

// To be combined with _target_to_arg
_arch_to_arg := [runtime.Odin_Arch_Type]string {
    .Unknown = "UNKNOWN_ARCH",
    .amd64 = "amd64",
    .i386 = "i386",
    .arm32 = "arm32",
    .arm64 = "arm64",
    .wasm32 = "wasm32",
    .wasm64 = "wasm64",
}
