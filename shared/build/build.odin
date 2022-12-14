package jam_build

import "core:strings"
import "core:fmt"

configuration_make :: proc(allocator := context.allocator) -> (config: Config) {
    config.defines = make(map[string]Define_Val, 32, allocator)
    config.collections = make(map[string]string, 16, allocator)
    return
}

configuration_delete :: proc(config: Config) {
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
        fmt.sbprintf(sb, "-platform:%s_%s", sb)
    }
}

_collection_to_args :: proc(sb: ^strings.Builder, collection: string, path: string) {
    fmt.sbprintf(sb, `-collection:%s="%s"`, collection, path)
}

_flags_to_args :: proc(sb: ^strings.Builder, flags: Compiler_Flags) {
    for flag in Compiler_Flag do if flag in flags {
        fmt.sbprintf(sb, "%s ", _compiler_flag_to_arg[flag])
    }
}

_config_to_args :: proc(sb: ^strings.Builder, config: Config, allocator := context.allocator) {
    
}

generate_ols :: proc(root_path: string, config: Config) {

}

build_package :: proc(pkg_path: string, config: Config) {

}