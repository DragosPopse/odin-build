package test_build_system

import "core:fmt"
import "shared:build"

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
    #partial switch target.platform.os {
        case .Windows: exeStr = "game.exe" 
    }

    config = build.config_make()
    config.platform = target.platform
    
    if target.mode == .Debug {
        config.flags += {.Debug}
        config.optimization = .Minimal
        modeStr = "debug"
    } else if target.mode == .Release {
        config.optimization = .Speed
        modeStr = "release"
    }
    config.out = fmt.aprintf("build/test/%s-%s-%s/%s", osStr, archStr, modeStr, exeStr)
    return
}

main :: proc() {
    project: build.Project(build.Default_Target)
    project.targets = make([dynamic]Target)
    project.configure_target_proc = configure_target
    project.src_root = "test/to_build"
    add_targets(&project)
    build.build_project(project)
}