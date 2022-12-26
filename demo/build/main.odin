package test_build_system

import "core:fmt"
import "shared:build"
import "core:os"
import "core:strings"

Target :: build.Default_Target
Project :: build.Project(Target)

platforms := []build.Platform{
    {.Windows, .amd64},
    {.Linux, .arm64},
}


modes := [][]build.Default_Target_Mode {
    {.Debug, .Release},
    {.Release}, // only release on linux
}

add_targets :: proc(project: ^Project) {
    target: Target
    for platform, i in platforms {
        target.platform = platform 
        for mode in modes[i] {
            target.mode = mode
            build.add_target(project, target)
        }
    }
}

configure_target :: proc(project: Project, target: Target) -> (config: build.Config) {
    osStr := build._os_to_arg[target.platform.os]
    archStr := build._arch_to_arg[target.platform.arch]
    modeStr: string
    exeStr := "game.out"

    config = build.config_make()
    config.platform = target.platform
    config.collections["shared"] = strings.concatenate({ODIN_ROOT, "shared"})
    config.name = fmt.aprintf("%s-%s", osStr, archStr)
    #partial switch target.platform.os {
        case .Windows: {
            exeStr = "game.exe"
            if target.mode == .Debug {
                config.name = "windb" // mem leak but who cares its a build system
            }
        }
       
    }


    if target.mode == .Debug {
        config.flags += {.Debug}
        config.optimization = .Minimal
        modeStr = "debug"
    } else if target.mode == .Release {
        config.optimization = .Speed
        modeStr = "release"
    }
    config.out = fmt.aprintf("out/test/%s-%s-%s/%s", osStr, archStr, modeStr, exeStr)
    return
}

main :: proc() {
    project: build.Project(build.Default_Target)
    project.targets = make([dynamic]Target)
    project.configure_target_proc = configure_target
    project.src_root = "demo/to_build"
    options := build.build_options_make_from_args(os.args[1:])
    add_targets(&project)
    build.build_project(project, options)
}