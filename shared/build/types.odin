package jam_build

import "core:runtime"

Build_Command_Type :: enum {
    Invalid,
    Build,
    Dev_Setup,
    Display_Help,
}

Build_Options :: struct {
    command_type: Build_Command_Type,
    config_name: string, // Config.name, empty or `all`
    dev_env: Dev_Env,
}

Define_Val :: union #no_nil {
    bool,
    int,
    string,
}

Platform :: struct {
    os: runtime.Odin_OS_Type,
    arch: runtime.Odin_Arch_Type,
}

// intrussive? rawptr maybe
Target :: struct {

}

Config :: struct {
    name: string, // Calling `output.exe <config name>` will build only that config
    platform: Platform, // Change this to a Maybe?
    out: string,
    build_mode: Build_Mode,
    optimization: Optimization_Mode,
    vet: Vet_Mode,
    style: Style_Mode,
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
    Show_System_Calls,
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

//TODO
Timings_Export :: struct {
    mode: Timings_Mode,
    format: Timings_Format,
    filename: Maybe(string),
}

Dev_Env :: enum {
    None,
    VSCode,
    // TODO: Add more IDEs/editors
}

Collection :: struct {
    name, path: string,
}

Language_Server_Settings :: struct {
    collections: [dynamic]Collection,
    enable_document_symbols: bool,
    enable_semantic_tokens: bool,
    enable_hover: bool, 
    enable_snippets: bool,
    checker_args: string,
}






