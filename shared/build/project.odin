package jam_build 

import "core:thread"
import "core:fmt"
import "core:os"

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

display_command_help :: proc(project: Project($Target)) {
    fmt.printf("Possible usages:\n")
    fmt.printf("%s <configuration name|all> -> builds the specified configuration or all targets\n", os.args[0])
    fmt.printf("%s -devenv:<editor> <configuration name> -> generates project files configured for the given configuration. If no editor is specified, it will generate only ols.json\n", os.args[0]) 
    fmt.printf("Available Configurations:\n")
    for target in project.targets {
        config := project->configure_target_proc(target)
        fmt.printf("\t%s\n", config.name)
    }
}

build_project :: proc(project: Project($Target), options: Build_Options) {
    switch options.command_type {
        case .Invalid:
            
        case .Display_Help: {
           display_command_help(project)
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
                    fmt.printf("Could not find configuration %s\n", options.config_name)
                }
            }
        }

        case .Dev_Setup: {
            foundTarget := false
                for target in project.targets {
                    config := project->configure_target_proc(target)
                    if options.config_name == config.name {
                        foundTarget = true
                        generate_ols(config)
                        break
                    }
                }

                if !foundTarget {
                    fmt.printf("Could not find configuration %s\n", options.config_name)
                }
        }
    }
    
}