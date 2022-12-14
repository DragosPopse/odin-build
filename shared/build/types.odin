package jam_build

Define_Val :: union #no_nil {
    bool,
    int,
    string,
}

Platform :: struct {
    os: Odin_OS_Type,
    arch: Odin_Arch_Type,
}

// intrussive? rawptr maybe
Target :: struct {

}

Config :: struct {
    platform: Platform, // Change this to a Maybe?
    build_mode: Build_Mode,
    optimization: Optimization_Mode,
    vet: Vet_Mode,
    flags: Compiler_Flags,
    defines: map[string]Define_Val,
    collections: map[string]string,
}

// Static lib?
Build_Mode :: enum {
    EXE,
    Shared,
    OBJ,
    ASM,
    LLVM_IR,
}

Vet_Mode :: enum {
    None,
    Vet,
    Vet_Extra,
}

Style_Mode :: enum {
    None, 
    Strict,
    Strict_Init_Only,
}

Optimization_Mode :: enum {
    Minimal,
    Speed,
    Size,
}

Reloc_Mode :: enum {
    Default,
    Static,
    Pic,
    Dynamic_No_Pic,
}

Compiler_Flag :: enum {
    Debug,
    Disable_Assert,
    No_Bounds_Check,
    No_CRT,
    LLD,
    Use_Separate_Modules,
    Ignore_Unknown_Attributes,
    No_Entry_Point,
    Disable_Red_Zone,
    Disallow_Do,
    Default_To_Nil_Allocator,
    Ignore_Vs_Search,
    Foreign_Error_Procedures,
    Verbose_Errors,
    Ignore_Warnings,
    Warnings_As_Errors,
    Keep_Temp_Files,
    No_Threaded_Checker,
}

Compiler_Flags :: bit_set[Compiler_Flag]

Timings_Mode :: enum {
    Disabled,
    Basic,
    Advanced,
}

Timings_Format :: enum {
    Default,
    JSON,
    CSV,
}

Timings_Export :: struct {
    mode: Timings_Mode,
    format: Timings_Format,
    filename: Maybe(string),
}







