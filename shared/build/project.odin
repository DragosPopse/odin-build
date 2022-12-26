package jam_build 

import "core:thread"
import "core:sync"
import "core:fmt"

Default_Target_Mode :: enum {
    Release,
    Debug,
}

Default_Target :: struct {
    platform: Platform,
    mode: Default_Target_Mode,
}


Project :: struct($Target: typeid) {
    targets: [dynamic]Target,
    src_root: string,
    configure_target_proc: proc(project: Project(Target), target: Target) -> Config, // There should be a way to skip a target. Maybe(Config)?
}

add_target :: #force_inline proc(project: ^Project($Target), target: Target) {
    append(&project.targets, target)
}

build_project :: proc(project: Project($Target), options: Build_Options) {
    switch options.command_type {
        case .Invalid:
            
        case .Display_Help: {
            fmt.printf("Available Targets:\n")
            for target in project.targets {
                config := project->configure_target_proc(target)
                fmt.printf("\t%s\n", config.name)
            }
        }

        case .Build: {
            if options.config_name == "all" {
                for target in project.targets {
                    config := project->configure_target_proc(target)
                    build_package(project.src_root, config)
                }
            } else {
                foundTarget := false
                for target in project.targets {
                    config := project->configure_target_proc(target)
                    if options.config_name == config.name {
                        foundTarget = true
                        build_package(project.src_root, config)
                        break
                    }
                }

                if !foundTarget {
                    fmt.printf("Could not find target %s\n", options.config_name)
                }
            }
        }

        case .Dev_Setup: {

        }
    }
    
}