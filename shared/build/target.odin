package jam_build 

import "core:thread"
import "core:sync"

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

build_project :: proc(project: Project($Target)) {
    package_builder :: proc(t: ^thread.Thread) { // WIP threading
        project := cast(^Project(Target))t.user_args[0]
        target := cast(^Target)t.user_args[1]
        config := project->configure_target_proc(target^)
        build_package(project.src_root, config)
    }
    for target in project.targets {
        config := project->configure_target_proc(target)
        build_package(project.src_root, config)
    }
}