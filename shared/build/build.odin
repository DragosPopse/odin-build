package jam_build

import "core:strings"
import "core:fmt"
import "core:os"
import "core:c/libc"
import "core:path/filepath"
import "core:sync"

config_make :: proc(allocator := context.allocator) -> (config: Config) {
    config.defines = make(map[string]Define_Val, 32, allocator)
    config.collections = make(map[string]string, 16, allocator)
    return
}

config_delete :: proc(config: Config) {
    delete(config.defines)
    delete(config.collections)
}

_define_to_arg :: proc(sb: ^strings.Builder, name: string, val: Define_Val) {
    using strings
    
    fmt.sbprintf(sb, "-define:%s=", name)

    switch v in val {
        case bool: {
            write_string(sb, "true" if v else "false")
        }
        case int: {
            write_int(sb, v)
        }
        case string: {
            fmt.sbprintf(sb, `"%s"`, v)
        }
    }
}

_platform_to_arg :: proc(sb: ^strings.Builder, platform: Platform) {
    if platform.os != .Unknown {
        fmt.sbprintf(sb, "-target:%s_%s", _os_to_arg[platform.os], _arch_to_arg[platform.arch])
    }
}

_collection_to_arg :: proc(sb: ^strings.Builder, collection: string, path: string) {
    fmt.sbprintf(sb, `-collection:%s="%s"`, collection, path)
}

_flags_to_arg :: proc(sb: ^strings.Builder, flags: Compiler_Flags) {
    for flag in Compiler_Flag do if flag in flags {
        fmt.sbprintf(sb, "%s ", _compiler_flag_to_arg[flag])
    }
}

_config_to_args :: proc(sb: ^strings.Builder, config: Config) {
    using strings, fmt

    if config.vet != .None {
        sbprintf(sb, "%s ", _vet_mode_to_arg[config.vet])
    }
    sbprintf(sb, "%s ", _build_mode_to_arg[config.build_mode])
    if config.style != .None {
        sbprintf(sb, "%s ", _style_mode_to_arg[config.style])
    }
    sbprintf(sb, "%s ", _optimization_mode_to_arg[config.optimization])

    _platform_to_arg(sb, config.platform)
    write_string(sb, " ")
    _flags_to_arg(sb, config.flags)
    // function already returns space
    for key, val in config.collections {
        _collection_to_arg(sb, key, val)
        write_string(sb, " ")
    }

    for key, val in config.defines {
        _define_to_arg(sb, key, val)
        write_string(sb, " ")
    }

    sbprintf(sb, "-out:%s", config.out)
}


build_package :: proc(pkg_path: string, config: Config) {
    config_output_dirs: {
        dir := filepath.dir(config.out, context.temp_allocator) 
        slashDir, _ := filepath.to_slash(dir, context.temp_allocator)
        dirs := strings.split_after(slashDir, "/", context.temp_allocator)
        for _, i in dirs {
            newDir := strings.concatenate(dirs[0 : i + 1], context.temp_allocator)
            os.make_directory(newDir)
        }
    }
    
    argsBuilder := strings.builder_make() 
    _config_to_args(&argsBuilder, config)
    args := strings.to_string(argsBuilder)
    command := fmt.ctprintf("odin build %s %s", pkg_path, args)
    fmt.printf("Running: %s\n", command)
    libc.system(command)
}

generate_ols :: proc(root_path: string, config: Config) {

}


default_build_options :: proc() -> (o: Build_Options) {
    o.command_type = .Build
    o.config_name = "all"
    return
}

/*
    output.exe <config-name|all> // build 1 target or all
    output.exe -devenv:<editor> <config-name> // Setup the devenv without building. If no editor is specified, it will just generate ols.json
    output.exe help
*/
build_options_make_from_args :: proc(args: []string) -> (o: Build_Options) {
    if len(args) == 0 {
        o.command_type = .Display_Help
        return
    }
    command := args[0] 
    switch {
        case strings.has_prefix(command, "-devenv"): {
            o.command_type = .Dev_Setup
            components := strings.split(command, ":", context.temp_allocator)
            if len(components) == 2 {
                switch components[1] {
                    case "vscode": {
                        o.dev_env = .VSCode 
                    }
                    case: {
                        o.dev_env = .None 
                        o.command_type = .Invalid
                    }
                }
            } else {
                o.dev_env = .None
            }
        }

        case: {
            o.command_type = .Build
        }
    }

    #partial switch o.command_type {
        case .Build: {
            assert(len(args) == 1, "Expected 1 argument for build command")
            o.config_name = args[0] 
        }
        
        case .Dev_Setup: {
            assert(len(args) == 2, "Expected 1 argument for devenv command")
            o.config_name = args[1]
        }
    }

    assert(o.command_type != .Invalid, "Invalid arguments")
    return
}